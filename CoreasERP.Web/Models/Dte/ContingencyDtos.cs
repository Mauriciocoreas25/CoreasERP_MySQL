using System.Text.Json.Serialization;

namespace CoreasERP.Models.Dte;

/// <summary>
/// Payload para POST /api/Contingency/start
/// </summary>
public class ContingencyStartDto
{
    [JsonPropertyName("codigoMotivo")]
    public string CodigoMotivo { get; set; } = "3"; // CAT-005: 1=Emisor, 2=Energía, 3=Internet, 4=Hacienda, 5=Otro

    [JsonPropertyName("descripcionMotivo")]
    public string DescripcionMotivo { get; set; } = string.Empty;
}

/// <summary>
/// Respuesta para GET /api/Contingency/active
/// </summary>
public class ContingencyActiveDto
{
    [JsonPropertyName("active")]
    public bool Active { get; set; }

    public bool Activa => Active;

    [JsonPropertyName("eventDetails")]
    public ContingencyEventDetails? EventDetails { get; set; }
}

public class ContingencyEventDetails
{
    [JsonPropertyName("id")]
    public string? Id { get; set; }

    [JsonPropertyName("codigoMotivo")]
    public string? CodigoMotivo { get; set; }

    [JsonPropertyName("descripcionMotivo")]
    public string? DescripcionMotivo { get; set; }

    [JsonPropertyName("estado")]
    public string? Estado { get; set; }

    [JsonPropertyName("fechaInicio")]
    public DateTime? FechaInicio { get; set; }

    [JsonPropertyName("fechaFin")]
    public DateTime? FechaFin { get; set; }
}
