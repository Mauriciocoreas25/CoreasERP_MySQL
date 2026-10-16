using Microsoft.JSInterop;
using CoreasERP.Models;
#if WINDOWS
using System.Drawing;
using System.Drawing.Printing;
using System.Runtime.InteropServices;
using GdiFont = System.Drawing.Font;
using GdiBrush = System.Drawing.Brush;
using GdiBrushes = System.Drawing.Brushes;
using GdiImage = System.Drawing.Image;
#endif

namespace CoreasERP.Services;

public interface IPrintService
{
    List<string> GetInstalledPrinters();
    string GetDefaultPrinterName();
    Task<(bool Success, string Message)> PrintReceiptDirectAsync(Venta venta, ConfiguracionNegocio? config = null);
    Task<(bool Success, string Message)> PrintDevolucionDirectAsync(Venta venta, ConfiguracionNegocio? config = null);
    Task<(bool Success, string Message)> PrintMermaDirectAsync(List<Merma> mermas, decimal totalCosto, string motivo, string cajero, string supervisor, ConfiguracionNegocio? config = null);
    Task<(bool Success, string Message)> PrintPriceTagsDirectAsync(List<CambioPrecio> items, ConfiguracionNegocio? config = null);
    Task<(bool Success, string Message)> PrintTestReceiptAsync(string? printerName, int paperWidthMm, ConfiguracionNegocio? config = null);
    Task PrintReceiptAsync(IJSRuntime jsRuntime, string elementId = "thermal-receipt");
    Task PrintInvoiceLetterAsync(IJSRuntime jsRuntime, string elementId = "letter-invoice");
    Task PrintCorteDirectAsync(ResumenCorteDto resumen, ConfiguracionNegocio? config = null);
    Task PrintCorteAsync(IJSRuntime jsRuntime, string elementId = "corte-receipt");
    Task PrintPriceTagsAsync(IJSRuntime jsRuntime, string elementId, string orientation = "landscape");
    Task<(bool Success, string Message)> PrintMovimientoCajaDirectAsync(MovimientoCaja movimiento, string nombreCajero, string? nombreSupervisor, ConfiguracionNegocio? config = null);
    Task PrintMovimientoCajaAsync(IJSRuntime jsRuntime, string elementId = "movimiento-caja-receipt");
    Task<(bool Success, string Message)> OpenCashDrawerAsync(ConfiguracionNegocio? config = null);
}

public class PrintService : IPrintService
{
    private readonly IQrCodeService _qrCodeService;

    public PrintService(IQrCodeService qrCodeService)
    {
        _qrCodeService = qrCodeService;
    }

    public List<string> GetInstalledPrinters()
    {
        var printers = new List<string>();
#if WINDOWS
        try
        {
            foreach (string printer in PrinterSettings.InstalledPrinters)
            {
                printers.Add(printer);
            }
        }
        catch { }
#endif
        return printers;
    }

    public string GetDefaultPrinterName()
    {
#if WINDOWS
        try
        {
            var settings = new PrinterSettings();
            return settings.PrinterName ?? string.Empty;
        }
        catch { }
#endif
        return string.Empty;
    }

