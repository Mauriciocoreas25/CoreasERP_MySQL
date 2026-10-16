using CoreasERP.Models.Dte;

namespace CoreasERP.Services.Dte;

public interface IFelSvApiService
{
    /// <summary>
    /// Emite un DTE transmitiéndolo al endpoint POST /api/Dtes/emit con el header X-Tenant-Id.
    /// Maneja respuestas 200 (éxito/sello), 400 (error de validación) y 503 (contingencia/Hacienda indisponible).
    /// </summary>
    Task<EmitDteResponseDto> EmitirDteAsync(EmitDteRequestDto request, string? tenantId = null);

    /// <summary>
    /// Obtiene el PDF generado oficialmente por FelSv para el DTE especificado.
    /// </summary>
    Task<byte[]?> ObtenerDtePdfAsync(string dteId, string? tenantId = null);

    /// <summary>
    /// Obtiene la representación de ticket de texto formateado para el DTE especificado.
    /// </summary>
    Task<string?> ObtenerDteTicketAsync(string dteId, string? tenantId = null);

    /// <summary>
    /// Inicia un evento de contingencia oficial (CAT-005) vía POST /api/Contingency/start.
    /// </summary>
    Task<(bool Success, string Message)> IniciarContingenciaAsync(string codigoMotivo, string descripcionMotivo, string? tenantId = null);

    /// <summary>
    /// Consulta si la sucursal actual se encuentra operando en contingencia diferida vía GET /api/Contingency/active.
    /// </summary>
    Task<ContingencyActiveDto> ConsultarContingenciaActivaAsync(string? tenantId = null);

    /// <summary>
    /// Detiene el evento de contingencia y activa la transmisión diferida en segundo plano vía POST /api/Contingency/stop.
    /// </summary>
    Task<(bool Success, string Message)> DetenerContingenciaAsync(string? tenantId = null);

    /// <summary>
    /// Invalida/anula un DTE previamente transmitido vía POST /api/Invalidation (CAT-024).
    /// </summary>
    Task<InvalidateDteResponseDto> InvalidarDteAsync(InvalidateDteRequestDto request, string? tenantId = null);

    /// <summary>
    /// Comprueba la conectividad con el servidor de la API de FelSv.
    /// </summary>
    Task<(bool Online, string Message)> ProbarConexionAsync(string? apiUrl = null, string? tenantId = null);
}
