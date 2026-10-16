namespace CoreasERP.Models;

public class Usuario
{
    public int IdUsuario { get; set; }
    public int IdRol { get; set; }
    public string NombreUsuario { get; set; } = string.Empty; // 'Usuario' en BD
    public string Nombre { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string? Telefono { get; set; }
    public string Clave { get; set; } = string.Empty;
    public bool Estado { get; set; } = true;
    public DateTime FechaCreacion { get; set; } = DateTime.Now;

    public Rol? Rol { get; set; }
    public ICollection<Venta> Ventas { get; set; } = new List<Venta>();
    public ICollection<CorteCaja> CortesCaja { get; set; } = new List<CorteCaja>();
}