    public Task<(bool Success, string Message)> PrintReceiptDirectAsync(Venta venta, ConfiguracionNegocio? config = null)
    {
#if WINDOWS
        return Task.Run<(bool Success, string Message)>(() =>
        {
            try
            {
                string printerName = !string.IsNullOrWhiteSpace(config?.NombreImpresora)
                    ? config.NombreImpresora.Trim()
                    : GetDefaultPrinterName();

                if (string.IsNullOrWhiteSpace(printerName))
                {
                    return (false, "No se detectó ninguna impresora conectada en el sistema.");
                }

                using var doc = new PrintDocument();
                doc.PrinterSettings.PrinterName = printerName;

                if (!doc.PrinterSettings.IsValid)
                {
                    return (false, $"La impresora '{printerName}' no se encuentra disponible o no es válida.");
                }

                doc.PrintController = new StandardPrintController();
                doc.DefaultPageSettings.Margins = new Margins(0, 0, 0, 0);

                doc.PrintPage += (sender, e) =>
                {
                    var g = e.Graphics;
                    if (g == null) return;

                    // 1. Detección precisa de ancho de papel respetando la configuración del usuario
                    bool is58mm = (config?.AnchoPapelMm == 58);
                    if (config?.AnchoPapelMm == 80)
                    {
                        is58mm = false;
                    }
                    else if (config?.AnchoPapelMm == 58)
                    {
                        is58mm = true;
                    }
                    else
                    {
                        string pUpper = printerName.ToUpperInvariant();
                        if (pUpper.Contains("58") || pUpper.Contains("MINI") || pUpper.Contains("ZJ") || pUpper.Contains("POS58") || pUpper.Contains("MPT"))
                        {
                            is58mm = true;
                        }
                        else if (e.PageBounds.Width > 0 && e.PageBounds.Width <= 240)
                        {
                            is58mm = true;
                        }
                    }

                    int anchoMm = is58mm ? 58 : 80;
                    float anchoPapelPuntos = is58mm ? 200f : 280f;
                    if (e.PageBounds.Width > 0 && e.PageBounds.Width < anchoPapelPuntos)
                    {
                        anchoPapelPuntos = e.PageBounds.Width - 4f;
                    }

                    // Margen izquierdo optimizado (seguridad para que no coma el inicio del texto)
                    float margenIzq = is58mm ? 8f : 12f;
                    float anchoContenido = Math.Max(140f, anchoPapelPuntos - margenIzq);

                    using var fontTitle = new GdiFont("Courier New", is58mm ? 9f : 10.5f, FontStyle.Bold);
                    using var fontBold = new GdiFont("Courier New", is58mm ? 7.5f : 8.5f, FontStyle.Bold);
                    using var fontRegular = new GdiFont("Courier New", is58mm ? 7.2f : 8.2f, FontStyle.Regular);
                    using var fontSmall = new GdiFont("Courier New", is58mm ? 6.5f : 7.2f, FontStyle.Regular);
                    using var fontTotals = new GdiFont("Courier New", is58mm ? 9.5f : 11f, FontStyle.Bold);

                    GdiBrush brush = GdiBrushes.Black;
                    float y = 8f;
                    float lineaH = fontRegular.GetHeight(g) + 3f;

                    // Formatos con LineAlignment = Near para evitar que textos multi-línea se aplasten entre sí
                    using var fmtCenter = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.Word };
                    using var fmtNear = new StringFormat { Alignment = StringAlignment.Near, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.Word };
                    using var fmtFar = new StringFormat { Alignment = StringAlignment.Far, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.None };

                    void DrawCenter(string text, GdiFont f)
                    {
                        string clean = SanitizeThermalText(text);
                        if (string.IsNullOrWhiteSpace(clean)) return;
                        var size = g.MeasureString(clean, f, (int)anchoContenido, fmtCenter);
                        float h = Math.Max(f.GetHeight(g) + 2f, size.Height);
                        g.DrawString(clean, f, brush, new RectangleF(margenIzq, y, anchoContenido, h), fmtCenter);
                        y += h + 2f;
                    }

                    void DrawSeparator(char c = '-')
                    {
                        int numChars = is58mm ? 26 : 36;
                        string sep = new string(c, numChars);
                        DrawCenter(sep, fontRegular);
                    }

                    void DrawMetaRow(string label, string val, GdiFont? fVal = null)
                    {
                        string cleanVal = SanitizeThermalText(val);
                        var f = fVal ?? fontRegular;
                        float h = f.GetHeight(g) + 2f;
                        g.DrawString($"{label} {cleanVal}", f, brush, new RectangleF(margenIzq, y, anchoContenido, h), fmtNear);
                        y += h + 1f;
                    }

                    // 1. Cabecera del Establecimiento
                    string nombreNegocio = config?.NombreNegocio ?? "COREAS ERP";
                    DrawCenter(nombreNegocio, fontTitle);

                    if (!string.IsNullOrWhiteSpace(config?.Propietario))
                        DrawCenter(config.Propietario, fontSmall);

                    if (!string.IsNullOrWhiteSpace(config?.Nit) || !string.IsNullOrWhiteSpace(config?.Nrc))
                    {
                        string taxInfo = $"NIT: {config?.Nit ?? "-"} NRC: {config?.Nrc ?? "-"}";
                        DrawCenter(taxInfo, fontSmall);
                    }

                    if (!string.IsNullOrWhiteSpace(config?.Direccion))
                        DrawCenter(config.Direccion, fontSmall);

                    if (!string.IsNullOrWhiteSpace(config?.Telefono))
                        DrawCenter($"Tel: {config.Telefono}", fontSmall);

                    DrawSeparator();

                    // 2. Metadatos del Comprobante
                    DrawMetaRow("COMPROB:", venta.NumComprobante, fontBold);
                    DrawMetaRow("TIPO:", venta.TipoComprobante.ToUpper());
                    string fechaFormateada = $"{venta.FechaHora:dd/MM/yyyy} {venta.FechaHora.ToString("hh:mm tt", System.Globalization.CultureInfo.InvariantCulture)}";
                    DrawMetaRow("FECHA:", fechaFormateada);
                    DrawMetaRow("CAJERO:", venta.Usuario?.Nombre ?? "Cajero de Turno");
                    DrawMetaRow("CLIENTE:", venta.Cliente?.Nombre ?? "Consumidor Final");

                    if (!string.IsNullOrWhiteSpace(venta.Cliente?.NumDocumento))
                    {
                        DrawMetaRow("DOC:", venta.Cliente.NumDocumento);
                    }

                    DrawSeparator();

                    // 3. Tabla de Productos (Formato universal de 2 líneas: descripción completa arriba, cantidad x precio abajo)
                    g.DrawString("DESCRIPCION", fontBold, brush, new RectangleF(margenIzq, y, anchoContenido * 0.65f, lineaH), fmtNear);
                    g.DrawString("TOTAL", fontBold, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtFar);
                    y += lineaH + 2f;
                    DrawSeparator('.');

                    int maxCharsDesc = is58mm ? 32 : 42;
                    foreach (var item in venta.DetalleVentas)
                    {
                        string rawName = item.Producto?.Nombre ?? "Producto";
                        string desc = SanitizeThermalText(rawName);
                        if (desc.Length > maxCharsDesc)
                        {
                            desc = desc.Substring(0, maxCharsDesc);
                        }

                        var descSize = g.MeasureString(desc, fontBold, (int)anchoContenido, fmtNear);
                        float descH = Math.Max(lineaH, descSize.Height);

                        // Línea 1: Nombre del producto (máximo espacio horizontal para no desbordar)
                        g.DrawString(desc, fontBold, brush, new RectangleF(margenIzq, y, anchoContenido, descH), fmtNear);
                        y += descH + 1f;

                        // Línea 2: Cantidad x P.U. a la izquierda y Subtotal a la derecha
                        string cantPu = $"  {item.Cantidad:G29} x ${item.Precio:F2}";
                        g.DrawString(cantPu, fontRegular, brush, new RectangleF(margenIzq, y, anchoContenido * 0.60f, lineaH), fmtNear);
                        g.DrawString($"${item.Subtotal:F2}", fontBold, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtFar);
                        y += lineaH + 3f;
                    }

                    DrawSeparator();

                    // 4. Totales Financieros
                    void DrawTotalRow(string label, string val, GdiFont f)
                    {
                        float h = f.GetHeight(g) + 2f;
                        g.DrawString(label, f, brush, new RectangleF(margenIzq, y, anchoContenido * 0.60f, h), fmtNear);
                        g.DrawString(val, f, brush, new RectangleF(margenIzq, y, anchoContenido, h), fmtFar);
                        y += h + 2f;
                    }

                    DrawTotalRow("SUBTOTAL:", $"${venta.Subtotal:F2}", fontRegular);
                    DrawTotalRow("IVA (13%):", $"${venta.Impuesto:F2}", fontRegular);
                    DrawTotalRow("TOTAL:", $"${venta.Total:F2}", fontTotals);

                    DrawSeparator('.');

                    // 5. Detalles de Pago
                    DrawTotalRow("METODO:", SanitizeThermalText(venta.MetodoPago), fontRegular);

                    if (venta.TipoComprobante.Equals("Anticipo", StringComparison.OrdinalIgnoreCase))
                    {
                        decimal anticipo = Math.Min(venta.PagoCon ?? 0m, venta.Total);
                        decimal saldo = Math.Max(0m, venta.Total - anticipo);
                        DrawTotalRow("ABONADO:", $"${anticipo:F2}", fontBold);
                        DrawTotalRow("SALDO PEND:", $"${saldo:F2}", fontBold);
                    }
                    else if (venta.MetodoPago == "Efectivo")
                    {
                        DrawTotalRow("PAGO CON:", $"${(venta.PagoCon ?? venta.Total):F2}", fontRegular);
                        DrawTotalRow("CAMBIO:", $"${(venta.Cambio ?? 0m):F2}", fontBold);
                    }

                    // 6. Bloque DTE (Solo si tiene Código de Generación)
                    if (!string.IsNullOrWhiteSpace(venta.CodigoGeneracion))
                    {
                        DrawSeparator();
                        DrawCenter("DOCUMENTO TRIBUTARIO ELECTRONICO", fontBold);

                        g.DrawString("COD. GENERACION:", fontBold, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtNear);
                        y += lineaH + 2f;
                        g.DrawString(venta.CodigoGeneracion, fontSmall, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH * 1.8f), fmtNear);
                        y += lineaH * 1.5f + 2f;

                        if (!string.IsNullOrWhiteSpace(venta.NumeroControl))
                        {
                            g.DrawString($"NUM. CONTROL: {venta.NumeroControl}", fontSmall, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtNear);
                            y += lineaH + 2f;
                        }

                        if (!string.IsNullOrWhiteSpace(venta.SelloRecepcion))
                        {
                            g.DrawString("SELLO RECEPCION MH:", fontBold, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtNear);
                            y += lineaH + 2f;
                            g.DrawString(venta.SelloRecepcion, fontSmall, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH * 1.8f), fmtNear);
                            y += lineaH * 1.5f + 2f;
                        }

                        string estadoStr = venta.EstadoDte == "Transmitido" ? "TRANSMITIDO (MH)" : (venta.EstadoDte == "Contingencia_Pendiente" ? "CONTINGENCIA" : (venta.EstadoDte ?? "-"));
                        g.DrawString($"ESTADO: {estadoStr}", fontBold, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtNear);
                        y += lineaH + 4f;

                        // QR Oficial de Hacienda
                        string amb = config?.FelSvAmbiente ?? "00";
                        byte[]? qrBytes = _qrCodeService.GenerarQrBytesDteHacienda(venta.CodigoGeneracion, venta.FechaHora, amb, pixelsPerModule: 3);
                        if (qrBytes != null && qrBytes.Length > 0)
                        {
                            using var ms = new MemoryStream(qrBytes);
                            using var qrImg = GdiImage.FromStream(ms);
                            float qrSize = is58mm ? 90f : 120f;
                            float qrX = margenIzq + (anchoContenido - qrSize) / 2f;
                            g.DrawImage(qrImg, qrX, y, qrSize, qrSize);
                            y += qrSize + 4f;

                            DrawCenter("Escanee para verificar en Hacienda", fontSmall);
                        }
                    }

                    DrawSeparator();

                    // 7. Pie de Ticket y Agradecimiento
                    string msg = string.IsNullOrWhiteSpace(config?.MensajeTicket)
                        ? "!GRACIAS POR SU COMPRA! VUELVA PRONTO"
                        : SanitizeThermalText(config.MensajeTicket);
                    DrawCenter(msg, fontRegular);

                    string softwareInfo = !string.IsNullOrWhiteSpace(venta.CodigoGeneracion)
                        ? "Software: Coreas ERP Local · FelSv DTE"
                        : "Software: Coreas ERP Local";
                    DrawCenter(softwareInfo, fontSmall);

                    // 8. ALIMENTACIÓN DE PAPEL: Delimitador visual final para asegurar rasterizado completo
                    DrawCenter("- - - - - - - - - - - -", fontSmall);
                    y += 30f;
                    e.HasMorePages = false;
                };

                doc.Print();

                // Pausa breve de 150ms para que el Spooler de Windows finalice el trabajo GDI
                // antes de enviar los bytes RAW de avance de papel y apertura de gaveta.
                Thread.Sleep(150);

                // 1. Avance físico de papel hacia arriba (subir el papel para librar la cuchilla de corte sin presionar FEED)
                // 2. Apertura automática de la gaveta de dinero al finalizar la venta
                // 3. Corte automático de papel (guillotina)
                SendPaperFeedAndDrawerKick(printerName, openDrawer: true, extraLines: 6, cutPaper: config?.CortarPapel ?? true);

                return (true, $"Ticket impreso correctamente en '{printerName}'.");
            }
            catch (Exception ex)
            {
                return (false, $"Error al imprimir ticket térmico: {ex.Message}");
            }
        });
#else
        return Task.FromResult((false, "Impresión directa por controlador solo disponible en Windows."));
