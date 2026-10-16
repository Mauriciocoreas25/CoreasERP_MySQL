namespace CoreasERP.Models;

public class Merma
{
    public int IdMerma { get; set; }
    public int IdProducto { get; set; }
    public int IdUsuarioSupervisor { get; set; }
    public int? IdUsuarioCajero { get; set; }
    public decimal Cantidad { get; set; }
    public decimal CantidadBaseStock { get; set; }
    public decimal CostoUnitario { get; set; }
    public decimal CostoTotal { get; set; }
    public string Motivo { get; set; } = string.Empty;
    public string? Observaciones { get; set; }
    public DateTime FechaHora { get; set; } = DateTime.Now;

    public Producto? Producto { get; set; }
    public Usuario? UsuarioSupervisor { get; set; }
    public Usuario? UsuarioCajero { get; set; }
}
