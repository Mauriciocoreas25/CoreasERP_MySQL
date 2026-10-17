using System.ComponentModel.DataAnnotations.Schema;

namespace CoreasERP.Models;

public class Producto
{
    public int IdProducto { get; set; }
    public int IdCategoria { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public decimal PrecioCompra { get; set; } = 0.000m;
    public decimal PrecioVenta { get; set; } = 0.000m;
    public decimal? PrecioGranel { get; set; }
    public decimal? CostoGranel { get; set; }
    public decimal? CantidadPorEmpaque { get; set; } = 1.000m;
    public decimal Stock { get; set; } = 0.000m;
    public decimal StockMinimo { get; set; } = 5.000m;
    public bool EsGranel { get; set; } = false;
    public string? UnidadMedida { get; set; } = "Unidad";
    public string? Imagen { get; set; }
    public string? ImagenUrl { get; set; }
    public decimal MargenExcepcion { get; set; } = 0.000m;
    public bool Estado { get; set; } = true;
    public DateTime FechaCreacion { get; set; } = DateTime.Now;

    public Categoria? Categoria { get; set; }
    public ICollection<DetalleVenta> DetalleVentas { get; set; } = new List<DetalleVenta>();
    public ICollection<ProductoMaterial> Materiales { get; set; } = new List<ProductoMaterial>();
    public ICollection<AjusteInventario> AjustesInventario { get; set; } = new List<AjusteInventario>();

    [NotMapped]
    public decimal MargenGanancia => PrecioCompra > 0 ? Math.Round(((PrecioVenta - PrecioCompra) / PrecioCompra) * 100m, 3, MidpointRounding.AwayFromZero) : 0m;

    [NotMapped]
    public decimal CostoEfectivoGranel => (CostoGranel.HasValue && CostoGranel.Value > 0)
        ? Math.Round(CostoGranel.Value, 3, MidpointRounding.AwayFromZero)
        : (CantidadPorEmpaque.HasValue && CantidadPorEmpaque.Value > 0
            ? Math.Round(PrecioCompra / CantidadPorEmpaque.Value, 3, MidpointRounding.AwayFromZero)
            : Math.Round(PrecioCompra, 3, MidpointRounding.AwayFromZero));

    [NotMapped]
    public decimal MargenGananciaGranel
    {
        get
        {
            decimal c = CostoEfectivoGranel;
            if (c <= 0 || !PrecioGranel.HasValue || PrecioGranel.Value <= 0) return 0m;
            return Math.Round(((PrecioGranel.Value - c) / c) * 100m, 3, MidpointRounding.AwayFromZero);
        }
    }
}
