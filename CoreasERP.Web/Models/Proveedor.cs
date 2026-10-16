namespace CoreasERP.Models;

public class Proveedor
{
    public int IdProveedor { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Contacto { get; set; }
    public string? Telefono { get; set; }
    public string? Email { get; set; }
    public string? Direccion { get; set; }
    public string? Nrc { get; set; }
    public string? Nit { get; set; }
    public bool Estado { get; set; } = true;
    public DateTime FechaCreacion { get; set; } = DateTime.Now;

    public ICollection<Compra> Compras { get; set; } = new List<Compra>();
}
