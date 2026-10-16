namespace CoreasERP.Models;

public class DetalleCompra
{
    public int IdDetalleCompra { get; set; }
    public int IdCompra { get; set; }
    public int IdProducto { get; set; }
    public decimal Cantidad { get; set; }
    public decimal PrecioCompra { get; set; }
    public decimal Subtotal { get; set; }

    public Compra? Compra { get; set; }
    public Producto? Producto { get; set; }
}
