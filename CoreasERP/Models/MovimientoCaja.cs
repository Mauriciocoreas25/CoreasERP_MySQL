namespace CoreasERP.Models;

public class MovimientoCaja
{
    public int IdMovimiento { get; set; }
    public int? IdCorte { get; set; }
    public int IdUsuario { get; set; }
    public string Tipo { get; set; } = "Gasto"; // 'Retiro', 'Gasto', 'Ingreso'
    public decimal Monto { get; set; } = 0.00m;
    public string Motivo { get; set; } = string.Empty;
    public DateTime FechaHora { get; set; } = DateTime.Now;

    public CorteCaja? Corte { get; set; }
    public Usuario? Usuario { get; set; }
}
