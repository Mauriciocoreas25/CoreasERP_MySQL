using System.Text.Json.Serialization;

namespace CoreasERP.Models.Dte;

/// <summary>
/// DTO Wrapper requerido por el endpoint POST /api/Dtes/emit según el Manual Técnico Oficial.
/// </summary>
public class EmitDteRequestDto
{
    [JsonPropertyName("rawDteJson")]
    public string RawDteJson { get; set; } = string.Empty;

    [JsonPropertyName("tipoDte")]
    public string? TipoDte { get; set; }

    [JsonPropertyName("numeroControl")]
    public string? NumeroControl { get; set; }

    [JsonPropertyName("receptorDocumento")]
    public string? ReceptorDocumento { get; set; }

    [JsonPropertyName("receptorNombre")]
    public string? ReceptorNombre { get; set; }

    [JsonPropertyName("montoTotal")]
    public decimal MontoTotal { get; set; }
}

/// <summary>
/// DTO que representa la respuesta procesada de la API de FelSv y el Ministerio de Hacienda.
/// </summary>
public class EmitDteResponseDto
{
    public bool Success { get; set; }
    public string? DteId { get; set; }
    public string? CodigoGeneracion { get; set; }
    public string? NumeroControl { get; set; }
    public string? SelloRecepcion { get; set; }
    public string? Estado { get; set; } // 'Transmitido', 'Contingencia_Pendiente', 'Rechazado'
    public string? FechaHoraProcesamiento { get; set; }
    public string? MensajeHacienda { get; set; }
    public List<string>? Observaciones { get; set; }
    public string? ErrorCode { get; set; }
    public string? RawResponse { get; set; }
}