#endif
    }

    public Task<(bool Success, string Message)> PrintDevolucionDirectAsync(Venta venta, ConfiguracionNegocio? config = null)
    {
#if WINDOWS
        return Task.Run<(bool Success, string Message)>(() =>
        {
            try
            {
                string printerName = !string.IsNullOrWhiteSpace(config?.NombreImpresora)
                    ? config.NombreImpresora.Trim()
                    : GetDefaultPrinterName();

                if (string.IsNullOrWhiteSpace(printerName))
                {
                    return (false, "No se detectó ninguna impresora conectada en el sistema.");
                }

                using var doc = new PrintDocument();
                doc.PrinterSettings.PrinterName = printerName;

                if (!doc.PrinterSettings.IsValid)
                {
                    return (false, $"La impresora '{printerName}' no se encuentra disponible o no es válida.");
                }

                doc.PrintController = new StandardPrintController();
                doc.DefaultPageSettings.Margins = new Margins(0, 0, 0, 0);

                doc.PrintPage += (sender, e) =>
                {
                    var g = e.Graphics;
                    if (g == null) return;

                    bool is58mm = (config?.AnchoPapelMm == 58);
                    if (config?.AnchoPapelMm == 80)
                    {
                        is58mm = false;
                    }
                    else if (config?.AnchoPapelMm == 58)
                    {
                        is58mm = true;
                    }
                    else
                    {
                        string pUpper = printerName.ToUpperInvariant();
                        if (pUpper.Contains("58") || pUpper.Contains("MINI") || pUpper.Contains("ZJ") || pUpper.Contains("POS58") || pUpper.Contains("MPT"))
                        {
                            is58mm = true;
                        }
                        else if (e.PageBounds.Width > 0 && e.PageBounds.Width <= 240)
                        {
                            is58mm = true;
                        }
                    }

                    int anchoMm = is58mm ? 58 : 80;
                    float anchoPapelPuntos = is58mm ? 200f : 280f;
                    if (e.PageBounds.Width > 0 && e.PageBounds.Width < anchoPapelPuntos)
                    {
                        anchoPapelPuntos = e.PageBounds.Width - 4f;
                    }

                    float margenIzq = is58mm ? 8f : 12f;
                    float anchoContenido = Math.Max(140f, anchoPapelPuntos - margenIzq);

                    using var fontTitle = new GdiFont("Courier New", is58mm ? 9f : 10.5f, FontStyle.Bold);
                    using var fontSubtitle = new GdiFont("Courier New", is58mm ? 8f : 9.5f, FontStyle.Bold);
                    using var fontBold = new GdiFont("Courier New", is58mm ? 7.5f : 8.5f, FontStyle.Bold);
                    using var fontRegular = new GdiFont("Courier New", is58mm ? 7.2f : 8.2f, FontStyle.Regular);
                    using var fontSmall = new GdiFont("Courier New", is58mm ? 6.5f : 7.2f, FontStyle.Regular);
                    using var fontTotals = new GdiFont("Courier New", is58mm ? 9.5f : 11f, FontStyle.Bold);

                    GdiBrush brush = GdiBrushes.Black;
                    float y = 8f;
                    float lineaH = fontRegular.GetHeight(g) + 3f;

                    using var fmtCenter = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.Word };
                    using var fmtNear = new StringFormat { Alignment = StringAlignment.Near, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.Word };
                    using var fmtFar = new StringFormat { Alignment = StringAlignment.Far, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.None };

                    void DrawCenter(string text, GdiFont f)
                    {
                        string clean = SanitizeThermalText(text);
                        if (string.IsNullOrWhiteSpace(clean)) return;
                        var size = g.MeasureString(clean, f, (int)anchoContenido, fmtCenter);
                        float h = Math.Max(f.GetHeight(g) + 2f, size.Height);
                        g.DrawString(clean, f, brush, new RectangleF(margenIzq, y, anchoContenido, h), fmtCenter);
                        y += h + 2f;
                    }

                    void DrawSeparator(char c = '-')
                    {
                        int numChars = is58mm ? 26 : 36;
                        string sep = new string(c, numChars);
                        DrawCenter(sep, fontRegular);
                    }

                    void DrawMetaRow(string label, string val, GdiFont? fVal = null)
                    {
                        string cleanVal = SanitizeThermalText(val);
                        var f = fVal ?? fontRegular;
                        float h = f.GetHeight(g) + 2f;
                        g.DrawString($"{label} {cleanVal}", f, brush, new RectangleF(margenIzq, y, anchoContenido, h), fmtNear);
                        y += h + 1f;
                    }

                    // 1. Encabezado del Establecimiento
                    string nombreNegocio = config?.NombreNegocio ?? "COREAS ERP";
                    DrawCenter(nombreNegocio, fontTitle);

                    if (!string.IsNullOrWhiteSpace(config?.Propietario))
                        DrawCenter(config.Propietario, fontSmall);

                    if (!string.IsNullOrWhiteSpace(config?.Nit) || !string.IsNullOrWhiteSpace(config?.Nrc))
                        DrawCenter($"NIT: {config?.Nit ?? "-"} NRC: {config?.Nrc ?? "-"}", fontSmall);

                    if (!string.IsNullOrWhiteSpace(config?.Direccion))
                        DrawCenter(config.Direccion, fontSmall);

                    if (!string.IsNullOrWhiteSpace(config?.Telefono))
                        DrawCenter($"Tel: {config.Telefono}", fontSmall);

                    DrawSeparator('=');

                    // 2. Título de Devolución
                    DrawCenter("*** COMPROBANTE DE DEVOLUCION ***", fontSubtitle);
                    DrawCenter("ANULACION / REEMBOLSO DE VENTA", fontSmall);
                    DrawSeparator('-');

                    // 3. Metadatos del Documento Original y Devolución
                    DrawMetaRow("COMPROB. ORIG:", venta.NumComprobante, fontBold);
                    DrawMetaRow("TIPO:", venta.TipoComprobante.ToUpper());
                    string fOrig = $"{venta.FechaHora:dd/MM/yyyy} {venta.FechaHora.ToString("hh:mm tt", System.Globalization.CultureInfo.InvariantCulture)}";
                    DrawMetaRow("FECHA VENTA:", fOrig);
                    string fDev = $"{DateTime.Now:dd/MM/yyyy} {DateTime.Now.ToString("hh:mm tt", System.Globalization.CultureInfo.InvariantCulture)}";
                    DrawMetaRow("FECHA ANUL:", fDev, fontBold);
                    DrawMetaRow("CAJERO:", venta.Usuario?.Nombre ?? "Cajero de Turno");
                    DrawMetaRow("CLIENTE:", venta.Cliente?.Nombre ?? "Consumidor Final");

                    if (!string.IsNullOrWhiteSpace(venta.Cliente?.NumDocumento))
                    {
                        DrawMetaRow("DOC:", venta.Cliente.NumDocumento);
                    }

                    DrawSeparator('-');

                    // 4. Detalle de Artículos Devueltos
                    DrawCenter("ARTICULOS DEVUELTOS / REINGRESADOS", fontBold);
                    DrawSeparator('.');

                    g.DrawString("DESCRIPCION", fontBold, brush, new RectangleF(margenIzq, y, anchoContenido * 0.65f, lineaH), fmtNear);
                    g.DrawString("DEVUELTO", fontBold, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtFar);
                    y += lineaH + 2f;
                    DrawSeparator('.');

                    int maxCharsDesc = is58mm ? 32 : 42;
                    foreach (var item in venta.DetalleVentas)
                    {
                        string rawName = item.Producto?.Nombre ?? "Producto";
                        string desc = SanitizeThermalText(rawName);
                        if (desc.Length > maxCharsDesc)
                        {
                            desc = desc.Substring(0, maxCharsDesc);
                        }

                        var descSize = g.MeasureString(desc, fontBold, (int)anchoContenido, fmtNear);
                        float descH = Math.Max(lineaH, descSize.Height);

                        // Línea 1: Nombre del producto
                        g.DrawString(desc, fontBold, brush, new RectangleF(margenIzq, y, anchoContenido, descH), fmtNear);
                        y += descH + 1f;

                        // Línea 2: Cantidad x P.U. a la izquierda y Subtotal devuelto a la derecha
                        string cantPu = $"  {item.Cantidad:G29} x ${item.Precio:F2}";
                        g.DrawString(cantPu, fontRegular, brush, new RectangleF(margenIzq, y, anchoContenido * 0.60f, lineaH), fmtNear);
                        g.DrawString($"-${item.Subtotal:F2}", fontBold, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtFar);
                        y += lineaH + 3f;
                    }

                    DrawSeparator('-');

                    // 5. Totales Financieros Reembolsados
                    void DrawTotalRow(string label, string val, GdiFont f)
                    {
                        float h = f.GetHeight(g) + 2f;
                        g.DrawString(label, f, brush, new RectangleF(margenIzq, y, anchoContenido * 0.60f, h), fmtNear);
                        g.DrawString(val, f, brush, new RectangleF(margenIzq, y, anchoContenido, h), fmtFar);
                        y += h + 2f;
                    }

                    DrawTotalRow("SUBTOTAL DEV:", $"-${venta.Subtotal:F2}", fontRegular);
                    DrawTotalRow("IVA DEV (13%):", $"-${venta.Impuesto:F2}", fontRegular);
                    DrawTotalRow("TOTAL REEMBOLSADO:", $"-${venta.Total:F2}", fontTotals);

                    DrawSeparator('.');
                    DrawTotalRow("METODO ORIG:", SanitizeThermalText(venta.MetodoPago), fontRegular);
                    DrawSeparator('-');

                    // 6. Leyenda de Inventario
                    DrawCenter("** MERCANCIA DEVUELTA A INVENTARIO **", fontBold);
                    DrawCenter("Stock fisico restablecido correctamente.", fontSmall);
                    DrawSeparator('-');
                    y += lineaH * 1.5f;

                    // 7. Firmas de Conformidad
                    string lineaFirma = "____________________________";
                    DrawCenter(lineaFirma, fontRegular);
                    DrawCenter("FIRMA CLIENTE CONFORME", fontSmall);
                    y += lineaH * 1.5f;

                    DrawCenter(lineaFirma, fontRegular);
                    DrawCenter("FIRMA CAJERO / AUTORIZADO", fontSmall);
                    y += lineaH;

                    DrawCenter("Coreas ERP · Control de Devoluciones", fontSmall);

                    // 8. Delimitador visual final
                    DrawCenter("- - - - - - - - - - - -", fontSmall);
                    y += 30f;
                    e.HasMorePages = false;
                };

                doc.Print();

                Thread.Sleep(150);
                SendPaperFeedAndDrawerKick(printerName, openDrawer: true, extraLines: 6, cutPaper: config?.CortarPapel ?? true);

                return (true, $"Comprobante de devolución impreso correctamente en '{printerName}'.");
            }
            catch (Exception ex)
            {
                return (false, $"Error al imprimir comprobante de devolución: {ex.Message}");
            }
        });
#else
        return Task.FromResult((false, "Impresión de devolución solo disponible en Windows."));
