namespace CoreasERP.Models;

public class ClienteCuenta
{
    public int IdClienteCuenta { get; set; }
    public int IdCliente { get; set; }
    public string Email { get; set; } = string.Empty;
    public string Clave { get; set; } = string.Empty;
    public string? TokenRecuperacion { get; set; }
    public bool Estado { get; set; } = true;
    public DateTime FechaRegistro { get; set; } = DateTime.Now;

    public Cliente? Cliente { get; set; }
}
