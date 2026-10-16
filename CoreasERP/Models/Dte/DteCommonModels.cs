using System.Text.Json.Serialization;

namespace CoreasERP.Models.Dte;

public class DteRoot
{
    [JsonPropertyName("identificacion")]
    public DteIdentificacion Identificacion { get; set; } = new();

    [JsonPropertyName("documentoRelacionado")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public List<DteDocumentoRelacionado>? DocumentoRelacionado { get; set; }

    [JsonPropertyName("receptor")]
    public DteReceptor Receptor { get; set; } = new();

    [JsonPropertyName("cuerpoDocumento")]
    public List<DteCuerpoItem> CuerpoDocumento { get; set; } = new();

    [JsonPropertyName("resumen")]
    public DteResumen Resumen { get; set; } = new();
}

public class DteIdentificacion
{
    [JsonPropertyName("version")]
    public int Version { get; set; } = 1;

    [JsonPropertyName("ambiente")]
    public string Ambiente { get; set; } = "00"; // '00' = Pruebas, '01' = Produccion

    [JsonPropertyName("tipoDte")]
    public string TipoDte { get; set; } = "01"; // '01', '03', '04', '05', '06', '14'

    [JsonPropertyName("numeroControl")]
    public string NumeroControl { get; set; } = string.Empty;

    [JsonPropertyName("codigoGeneracion")]
    public string CodigoGeneracion { get; set; } = string.Empty;

    [JsonPropertyName("tipoModelo")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public int? TipoModelo { get; set; } // 1 = Previo, 2 = Diferido

    [JsonPropertyName("tipoOperacion")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public int? TipoOperacion { get; set; } // 1 = Normal, 2 = Contingencia

    [JsonPropertyName("tipoContingencia")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public int? TipoContingencia { get; set; }

    [JsonPropertyName("motivoContin")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? MotivoContin { get; set; }

    [JsonPropertyName("fecEmi")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? FecEmi { get; set; } // YYYY-MM-DD

    [JsonPropertyName("horEmi")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? HorEmi { get; set; } // HH:mm:ss

    [JsonPropertyName("tipoMoneda")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? TipoMoneda { get; set; } = "USD";
}

public class DteDocumentoRelacionado
{
    [JsonPropertyName("tipoDocumento")]
    public string TipoDocumento { get; set; } = "03"; // '03' CCF, etc.

    [JsonPropertyName("tipoGeneracion")]
    public int TipoGeneracion { get; set; } = 1; // 1 = Electronico, 2 = Fisico

    [JsonPropertyName("numeroDocumento")]
    public string NumeroDocumento { get; set; } = string.Empty; // UUID del documento relacionado

    [JsonPropertyName("fechaEmision")]
    public string FechaEmision { get; set; } = string.Empty; // YYYY-MM-DD
}

public class DteReceptor
{
    [JsonPropertyName("tipoDocumento")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? TipoDocumento { get; set; } // '13' DUI, '36' NIT, '02', '03'

    [JsonPropertyName("numDocumento")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? NumDocumento { get; set; }

    [JsonPropertyName("nit")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? Nit { get; set; }

    [JsonPropertyName("nrc")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? Nrc { get; set; }

    [JsonPropertyName("nombre")]
    public string Nombre { get; set; } = string.Empty;

    [JsonPropertyName("codActividad")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? CodActividad { get; set; }

    [JsonPropertyName("descActividad")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? DescActividad { get; set; }

    [JsonPropertyName("nombreComercial")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? NombreComercial { get; set; }

    [JsonPropertyName("direccion")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public DteDireccion? Direccion { get; set; }

    [JsonPropertyName("telefono")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? Telefono { get; set; }

    [JsonPropertyName("correo")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? Correo { get; set; }

    // Requerido específicamente en DTE 04 Nota de Remisión
    [JsonPropertyName("bienTitulo")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? BienTitulo { get; set; } // '01' = Propiedad, '02' = Consignación, etc.
}

public class DteDireccion
{
    [JsonPropertyName("catDepartamento")]
    public string CatDepartamento { get; set; } = "12"; // 2 dígitos CAT-012 (ej: 12 San Miguel, 06 San Salvador)

    [JsonPropertyName("catMunicipio")]
    public string CatMunicipio { get; set; } = "1201"; // 4 dígitos CAT-013 (ej: 1201 San Miguel, 0614 San Salvador)

    [JsonPropertyName("texto")]
    public string Texto { get; set; } = "San Miguel, El Salvador";

    [JsonPropertyName("departamento")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? Departamento { get; set; }

    [JsonPropertyName("municipio")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? Municipio { get; set; }

    [JsonPropertyName("distrito")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? Distrito { get; set; }

    [JsonPropertyName("complemento")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? Complemento { get; set; }
}

public class DteCuerpoItem
{
    [JsonPropertyName("numItem")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public int? NumItem { get; set; }

    [JsonPropertyName("tipoItem")]
    public int TipoItem { get; set; } = 1; // 1 = Bien, 2 = Servicio

    // Utilizado en NC (05) y ND (06) para referenciar el UUID del CCF
    [JsonPropertyName("numeroDocumento")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? NumeroDocumento { get; set; }

    [JsonPropertyName("codigo")]
    public string Codigo { get; set; } = string.Empty;

    [JsonPropertyName("descripcion")]
    public string Descripcion { get; set; } = string.Empty;

    [JsonPropertyName("cantidad")]
    public decimal Cantidad { get; set; } = 1.0m;

    [JsonPropertyName("uniMedida")]
    public int UniMedida { get; set; } = 59; // 59 = Unidad

    [JsonPropertyName("precioUni")]
    public decimal PrecioUni { get; set; }

    // En NC y ND se envía la venta gravada del ítem
    [JsonPropertyName("ventaGravada")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public decimal? VentaGravada { get; set; }
}

public class DteResumen
{
    [JsonPropertyName("condicionOperacion")]
    public int CondicionOperacion { get; set; } = 1; // 1 = Contado, 2 = Credito, 3 = Otro

    [JsonPropertyName("formaPago")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public string? FormaPago { get; set; } // '01' Efectivo, '02' Tarjeta, '05' Transferencia

    // Utilizado en NC (05) y ND (06)
    [JsonPropertyName("totalGravada")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public decimal? TotalGravada { get; set; }

    // Utilizado en DTE 14 Sujeto Excluido (Retención de Renta 10%)
    [JsonPropertyName("reteRenta")]
    [JsonIgnore(Condition = JsonIgnoreCondition.WhenWritingNull)]
    public decimal? ReteRenta { get; set; }
}
