namespace CoreasERP.Models;

public class AjusteInventario
{
    public int IdAjuste { get; set; }
    public int IdProducto { get; set; }
    public int IdUsuarioSupervisor { get; set; }
    public decimal StockAnterior { get; set; }
    public decimal StockNuevo { get; set; }
    public decimal Diferencia { get; set; }
    public string Motivo { get; set; } = string.Empty;
    public DateTime FechaHora { get; set; } = DateTime.Now;

    public Producto? Producto { get; set; }
    public Usuario? UsuarioSupervisor { get; set; }
}
