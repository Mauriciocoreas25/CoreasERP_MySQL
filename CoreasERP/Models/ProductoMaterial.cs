namespace CoreasERP.Models;

public class ProductoMaterial
{
    public int IdProductoMaterial { get; set; }
    public int IdProductoPadre { get; set; }
    public int IdProductoInsumo { get; set; }
    public decimal Cantidad { get; set; } = 1.00m;
    public DateTime FechaCreacion { get; set; } = DateTime.Now;

    public Producto? ProductoPadre { get; set; }
    public Producto? ProductoInsumo { get; set; }
}
