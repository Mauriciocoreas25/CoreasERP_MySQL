namespace CoreasERP.Models;

public class DetalleVenta
{
    public int IdDetalle { get; set; }
    public int IdVenta { get; set; }
    public int IdProducto { get; set; }
    public decimal Cantidad { get; set; }
    public decimal Precio { get; set; }
    public decimal Descuento { get; set; } = 0.00m;
    public decimal Subtotal { get; set; }

    public Venta? Venta { get; set; }
    public Producto? Producto { get; set; }
}
