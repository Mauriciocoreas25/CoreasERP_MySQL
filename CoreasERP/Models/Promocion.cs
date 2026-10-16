namespace CoreasERP.Models;

public class Promocion
{
    public int IdPromocion { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public string TipoDescuento { get; set; } = "Porcentaje"; // 'Porcentaje' o 'Fijo'
    public decimal Valor { get; set; } = 0.00m;
    public DateTime FechaInicio { get; set; } = DateTime.Now;
    public DateTime FechaFin { get; set; } = DateTime.Now.AddMonths(1);
    public bool Estado { get; set; } = true;
    public int? IdProducto { get; set; }

    public Producto? Producto { get; set; }
}
