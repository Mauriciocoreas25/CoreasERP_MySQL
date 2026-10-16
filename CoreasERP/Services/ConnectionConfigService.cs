using MySqlConnector;

namespace CoreasERP.Services;

public interface IConnectionConfigService
{
    string GetConnectionString();
    void SetConnectionString(string connectionString);
    Task<(bool Success, string Message)> TestConnectionAsync(string connectionString);
}

public class ConnectionConfigService : IConnectionConfigService
{
    private const string PrefKey = "MYSQL_CONNECTION_STRING";
    private const string DefaultConnection = "Server=127.0.0.1;Port=3306;Database=Coreas_ERP;User=root;Password=;AllowUserVariables=True;CharSet=utf8mb4;";

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
        return conn;
    }

    public void SetConnectionString(string connectionString)
    {
        var conn = connectionString.Trim();
        Preferences.Default.Set(PrefKey, conn);
    }

    public async Task<(bool Success, string Message)> TestConnectionAsync(string connectionString)
    {
        try
        {
            var builder = new MySqlConnectionStringBuilder(connectionString)
            {
                ConnectionTimeout = 5
            };

            // Primero probar conexión al servidor MySQL (sin exigir que la BD ya exista, o creándola si no existe)
            var dbName = builder.Database;
            builder.Database = "";

            await using var connection = new MySqlConnection(builder.ConnectionString);
            await connection.OpenAsync();

            if (!string.IsNullOrWhiteSpace(dbName))
            {
                await using var cmd = connection.CreateCommand();
                cmd.CommandText = $"CREATE DATABASE IF NOT EXISTS `{dbName.Replace("`", "")}` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;";
                await cmd.ExecuteNonQueryAsync();
            }

            return (true, "¡Conexión exitosa a MySQL / MariaDB!");
        }
        catch (Exception ex)
        {
            return (false, $"Error al conectar a MySQL: {ex.Message}");
        }
    }
}
