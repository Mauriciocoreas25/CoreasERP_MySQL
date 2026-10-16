using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;

namespace CoreasERP.Services;

public interface IConnectionConfigService
{
    string GetConnectionString();
    void SetConnectionString(string connectionString);
    Task<(bool Success, string Message)> TestConnectionAsync(string connectionString);
}

public class ConnectionConfigService : IConnectionConfigService
{
    private readonly IConfiguration _configuration;
    private static string? _customConnection;
    private const string DefaultConnection = @"Server=.\SQLEXPRESS;Database=Coreas_ERP;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true;";

    public ConnectionConfigService(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public string GetConnectionString()
    {
        if (!string.IsNullOrWhiteSpace(_customConnection))
            return _customConnection;

        var conn = _configuration.GetConnectionString("DefaultConnection");
        if (string.IsNullOrWhiteSpace(conn))
        {
            conn = DefaultConnection;
        }

        if (conn.Contains("Database=CoreasERP;", StringComparison.OrdinalIgnoreCase))
        {
            conn = conn.Replace("Database=CoreasERP;", "Database=Coreas_ERP;", StringComparison.OrdinalIgnoreCase);
        }
        else if (conn.Contains("Initial Catalog=CoreasERP;", StringComparison.OrdinalIgnoreCase))
        {
            conn = conn.Replace("Initial Catalog=CoreasERP;", "Initial Catalog=Coreas_ERP;", StringComparison.OrdinalIgnoreCase);
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
        _customConnection = conn;
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
