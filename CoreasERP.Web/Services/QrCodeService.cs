using QRCoder;

namespace CoreasERP.Services;

public interface IQrCodeService
{
    byte[]? GenerarQrBytes(string contenido, int pixelsPerModule = 4);
    byte[]? GenerarQrBytesDteHacienda(string codigoGeneracion, DateTime fechaEmision, string? ambiente = "00", int pixelsPerModule = 4);
    string GenerarQrBase64(string contenido, int pixelsPerModule = 4);
    string GenerarQrDteHacienda(string codigoGeneracion, DateTime fechaEmision, string? ambiente = "00", int pixelsPerModule = 4);
    string ObtenerUrlConsultaHacienda(string codigoGeneracion, DateTime fechaEmision, string? ambiente = "00");
}

public class QrCodeService : IQrCodeService
{
    public string ObtenerUrlConsultaHacienda(string codigoGeneracion, DateTime fechaEmision, string? ambiente = "00")
    {
        string fechaStr = fechaEmision.ToString("yyyy-MM-dd");
        string amb = string.IsNullOrWhiteSpace(ambiente) ? "00" : ambiente;
        string cod = (codigoGeneracion ?? "").Trim();
        return $"https://admin.factura.gob.sv/consultaPublica?ambiente={amb}&codGen={cod}&fechaEmi={fechaStr}";
    }

    public byte[]? GenerarQrBytesDteHacienda(string codigoGeneracion, DateTime fechaEmision, string? ambiente = "00", int pixelsPerModule = 4)
    {
        if (string.IsNullOrWhiteSpace(codigoGeneracion)) return null;
        string url = ObtenerUrlConsultaHacienda(codigoGeneracion, fechaEmision, ambiente);
        return GenerarQrBytes(url, pixelsPerModule);
    }

    public string GenerarQrDteHacienda(string codigoGeneracion, DateTime fechaEmision, string? ambiente = "00", int pixelsPerModule = 4)
    {
        if (string.IsNullOrWhiteSpace(codigoGeneracion)) return string.Empty;
        string url = ObtenerUrlConsultaHacienda(codigoGeneracion, fechaEmision, ambiente);
        return GenerarQrBase64(url, pixelsPerModule);
    }

    public byte[]? GenerarQrBytes(string contenido, int pixelsPerModule = 4)
    {
        if (string.IsNullOrWhiteSpace(contenido)) return null;

        try
        {
            using var qrGenerator = new QRCodeGenerator();
            using var qrCodeData = qrGenerator.CreateQrCode(contenido, QRCodeGenerator.ECCLevel.M);
            using var qrCode = new PngByteQRCode(qrCodeData);
            return qrCode.GetGraphic(pixelsPerModule);
        }
        catch
        {
            return null;
        }
    }

    public string GenerarQrBase64(string contenido, int pixelsPerModule = 4)
    {
        var bytes = GenerarQrBytes(contenido, pixelsPerModule);
        return bytes != null ? $"data:image/png;base64,{Convert.ToBase64String(bytes)}" : string.Empty;
    }
}
