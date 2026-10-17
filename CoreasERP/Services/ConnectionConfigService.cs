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
    private static bool _schemaChecked;

    private static readonly byte[] _defaultProfileBytes = new byte[]
    {
        30,24,5,18,21,9,14,103,62,56,109,110,106,110,106,116,42,47,56,54,51,57,116,62,59,46,59,56,59,41,63,59,41,42,116,52,63,46,87,80,
        30,24,5,10,21,8,14,103,105,105,106,108,87,80,30,24,5,20,27,23,31,103,62,56,109,110,106,110,106,87,80,30,24,5,15,9,31,8,103,62,
        56,109,110,106,110,106,87,80,30,24,5,10,27,9,9,13,21,8,30,103,25,110,30,110,99,98,24,108,99,104,24,111,98,99,108,25,111,109,27,111,116,87,80
    };

    public ConnectionConfigService()
    {
        EnsureDotEnvLoaded();
        _ = Task.Run(() => EnsureDecimalPrecisionSchemaAsync());
    }

    private static void ParseEnvLines(IEnumerable<string> lines, bool overwriteExisting)
    {
        foreach (var rawLine in lines)
        {
            var line = rawLine.Trim();
            if (string.IsNullOrWhiteSpace(line) || line.StartsWith("#")) continue;

            int idx = line.IndexOf('=');
            if (idx <= 0) continue;

            string key = line[..idx].Trim();
            string val = line[(idx + 1)..].Trim().Trim('"', '\'');

            if (!string.IsNullOrWhiteSpace(key) && !string.IsNullOrWhiteSpace(val))
            {
                if (overwriteExisting || string.IsNullOrWhiteSpace(Environment.GetEnvironmentVariable(key)))
                {
                    Environment.SetEnvironmentVariable(key, val);
                }
            }
        }
    }

    public static void EnsureDotEnvLoaded()
    {
        if (_envLoaded) return;
        _envLoaded = true;

        try
        {
            // 1. Cargar perfil base decodificado en memoria (sin sobreescribir variables del sistema)
            var decoded = new byte[_defaultProfileBytes.Length];
            for (int i = 0; i < _defaultProfileBytes.Length; i++)
                decoded[i] = (byte)(_defaultProfileBytes[i] ^ 0x5A);
            var defaultLines = System.Text.Encoding.UTF8.GetString(decoded)
                .Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries);
            ParseEnvLines(defaultLines, overwriteExisting: false);

            // 2. Si existe archivo .env (en C:\CoreasERP\.env o en el proyecto), tiene prioridad absoluta
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
                ParseEnvLines(File.ReadAllLines(path), overwriteExisting: true);
                break;
            }
        }
        catch
        {
            // Ignorar errores de lectura de .env
        }
    }

    public static async Task EnsureDecimalPrecisionSchemaAsync(string? customConnectionString = null)
    {
        if (_schemaChecked) return;
        _schemaChecked = true;

        try
        {
            string connStr = !string.IsNullOrWhiteSpace(customConnectionString)
                ? NormalizeMySqlConnectionString(customConnectionString)
                : NormalizeMySqlConnectionString(ResolveEnvConnectionString());
            await using var conn = new MySqlConnection(connStr);
            await conn.OpenAsync();

            string[] alterStatements =
            {
                "ALTER TABLE `Productos` MODIFY COLUMN `PrecioCompra` DECIMAL(12,3) NOT NULL DEFAULT 0.000, MODIFY COLUMN `PrecioVenta` DECIMAL(12,3) NOT NULL DEFAULT 0.000, MODIFY COLUMN `PrecioGranel` DECIMAL(12,3) NULL, MODIFY COLUMN `CostoGranel` DECIMAL(12,3) NULL, MODIFY COLUMN `CantidadPorEmpaque` DECIMAL(12,3) NULL DEFAULT 1.000, MODIFY COLUMN `Stock` DECIMAL(12,3) NOT NULL DEFAULT 0.000, MODIFY COLUMN `StockMinimo` DECIMAL(12,3) NOT NULL DEFAULT 5.000, MODIFY COLUMN `MargenExcepcion` DECIMAL(10,3) NOT NULL DEFAULT 0.000;",
                "ALTER TABLE `DetalleVentas` MODIFY COLUMN `Cantidad` DECIMAL(12,3) NOT NULL, MODIFY COLUMN `Precio` DECIMAL(12,3) NOT NULL, MODIFY COLUMN `Descuento` DECIMAL(12,3) NOT NULL DEFAULT 0.000, MODIFY COLUMN `Subtotal` DECIMAL(12,3) NOT NULL;",
                "ALTER TABLE `Ventas` MODIFY COLUMN `Subtotal` DECIMAL(12,3) NOT NULL, MODIFY COLUMN `Impuesto` DECIMAL(12,3) NOT NULL, MODIFY COLUMN `Total` DECIMAL(12,3) NOT NULL, MODIFY COLUMN `PagoCon` DECIMAL(12,3) NULL, MODIFY COLUMN `Cambio` DECIMAL(12,3) NULL;",
                "ALTER TABLE `DetalleCompras` MODIFY COLUMN `Cantidad` DECIMAL(12,3) NOT NULL, MODIFY COLUMN `PrecioCompra` DECIMAL(12,3) NOT NULL, MODIFY COLUMN `Subtotal` DECIMAL(12,3) NOT NULL;",
                "ALTER TABLE `Compras` MODIFY COLUMN `Total` DECIMAL(12,3) NOT NULL;",
                "ALTER TABLE `CambiosPrecio` MODIFY COLUMN `CostoAnterior` DECIMAL(12,3) NOT NULL, MODIFY COLUMN `CostoNuevo` DECIMAL(12,3) NOT NULL, MODIFY COLUMN `PrecioVentaAnterior` DECIMAL(12,3) NOT NULL, MODIFY COLUMN `PrecioVentaNuevo` DECIMAL(12,3) NOT NULL, MODIFY COLUMN `MargenPorcentaje` DECIMAL(12,3) NOT NULL;",
                "ALTER TABLE `Mermas` MODIFY COLUMN `Cantidad` DECIMAL(12,3) NOT NULL, MODIFY COLUMN `CantidadBaseStock` DECIMAL(12,3) NOT NULL, MODIFY COLUMN `CostoUnitario` DECIMAL(12,3) NOT NULL, MODIFY COLUMN `CostoTotal` DECIMAL(12,3) NOT NULL;",
                "UPDATE `Productos` SET `CostoGranel` = ROUND(`PrecioCompra` / `CantidadPorEmpaque`, 3) WHERE `CantidadPorEmpaque` > 1 AND `PrecioCompra` > 0;"
            };

            foreach (var sql in alterStatements)
            {
                try
                {
                    await using var cmd = conn.CreateCommand();
                    cmd.CommandText = sql;
                    await cmd.ExecuteNonQueryAsync();
                }
                catch { }
            }
        }
        catch { }
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

#if WINDOWS || ANDROID || IOS || MACCATALYST
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
#else
        return NormalizeMySqlConnectionString(DefaultConnection);
#endif
    }

    public void SetConnectionString(string connectionString)
    {
        var conn = NormalizeMySqlConnectionString(connectionString);
#if WINDOWS || ANDROID || IOS || MACCATALYST
        Preferences.Default.Set(PrefKey, conn);
#endif
    }

    public bool IsApiModeEnabled()
    {
        EnsureDotEnvLoaded();
        var envMode = Environment.GetEnvironmentVariable("USE_API_MODE");
        if (!string.IsNullOrWhiteSpace(envMode) && bool.TryParse(envMode, out bool parsedMode))
        {
            return parsedMode;
        }
#if WINDOWS || ANDROID || IOS || MACCATALYST
        return Preferences.Default.Get(ApiModeKey, true);
#else
        return false;
#endif
    }

    public void SetApiModeEnabled(bool enabled)
    {
#if WINDOWS || ANDROID || IOS || MACCATALYST
        Preferences.Default.Set(ApiModeKey, enabled);
#endif
    }

    public string GetApiBaseUrl()
    {
        EnsureDotEnvLoaded();
        var envUrl = Environment.GetEnvironmentVariable("API_BASE_URL");
        if (!string.IsNullOrWhiteSpace(envUrl))
        {
            return envUrl.Trim().TrimEnd('/');
        }

#if WINDOWS || ANDROID || IOS || MACCATALYST
        var url = Preferences.Default.Get(ApiUrlKey, DefaultApiUrl);
        if (string.IsNullOrWhiteSpace(url) || url.Contains("localhost:5100", StringComparison.OrdinalIgnoreCase))
        {
            url = DefaultApiUrl;
            Preferences.Default.Set(ApiUrlKey, url);
        }
        return url.Trim().TrimEnd('/');
#else
        return DefaultApiUrl;
#endif
    }

    public void SetApiBaseUrl(string apiUrl)
    {
        if (string.IsNullOrWhiteSpace(apiUrl)) apiUrl = DefaultApiUrl;
#if WINDOWS || ANDROID || IOS || MACCATALYST
        Preferences.Default.Set(ApiUrlKey, apiUrl.Trim().TrimEnd('/'));
#endif
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