#endif
    }

    public Task<(bool Success, string Message)> PrintMermaDirectAsync(List<Merma> mermas, decimal totalCosto, string motivo, string cajero, string supervisor, ConfiguracionNegocio? config = null)
    {
#if WINDOWS
        return Task.Run<(bool Success, string Message)>(() =>
        {
            try
            {
                string printerName = !string.IsNullOrWhiteSpace(config?.NombreImpresora)
                    ? config.NombreImpresora.Trim()
                    : GetDefaultPrinterName();

                if (string.IsNullOrWhiteSpace(printerName))
                {
                    return (false, "No se detectó ninguna impresora conectada en el sistema.");
                }

                using var doc = new PrintDocument();
                doc.PrinterSettings.PrinterName = printerName;

                if (!doc.PrinterSettings.IsValid)
                {
                    return (false, $"La impresora '{printerName}' no se encuentra disponible o no es válida.");
                }

                doc.PrintController = new StandardPrintController();
                doc.DefaultPageSettings.Margins = new Margins(0, 0, 0, 0);

                doc.PrintPage += (sender, e) =>
                {
                    var g = e.Graphics;
                    if (g == null) return;

                    bool is58mm = (config?.AnchoPapelMm == 58);
                    float anchoPapelPuntos = is58mm ? 200f : 280f;
                    if (e.PageBounds.Width > 0 && e.PageBounds.Width < anchoPapelPuntos)
                    {
                        anchoPapelPuntos = e.PageBounds.Width - 4f;
                    }

                    float margenIzq = is58mm ? 8f : 12f;
                    float anchoContenido = Math.Max(140f, anchoPapelPuntos - margenIzq);

                    using var fontTitle = new GdiFont("Courier New", is58mm ? 9f : 10.5f, FontStyle.Bold);
                    using var fontSubtitle = new GdiFont("Courier New", is58mm ? 8f : 9.5f, FontStyle.Bold);
                    using var fontBold = new GdiFont("Courier New", is58mm ? 7.5f : 8.5f, FontStyle.Bold);
                    using var fontRegular = new GdiFont("Courier New", is58mm ? 7.2f : 8.2f, FontStyle.Regular);
                    using var fontSmall = new GdiFont("Courier New", is58mm ? 6.5f : 7.2f, FontStyle.Regular);
                    using var fontTotals = new GdiFont("Courier New", is58mm ? 9.5f : 11f, FontStyle.Bold);

                    GdiBrush brush = GdiBrushes.Black;
                    float y = 8f;
                    float lineaH = fontRegular.GetHeight(g) + 3f;

                    using var fmtCenter = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.Word };
                    using var fmtNear = new StringFormat { Alignment = StringAlignment.Near, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.Word };
                    using var fmtFar = new StringFormat { Alignment = StringAlignment.Far, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.None };

                    void DrawCenter(string text, GdiFont f)
                    {
                        string clean = SanitizeThermalText(text);
                        if (string.IsNullOrWhiteSpace(clean)) return;
                        var size = g.MeasureString(clean, f, (int)anchoContenido, fmtCenter);
                        float h = Math.Max(f.GetHeight(g) + 2f, size.Height);
                        g.DrawString(clean, f, brush, new RectangleF(margenIzq, y, anchoContenido, h), fmtCenter);
                        y += h + 2f;
                    }

                    void DrawSeparator(char c = '-')
                    {
                        int numChars = is58mm ? 26 : 36;
                        string sep = new string(c, numChars);
                        DrawCenter(sep, fontRegular);
                    }

                    void DrawMetaRow(string label, string val, GdiFont? fVal = null)
                    {
                        string cleanVal = SanitizeThermalText(val);
                        var f = fVal ?? fontRegular;
                        float h = f.GetHeight(g) + 2f;
                        g.DrawString($"{label} {cleanVal}", f, brush, new RectangleF(margenIzq, y, anchoContenido, h), fmtNear);
                        y += h + 1f;
                    }

                    // Encabezado
                    string nombreNegocio = config?.NombreNegocio ?? "COREAS ERP";
                    DrawCenter(nombreNegocio, fontTitle);
                    if (!string.IsNullOrWhiteSpace(config?.Direccion))
                        DrawCenter(config.Direccion, fontSmall);
                    DrawSeparator('=');

                    DrawCenter("*** SALIDA POR MERMA / GASTO ***", fontSubtitle);
                    DrawCenter("CONTROL INTERNO - VALUADO A COSTO", fontSmall);
                    DrawSeparator('-');

                    DrawMetaRow("FECHA:", DateTime.Now.ToString("dd/MM/yyyy hh:mm tt"));
                    DrawMetaRow("MOTIVO:", motivo, fontBold);
                    DrawMetaRow("CAJERO:", cajero);
                    DrawMetaRow("SUPERVISOR:", supervisor, fontBold);
                    DrawSeparator('-');

                    DrawCenter("ARTICULOS DADOS DE BAJA", fontBold);
                    DrawSeparator('.');

                    g.DrawString("CANT  DESCRIPCION", fontBold, brush, new RectangleF(margenIzq, y, anchoContenido * 0.70f, lineaH), fmtNear);
                    g.DrawString("TOTAL COSTO", fontBold, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtFar);
                    y += lineaH + 2f;
                    DrawSeparator('.');

                    foreach (var m in mermas)
                    {
                        decimal cant = m.Cantidad;
                        string nom = m.Producto?.Nombre ?? "Producto";
                        decimal costoSub = m.CostoTotal;

                        string lineaDesc = $"{cant:G29}x {nom}";
                        string cleanDesc = SanitizeThermalText(lineaDesc);
                        if (cleanDesc.Length > 24) cleanDesc = cleanDesc.Substring(0, 24);

                        g.DrawString(cleanDesc, fontRegular, brush, new RectangleF(margenIzq, y, anchoContenido * 0.70f, lineaH), fmtNear);
                        g.DrawString($"${costoSub:N2}", fontRegular, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtFar);
                        y += lineaH + 1f;
                    }

                    DrawSeparator('=');
                    g.DrawString("TOTAL PERDIDA A COSTO:", fontTotals, brush, new RectangleF(margenIzq, y, anchoContenido * 0.65f, fontTotals.GetHeight(g) + 2f), fmtNear);
                    g.DrawString($"${totalCosto:N2}", fontTotals, brush, new RectangleF(margenIzq, y, anchoContenido, fontTotals.GetHeight(g) + 2f), fmtFar);
                    y += fontTotals.GetHeight(g) + 15f;

                    // Firmas
                    DrawCenter("____________________________", fontRegular);
                    DrawCenter($"AUTORIZO: {supervisor.ToUpperInvariant()}", fontSmall);
                    y += 10f;
                    DrawCenter("____________________________", fontRegular);
                    DrawCenter($"ENTREGO: {cajero.ToUpperInvariant()}", fontSmall);
                    y += 20f;

                    e.HasMorePages = false;
                };

                doc.Print();

                Thread.Sleep(150);
                SendPaperFeedAndDrawerKick(printerName, openDrawer: false, extraLines: 6, cutPaper: config?.CortarPapel ?? true);

                return (true, $"Comprobante de merma impreso correctamente en '{printerName}'.");
            }
            catch (Exception ex)
            {
                return (false, $"Error al imprimir comprobante de merma: {ex.Message}");
            }
        });
#else
        return Task.FromResult((false, "Impresión directa solo disponible en Windows."));
