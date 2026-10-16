namespace CoreasERP.Models;

public class OrdenWeb
{
    public int IdOrden { get; set; }
    public int IdCliente { get; set; }
    public DateTime FechaOrden { get; set; } = DateTime.Now;
    public decimal Total { get; set; } = 0.00m;
    public string EstadoPago { get; set; } = "Pendiente"; // 'Pendiente', 'Pagado', 'Rechazado'
    public string EstadoEnvio { get; set; } = "Procesando"; // 'Procesando', 'En Camino', 'Entregado', 'Cancelado'
    public int? IdVenta { get; set; }

    public Cliente? Cliente { get; set; }
    public Venta? Venta { get; set; }
    public ICollection<DetalleOrdenWeb> DetalleOrdenesWeb { get; set; } = new List<DetalleOrdenWeb>();
}
