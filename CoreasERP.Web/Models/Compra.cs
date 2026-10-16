namespace CoreasERP.Models;

public class Compra
{
    public int IdCompra { get; set; }
    public int IdProveedor { get; set; }
    public int IdUsuario { get; set; }
    public string NumFactura { get; set; } = string.Empty;
    public decimal Total { get; set; } = 0.00m;
    public DateTime FechaHora { get; set; } = DateTime.Now;
    public string Estado { get; set; } = "Completada"; // 'Completada', 'Anulada'
    public string? Observaciones { get; set; }

    public Proveedor? Proveedor { get; set; }
    public Usuario? Usuario { get; set; }
    public ICollection<DetalleCompra> DetalleCompras { get; set; } = new List<DetalleCompra>();
}
