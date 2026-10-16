namespace CoreasERP.Models;

public class ConfiguracionNegocio
{
    public int IdConfig { get; set; }
    public string NombreNegocio { get; set; } = "Coreas ERP";
    public string? Propietario { get; set; } = "Jostin Alexander Amaya Chavez";
    public string? Telefono { get; set; } = "7007-9140";
    public string? Email { get; set; } = "info@coreaserp.com";
    public string? Direccion { get; set; } = "San Miguel, El Salvador";
    public string? Nrc { get; set; } = "389607-9";
    public string? Nit { get; set; } = "06898170-7";
    public decimal TasaIva { get; set; } = 13.00m;
    public string MensajeTicket { get; set; } = "¡Gracias por su compra! Vuelva pronto";

    // Parámetros de Facturación Electrónica (FelSv / MH)
    public bool HabilitarDte { get; set; } = true;
    public string? FelSvApiUrl { get; set; } = "http://localhost:5000";
    public string? FelSvTenantId { get; set; } = "772e934a-320b-4891-a245-f2dd7911c994";
    public string? FelSvAmbiente { get; set; } = "00"; // '00' Pruebas, '01' Producción
    public string? CodEstablecimiento { get; set; } = "M001";
    public string? CodPuntoVenta { get; set; } = "P001";
    public string? CatDepartamento { get; set; } = "12"; // 12 = San Miguel
    public string? CatMunicipio { get; set; } = "1201"; // 1201 = San Miguel

    // Parámetros de Impresión Térmica y Documentos Carta
    public string? NombreImpresora { get; set; } = ""; // Vacío = Predeterminada de Windows (Térmica)
    public string? NombreImpresoraDocumentos { get; set; } = ""; // Vacío = Diálogo Windows / PDF
    public int AnchoPapelMm { get; set; } = 58; // 58 (compacto POS-58 por defecto) u 80 (estándar)
    public bool ImpresionDirecta { get; set; } = true; // Imprimir directo a la impresora sin diálogo
    public bool CortarPapel { get; set; } = true; // Activar corte automático de papel (guillotina)
}
