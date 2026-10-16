namespace CoreasERP.Models;

public class CorteCaja
{
    public int IdCorte { get; set; }
    public int IdUsuario { get; set; }
    public decimal MontoInicial { get; set; } = 0.00m;
    public decimal TotalVentas { get; set; } = 0.00m;
    public decimal? MontoFinal { get; set; }
    public decimal Diferencia { get; set; } = 0.00m;
    public DateTime FechaApertura { get; set; } = DateTime.Now;
    public DateTime? FechaCierre { get; set; }
    public string Estado { get; set; } = "Abierta"; // 'Abierta' o 'Cerrada'

    public Usuario? Usuario { get; set; }
}