#endif
    }

    public Task<(bool Success, string Message)> PrintMovimientoCajaDirectAsync(
        MovimientoCaja movimiento,
        string nombreCajero,
        string? nombreSupervisor,
        ConfiguracionNegocio? config = null)
    {
#if WINDOWS
        return Task.Run<(bool Success, string Message)>(() =>
        {
            try
            {
                if (movimiento == null)
                {
                    return (false, "El movimiento de caja no es válido.");
                }

                string printerName = !string.IsNullOrWhiteSpace(config?.NombreImpresora)
                    ? config.NombreImpresora.Trim()
                    : GetDefaultPrinterName();

                if (string.IsNullOrWhiteSpace(printerName))
                {
                    return (false, "No se detectó ninguna impresora conectada en el sistema.");
                }

                using var doc = new PrintDocument();
                doc.PrinterSettings.PrinterName = printerName;

                if (!doc.PrinterSettings.IsValid)
                {
                    return (false, $"La impresora '{printerName}' no se encuentra disponible o no es válida.");
                }

                doc.PrintController = new StandardPrintController();
                doc.DefaultPageSettings.Margins = new Margins(0, 0, 0, 0);

                doc.PrintPage += (sender, e) =>
                {
                    var g = e.Graphics;
                    if (g == null) return;

                    bool is58mm = (config?.AnchoPapelMm == 58);
                    float anchoContenido = is58mm ? 180f : 260f;
                    float margenIzq = 5f;
                    float y = 5f;

                    using var fontTitle = new GdiFont("Courier New", is58mm ? 9f : 10f, FontStyle.Bold);
                    using var fontSubtitle = new GdiFont("Courier New", is58mm ? 8.5f : 9.5f, FontStyle.Bold);
                    using var fontRegular = new GdiFont("Courier New", is58mm ? 7.5f : 8.5f, FontStyle.Regular);
                    using var fontBold = new GdiFont("Courier New", is58mm ? 7.5f : 8.5f, FontStyle.Bold);
                    using var fontSmall = new GdiFont("Courier New", is58mm ? 6.5f : 7.5f, FontStyle.Regular);
                    using var fontTotals = new GdiFont("Courier New", is58mm ? 9.5f : 11f, FontStyle.Bold);
                    using var brush = new SolidBrush(System.Drawing.Color.Black);

                    using var fmtCenter = new StringFormat { Alignment = StringAlignment.Center };
                    using var fmtNear = new StringFormat { Alignment = StringAlignment.Near };
                    using var fmtFar = new StringFormat { Alignment = StringAlignment.Far };

                    float lineaH = fontRegular.GetHeight(g) + 2f;

                    void DrawCenter(string text, GdiFont f)
                    {
                        if (string.IsNullOrWhiteSpace(text)) return;
                        string clean = SanitizeThermalText(text);
                        g.DrawString(clean, f, brush, new RectangleF(margenIzq, y, anchoContenido, f.GetHeight(g) + 2f), fmtCenter);
                        y += f.GetHeight(g) + 2f;
                    }

                    void DrawSeparator(char c = '-')
                    {
                        int charCount = is58mm ? 32 : 44;
                        g.DrawString(new string(c, charCount), fontSmall, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtNear);
                        y += lineaH - 1f;
                    }

                    void DrawMetaRow(string label, string val, GdiFont? f = null)
                    {
                        f ??= fontRegular;
                        string cleanVal = SanitizeThermalText(val);
                        g.DrawString($"{label} {cleanVal}", f, brush, new RectangleF(margenIzq, y, anchoContenido, f.GetHeight(g) + 2f), fmtNear);
                        y += f.GetHeight(g) + 2f;
                    }

                    // 1. Encabezado de Empresa
                    string nombreNegocio = config?.NombreNegocio ?? "COREAS ERP";
                    DrawCenter(nombreNegocio, fontTitle);
                    if (!string.IsNullOrWhiteSpace(config?.Propietario))
                        DrawCenter(config.Propietario, fontSmall);
                    if (!string.IsNullOrWhiteSpace(config?.Direccion))
                        DrawCenter(config.Direccion, fontSmall);
                    if (!string.IsNullOrWhiteSpace(config?.Telefono))
                        DrawCenter($"TEL: {config.Telefono}", fontSmall);
                    DrawSeparator('=');

                    // 2. Título del Documento
                    string tituloDoc = movimiento.Tipo switch
                    {
                        "Retiro" => "*** RETIRO DE EFECTIVO ***",
                        "Gasto" => "*** SALIDA POR GASTO ***",
                        "Ingreso" => "*** ENTRADA DE EFECTIVO ***",
                        _ => "*** MOVIMIENTO DE CAJA ***"
                    };
                    DrawCenter(tituloDoc, fontSubtitle);
                    DrawCenter("CONTROL INTERNO DE CAJA", fontSmall);
                    DrawSeparator('-');

                    // 3. Metadatos de Auditoría
                    DrawMetaRow("FOLIO MOV:", $"#MOV-{movimiento.IdMovimiento:D6}", fontBold);
                    if (movimiento.IdCorte.HasValue)
                        DrawMetaRow("TURNO CAJA:", $"CC-{movimiento.IdCorte.Value:D5}");
                    DrawMetaRow("FECHA/HORA:", movimiento.FechaHora.ToString("dd/MM/yyyy hh:mm tt"));
                    DrawMetaRow("TIPO OPERACION:", movimiento.Tipo.ToUpper(), fontBold);
                    DrawMetaRow("CAJERO:", nombreCajero);
                    if (!string.IsNullOrWhiteSpace(nombreSupervisor))
                        DrawMetaRow("AUTORIZADO POR:", nombreSupervisor, fontBold);
                    DrawSeparator('-');

                    // 4. Monto Destacado
                    string etiquetaMonto = movimiento.Tipo == "Retiro" ? "MONTO RETIRADO:" : (movimiento.Tipo == "Gasto" ? "MONTO GASTO:" : "TOTAL MONTO:");
                    g.DrawString(etiquetaMonto, fontTotals, brush, new RectangleF(margenIzq, y, anchoContenido * 0.58f, fontTotals.GetHeight(g) + 4f), fmtNear);
                    g.DrawString($"${movimiento.Monto:N2}", fontTotals, brush, new RectangleF(margenIzq, y, anchoContenido, fontTotals.GetHeight(g) + 4f), fmtFar);
                    y += fontTotals.GetHeight(g) + 6f;
                    DrawSeparator('-');

                    // 5. Justificación / Concepto
                    DrawCenter("CONCEPTO / JUSTIFICACION", fontBold);
                    string motivoLimpio = SanitizeThermalText(movimiento.Motivo);
                    var sizeMotivo = g.MeasureString(motivoLimpio, fontRegular, (int)anchoContenido);
                    g.DrawString(motivoLimpio, fontRegular, brush, new RectangleF(margenIzq, y, anchoContenido, sizeMotivo.Height + 4f), fmtNear);
                    y += sizeMotivo.Height + 18f;

                    // 6. Firmas de Control Interno
                    DrawCenter("____________________________", fontRegular);
                    DrawCenter($"ENTREGO: {SanitizeThermalText(nombreCajero).ToUpper()}", fontSmall);
                    y += 14f;
                    DrawCenter("____________________________", fontRegular);
                    string firmaRecibe = !string.IsNullOrWhiteSpace(nombreSupervisor) ? nombreSupervisor : "ADMINISTRACION / RECEPTOR";
                    DrawCenter($"RECIBIO / AUTORIZO: {SanitizeThermalText(firmaRecibe).ToUpper()}", fontSmall);
                    y += 10f;
                    DrawSeparator('=');

                    DrawCenter("Comprobante de control interno de caja.", fontSmall);
                    DrawCenter("Conserve este ticket para arqueo de turno.", fontSmall);
                    y += 20f;

                    e.HasMorePages = false;
                };

                doc.Print();

                Thread.Sleep(150);
                SendPaperFeedAndDrawerKick(printerName, openDrawer: false, extraLines: 6, cutPaper: config?.CortarPapel ?? true);

                return (true, $"Comprobante de {movimiento.Tipo.ToLower()} impreso correctamente en '{printerName}'.");
            }
            catch (Exception ex)
            {
                return (false, $"Error al imprimir comprobante de movimiento de caja: {ex.Message}");
            }
        });
#else
        return Task.FromResult((false, "Impresión directa solo disponible en Windows."));
#endif
    }

    public Task<(bool Success, string Message)> PrintPriceTagsDirectAsync(List<CambioPrecio> items, ConfiguracionNegocio? config = null)
    {
#if WINDOWS
        return Task.Run<(bool Success, string Message)>(() =>
        {
            try
            {
                if (items == null || !items.Any())
                {
                    return (false, "No hay artículos seleccionados para imprimir etiquetas de precio.");
                }

                string printerName = !string.IsNullOrWhiteSpace(config?.NombreImpresora)
                    ? config.NombreImpresora.Trim()
                    : GetDefaultPrinterName();

                if (string.IsNullOrWhiteSpace(printerName))
                {
                    return (false, "No se detectó ninguna impresora conectada en el sistema.");
                }

                using var doc = new PrintDocument();
                doc.PrinterSettings.PrinterName = printerName;

                if (!doc.PrinterSettings.IsValid)
                {
                    return (false, $"La impresora '{printerName}' no se encuentra disponible o no es válida.");
                }

                doc.PrintController = new StandardPrintController();
                doc.DefaultPageSettings.Margins = new Margins(0, 0, 0, 0);

                doc.PrintPage += (sender, e) =>
                {
                    var g = e.Graphics;
                    if (g == null) return;

                    bool is58mm = (config?.AnchoPapelMm == 58);
                    if (config?.AnchoPapelMm == 80)
                    {
                        is58mm = false;
                    }
                    else if (config?.AnchoPapelMm == 58)
                    {
                        is58mm = true;
                    }
                    else
                    {
                        string pUpper = printerName.ToUpperInvariant();
                        if (pUpper.Contains("58") || pUpper.Contains("MINI") || pUpper.Contains("ZJ") || pUpper.Contains("POS58") || pUpper.Contains("MPT"))
                        {
                            is58mm = true;
                        }
                        else if (e.PageBounds.Width > 0 && e.PageBounds.Width <= 240)
                        {
                            is58mm = true;
                        }
                    }

                    int anchoMm = is58mm ? 58 : 80;
                    float anchoPapelPuntos = is58mm ? 200f : 280f;
                    if (e.PageBounds.Width > 0 && e.PageBounds.Width < anchoPapelPuntos)
                    {
                        anchoPapelPuntos = e.PageBounds.Width - 4f;
                    }

                    float margenIzq = is58mm ? 8f : 12f;
                    float anchoContenido = Math.Max(140f, anchoPapelPuntos - margenIzq);

                    using var fontHeader = new GdiFont("Courier New", is58mm ? 8.5f : 9.5f, FontStyle.Bold);
                    using var fontProdName = new GdiFont("Courier New", is58mm ? 9f : 10.5f, FontStyle.Bold);
                    using var fontRegular = new GdiFont("Courier New", is58mm ? 7.2f : 8.2f, FontStyle.Regular);
                    using var fontSmall = new GdiFont("Courier New", is58mm ? 6.5f : 7.2f, FontStyle.Regular);
                    using var fontBigPrice = new GdiFont("Courier New", is58mm ? 14f : 17f, FontStyle.Bold);
                    using var fontOldPrice = new GdiFont("Courier New", is58mm ? 8f : 9f, FontStyle.Strikeout);

                    GdiBrush brush = GdiBrushes.Black;
                    float y = 10f;
                    float lineaH = fontRegular.GetHeight(g) + 3f;

                    using var fmtCenter = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.Word };
                    using var fmtNear = new StringFormat { Alignment = StringAlignment.Near, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.Word };
                    using var fmtFar = new StringFormat { Alignment = StringAlignment.Far, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.None };

                    void DrawCenter(string text, GdiFont f)
                    {
                        string clean = SanitizeThermalText(text);
                        if (string.IsNullOrWhiteSpace(clean)) return;
                        var size = g.MeasureString(clean, f, (int)anchoContenido, fmtCenter);
                        float h = Math.Max(f.GetHeight(g) + 2f, size.Height);
                        g.DrawString(clean, f, brush, new RectangleF(margenIzq, y, anchoContenido, h), fmtCenter);
                        y += h + 2f;
                    }

                    int maxCharsDesc = is58mm ? 30 : 40;
                    string nombreNegocio = config?.NombreNegocio ?? "COREAS ERP";

                    foreach (var item in items)
                    {
                        bool esRebaja = item.PrecioVentaAnterior > 0 
                                     && item.PrecioVentaNuevo < item.PrecioVentaAnterior 
                                     && ((item.PrecioVentaAnterior - item.PrecioVentaNuevo) / item.PrecioVentaAnterior * 100m) >= 10m;

                        decimal diff = item.PrecioVentaAnterior - item.PrecioVentaNuevo;
                        decimal pct = esRebaja ? Math.Round((diff / item.PrecioVentaAnterior) * 100m, 0) : 0m;

                        // Cabecera de la etiqueta
                        if (esRebaja)
                        {
                            DrawCenter("*** ¡GRAN REBAJA! ***", fontHeader);
                            DrawCenter($"¡Ahorras ${diff:F2} (-{pct:0}%)!", fontSmall);
                        }
                        else
                        {
                            DrawCenter(nombreNegocio, fontHeader);
                            DrawCenter("ETIQUETA DE PRECIO", fontSmall);
                        }

                        // Nombre del Producto
                        string rawName = item.Producto?.Nombre ?? "Producto";
                        string desc = SanitizeThermalText(rawName);
                        if (desc.Length > maxCharsDesc * 2)
                        {
                            desc = desc.Substring(0, maxCharsDesc * 2);
                        }

                        var sizeDesc = g.MeasureString(desc, fontProdName, (int)anchoContenido, fmtCenter);
                        float hDesc = Math.Max(fontProdName.GetHeight(g) + 2f, sizeDesc.Height);
                        g.DrawString(desc, fontProdName, brush, new RectangleF(margenIzq, y, anchoContenido, hDesc), fmtCenter);
                        y += hDesc + 2f;

                        // SKU y Fecha
                        string sku = $"SKU: {item.Producto?.Codigo ?? "-"}";
                        string fActual = DateTime.Now.ToString("dd/MM/yyyy");
                        g.DrawString(sku, fontSmall, brush, new RectangleF(margenIzq, y, anchoContenido * 0.60f, lineaH), fmtNear);
                        g.DrawString(fActual, fontSmall, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtFar);
                        y += lineaH + 3f;

                        // Precios
                        if (esRebaja)
                        {
                            string antesTxt = $"Antes: ${item.PrecioVentaAnterior:F2}";
                            DrawCenter(antesTxt, fontOldPrice);
                            DrawCenter($"${item.PrecioVentaNuevo:F2}", fontBigPrice);
                        }
                        else
                        {
                            DrawCenter($"${item.PrecioVentaNuevo:F2}", fontBigPrice);
                        }

                        y += 4f;

                        // Línea de corte para góndola / fleje
                        string flejeLine = is58mm ? "- - [ CORTAR ] - -" : "- - - [ CORTAR FLEJE ] - - -";
                        DrawCenter(flejeLine, fontSmall);
                        y += 18f; // Espacio entre etiquetas
                    }

                    // Alimentación de papel al final
                    y += 240f;
                    g.DrawString(" ", fontSmall, brush, margenIzq, y);
                    e.HasMorePages = false;
                };

                doc.Print();
                return (true, $"{items.Count} etiquetas de precio enviadas a '{printerName}'.");
            }
            catch (Exception ex)
            {
                return (false, $"Error al imprimir etiquetas: {ex.Message}");
            }
        });
