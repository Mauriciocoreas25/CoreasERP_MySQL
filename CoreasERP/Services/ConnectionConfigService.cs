using System.Net.Http.Json;
using MySqlConnector;
using CoreasERP.Models.Api;

namespace CoreasERP.Services;

public interface IConnectionConfigService
{
    string GetConnectionString();
    void SetConnectionString(string connectionString);
    Task<(bool Success, string Message)> TestConnectionAsync(string connectionString);

    bool IsApiModeEnabled();
    void SetApiModeEnabled(bool enabled);
    string GetApiBaseUrl();
    void SetApiBaseUrl(string apiUrl);
    Task<(bool Success, string Message)> TestApiConnectionAsync(string apiUrl);
}

public class ConnectionConfigService : IConnectionConfigService
{
    private const string PrefKey = "MYSQL_CONNECTION_STRING";
    private const string ApiModeKey = "USE_API_MODE";
    private const string ApiUrlKey = "API_BASE_URL";

    private static string DefaultConnection =>
        Environment.GetEnvironmentVariable("MYSQL_CONNECTION_STRING")
        ?? "Server=127.0.0.1;Port=3306;Database=Coreas_ERP;User=root;Password=;AllowUserVariables=True;CharSet=utf8mb4;";
    private const string DefaultApiUrl = "http://coreaserp.runasp.net";

    public string GetConnectionString()
    {
        var conn = Preferences.Default.Get(PrefKey, DefaultConnection);
        if (string.IsNullOrWhiteSpace(conn) ||
            conn.Contains("SQLEXPRESS", StringComparison.OrdinalIgnoreCase) ||
            conn.Contains("Trusted_Connection", StringComparison.OrdinalIgnoreCase) ||
            conn.Contains("MSSQLLocalDB", StringComparison.OrdinalIgnoreCase))
        {
            conn = DefaultConnection;
            Preferences.Default.Set(PrefKey, conn);
        }
        return NormalizeMySqlConnectionString(conn);
    }

    public void SetConnectionString(string connectionString)
    {
        var conn = NormalizeMySqlConnectionString(connectionString);
        Preferences.Default.Set(PrefKey, conn);
    }

    public bool IsApiModeEnabled()
    {
        return Preferences.Default.Get(ApiModeKey, true);
    }

    public void SetApiModeEnabled(bool enabled)
    {
        Preferences.Default.Set(ApiModeKey, enabled);
    }

    public string GetApiBaseUrl()
    {
        var url = Preferences.Default.Get(ApiUrlKey, DefaultApiUrl);
        if (string.IsNullOrWhiteSpace(url) || url.Contains("localhost:5100", StringComparison.OrdinalIgnoreCase))
        {
            url = DefaultApiUrl;
            Preferences.Default.Set(ApiUrlKey, url);
        }
        return url.Trim().TrimEnd('/');
    }

    public void SetApiBaseUrl(string apiUrl)
    {
        if (string.IsNullOrWhiteSpace(apiUrl)) apiUrl = DefaultApiUrl;
        Preferences.Default.Set(ApiUrlKey, apiUrl.Trim().TrimEnd('/'));
    }

    public async Task<(bool Success, string Message)> TestConnectionAsync(string connectionString)
    {
        try
        {
            string normalized = NormalizeMySqlConnectionString(connectionString);
            var builder = new MySqlConnectionStringBuilder(normalized)
            {
                ConnectionTimeout = 8
            };

            var dbName = builder.Database;

            // Intentar conectar directamente a la base de datos primero (útil en servicios cloud donde el usuario ya tiene una BD asignada)
            try
            {
                await using var directConn = new MySqlConnection(builder.ConnectionString);
                await directConn.OpenAsync();
                return (true, $"¡Conexión exitosa a MySQL ({builder.Server}:{builder.Port}/{builder.Database})!");
            }
            catch
            {
                // Si la base de datos aún no existe (ej. servidor local), conectar sin BD y crearla
                builder.Database = "";
                await using var serverConn = new MySqlConnection(builder.ConnectionString);
                await serverConn.OpenAsync();

                if (!string.IsNullOrWhiteSpace(dbName))
                {
                    await using var cmd = serverConn.CreateCommand();
                    cmd.CommandText = $"CREATE DATABASE IF NOT EXISTS `{dbName.Replace("`", "")}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;";
                    await cmd.ExecuteNonQueryAsync();
                }

                return (true, $"¡Conexión exitosa a MySQL y base de datos '{dbName}' verificada!");
            }
        }
        catch (Exception ex)
        {
            return (false, $"Error al conectar a MySQL: {ex.Message}");
        }
    }

    public async Task<(bool Success, string Message)> TestApiConnectionAsync(string apiUrl)
    {
        if (string.IsNullOrWhiteSpace(apiUrl))
            return (false, "Debe ingresar la URL de la API (ej. http://localhost:5100 o https://tu-api.onrender.com).");

        try
        {
            string baseUrl = apiUrl.Trim().TrimEnd('/');
            using var http = new HttpClient { Timeout = TimeSpan.FromSeconds(10) };
            var response = await http.GetAsync($"{baseUrl}/api/health");
            if (!response.IsSuccessStatusCode)
            {
                return (false, $"La API respondió con código HTTP {(int)response.StatusCode} ({response.ReasonPhrase}).");
            }

            var result = await response.Content.ReadFromJsonAsync<ApiResultDto>();
            if (result != null)
            {
                return (result.Success, result.Message);
            }

            return (true, "¡Conexión exitosa con CoreasERP API!");
        }
        catch (Exception ex)
        {
            return (false, $"No se pudo conectar con la API: {ex.Message}");
        }
    }

    public static string NormalizeMySqlConnectionString(string input)
    {
        if (string.IsNullOrWhiteSpace(input))
            return DefaultConnection;

        input = input.Trim();
        if (input.StartsWith("mysql://", StringComparison.OrdinalIgnoreCase) ||
            input.StartsWith("mysqls://", StringComparison.OrdinalIgnoreCase))
        {
            try
            {
                var uri = new Uri(input);
                var userInfo = uri.UserInfo.Split(':', 2);
                string user = Uri.UnescapeDataString(userInfo[0]);
                string pass = userInfo.Length > 1 ? Uri.UnescapeDataString(userInfo[1]) : "";
                string db = uri.AbsolutePath.TrimStart('/');
                if (string.IsNullOrWhiteSpace(db)) db = "Coreas_ERP";
                int port = uri.Port > 0 ? uri.Port : 3306;
                return $"Server={uri.Host};Port={port};Database={db};User={user};Password={pass};SslMode=Preferred;AllowUserVariables=True;CharSet=utf8mb4;";
            }
            catch
            {
                return input;
            }
        }

        return input;
    }
}
