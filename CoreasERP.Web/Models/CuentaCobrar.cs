namespace CoreasERP.Models;

public class CuentaCobrar
{
    public int IdCuentaCobrar { get; set; }
    public int IdVenta { get; set; }
    public int IdCliente { get; set; }
    public decimal MontoTotal { get; set; }
    public decimal SaldoPendiente { get; set; }
    public DateTime FechaEmision { get; set; } = DateTime.Now;
    public DateTime? FechaVencimiento { get; set; }
    public string Estado { get; set; } = "Pendiente"; // 'Pendiente', 'Pagada'

    public Venta? Venta { get; set; }
    public Cliente? Cliente { get; set; }
    public ICollection<Abono> Abonos { get; set; } = new List<Abono>();
}