#else
        return Task.FromResult((false, "Impresión directa de etiquetas solo disponible en Windows."));
#endif
    }

    public Task<(bool Success, string Message)> PrintTestReceiptAsync(string? printerName, int paperWidthMm, ConfiguracionNegocio? config = null)
    {
#if WINDOWS
        return Task.Run<(bool Success, string Message)>(() =>
        {
            try
            {
                string targetPrinter = !string.IsNullOrWhiteSpace(printerName)
                    ? printerName.Trim()
                    : (!string.IsNullOrWhiteSpace(config?.NombreImpresora) ? config.NombreImpresora.Trim() : GetDefaultPrinterName());

                if (string.IsNullOrWhiteSpace(targetPrinter))
                {
                    return (false, "No se encontró ninguna impresora conectada para la prueba.");
                }

                using var doc = new PrintDocument();
                doc.PrinterSettings.PrinterName = targetPrinter;

                if (!doc.PrinterSettings.IsValid)
                {
                    return (false, $"La impresora '{targetPrinter}' no es válida o está fuera de línea.");
                }

                doc.PrintController = new StandardPrintController();
                doc.DefaultPageSettings.Margins = new Margins(0, 0, 0, 0);

                doc.PrintPage += (sender, e) =>
                {
                    var g = e.Graphics;
                    if (g == null) return;

                    bool is58mm = (paperWidthMm is 58) || (config?.AnchoPapelMm is 58);
                    if (config?.AnchoPapelMm == 80 || paperWidthMm == 80)
                    {
                        is58mm = false;
                    }
                    else if (config?.AnchoPapelMm == 58 || paperWidthMm == 58)
                    {
                        is58mm = true;
                    }
                    else
                    {
                        string pUpper = targetPrinter.ToUpperInvariant();
                        if (pUpper.Contains("58") || pUpper.Contains("MINI") || pUpper.Contains("ZJ") || pUpper.Contains("POS58") || pUpper.Contains("MPT"))
                        {
                            is58mm = true;
                        }
                        else if (e.PageBounds.Width > 0 && e.PageBounds.Width <= 240)
                        {
                            is58mm = true;
                        }
                    }

                    int anchoMm = is58mm ? 58 : 80;
                    float anchoPapelPuntos = is58mm ? 200f : 280f;
                    if (e.PageBounds.Width > 0 && e.PageBounds.Width < anchoPapelPuntos)
                    {
                        anchoPapelPuntos = e.PageBounds.Width - 4f;
                    }

                    float margenIzq = is58mm ? 8f : 12f;
                    float anchoContenido = Math.Max(140f, anchoPapelPuntos - margenIzq);

                    using var fontTitle = new GdiFont("Courier New", is58mm ? 9f : 10.5f, FontStyle.Bold);
                    using var fontBold = new GdiFont("Courier New", is58mm ? 7.5f : 8.5f, FontStyle.Bold);
                    using var fontRegular = new GdiFont("Courier New", is58mm ? 7.2f : 8.2f, FontStyle.Regular);
                    using var fontSmall = new GdiFont("Courier New", is58mm ? 6.5f : 7.2f, FontStyle.Regular);

                    GdiBrush brush = GdiBrushes.Black;
                    float y = 8f;
                    float lineaH = fontRegular.GetHeight(g) + 3f;

                    using var fmtCenter = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.Word };
                    using var fmtNear = new StringFormat { Alignment = StringAlignment.Near, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.Word };

                    void DrawCenter(string text, GdiFont f)
                    {
                        string clean = SanitizeThermalText(text);
                        if (string.IsNullOrWhiteSpace(clean)) return;
                        var size = g.MeasureString(clean, f, (int)anchoContenido, fmtCenter);
                        float h = Math.Max(f.GetHeight(g) + 2f, size.Height);
                        g.DrawString(clean, f, brush, new RectangleF(margenIzq, y, anchoContenido, h), fmtCenter);
                        y += h + 2f;
                    }

                    void DrawSeparator(char c = '=')
                    {
                        int numChars = is58mm ? 26 : 36;
                        string sep = new string(c, numChars);
                        DrawCenter(sep, fontRegular);
                    }

                    DrawCenter("PRUEBA DE IMPRESION TERMICA", fontTitle);
                    DrawCenter(config?.NombreNegocio ?? "COREAS ERP", fontBold);
                    string fechaPrueba = $"{DateTime.Now:dd/MM/yyyy} {DateTime.Now.ToString("hh:mm:ss tt", System.Globalization.CultureInfo.InvariantCulture)}";
                    DrawCenter(fechaPrueba, fontSmall);
                    DrawSeparator();

                    void DrawRow(string label, string val)
                    {
                        string cleanVal = SanitizeThermalText(val);
                        float h = fontRegular.GetHeight(g) + 2f;
                        g.DrawString($"{label} {cleanVal}", fontRegular, brush, new RectangleF(margenIzq, y, anchoContenido, h), fmtNear);
                        y += h + 2f;
                    }

                    DrawRow("IMPRESORA:", targetPrinter);
                    DrawRow("ANCHO PAPEL:", $"{anchoMm} mm ({(is58mm ? "Compacto" : "Estandar")})");
                    DrawRow("MARGENES:", "Ajuste Termico Directo");

                    DrawSeparator('-');
                    DrawCenter("|<- MARGEN IZQ - DER ->|", fontSmall);
                    DrawSeparator('-');

                    DrawCenter("!Configuracion exitosa!", fontBold);
                    DrawCenter("Tickets rapidos y sin distorsion.", fontSmall);

                    DrawSeparator();
                    DrawCenter("Coreas ERP - Punto de Venta", fontSmall);

                    // Delimitador visual final
                    DrawCenter("- - - - - - - - - - - -", fontSmall);
                    y += 30f;
                    e.HasMorePages = false;
                };

                doc.Print();

                Thread.Sleep(150);
                SendPaperFeedAndDrawerKick(targetPrinter, openDrawer: true, extraLines: 6, cutPaper: config?.CortarPapel ?? true);

                return (true, $"Prueba de impresión enviada exitosamente a '{targetPrinter}'.");
            }
            catch (Exception ex)
            {
                return (false, $"Error al realizar prueba de impresión: {ex.Message}");
            }
        });
#else
        return Task.FromResult((false, "Prueba de impresión solo disponible en Windows."));
