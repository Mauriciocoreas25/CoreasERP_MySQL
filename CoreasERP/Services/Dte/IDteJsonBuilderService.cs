using CoreasERP.Models;
using CoreasERP.Models.Dte;

namespace CoreasERP.Services.Dte;

public class DteExtraInfo
{
    public string? DocumentoRelacionadoUUID { get; set; }
    public string? DocumentoRelacionadoTipo { get; set; } = "03";
    public DateTime? DocumentoRelacionadoFecha { get; set; }
    public string? BienTitulo { get; set; } = "01"; // '01' Propiedad
    public string? CodActividad { get; set; }
    public string? DescActividad { get; set; }
    public string? CatDepartamento { get; set; } = "12";
    public string? CatMunicipio { get; set; } = "1201";
}

public interface IDteJsonBuilderService
{
    /// <summary>
    /// Construye el DTO final EmitDteRequestDto conteniendo el JSON interno (rawDteJson)
    /// específico según el tipo de documento tributario (01, 03, 04, 05, 06, 14).
    /// </summary>
    EmitDteRequestDto ConstruirPayloadDte(
        string tipoDte,
        Venta venta,
        Cliente cliente,
        ConfiguracionNegocio config,
        int correlativo,
        DteExtraInfo? extraInfo = null);

    /// <summary>
    /// Genera el correlativo normalizado con formato oficial MH:
    /// DTE-{tipoDte}-M{codEstable}P{codPuntoVenta}-{correlativo:D15}
    /// </summary>
    string GenerarNumeroControl(string tipoDte, string codEstable, string codPuntoVenta, int correlativo);

    /// <summary>
    /// Genera un UUID versión 4 en mayúsculas requerido por Ministerio de Hacienda.
    /// </summary>
    string GenerarCodigoGeneracion();

    /// <summary>
    /// Mapea el nombre de comprobante del POS ("Ticket", "Factura", "CCF (03)", "N.Remisión (04)", etc.)
    /// a su código DTE correspondiente ("01", "03", "04", "05", "06", "14").
    /// </summary>
    string? MapearTipoComprobanteADte(string tipoComprobante);
}
