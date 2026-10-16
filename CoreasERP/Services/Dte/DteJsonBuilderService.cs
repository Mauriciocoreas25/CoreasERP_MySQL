using System.Text.Json;
using System.Text.Json.Serialization;
using CoreasERP.Models;
using CoreasERP.Models.Dte;

namespace CoreasERP.Services.Dte;

public class DteJsonBuilderService : IDteJsonBuilderService
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        DefaultIgnoreCondition = JsonIgnoreCondition.WhenWritingNull
    };

    public string GenerarCodigoGeneracion()
    {
        return Guid.NewGuid().ToString().ToUpperInvariant();
    }

    public string GenerarNumeroControl(string tipoDte, string codEstable, string codPuntoVenta, int correlativo)
    {
        // Normalizar tipoDte a 2 dígitos
        string tDte = tipoDte.PadLeft(2, '0');
        // codEstable debe tener 4 caracteres (ej: M001)
        string estab = string.IsNullOrWhiteSpace(codEstable) ? "M001" : codEstable.Trim().ToUpperInvariant();
        // codPuntoVenta (ej: P001)
        string pto = string.IsNullOrWhiteSpace(codPuntoVenta) ? "P001" : codPuntoVenta.Trim().ToUpperInvariant();
        // Correlativo a 15 dígitos
        string corrStr = correlativo.ToString("D15");

        return $"DTE-{tDte}-{estab}{pto}-{corrStr}";
    }

    public string? MapearTipoComprobanteADte(string tipoComprobante)
    {
        if (string.IsNullOrWhiteSpace(tipoComprobante)) return null;

        string norm = tipoComprobante.Trim().ToLowerInvariant();
        if (norm.Contains("factura") && !norm.Contains("sujeto") && !norm.Contains("credito") && !norm.Contains("crédito"))
            return "01";
        if (norm.Contains("ccf") || norm.Contains("credito fiscal") || norm.Contains("crédito fiscal") || norm.Contains("(03)"))
            return "03";
        if (norm.Contains("remision") || norm.Contains("remisión") || norm.Contains("(04)"))
            return "04";
        if (norm.Contains("credito") || norm.Contains("crédito") || norm.Contains("(05)"))
            return "05";
        if (norm.Contains("debito") || norm.Contains("débito") || norm.Contains("(06)"))
            return "06";
        if (norm.Contains("sujeto") || norm.Contains("excluido") || norm.Contains("(14)"))
            return "14";
        if (norm.Contains("ticket"))
            return "01"; // Los tickets en El Salvador se emiten como Factura Electrónica (01)

        return null;
    }

    public EmitDteRequestDto ConstruirPayloadDte(
        string tipoDte,
        Venta venta,
        Cliente cliente,
        ConfiguracionNegocio config,
        int correlativo,
        DteExtraInfo? extraInfo = null)
    {
        extraInfo ??= new DteExtraInfo();

        string codigoGeneracion = GenerarCodigoGeneracion();
        string numeroControl = GenerarNumeroControl(
            tipoDte,
            config.CodEstablecimiento ?? "M001",
            config.CodPuntoVenta ?? "P001",
            correlativo);

        string rawJson = tipoDte switch
        {
            "01" => ConstruirFactura01(venta, cliente, config, codigoGeneracion, numeroControl, extraInfo),
            "03" => ConstruirCreditoFiscal03(venta, cliente, config, codigoGeneracion, numeroControl, extraInfo),
            "04" => ConstruirNotaRemision04(venta, cliente, config, codigoGeneracion, numeroControl, extraInfo),
            "05" => ConstruirNotaCredito05(venta, cliente, config, codigoGeneracion, numeroControl, extraInfo),
            "06" => ConstruirNotaDebito06(venta, cliente, config, codigoGeneracion, numeroControl, extraInfo),
            "14" => ConstruirSujetoExcluido14(venta, cliente, config, codigoGeneracion, numeroControl, extraInfo),
            _ => throw excitingException($"Tipo de DTE no soportado: '{tipoDte}'. Solo se admiten 01, 03, 04, 05, 06 y 14.")
        };

        string receptorDoc = "";
        string receptorNom = string.IsNullOrWhiteSpace(cliente.Nombre) ? "CLIENTE GENERAL" : cliente.Nombre;

        if (tipoDte == "01")
        {
            string docLimpio = LimpiarDocumento(cliente.NumDocumento);
            if (cliente.IdCliente != 1 && !string.IsNullOrWhiteSpace(docLimpio) && docLimpio != "000000000")
            {
                bool esNit = cliente.TipoDocumento == "NIT";
                bool esDui = !esNit;
                if ((esDui && docLimpio.Length == 9) || (esNit && (docLimpio.Length == 9 || docLimpio.Length == 14)))
                {
                    receptorDoc = docLimpio;
                }
            }
        }
        else
        {
            receptorDoc = LimpiarDocumento(cliente.NumDocumento ?? cliente.Nit);
        }

        return new EmitDteRequestDto
        {
            RawDteJson = rawJson,
            TipoDte = tipoDte,
            NumeroControl = numeroControl,
            ReceptorDocumento = receptorDoc,
            ReceptorNombre = receptorNom,
            MontoTotal = venta.Total
        };
    }

    private static InvalidOperationException excitingException(string msg) => new(msg);

    // =========================================================================
    // 5.1 DTE 01 — Factura Electrónica (FE)
    // =========================================================================
    private static string ConstruirFactura01(
        Venta venta,
        Cliente cliente,
        ConfiguracionNegocio config,
        string codGen,
        string numControl,
        DteExtraInfo extra)
    {
        string docLimpio = LimpiarDocumento(cliente.NumDocumento);
        bool esNit = cliente.TipoDocumento == "NIT";
        bool esDui = !esNit;

        // En DTE 01, si es consumidor final anónimo o no tiene DUI/NIT válido,
        // la normativa de Hacienda exige tipoDocumento y numDocumento en null/omitidos.
        bool tieneDocumentoValido = false;
        string? tipoDocMH = null;
        string? numDocMH = null;

        if (cliente.IdCliente != 1 && !string.IsNullOrWhiteSpace(docLimpio) && docLimpio != "000000000")
        {
            if (esDui && docLimpio.Length == 9)
            {
                tieneDocumentoValido = true;
                tipoDocMH = "13"; // DUI (9 dígitos exactos)
                numDocMH = docLimpio;
            }
            else if (esNit && (docLimpio.Length == 9 || docLimpio.Length == 14))
            {
                tieneDocumentoValido = true;
                tipoDocMH = "36"; // NIT
                numDocMH = docLimpio;
            }
        }

        var dte = new DteRoot
        {
            Identificacion = new DteIdentificacion
            {
                Version = 2,
                Ambiente = config.FelSvAmbiente ?? "00",
                TipoDte = "01",
                NumeroControl = numControl,
                CodigoGeneracion = codGen
            },
            Receptor = tieneDocumentoValido
                ? new DteReceptor
                {
                    TipoDocumento = tipoDocMH,
                    NumDocumento = numDocMH,
                    Nombre = cliente.Nombre,
                    Direccion = ConstruirDireccion(cliente, extra, config),
                    Telefono = LimpiarDocumento(cliente.Telefono),
                    Correo = cliente.Email
                }
                : new DteReceptor
                {
                    TipoDocumento = null,
                    NumDocumento = null,
                    Nombre = string.IsNullOrWhiteSpace(cliente.Nombre) ? "CLIENTE GENERAL" : cliente.Nombre,
                    Direccion = ConstruirDireccion(null, extra, config)
                },
            CuerpoDocumento = venta.DetalleVentas.Select((d, idx) => new DteCuerpoItem
            {
                NumItem = idx + 1,
                TipoItem = 1,
                Codigo = d.Producto?.Codigo ?? $"P-{d.IdProducto}",
                Descripcion = d.Producto?.Nombre ?? "Producto",
                Cantidad = d.Cantidad,
                UniMedida = MapearUniMedida(d.Producto?.UnidadMedida),
                PrecioUni = d.Precio
            }).ToList(),
            Resumen = new DteResumen
            {
                CondicionOperacion = venta.TipoComprobante.Equals("Anticipo", StringComparison.OrdinalIgnoreCase) ? 2 : 1,
                FormaPago = MapearFormaPago(venta.MetodoPago)
            }
        };

        return JsonSerializer.Serialize(dte, JsonOptions);
    }

    // =========================================================================
    // 5.2 DTE 03 — Comprobante de Crédito Fiscal (CCF)
    // =========================================================================
    private static string ConstruirCreditoFiscal03(
        Venta venta,
        Cliente cliente,
        ConfiguracionNegocio config,
        string codGen,
        string numControl,
        DteExtraInfo extra)
    {
        string nit = LimpiarDocumento(cliente.NumDocumento ?? cliente.Nit);
        string nrc = LimpiarDocumento(cliente.Nrc);

        var dte = new DteRoot
        {
            Identificacion = new DteIdentificacion
            {
                Version = 4,
                Ambiente = config.FelSvAmbiente ?? "00",
                TipoDte = "03",
                NumeroControl = numControl,
                CodigoGeneracion = codGen
            },
            Receptor = new DteReceptor
            {
                TipoDocumento = "36",
                NumDocumento = nit,
                Nit = nit,
                Nrc = nrc,
                Nombre = cliente.Nombre,
                CodActividad = extra.CodActividad ?? "46309",
                DescActividad = extra.DescActividad ?? (cliente.Giro ?? "Venta al por mayor de otros productos"),
                NombreComercial = !string.IsNullOrWhiteSpace(cliente.Nombre) ? cliente.Nombre : "Contribuyente",
                Direccion = ConstruirDireccion(cliente, extra, config),
                Telefono = LimpiarDocumento(cliente.Telefono),
                Correo = cliente.Email
            },
            CuerpoDocumento = venta.DetalleVentas.Select((d, idx) => new DteCuerpoItem
            {
                NumItem = idx + 1,
                TipoItem = 1,
                Codigo = d.Producto?.Codigo ?? $"COD-{d.IdProducto}",
                Descripcion = d.Producto?.Nombre ?? "Producto",
                Cantidad = d.Cantidad,
                UniMedida = MapearUniMedida(d.Producto?.UnidadMedida),
                PrecioUni = d.Precio
            }).ToList(),
            Resumen = new DteResumen
            {
                CondicionOperacion = venta.TipoComprobante.Equals("Anticipo", StringComparison.OrdinalIgnoreCase) ? 2 : 1,
                FormaPago = MapearFormaPago(venta.MetodoPago)
            }
        };

        return JsonSerializer.Serialize(dte, JsonOptions);
    }

    // =========================================================================
    // 5.3 DTE 04 — Nota de Remisión (NR)
    // =========================================================================
    private static string ConstruirNotaRemision04(
        Venta venta,
        Cliente cliente,
        ConfiguracionNegocio config,
        string codGen,
        string numControl,
        DteExtraInfo extra)
    {
        string nit = LimpiarDocumento(cliente.NumDocumento ?? cliente.Nit);
        string nrc = LimpiarDocumento(cliente.Nrc);
        string uuidRelacionado = extra.DocumentoRelacionadoUUID ?? Guid.NewGuid().ToString().ToUpperInvariant();
        string fechaRel = (extra.DocumentoRelacionadoFecha ?? venta.FechaHora).ToString("yyyy-MM-dd");

        var dte = new DteRoot
        {
            Identificacion = new DteIdentificacion
            {
                Version = 4,
                Ambiente = config.FelSvAmbiente ?? "00",
                TipoDte = "04",
                NumeroControl = numControl,
                CodigoGeneracion = codGen
            },
            DocumentoRelacionado = new List<DteDocumentoRelacionado>
            {
                new()
                {
                    TipoDocumento = extra.DocumentoRelacionadoTipo ?? "03",
                    TipoGeneracion = 1,
                    NumeroDocumento = uuidRelacionado,
                    FechaEmision = fechaRel
                }
            },
            Receptor = new DteReceptor
            {
                TipoDocumento = "36",
                NumDocumento = nit,
                Nrc = nrc,
                Nombre = cliente.Nombre,
                CodActividad = extra.CodActividad ?? "46309",
                DescActividad = extra.DescActividad ?? (cliente.Giro ?? "Comercio de mercadería"),
                Direccion = ConstruirDireccion(cliente, extra, config),
                Telefono = LimpiarDocumento(cliente.Telefono),
                Correo = cliente.Email,
                BienTitulo = extra.BienTitulo ?? "01" // '01' Propiedad
            },
            CuerpoDocumento = venta.DetalleVentas.Select((d, idx) => new DteCuerpoItem
            {
                NumItem = idx + 1,
                TipoItem = 1,
                Codigo = d.Producto?.Codigo ?? $"COD-{d.IdProducto}",
                Descripcion = d.Producto?.Nombre ?? "Mercadería en traslado",
                Cantidad = d.Cantidad,
                UniMedida = MapearUniMedida(d.Producto?.UnidadMedida),
                PrecioUni = d.Precio
            }).ToList(),
            Resumen = new DteResumen
            {
                CondicionOperacion = 1
            }
        };

        return JsonSerializer.Serialize(dte, JsonOptions);
    }

    // =========================================================================
    // 5.4 DTE 05 — Nota de Crédito (NC)
    // =========================================================================
    private static string ConstruirNotaCredito05(
        Venta venta,
        Cliente cliente,
        ConfiguracionNegocio config,
        string codGen,
        string numControl,
        DteExtraInfo extra)
    {
        string nit = LimpiarDocumento(cliente.NumDocumento ?? cliente.Nit);
        string nrc = LimpiarDocumento(cliente.Nrc);
        string uuidRelacionado = extra.DocumentoRelacionadoUUID ?? Guid.NewGuid().ToString().ToUpperInvariant();
        string fechaRel = (extra.DocumentoRelacionadoFecha ?? venta.FechaHora).ToString("yyyy-MM-dd");

        decimal totalGravada = venta.DetalleVentas.Sum(d => d.Subtotal);

        var dte = new DteRoot
        {
            Identificacion = new DteIdentificacion
            {
                Version = 4,
                Ambiente = config.FelSvAmbiente ?? "00",
                TipoDte = "05",
                NumeroControl = numControl,
                CodigoGeneracion = codGen
            },
            DocumentoRelacionado = new List<DteDocumentoRelacionado>
            {
                new()
                {
                    TipoDocumento = extra.DocumentoRelacionadoTipo ?? "03",
                    TipoGeneracion = 1,
                    NumeroDocumento = uuidRelacionado,
                    FechaEmision = fechaRel
                }
            },
            Receptor = new DteReceptor
            {
                TipoDocumento = "36",
                NumDocumento = nit,
                Nrc = nrc,
                Nombre = cliente.Nombre,
                CodActividad = extra.CodActividad ?? "46309",
                DescActividad = extra.DescActividad ?? (cliente.Giro ?? "Venta de productos"),
                Direccion = ConstruirDireccion(cliente, extra, config),
                Telefono = LimpiarDocumento(cliente.Telefono),
                Correo = cliente.Email
            },
            CuerpoDocumento = venta.DetalleVentas.Select((d, idx) => new DteCuerpoItem
            {
                NumItem = idx + 1,
                TipoItem = 1,
                NumeroDocumento = uuidRelacionado,
                Codigo = d.Producto?.Codigo ?? $"COD-{d.IdProducto}",
                Descripcion = $"Devolución / Descuento sobre {d.Producto?.Nombre ?? "artículo"}",
                Cantidad = d.Cantidad,
                UniMedida = 59,
                PrecioUni = d.Precio,
                VentaGravada = d.Subtotal
            }).ToList(),
            Resumen = new DteResumen
            {
                CondicionOperacion = 1,
                TotalGravada = totalGravada
            }
        };

        return JsonSerializer.Serialize(dte, JsonOptions);
    }

    // =========================================================================
    // 5.5 DTE 06 — Nota de Débito (ND)
    // =========================================================================
    private static string ConstruirNotaDebito06(
        Venta venta,
        Cliente cliente,
        ConfiguracionNegocio config,
        string codGen,
        string numControl,
        DteExtraInfo extra)
    {
        string nit = LimpiarDocumento(cliente.NumDocumento ?? cliente.Nit);
        string nrc = LimpiarDocumento(cliente.Nrc);
        string uuidRelacionado = extra.DocumentoRelacionadoUUID ?? Guid.NewGuid().ToString().ToUpperInvariant();
        string fechaRel = (extra.DocumentoRelacionadoFecha ?? venta.FechaHora).ToString("yyyy-MM-dd");

        decimal totalGravada = venta.DetalleVentas.Sum(d => d.Subtotal);

        var dte = new DteRoot
        {
            Identificacion = new DteIdentificacion
            {
                Version = 4,
                Ambiente = config.FelSvAmbiente ?? "00",
                TipoDte = "06",
                NumeroControl = numControl,
                CodigoGeneracion = codGen
            },
            DocumentoRelacionado = new List<DteDocumentoRelacionado>
            {
                new()
                {
                    TipoDocumento = extra.DocumentoRelacionadoTipo ?? "03",
                    TipoGeneracion = 1,
                    NumeroDocumento = uuidRelacionado,
                    FechaEmision = fechaRel
                }
            },
            Receptor = new DteReceptor
            {
                TipoDocumento = "36",
                NumDocumento = nit,
                Nrc = nrc,
                Nombre = cliente.Nombre,
                CodActividad = extra.CodActividad ?? "46309",
                DescActividad = extra.DescActividad ?? (cliente.Giro ?? "Comercio"),
                Direccion = ConstruirDireccion(cliente, extra, config),
                Telefono = LimpiarDocumento(cliente.Telefono),
                Correo = cliente.Email
            },
            CuerpoDocumento = venta.DetalleVentas.Select((d, idx) => new DteCuerpoItem
            {
                NumItem = idx + 1,
                TipoItem = 2, // 2 = Servicio (Cargos, mora, etc.)
                NumeroDocumento = uuidRelacionado,
                Codigo = d.Producto?.Codigo ?? "SERV-CARGO",
                Descripcion = d.Producto?.Nombre ?? "Cargos e intereses moratorios",
                Cantidad = d.Cantidad,
                UniMedida = 59,
                PrecioUni = d.Precio,
                VentaGravada = d.Subtotal
            }).ToList(),
            Resumen = new DteResumen
            {
                CondicionOperacion = 1,
                TotalGravada = totalGravada
            }
        };

        return JsonSerializer.Serialize(dte, JsonOptions);
    }

    // =========================================================================
    // 5.7 DTE 14 — Factura Sujeto Excluido (FSE)
    // =========================================================================
    private static string ConstruirSujetoExcluido14(
        Venta venta,
        Cliente cliente,
        ConfiguracionNegocio config,
        string codGen,
        string numControl,
        DteExtraInfo extra)
    {
        string dui = LimpiarDocumento(cliente.NumDocumento);
        decimal total = venta.Total;
        decimal reteRenta = Math.Round(total * 0.10m, 2); // Retención de 10% de ISR

        var dte = new DteRoot
        {
            Identificacion = new DteIdentificacion
            {
                Version = 2,
                Ambiente = config.FelSvAmbiente ?? "00",
                TipoDte = "14",
                NumeroControl = numControl,
                CodigoGeneracion = codGen
            },
            Receptor = new DteReceptor
            {
                TipoDocumento = "13", // DUI
                NumDocumento = dui,
                Nombre = cliente.Nombre,
                CodActividad = extra.CodActividad ?? "62020",
                DescActividad = extra.DescActividad ?? (cliente.Giro ?? "Servicios de soporte y suministros"),
                Direccion = ConstruirDireccion(cliente, extra, config),
                Telefono = LimpiarDocumento(cliente.Telefono),
                Correo = cliente.Email
            },
            CuerpoDocumento = venta.DetalleVentas.Select((d, idx) => new DteCuerpoItem
            {
                NumItem = idx + 1,
                TipoItem = 2, // 2 = Servicio / Compra sujeto excluido
                Codigo = d.Producto?.Codigo ?? $"SERV-{d.IdProducto}",
                Descripcion = d.Producto?.Nombre ?? "Servicio o bien sujeto excluido",
                Cantidad = d.Cantidad,
                UniMedida = MapearUniMedida(d.Producto?.UnidadMedida),
                PrecioUni = d.Precio
            }).ToList(),
            Resumen = new DteResumen
            {
                CondicionOperacion = 1,
                FormaPago = MapearFormaPago(venta.MetodoPago),
                ReteRenta = reteRenta
            }
        };

        return JsonSerializer.Serialize(dte, JsonOptions);
    }

    private static string LimpiarDocumento(string? doc)
    {
        if (string.IsNullOrWhiteSpace(doc)) return "";
        return doc.Replace("-", "").Replace(" ", "").Trim();
    }

    private static string MapearFormaPago(string? metodoPago)
    {
        if (string.IsNullOrWhiteSpace(metodoPago)) return "01";
        return metodoPago.Trim().ToLowerInvariant() switch
        {
            "tarjeta" => "02",
            "transferencia" => "05",
            _ => "01" // Efectivo
        };
    }

    private static int MapearUniMedida(string? unidad)
    {
        if (string.IsNullOrWhiteSpace(unidad)) return 59;
        string u = unidad.Trim().ToLowerInvariant();
        if (u.Contains("libra") || u == "lb" || u == "lbs" || u == "26") return 26;
        if (u.Contains("kilo") || u == "kg" || u == "kgs" || u == "24") return 24;
        if (u.Contains("gram") || u == "g" || u == "gr" || u == "23") return 23;
        if (u.Contains("onza") || u == "oz" || u == "27") return 27;
        return 59; // 59 = Unidad CAT-014 MH
    }

    private static DteDireccion ConstruirDireccion(Cliente? cliente, DteExtraInfo extra, ConfiguracionNegocio config)
    {
        string depto = extra.CatDepartamento ?? config.CatDepartamento ?? "12";
        string muni = extra.CatMunicipio ?? config.CatMunicipio ?? "1201";
        string texto = !string.IsNullOrWhiteSpace(cliente?.Direccion) ? cliente.Direccion : "San Miguel, El Salvador";

        return new DteDireccion
        {
            CatDepartamento = depto,
            CatMunicipio = muni,
            Texto = texto,
            Departamento = depto,
            Municipio = muni.Length == 4 ? muni.Substring(2, 2) : muni,
            Distrito = "01",
            Complemento = texto
        };
    }
}