#endif
    }

    public async Task PrintReceiptAsync(IJSRuntime jsRuntime, string elementId = "thermal-receipt")
    {
        try
        {
            await jsRuntime.InvokeVoidAsync("coreasPrintReceipt", elementId);
        }
        catch (Exception)
        {
            await jsRuntime.InvokeVoidAsync("window.print");
        }
    }

    public async Task PrintInvoiceLetterAsync(IJSRuntime jsRuntime, string elementId = "letter-invoice")
    {
        try
        {
            await jsRuntime.InvokeVoidAsync("coreasPrintInvoiceLetter", elementId);
        }
        catch (Exception)
        {
            await jsRuntime.InvokeVoidAsync("window.print");
        }
    }

    public Task PrintCorteDirectAsync(ResumenCorteDto resumen, ConfiguracionNegocio? config = null)
    {
#if WINDOWS
        return Task.Run(() =>
        {
            try
            {
                string printerName = !string.IsNullOrWhiteSpace(config?.NombreImpresora)
                    ? config.NombreImpresora.Trim()
                    : GetDefaultPrinterName();

                if (string.IsNullOrWhiteSpace(printerName))
                    return;

                using var doc = new PrintDocument();
                doc.PrinterSettings.PrinterName = printerName;
                if (!doc.PrinterSettings.IsValid) return;

                doc.PrintController = new StandardPrintController();
                doc.DefaultPageSettings.Margins = new Margins(0, 0, 0, 0);

                doc.PrintPage += (sender, e) =>
                {
                    var g = e.Graphics;
                    if (g == null) return;

                    bool is58mm = (config?.AnchoPapelMm is 58);
                    if (config?.AnchoPapelMm == 80)
                    {
                        is58mm = false;
                    }
                    else if (config?.AnchoPapelMm == 58)
                    {
                        is58mm = true;
                    }
                    else
                    {
                        string pUpper = printerName.ToUpperInvariant();
                        if (pUpper.Contains("58") || pUpper.Contains("MINI") || pUpper.Contains("ZJ") || pUpper.Contains("POS58") || pUpper.Contains("MPT"))
                        {
                            is58mm = true;
                        }
                        else if (e.PageBounds.Width > 0 && e.PageBounds.Width <= 240)
                        {
                            is58mm = true;
                        }
                    }

                    int anchoMm = is58mm ? 58 : 80;
                    float anchoPapelPuntos = is58mm ? 200f : 280f;
                    if (e.PageBounds.Width > 0 && e.PageBounds.Width < anchoPapelPuntos)
                    {
                        anchoPapelPuntos = e.PageBounds.Width - 4f;
                    }

                    float margenIzq = is58mm ? 8f : 12f;
                    float anchoContenido = Math.Max(140f, anchoPapelPuntos - margenIzq);

                    using var fontTitle = new GdiFont("Courier New", is58mm ? 9f : 11f, FontStyle.Bold);
                    using var fontSubtitle = new GdiFont("Courier New", is58mm ? 8f : 9.5f, FontStyle.Bold);
                    using var fontBold = new GdiFont("Courier New", is58mm ? 7.5f : 8.5f, FontStyle.Bold);
                    using var fontRegular = new GdiFont("Courier New", is58mm ? 7.2f : 8.5f, FontStyle.Regular);
                    using var fontSmall = new GdiFont("Courier New", is58mm ? 6.5f : 7.2f, FontStyle.Regular);

                    GdiBrush brush = GdiBrushes.Black;
                    float y = 8f;
                    float lineaH = fontRegular.GetHeight(g) + 3f;

                    using var fmtCenter = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.Word };
                    using var fmtNear = new StringFormat { Alignment = StringAlignment.Near, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.Word };
                    using var fmtFar = new StringFormat { Alignment = StringAlignment.Far, LineAlignment = StringAlignment.Near, Trimming = StringTrimming.None };

                    void ImprimirLineaSeparador(char c = '-')
                    {
                        int numChars = is58mm ? 26 : 36;
                        string sep = new string(c, numChars);
                        var size = g.MeasureString(sep, fontRegular, (int)anchoContenido, fmtCenter);
                        float h = Math.Max(lineaH, size.Height);
                        g.DrawString(sep, fontRegular, brush, new RectangleF(margenIzq, y, anchoContenido, h), fmtCenter);
                        y += h + 2f;
                    }

                    void DrawRow(string label, string val, GdiFont? fLabel = null, GdiFont? fVal = null)
                    {
                        var fl = fLabel ?? fontRegular;
                        var fv = fVal ?? fontRegular;
                        float h = Math.Max(fl.GetHeight(g), fv.GetHeight(g)) + 3f;
                        string cleanLbl = SanitizeThermalText(label);
                        g.DrawString(cleanLbl, fl, brush, new RectangleF(margenIzq, y, anchoContenido * 0.60f, h), fmtNear);
                        g.DrawString(val, fv, brush, new RectangleF(margenIzq, y, anchoContenido, h), fmtFar);
                        y += h + 2f;
                    }

                    void DrawCenterText(string text, GdiFont f)
                    {
                        string clean = SanitizeThermalText(text);
                        if (string.IsNullOrWhiteSpace(clean)) return;
                        var size = g.MeasureString(clean, f, (int)anchoContenido, fmtCenter);
                        float h = Math.Max(f.GetHeight(g) + 2f, size.Height);
                        g.DrawString(clean, f, brush, new RectangleF(margenIzq, y, anchoContenido, h), fmtCenter);
                        y += h + 2f;
                    }

                    // Encabezado
                    DrawCenterText(resumen.NombreEmpresa.ToUpper(), fontTitle);

                    string titulo = resumen.TipoCorte == "CORTE Z" ? "*** CORTE Z (CIERRE FINAL) ***" : "*** CORTE X (ARQUEO PARCIAL) ***";
                    DrawCenterText(titulo, fontSubtitle);

                    ImprimirLineaSeparador('=');

                    g.DrawString($"Corte #: CC-{resumen.IdCorte:D5}", fontBold, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtNear);
                    y += lineaH + 2f;
                    g.DrawString($"Cajero:  {resumen.NombreCajero}", fontRegular, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtNear);
                    y += lineaH + 2f;
                    string fApertura = $"{resumen.FechaApertura:dd/MM/yyyy} {resumen.FechaApertura.ToString("hh:mm tt", System.Globalization.CultureInfo.InvariantCulture)}";
                    g.DrawString($"Apertura: {fApertura}", fontSmall, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtNear);
                    y += lineaH + 2f;
                    string fCorte = $"{resumen.FechaCorte:dd/MM/yyyy} {resumen.FechaCorte.ToString("hh:mm tt", System.Globalization.CultureInfo.InvariantCulture)}";
                    g.DrawString($"Corte:    {fCorte}", fontSmall, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtNear);
                    y += lineaH + 2f;

                    ImprimirLineaSeparador('-');

                    // 1. Resumen por Documento
                    g.DrawString("DOCUMENTOS EMITIDOS", fontBold, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtNear);
                    y += lineaH + 3f;

                    foreach (var docItem in resumen.Documentos)
                    {
                        string txtTipo = docItem.TipoComprobante;
                        if (txtTipo.Length > 15) txtTipo = txtTipo.Substring(0, 15);
                        string info = docItem.EsInformativo ? " (Inf)" : "";
                        DrawRow($"{txtTipo}{info} ({docItem.Cantidad})", $"${docItem.MontoTotal:F2}", fontRegular, fontBold);
                    }

                    if (resumen.CantidadAnticipos > 0)
                    {
                        g.DrawString($"  -> Efectivo: +${resumen.AnticiposCobradoEfectivo:F2}", fontSmall, brush, new RectangleF(margenIzq + 4, y, anchoContenido - 4, lineaH), fmtNear);
                        y += lineaH + 2f;
                        g.DrawString($"  -> Saldo CXC: ${resumen.AnticiposSaldoCXC:F2}", fontSmall, brush, new RectangleF(margenIzq + 4, y, anchoContenido - 4, lineaH), fmtNear);
                        y += lineaH + 2f;
                    }

                    ImprimirLineaSeparador('-');

                    // 2. Formas de Pago
                    g.DrawString("DESGLOSE FORMAS DE PAGO", fontBold, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtNear);
                    y += lineaH + 3f;
                    DrawRow("Ventas Efectivo:", $"${resumen.TotalVentasEfectivo:F2}");

                    if (resumen.TotalVentasTarjetas > 0)
                        DrawRow("Tarjetas:", $"${resumen.TotalVentasTarjetas:F2}");
                    if (resumen.TotalVentasTransferencias > 0)
                        DrawRow("Transferencias:", $"${resumen.TotalVentasTransferencias:F2}");
                    if (resumen.TotalVentasCreditoCXC > 0)
                        DrawRow("Crédito / CXC:", $"${resumen.TotalVentasCreditoCXC:F2}");

                    ImprimirLineaSeparador('-');

                    // 3. Movimientos de Caja
                    g.DrawString("MOVIMIENTOS DE CAJA", fontBold, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtNear);
                    y += lineaH + 3f;
                    DrawRow("Fondo Inicial:", $"${resumen.FondoInicial:F2}");
                    DrawRow("(+) Ventas Efectivo:", $"${resumen.TotalVentasEfectivo:F2}");

                    if (resumen.TotalAbonosEfectivo > 0)
                        DrawRow("(+) Abonos CXC:", $"${resumen.TotalAbonosEfectivo:F2}");
                    if (resumen.TotalIngresosExtras > 0)
                        DrawRow("(+) Ingresos Extras:", $"${resumen.TotalIngresosExtras:F2}");
                    if (resumen.TotalRetiros > 0)
                        DrawRow("(-) Retiros:", $"-${resumen.TotalRetiros:F2}");
                    if (resumen.TotalGastos > 0)
                        DrawRow("(-) Gastos:", $"-${resumen.TotalGastos:F2}");
                    if (resumen.TotalDevolucionesEfectivo > 0)
                        DrawRow("(-) Devoluciones:", $"-${resumen.TotalDevolucionesEfectivo:F2}");

                    ImprimirLineaSeparador('=');

                    // 4. Balance de Efectivo en Gaveta
                    DrawRow("EFECTIVO ESPERADO:", $"${resumen.EfectivoEsperado:F2}", fontBold, fontSubtitle);

                    if (resumen.EfectivoContado.HasValue)
                    {
                        DrawRow("EFECTIVO CONTADO:", $"${resumen.EfectivoContado.Value:F2}", fontBold, fontSubtitle);

                        decimal diff = resumen.Diferencia ?? 0m;
                        string diffTxt = diff == 0 ? "$0.00 (CUADRADA)" : (diff > 0 ? $"+${diff:F2} (SOBRANTE)" : $"-${Math.Abs(diff):F2} (FALTANTE)");
                        DrawRow("DIFERENCIA:", diffTxt, fontBold, fontBold);

                        if (resumen.DesgloseFisico != null)
                        {
                            g.DrawString($"Billetes: ${resumen.DesgloseFisico.TotalBilletes:F2} | Monedas: ${resumen.DesgloseFisico.TotalMonedas:F2}", fontSmall, brush, new RectangleF(margenIzq, y, anchoContenido, lineaH), fmtNear);
                            y += lineaH + 2f;
                        }
                    }

                    ImprimirLineaSeparador('-');
                    y += lineaH * 1.5f;

                    // Firmas
                    string lineaFirma = "____________________________";
                    DrawCenterText(lineaFirma, fontRegular);
                    DrawCenterText("FIRMA DEL CAJERO", fontSmall);
                    y += lineaH + 2f;

                    DrawCenterText(lineaFirma, fontRegular);
                    DrawCenterText("FIRMA SUPERVISOR / AUDITOR", fontSmall);
                    y += lineaH + 2f;

                    DrawCenterText("Coreas ERP - Control de Caja", fontSmall);

                    // Delimitador visual final
                    DrawCenterText("- - - - - - - - - - - -", fontSmall);
                    y += 30f;
                    e.HasMorePages = false;
                };

                doc.Print();

                Thread.Sleep(150);
                SendPaperFeedAndDrawerKick(printerName, openDrawer: false, extraLines: 6, cutPaper: config?.CortarPapel ?? true);
            }
            catch { }
        });
