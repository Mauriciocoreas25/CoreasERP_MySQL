using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace CoreasERP.Models;

[Table("CambiosPrecio")]
public class CambioPrecio
{
    [Key]
    public int IdCambioPrecio { get; set; }

    public int IdProducto { get; set; }

    public int? IdCompra { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal CostoAnterior { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal CostoNuevo { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal PrecioVentaAnterior { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal PrecioVentaNuevo { get; set; }

    [Column(TypeName = "decimal(18,2)")]
    public decimal MargenPorcentaje { get; set; }

    [MaxLength(255)]
    public string Motivo { get; set; } = string.Empty;

    public DateTime FechaHora { get; set; } = DateTime.Now;

    [MaxLength(50)]
    public string Estado { get; set; } = "Pendiente"; // "Pendiente", "Aplicado", "Descartado"

    public DateTime? FechaAplicacion { get; set; }

    // Relaciones
    [ForeignKey("IdProducto")]
    public virtual Producto? Producto { get; set; }

    [ForeignKey("IdCompra")]
    public virtual Compra? Compra { get; set; }
}
