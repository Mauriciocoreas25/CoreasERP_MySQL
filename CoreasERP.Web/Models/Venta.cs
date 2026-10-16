namespace CoreasERP.Models;

public class Venta
{
    public int IdVenta { get; set; }
    public int IdCliente { get; set; }
    public int IdUsuario { get; set; }
    public string TipoComprobante { get; set; } = "Ticket"; // 'Ticket', 'Factura', 'Credito Fiscal'
    public string NumComprobante { get; set; } = string.Empty;
    public string MetodoPago { get; set; } = "Efectivo"; // 'Efectivo', 'Tarjeta', 'Transferencia'
    public decimal Subtotal { get; set; } = 0.00m;
    public decimal Impuesto { get; set; } = 0.00m; // 13% IVA
    public decimal Total { get; set; } = 0.00m;
    public decimal? PagoCon { get; set; }
    public decimal? Cambio { get; set; }
    public string Estado { get; set; } = "Completada"; // 'Completada' o 'Anulada'
    public DateTime FechaHora { get; set; } = DateTime.Now;

    // Campos de Facturación Electrónica (DTE)
    public string? CodigoGeneracion { get; set; } // UUID v4 único
    public string? NumeroControl { get; set; } // DTE-XX-M001P001-XXXXXXXXXXXXXXX
    public string? SelloRecepcion { get; set; } // Sello devuelto por Ministerio de Hacienda
    public string? EstadoDte { get; set; } = "No_Aplica"; // 'Transmitido', 'Contingencia_Pendiente', 'Rechazado', 'Invalidado', 'No_Aplica'
    public string? DteId { get; set; } // ID retornado por FelSv API
    public string? RespuestaHacienda { get; set; }

    public Cliente? Cliente { get; set; }
    public Usuario? Usuario { get; set; }
    public ICollection<DetalleVenta> DetalleVentas { get; set; } = new List<DetalleVenta>();
}