#else
        return Task.CompletedTask;
#endif
    }

    public async Task PrintCorteAsync(IJSRuntime jsRuntime, string elementId = "corte-receipt")
    {
        try
        {
            await jsRuntime.InvokeVoidAsync("coreasPrintCorte", elementId);
        }
        catch (Exception)
        {
            await jsRuntime.InvokeVoidAsync("window.print");
        }
    }

    public async Task PrintPriceTagsAsync(IJSRuntime jsRuntime, string elementId, string orientation = "landscape")
    {
        try
        {
            await jsRuntime.InvokeVoidAsync("coreasPrintPriceTags", elementId, orientation);
        }
        catch (Exception)
        {
            await jsRuntime.InvokeVoidAsync("window.print");
        }
    }

    public async Task PrintMovimientoCajaAsync(IJSRuntime jsRuntime, string elementId = "movimiento-caja-receipt")
    {
        try
        {
            await jsRuntime.InvokeVoidAsync("coreasPrintReceipt", elementId);
        }
        catch (Exception)
        {
            await jsRuntime.InvokeVoidAsync("window.print");
        }
    }

    public static string SanitizeThermalText(string? text)
    {
        if (string.IsNullOrWhiteSpace(text)) return string.Empty;
        return text
            .Replace('á', 'a').Replace('é', 'e').Replace('í', 'i').Replace('ó', 'o').Replace('ú', 'u')
            .Replace('Á', 'A').Replace('É', 'E').Replace('Í', 'I').Replace('Ó', 'O').Replace('Ú', 'U')
            .Replace('ñ', 'n').Replace('Ñ', 'N')
            .Replace('ü', 'u').Replace('Ü', 'U')
            .Replace('¡', '!')
            .Replace('¿', '?');
    }

    // Secuencia universal ESC/POS para apertura de gaveta de dinero
    // Envía pulso Pin 2 (Epson/Xprinter/Bixolon) + Pin 5 + DLE DC4 realtime kick
    private static readonly byte[] DrawerKickBytes = new byte[]
    {
        0x1B, 0x70, 0x00, 0x19, 0xFA, // ESC p 0 25 250 (Pin 2)
        0x1B, 0x70, 0x01, 0x19, 0xFA, // ESC p 1 25 250 (Pin 5)
        0x10, 0x14, 0x01, 0x01, 0x01  // DLE DC4 1 1 1 (Epson Realtime)
    };

    public Task<(bool Success, string Message)> OpenCashDrawerAsync(ConfiguracionNegocio? config = null)
    {
#if WINDOWS
        return Task.Run<(bool Success, string Message)>(() =>
        {
            try
            {
                string printerName = !string.IsNullOrWhiteSpace(config?.NombreImpresora)
                    ? config.NombreImpresora.Trim()
                    : GetDefaultPrinterName();

                if (string.IsNullOrWhiteSpace(printerName))
                {
                    return (false, "No se detectó ninguna impresora configurada para abrir la gaveta.");
                }

                bool sent = RawPrinterHelper.SendBytesToPrinter(printerName, DrawerKickBytes);
                if (sent)
                {
                    return (true, $"Señal de apertura enviada a la gaveta en '{printerName}'.");
                }
                else
                {
                    return (false, $"No se pudo enviar el pulso a la impresora '{printerName}'. Verifique que esté encendida.");
                }
            }
            catch (Exception ex)
            {
                return (false, $"Error al abrir la gaveta: {ex.Message}");
            }
        });
#else
        return Task.FromResult((false, "Apertura de gaveta por controlador solo disponible en Windows."));
#endif
    }

#if WINDOWS
    // Comandos directos ESC/POS para avance físico de papel hacia arriba (push fuera de la cuchilla),
    // apertura automática de gaveta de dinero y corte de papel por guillotina.
    public static void SendPaperFeedAndDrawerKick(string printerName, bool openDrawer = true, int extraLines = 6, bool cutPaper = true)
    {
        if (string.IsNullOrWhiteSpace(printerName)) return;

        try
        {
            var bytesList = new List<byte>();

            // 1. Apertura automática de gaveta de dinero por pulso eléctrico (Pin 2 y Pin 5)
            if (openDrawer)
            {
                bytesList.AddRange(DrawerKickBytes);
            }

            // 2. Avance físico de papel hacia arriba (Line Feeds directos al motor de la impresora)
            for (int i = 0; i < extraLines; i++)
            {
                bytesList.Add(0x0A); // \n (Line Feed)
            }
            bytesList.AddRange(new byte[] { 0x1B, 0x64, (byte)Math.Min(extraLines, 6) }); // ESC d <n> (Feed n lines)
            bytesList.Add(0x0A);

            // 3. Corte automático de papel (Guillotina)
            if (cutPaper)
            {
                // ESC/POS GS V 66 0 (Función B: avance al corte y corte parcial con bisagra)
                bytesList.AddRange(new byte[] { 0x1D, 0x56, 0x42, 0x00 });
            }

            RawPrinterHelper.SendBytesToPrinter(printerName, bytesList.ToArray());
        }
        catch { }
    }
#endif
}

#if WINDOWS
internal static class RawPrinterHelper
{
    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
    public struct DOCINFOA
    {
        [MarshalAs(UnmanagedType.LPStr)] public string pDocName;
        [MarshalAs(UnmanagedType.LPStr)] public string? pOutputFile;
        [MarshalAs(UnmanagedType.LPStr)] public string pDataType;
    }

    [DllImport("winspool.Drv", EntryPoint = "OpenPrinterA", SetLastError = true, CharSet = CharSet.Ansi, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
    public static extern bool OpenPrinter([MarshalAs(UnmanagedType.LPStr)] string szPrinter, out IntPtr hPrinter, IntPtr pd);

    [DllImport("winspool.Drv", EntryPoint = "ClosePrinter", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
    public static extern bool ClosePrinter(IntPtr hPrinter);

    [DllImport("winspool.Drv", EntryPoint = "StartDocPrinterA", SetLastError = true, CharSet = CharSet.Ansi, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
    public static extern bool StartDocPrinter(IntPtr hPrinter, Int32 level, [In] ref DOCINFOA di);

    [DllImport("winspool.Drv", EntryPoint = "EndDocPrinter", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
    public static extern bool EndDocPrinter(IntPtr hPrinter);

    [DllImport("winspool.Drv", EntryPoint = "StartPagePrinter", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
    public static extern bool StartPagePrinter(IntPtr hPrinter);

    [DllImport("winspool.Drv", EntryPoint = "EndPagePrinter", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
    public static extern bool EndPagePrinter(IntPtr hPrinter);

    [DllImport("winspool.Drv", EntryPoint = "WritePrinter", SetLastError = true, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
    public static extern bool WritePrinter(IntPtr hPrinter, IntPtr pBytes, Int32 dwCount, out Int32 dwWritten);

    public static bool SendBytesToPrinter(string szPrinterName, byte[] bytes)
    {
        if (string.IsNullOrWhiteSpace(szPrinterName) || bytes == null || bytes.Length == 0)
            return false;

        IntPtr pUnmanagedBytes = Marshal.AllocCoTaskMem(bytes.Length);
        Marshal.Copy(bytes, 0, pUnmanagedBytes, bytes.Length);

        IntPtr hPrinter;
        if (!OpenPrinter(szPrinterName, out hPrinter, IntPtr.Zero))
        {
            Marshal.FreeCoTaskMem(pUnmanagedBytes);
            return false;
        }

        var di = new DOCINFOA
        {
            pDocName = "CashDrawerKick",
            pOutputFile = null,
            pDataType = "RAW"
        };
        bool success = false;
        if (StartDocPrinter(hPrinter, 1, ref di))
        {
            if (StartPagePrinter(hPrinter))
            {
                success = WritePrinter(hPrinter, pUnmanagedBytes, bytes.Length, out _);
                EndPagePrinter(hPrinter);
            }
            EndDocPrinter(hPrinter);
        }
        ClosePrinter(hPrinter);
        Marshal.FreeCoTaskMem(pUnmanagedBytes);
        return success;
    }
}
#endif
