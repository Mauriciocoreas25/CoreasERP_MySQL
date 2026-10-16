namespace CoreasERP.Models;

public class DetalleOrdenWeb
{
    public int IdDetalleOrden { get; set; }
    public int IdOrden { get; set; }
    public int IdProducto { get; set; }
    public decimal Cantidad { get; set; }
    public decimal Precio { get; set; }
    public decimal Subtotal { get; set; }

    public OrdenWeb? OrdenWeb { get; set; }
    public Producto? Producto { get; set; }
}
