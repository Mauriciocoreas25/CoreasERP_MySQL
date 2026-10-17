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
    private static bool _envLoaded;

    public ConnectionConfigService()
    {
        EnsureDotEnvLoaded();
    }

    public static void EnsureDotEnvLoaded()
    {
        if (_envLoaded) return;
        _envLoaded = true;

        try
        {
            var candidatePaths = new List<string>
            {
                @"C:\CoreasERP\.env",
                Path.Combine(AppContext.BaseDirectory, ".env"),
                Path.Combine(Directory.GetCurrentDirectory(), ".env")
            };

            var dir = new DirectoryInfo(AppContext.BaseDirectory);
            for (int i = 0; i < 6 && dir != null; i++)
            {
                candidatePaths.Add(Path.Combine(dir.FullName, ".env"));
                dir = dir.Parent;
            }

            foreach (var path in candidatePaths.Distinct(StringComparer.OrdinalIgnoreCase))
            {
                if (!File.Exists(path)) continue;

                foreach (var rawLine in File.ReadAllLines(path))
                {
                    var line = rawLine.Trim();
                    if (string.IsNullOrWhiteSpace(line) || line.StartsWith("#")) continue;

                    int idx = line.IndexOf('=');
                    if (idx <= 0) continue;

                    string key = line[..idx].Trim();
                    string val = line[(idx + 1)..].Trim().Trim('"', '\'');

                    if (!string.IsNullOrWhiteSpace(key) && !string.IsNullOrWhiteSpace(val))
                    {
                        Environment.SetEnvironmentVariable(key, val);
                    }
                }
                break;
            }
        }
        catch
        {
            // Ignorar errores de lectura de .env
        }
    }

    public static string ResolveEnvConnectionString()
    {
        EnsureDotEnvLoaded();

        var directConn = Environment.GetEnvironmentVariable("MYSQL_CONNECTION_STRING")
            ?? Environment.GetEnvironmentVariable("DATABASE_URL");
        if (!string.IsNullOrWhiteSpace(directConn))
            return directConn;

        var host = Environment.GetEnvironmentVariable("DB_HOST");
        if (!string.IsNullOrWhiteSpace(host))
        {
            var port = Environment.GetEnvironmentVariable("DB_PORT") ?? "3306";
            var db = Environment.GetEnvironmentVariable("DB_NAME") ?? "Coreas_ERP";
            var user = Environment.GetEnvironmentVariable("DB_USER") ?? "root";
            var pass = Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "";
            return $"Server={host};Port={port};Database={db};User={user};Password={pass};SslMode=Preferred;AllowUserVariables=True;CharSet=utf8mb4;";
        }

        return "Server=127.0.0.1;Port=3306;Database=Coreas_ERP;User=root;Password=;AllowUserVariables=True;CharSet=utf8mb4;";
    }

    private static string DefaultConnection => ResolveEnvConnectionString();

    private static string DefaultApiUrl
    {
        get
        {
            EnsureDotEnvLoaded();
            var envUrl = Environment.GetEnvironmentVariable("API_BASE_URL");
            return !string.IsNullOrWhiteSpace(envUrl) ? envUrl.Trim().TrimEnd('/') : "http://coreaserp.runasp.net";
        }
    }

    public string GetConnectionString()
    {
        EnsureDotEnvLoaded();
        var envHost = Environment.GetEnvironmentVariable("DB_HOST");
        var envDirect = Environment.GetEnvironmentVariable("MYSQL_CONNECTION_STRING");
        if (!string.IsNullOrWhiteSpace(envHost) || !string.IsNullOrWhiteSpace(envDirect))
        {
            return NormalizeMySqlConnectionString(DefaultConnection);
        }

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
        EnsureDotEnvLoaded();
        var envMode = Environment.GetEnvironmentVariable("USE_API_MODE");
        if (!string.IsNullOrWhiteSpace(envMode) && bool.TryParse(envMode, out bool parsedMode))
        {
            return parsedMode;
        }
        return Preferences.Default.Get(ApiModeKey, true);
    }

    public void SetApiModeEnabled(bool enabled)
    {
        Preferences.Default.Set(ApiModeKey, enabled);
    }

    public string GetApiBaseUrl()
    {
        EnsureDotEnvLoaded();
        var envUrl = Environment.GetEnvironmentVariable("API_BASE_URL");
        if (!string.IsNullOrWhiteSpace(envUrl))
        {
            return envUrl.Trim().TrimEnd('/');
        }

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
