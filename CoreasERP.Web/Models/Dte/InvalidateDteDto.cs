using System.Text.Json.Serialization;

namespace CoreasERP.Models.Dte;

/// <summary>
/// Payload para POST /api/Invalidation conforme a la normativa de Hacienda (CAT-024 y CAT-022)
/// </summary>
public class InvalidateDteRequestDto
{
    [JsonPropertyName("dteId")]
    public string DteId { get; set; } = string.Empty;

    [JsonPropertyName("tipoAnulacion")]
    public int TipoAnulacion { get; set; } = 2; // CAT-024: 1=Emisor, 2=Receptor, 3=Sin efecto, 4=Otros

    [JsonPropertyName("motivoAnulacion")]
    public string MotivoAnulacion { get; set; } = string.Empty; // Min 15 caracteres

    [JsonPropertyName("nombreResponsable")]
    public string NombreResponsable { get; set; } = string.Empty;

    [JsonPropertyName("tipDocResponsable")]
    public string TipDocResponsable { get; set; } = "36"; // CAT-022: '36' NIT, '13' DUI

    [JsonPropertyName("numDocResponsable")]
    public string NumDocResponsable { get; set; } = string.Empty;

    [JsonPropertyName("nombreSolicita")]
    public string NombreSolicita { get; set; } = string.Empty;

    [JsonPropertyName("tipDocSolicita")]
    public string TipDocSolicita { get; set; } = "13"; // CAT-022: '13' DUI, '36' NIT, '02' Pasaporte

    [JsonPropertyName("numDocSolicita")]
    public string NumDocSolicita { get; set; } = string.Empty;

    [JsonPropertyName("codigoGeneracionR")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? CodigoGeneracionR { get; set; }
}

public class InvalidateDteResponseDto
{
    public bool Success { get; set; }
    public string? SelloInvalidacion { get; set; }
    public string? Estado { get; set; }
    public string? Mensaje { get; set; }
}
