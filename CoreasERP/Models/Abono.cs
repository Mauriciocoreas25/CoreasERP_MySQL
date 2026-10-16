namespace CoreasERP.Models;

public class Abono
{
    public int IdAbono { get; set; }
    public int IdCuentaCobrar { get; set; }
    public int IdUsuario { get; set; }
    public decimal Monto { get; set; }
    public string MetodoPago { get; set; } = "Efectivo";
    public DateTime FechaHora { get; set; } = DateTime.Now;
    public string? Notas { get; set; }

    public CuentaCobrar? CuentaCobrar { get; set; }
    public Usuario? Usuario { get; set; }
}
