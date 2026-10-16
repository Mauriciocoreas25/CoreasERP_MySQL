using System.Net;
using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Models.Dte;

namespace CoreasERP.Services.Dte;

public class FelSvApiService : IFelSvApiService
{
    private readonly HttpClient _httpClient;
    private readonly IDbContextFactory<AppDbContext> _contextFactory;

    public FelSvApiService(HttpClient httpClient, IDbContextFactory<AppDbContext> contextFactory)
    {
        _httpClient = httpClient;
        _contextFactory = contextFactory;
        try
        {
            _httpClient.Timeout = TimeSpan.FromSeconds(15);
        }
        catch { }
    }

    private async Task<(string BaseUrl, string TenantId)> ObtenerConfiguracionAsync(string? tenantOverride = null)
    {
        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            var config = await context.ConfiguracionNegocio.FirstOrDefaultAsync();
            string url = !string.IsNullOrWhiteSpace(config?.FelSvApiUrl) 
                ? config.FelSvApiUrl.Trim().TrimEnd('/') 
                : "http://localhost:5000";
            
            string rawTenant = tenantOverride ?? config?.FelSvTenantId ?? "SUCURSAL-01";
            string tenant = rawTenant.Trim('\'', '"', ' ');
            if (string.IsNullOrWhiteSpace(tenant)) tenant = "SUCURSAL-01";
            
            return (url, tenant);
        }
        catch
        {
            return ("http://localhost:5000", (tenantOverride ?? "SUCURSAL-01").Trim('\'', '"', ' '));
        }
    }

    public async Task<EmitDteResponseDto> EmitirDteAsync(EmitDteRequestDto request, string? tenantId = null)
    {
        var (baseUrl, tenant) = await ObtenerConfiguracionAsync(tenantId);
        string endpoint = $"{baseUrl}/api/Dtes/emit";

        try
        {
            using var httpRequest = new HttpRequestMessage(HttpMethod.Post, endpoint);
            httpRequest.Headers.Add("X-Tenant-Id", tenant);
            httpRequest.Headers.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

            string jsonBody = JsonSerializer.Serialize(request);
            httpRequest.Content = new StringContent(jsonBody, Encoding.UTF8, "application/json");

            using var response = await _httpClient.SendAsync(httpRequest);
            string responseContent = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode)
            {
                var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
                try
                {
                    using var doc = JsonDocument.Parse(responseContent);
                    var root = doc.RootElement;

                    string? dteId = GetStringOrNull(root, "id") ?? GetStringOrNull(root, "dteId");
                    string? codGen = GetStringOrNull(root, "codigoGeneracion");
                    string? numCtrl = GetStringOrNull(root, "numeroControl");
                    string? sello = GetStringOrNull(root, "selloRecepcion") ?? GetStringOrNull(root, "sello");
                    string? estado = GetStringOrNull(root, "estado") ?? "Transmitido";
                    string? fechaProc = GetStringOrNull(root, "fechaHoraProcesamiento") ?? GetStringOrNull(root, "fecEmi");
                    string? mensaje = GetStringOrNull(root, "mensajeRespuesta")
                        ?? GetStringOrNull(root, "mensaje")
                        ?? GetStringOrNull(root, "message")
                        ?? (string.Equals(estado, "Rechazado", StringComparison.OrdinalIgnoreCase) ? "DTE rechazado por Hacienda" : "DTE procesado exitosamente.");

                    bool isSuccess = !string.Equals(estado, "Rechazado", StringComparison.OrdinalIgnoreCase);

                    return new EmitDteResponseDto
                    {
                        Success = isSuccess,
                        DteId = dteId,
                        CodigoGeneracion = codGen ?? request.NumeroControl,
                        NumeroControl = numCtrl ?? request.NumeroControl,
                        SelloRecepcion = sello,
                        Estado = estado,
                        FechaHoraProcesamiento = fechaProc,
                        MensajeHacienda = mensaje,
                        RawResponse = responseContent
                    };
                }
                catch
                {
                    return new EmitDteResponseDto
                    {
                        Success = true,
                        Estado = "Transmitido",
                        RawResponse = responseContent
                    };
                }
            }
            else if (response.StatusCode == HttpStatusCode.ServiceUnavailable)
            {
                // Código 503: Servidores de Hacienda indisponibles (Contingencia requerida)
                return new EmitDteResponseDto
                {
                    Success = false,
                    Estado = "Contingencia_Pendiente",
                    ErrorCode = "HACIENDA_UNAVAILABLE",
                    MensajeHacienda = "Los servidores del Ministerio de Hacienda no están disponibles temporalmente.",
                    RawResponse = responseContent
                };
            }
            else
            {
                // Código 400 u otro error de validación
                string errorMsg = responseContent;
                try
                {
                    using var doc = JsonDocument.Parse(responseContent);
                    if (doc.RootElement.TryGetProperty("message", out var m)) errorMsg = m.GetString() ?? errorMsg;
                    else if (doc.RootElement.TryGetProperty("error", out var e)) errorMsg = e.GetString() ?? errorMsg;
                }
                catch { }

                return new EmitDteResponseDto
                {
                    Success = false,
                    Estado = "Rechazado",
                    ErrorCode = $"HTTP_{((int)response.StatusCode)}",
                    MensajeHacienda = errorMsg,
                    RawResponse = responseContent
                };
            }
        }
        catch (HttpRequestException ex)
        {
            // API local apagada o error de red: responder con contingencia pendiente local
            return new EmitDteResponseDto
            {
                Success = false,
                Estado = "Contingencia_Pendiente",
                ErrorCode = "API_OFFLINE",
                MensajeHacienda = $"No fue posible conectar con el servidor FelSv ({baseUrl}): {ex.Message}. El documento se guarda en Contingencia local.",
                RawResponse = ex.ToString()
            };
        }
        catch (Exception ex)
        {
            return new EmitDteResponseDto
            {
                Success = false,
                Estado = "Error_Interno",
                ErrorCode = "EXCEPTION",
                MensajeHacienda = ex.Message,
                RawResponse = ex.ToString()
            };
        }
    }

    public async Task<byte[]?> ObtenerDtePdfAsync(string dteId, string? tenantId = null)
    {
        var (baseUrl, tenant) = await ObtenerConfiguracionAsync(tenantId);
        string endpoint = $"{baseUrl}/api/Dtes/{dteId}/pdf";

        try
        {
            using var request = new HttpRequestMessage(HttpMethod.Get, endpoint);
            request.Headers.Add("X-Tenant-Id", tenant);
            using var response = await _httpClient.SendAsync(request);
            if (response.IsSuccessStatusCode)
            {
                return await response.Content.ReadAsByteArrayAsync();
            }
        }
        catch { }
        return null;
    }

    public async Task<string?> ObtenerDteTicketAsync(string dteId, string? tenantId = null)
    {
        var (baseUrl, tenant) = await ObtenerConfiguracionAsync(tenantId);
        string endpoint = $"{baseUrl}/api/Dtes/{dteId}/ticket";

        try
        {
            using var request = new HttpRequestMessage(HttpMethod.Get, endpoint);
            request.Headers.Add("X-Tenant-Id", tenant);
            using var response = await _httpClient.SendAsync(request);
            if (response.IsSuccessStatusCode)
            {
                return await response.Content.ReadAsStringAsync();
            }
        }
        catch { }
        return null;
    }

    public async Task<(bool Success, string Message)> IniciarContingenciaAsync(string codigoMotivo, string descripcionMotivo, string? tenantId = null)
    {
        var (baseUrl, tenant) = await ObtenerConfiguracionAsync(tenantId);
        string endpoint = $"{baseUrl}/api/Contingency/start";

        try
        {
            using var request = new HttpRequestMessage(HttpMethod.Post, endpoint);
            request.Headers.Add("X-Tenant-Id", tenant);
            var payload = new ContingencyStartDto
            {
                CodigoMotivo = codigoMotivo,
                DescripcionMotivo = descripcionMotivo
            };
            request.Content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");

            using var response = await _httpClient.SendAsync(request);
            string content = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode)
            {
                return (true, "Contingencia iniciada exitosamente en FelSv.");
            }
            return (false, $"Error al iniciar contingencia: {content}");
        }
        catch (Exception ex)
        {
            return (false, $"Error de conexión con FelSv: {ex.Message}");
        }
    }

    public async Task<ContingencyActiveDto> ConsultarContingenciaActivaAsync(string? tenantId = null)
    {
        var (baseUrl, tenant) = await ObtenerConfiguracionAsync(tenantId);
        string endpoint = $"{baseUrl}/api/Contingency/active";

        try
        {
            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(4));
            using var request = new HttpRequestMessage(HttpMethod.Get, endpoint);
            request.Headers.Add("X-Tenant-Id", tenant);
            using var response = await _httpClient.SendAsync(request, cts.Token);

            if (response.IsSuccessStatusCode)
            {
                string content = await response.Content.ReadAsStringAsync(cts.Token);
                var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
                return JsonSerializer.Deserialize<ContingencyActiveDto>(content, options) ?? new ContingencyActiveDto { Active = false };
            }
        }
        catch { }

        return new ContingencyActiveDto { Active = false };
    }

    public async Task<(bool Success, string Message)> DetenerContingenciaAsync(string? tenantId = null)
    {
        var (baseUrl, tenant) = await ObtenerConfiguracionAsync(tenantId);
        string endpoint = $"{baseUrl}/api/Contingency/stop";

        try
        {
            using var request = new HttpRequestMessage(HttpMethod.Post, endpoint);
            request.Headers.Add("X-Tenant-Id", tenant);
            request.Content = new StringContent("{}", Encoding.UTF8, "application/json");

            using var response = await _httpClient.SendAsync(request);
            string content = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode)
            {
                return (true, "Contingencia detenida exitosamente. Procesamiento en lote activado.");
            }
            return (false, $"Error al detener contingencia: {content}");
        }
        catch (Exception ex)
        {
            return (false, $"Error de conexión con FelSv: {ex.Message}");
        }
    }

    public async Task<InvalidateDteResponseDto> InvalidarDteAsync(InvalidateDteRequestDto request, string? tenantId = null)
    {
        var (baseUrl, tenant) = await ObtenerConfiguracionAsync(tenantId);
        string endpoint = $"{baseUrl}/api/Invalidation";

        try
        {
            using var httpRequest = new HttpRequestMessage(HttpMethod.Post, endpoint);
            httpRequest.Headers.Add("X-Tenant-Id", tenant);
            httpRequest.Content = new StringContent(JsonSerializer.Serialize(request), Encoding.UTF8, "application/json");

            using var response = await _httpClient.SendAsync(httpRequest);
            string content = await response.Content.ReadAsStringAsync();

            if (response.IsSuccessStatusCode)
            {
                try
                {
                    using var doc = JsonDocument.Parse(content);
                    string? sello = GetStringOrNull(doc.RootElement, "selloInvalidacion") ?? GetStringOrNull(doc.RootElement, "sello");
                    return new InvalidateDteResponseDto
                    {
                        Success = true,
                        SelloInvalidacion = sello,
                        Estado = "Invalidado",
                        Mensaje = "Documento invalidado exitosamente ante el Ministerio de Hacienda."
                    };
                }
                catch
                {
                    return new InvalidateDteResponseDto { Success = true, Estado = "Invalidado", Mensaje = "DTE invalidado." };
                }
            }
            return new InvalidateDteResponseDto
            {
                Success = false,
                Estado = "Rechazado",
                Mensaje = $"Error al invalidar DTE: {content}"
            };
        }
        catch (Exception ex)
        {
            return new InvalidateDteResponseDto
            {
                Success = false,
                Estado = "Error",
                Mensaje = $"Excepción al comunicarse con la API de invalidación: {ex.Message}"
            };
        }
    }

    public async Task<(bool Online, string Message)> ProbarConexionAsync(string? apiUrl = null, string? tenantId = null)
    {
        var (baseUrl, tenant) = await ObtenerConfiguracionAsync(tenantId);
        string url = !string.IsNullOrWhiteSpace(apiUrl) ? apiUrl.Trim().TrimEnd('/') : baseUrl;

        try
        {
            using var cts = new CancellationTokenSource(TimeSpan.FromSeconds(5));
            using var request = new HttpRequestMessage(HttpMethod.Get, $"{url}/api/Contingency/active");
            request.Headers.Add("X-Tenant-Id", tenant);
            using var response = await _httpClient.SendAsync(request, cts.Token);
            if (response.IsSuccessStatusCode || response.StatusCode == HttpStatusCode.NotFound)
            {
                return (true, $"Servidor FelSv alcanzable y operativo en {url} (HTTP {(int)response.StatusCode})");
            }
            return (false, $"Servidor respondió con código de error HTTP: {(int)response.StatusCode} {response.StatusCode}");
        }
        catch (OperationCanceledException)
        {
            return (false, $"Tiempo de espera agotado (5s) al intentar conectar con {url}. Verifique que el servicio FelSv esté iniciado.");
        }
        catch (Exception ex)
        {
            return (false, $"No se pudo conectar a {url}: {ex.Message}");
        }
    }

    private static string? GetStringOrNull(JsonElement el, string prop)
    {
        if (el.TryGetProperty(prop, out var p))
        {
            return p.GetString();
        }
        return null;
    }
}
