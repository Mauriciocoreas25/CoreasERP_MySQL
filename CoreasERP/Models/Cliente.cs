namespace CoreasERP.Models;

public class Cliente
{
    public int IdCliente { get; set; }
    public string TipoPersona { get; set; } = "Natural"; // 'Natural' o 'Juridica'
    public string Nombre { get; set; } = string.Empty;
    public string? TipoDocumento { get; set; } = "DUI"; // 'DUI', 'NIT', 'Pasaporte'
    public string? NumDocumento { get; set; }
    public string? Telefono { get; set; }
    public string? Email { get; set; }
    public string? Direccion { get; set; }
    public string? Nrc { get; set; } // Número de Registro de Contribuyente
    public string? Giro { get; set; } // Actividad o rubro comercial
    public DateTime FechaCreacion { get; set; } = DateTime.Now;

    [System.ComponentModel.DataAnnotations.Schema.NotMapped]
    public string? Nit
    {
        get => TipoDocumento == "NIT" ? NumDocumento : NumDocumento;
        set
        {
            if (TipoDocumento == "NIT" || string.IsNullOrEmpty(NumDocumento))
                NumDocumento = value;
        }
    }

    public ICollection<Venta> Ventas { get; set; } = new List<Venta>();
}
