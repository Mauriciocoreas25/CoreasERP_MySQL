using Microsoft.Data.SqlClient;

namespace CoreasERP.Services;

public interface IConnectionConfigService
{
    string GetConnectionString();
    void SetConnectionString(string connectionString);
    Task<(bool Success, string Message)> TestConnectionAsync(string connectionString);
}

public class ConnectionConfigService : IConnectionConfigService
{
    private const string PrefKey = "SQL_CONNECTION_STRING";
    private const string DefaultConnection = @"Server=.\SQLEXPRESS;Database=Coreas_ERP;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true;";

    public string GetConnectionString()
    {
        var conn = Preferences.Default.Get(PrefKey, DefaultConnection);
        if (conn.Contains("Database=CoreasERP;", StringComparison.OrdinalIgnoreCase))
        {
            conn = conn.Replace("Database=CoreasERP;", "Database=Coreas_ERP;", StringComparison.OrdinalIgnoreCase);
            Preferences.Default.Set(PrefKey, conn);
        }
        else if (conn.Contains("Initial Catalog=CoreasERP;", StringComparison.OrdinalIgnoreCase))
        {
            conn = conn.Replace("Initial Catalog=CoreasERP;", "Initial Catalog=Coreas_ERP;", StringComparison.OrdinalIgnoreCase);
            Preferences.Default.Set(PrefKey, conn);
        }
        return conn;
    }

    public void SetConnectionString(string connectionString)
    {
        var conn = connectionString.Trim();
        if (conn.Contains("Database=CoreasERP;", StringComparison.OrdinalIgnoreCase))
        {
            conn = conn.Replace("Database=CoreasERP;", "Database=Coreas_ERP;", StringComparison.OrdinalIgnoreCase);
        }
        else if (conn.Contains("Initial Catalog=CoreasERP;", StringComparison.OrdinalIgnoreCase))
        {
            conn = conn.Replace("Initial Catalog=CoreasERP;", "Initial Catalog=Coreas_ERP;", StringComparison.OrdinalIgnoreCase);
        }
        Preferences.Default.Set(PrefKey, conn);
    }

    public async Task<(bool Success, string Message)> TestConnectionAsync(string connectionString)
    {
        try
        {
            var builder = new SqlConnectionStringBuilder(connectionString)
            {
                ConnectTimeout = 5
            };

            await using var connection = new SqlConnection(builder.ConnectionString);
            await connection.OpenAsync();
            return (true, "¡Conexión exitosa a SQL Server!");
        }
        catch (Exception ex)
        {
            return (false, $"Error al conectar: {ex.Message}");
        }
    }
}
