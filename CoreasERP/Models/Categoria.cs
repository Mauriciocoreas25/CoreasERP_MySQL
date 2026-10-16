namespace CoreasERP.Models;

public class Categoria
{
    public int IdCategoria { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public string? Icono { get; set; } = "fa-box";
    public string? ImagenUrl { get; set; }
    public bool Estado { get; set; } = true;

    public ICollection<Producto> Productos { get; set; } = new List<Producto>();
}
