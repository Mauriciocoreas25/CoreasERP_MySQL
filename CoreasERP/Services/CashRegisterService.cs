using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Models;

namespace CoreasERP.Services;

public interface ICashRegisterService
{
    Task<CorteCaja?> GetCorteActivoAsync(int? idUsuario = null);
    Task<(bool Success, string Message, CorteCaja? Corte)> AbrirCajaAsync(int idUsuario, decimal montoInicial);
    Task<(bool Success, string Message, CorteCaja? Corte)> ActualizarMontoInicialAsync(int idCorte, decimal nuevoMontoInicial);
    Task<(bool Success, string Message, CorteCaja? Corte)> CerrarCajaAsync(int idCorte, decimal montoFinal, decimal? diferencia = null);
    Task<(bool Success, string Message, MovimientoCaja? Movimiento)> RegistrarMovimientoCajaAsync(int idUsuario, string tipo, decimal monto, string motivo, int? idCorte = null);
    Task<List<MovimientoCaja>> GetMovimientosCajaAsync(int? idCorte = null, DateTime? fechaDesde = null, DateTime? fechaHasta = null);
    Task<ResumenCorteDto> GenerarResumenCorteAsync(int idCorte, string tipoCorte = "CORTE X", DesgloseDenominacionDto? desgloseFisico = null);
    Task<List<CorteCaja>> GetHistorialCortesAsync();
}

public class CashRegisterService : ICashRegisterService
{
    private readonly IDbContextFactory<AppDbContext> _contextFactory;

    public CashRegisterService(IDbContextFactory<AppDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public async Task<CorteCaja?> GetCorteActivoAsync(int? idUsuario = null)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        var query = context.CortesCaja
            .Include(c => c.Usuario)
            .Where(c => c.Estado == "Abierta");

        if (idUsuario.HasValue && idUsuario.Value > 0)
        {
            query = query.Where(c => c.IdUsuario == idUsuario.Value);
        }

        return await query.OrderByDescending(c => c.FechaApertura).FirstOrDefaultAsync();
    }

    public async Task<(bool Success, string Message, CorteCaja? Corte)> AbrirCajaAsync(int idUsuario, decimal montoInicial)
    {
        if (montoInicial < 0)
            return (false, "El fondo inicial no puede ser negativo.", null);

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();

            var cajaAbierta = await context.CortesCaja
                .AnyAsync(c => c.IdUsuario == idUsuario && c.Estado == "Abierta");

            if (cajaAbierta)
            {
                return (false, "Ya existe un turno de caja abierto para este usuario.", null);
            }

            var corte = new CorteCaja
            {
                IdUsuario = idUsuario,
                MontoInicial = montoInicial,
                TotalVentas = 0.00m,
                Diferencia = 0.00m,
                FechaApertura = DateTime.Now,
                Estado = "Abierta"
            };

            await context.CortesCaja.AddAsync(corte);
            await context.SaveChangesAsync();
            return (true, "Turno de caja abierto exitosamente.", corte);
        }
        catch (Exception ex)
        {
            return (false, $"Error al abrir turno de caja: {ex.Message}", null);
        }
    }

    public async Task<(bool Success, string Message, CorteCaja? Corte)> ActualizarMontoInicialAsync(int idCorte, decimal nuevoMontoInicial)
    {
        if (nuevoMontoInicial < 0)
            return (false, "El fondo inicial no puede ser negativo.", null);

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            var corte = await context.CortesCaja.FindAsync(idCorte);
            if (corte == null) return (false, "Turno de caja no encontrado.", null);
            if (corte.Estado == "Cerrada") return (false, "No se puede modificar un turno ya cerrado.", null);

            corte.MontoInicial = nuevoMontoInicial;
            await context.SaveChangesAsync();
            return (true, "Fondo inicial actualizado.", corte);
        }
        catch (Exception ex)
        {
            return (false, $"Error al actualizar fondo inicial: {ex.Message}", null);
        }
    }

    public async Task<(bool Success, string Message, MovimientoCaja? Movimiento)> RegistrarMovimientoCajaAsync(
        int idUsuario, string tipo, decimal monto, string motivo, int? idCorte = null)
    {
        if (monto < 0 || (monto == 0 && tipo != "AperturaGaveta"))
            return (false, "El monto debe ser mayor a cero.", null);

        if (string.IsNullOrWhiteSpace(motivo))
            return (false, "Debe especificar el motivo o justificación del movimiento.", null);

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();

            if (!idCorte.HasValue)
            {
                var corteActivo = await context.CortesCaja
                    .Where(c => c.IdUsuario == idUsuario && c.Estado == "Abierta")
                    .OrderByDescending(c => c.FechaApertura)
                    .FirstOrDefaultAsync();
                if (corteActivo != null)
                {
                    idCorte = corteActivo.IdCorte;
                }
            }

            string motivoFinal = motivo.Trim();
            if (motivoFinal.Length > 250)
            {
                motivoFinal = motivoFinal.Substring(0, 250);
            }

            var mov = new MovimientoCaja
            {
                IdCorte = idCorte,
                IdUsuario = idUsuario,
                Tipo = tipo,
                Monto = monto,
                Motivo = motivoFinal,
                FechaHora = DateTime.Now
            };

            await context.MovimientosCaja.AddAsync(mov);
            await context.SaveChangesAsync();

            string mensajeRespuesta = tipo == "AperturaGaveta"
                ? "Apertura de gaveta registrada en auditoría de caja."
                : $"{tipo} de ${monto:F2} registrado exitosamente.";

            return (true, mensajeRespuesta, mov);
        }
        catch (Exception ex)
        {
            return (false, $"Error al registrar movimiento de caja: {ex.Message}", null);
        }
    }

    public async Task<List<MovimientoCaja>> GetMovimientosCajaAsync(int? idCorte = null, DateTime? fechaDesde = null, DateTime? fechaHasta = null)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        var query = context.MovimientosCaja.Include(m => m.Usuario).AsQueryable();

        if (idCorte.HasValue)
        {
            query = query.Where(m => m.IdCorte == idCorte.Value);
        }

        if (fechaDesde.HasValue)
        {
            query = query.Where(m => m.FechaHora >= fechaDesde.Value);
        }

        if (fechaHasta.HasValue)
        {
            query = query.Where(m => m.FechaHora <= fechaHasta.Value);
        }

        return await query.OrderByDescending(m => m.FechaHora).ToListAsync();
    }

    public async Task<ResumenCorteDto> GenerarResumenCorteAsync(int idCorte, string tipoCorte = "CORTE X", DesgloseDenominacionDto? desgloseFisico = null)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        var corte = await context.CortesCaja
            .Include(c => c.Usuario)
            .FirstOrDefaultAsync(c => c.IdCorte == idCorte);

        if (corte == null) return new ResumenCorteDto();

        var config = await context.ConfiguracionNegocio.FirstOrDefaultAsync();

        DateTime fechaInicio = corte.FechaApertura;
        DateTime fechaFin = (corte.Estado == "Cerrada" && corte.FechaCierre.HasValue)
            ? corte.FechaCierre.Value
            : DateTime.Now;

        // Consultar todas las ventas realizadas en el período del turno
        var ventas = await context.Ventas
            .Where(v => v.IdUsuario == corte.IdUsuario && v.FechaHora >= fechaInicio && v.FechaHora <= fechaFin && v.Estado != "Anulada")
            .ToListAsync();

        // Consultar movimientos manuales (gastos, retiros, ingresos)
        var movimientos = await context.MovimientosCaja
            .Where(m => m.IdCorte == idCorte || (m.IdUsuario == corte.IdUsuario && m.FechaHora >= fechaInicio && m.FechaHora <= fechaFin))
            .ToListAsync();

        // Consultar abonos a cuentas por cobrar recibidos en el período (excluyendo anticipos iniciales para no duplicar)
        var abonos = await context.Abonos
            .Where(a => a.IdUsuario == corte.IdUsuario && a.FechaHora >= fechaInicio && a.FechaHora <= fechaFin && (a.Notas == null || !a.Notas.Contains("Anticipo inicial")))
            .ToListAsync();

        var resumen = new ResumenCorteDto
        {
            IdCorte = corte.IdCorte,
            TipoCorte = tipoCorte,
            NombreCajero = corte.Usuario?.Nombre ?? "Cajero",
            NombreEmpresa = config?.NombreNegocio ?? "Coreas ERP",
            Sucursal = config?.CodEstablecimiento ?? "M001",
            PuntoVenta = config?.CodPuntoVenta ?? "P001",
            FechaApertura = corte.FechaApertura,
            FechaCorte = fechaFin,
            EstadoTurno = corte.Estado,
            FondoInicial = corte.MontoInicial,
            Movimientos = movimientos
        };

        // 1. Desglose por Tipo de Comprobante
        var tiposConocidos = new[] { "Ticket", "Factura", "CCF (03)", "Credito Fiscal", "N.Remisión (04)", "N.Crédito (05)", "N.Débito (06)", "Suj.Excluido (14)", "Anticipo", "Cotización" };
        var agrupado = ventas.GroupBy(v => v.TipoComprobante).ToList();

        foreach (var grupo in agrupado)
        {
            string tipo = grupo.Key;
            bool esCotizacion = tipo.Equals("Cotización", StringComparison.OrdinalIgnoreCase);
            bool esAnticipo = tipo.Equals("Anticipo", StringComparison.OrdinalIgnoreCase);
            bool esNotaCredito = tipo.Contains("N.Crédito", StringComparison.OrdinalIgnoreCase)
                || tipo.Contains("N.Credito", StringComparison.OrdinalIgnoreCase)
                || tipo.Contains("Nota de Crédito", StringComparison.OrdinalIgnoreCase)
                || tipo.Contains("(05)", StringComparison.OrdinalIgnoreCase);

            var itemDoc = new ItemTipoDocumentoCorteDto
            {
                TipoComprobante = tipo,
                Cantidad = grupo.Count(),
                MontoTotal = Math.Round(grupo.Sum(v => v.Total), 3, MidpointRounding.AwayFromZero),
                EsInformativo = esCotizacion
            };

            if (esCotizacion)
            {
                // Cotización es presupuesto: $0 efectivo, no afecta caja
                itemDoc.MontoEfectivo = 0m;
                itemDoc.MontoElectronico = 0m;
                itemDoc.MontoCreditoCXC = 0m;

                resumen.CantidadCotizaciones += itemDoc.Cantidad;
                resumen.TotalCotizacionesMonto += itemDoc.MontoTotal;
            }
            else if (esNotaCredito)
            {
                // Nota de Crédito (05) representa devolución/descuento, no ingreso de venta
                foreach (var v in grupo)
                {
                    if (v.MetodoPago == "Efectivo")
                    {
                        itemDoc.MontoEfectivo += v.Total;
                        resumen.TotalDevolucionesEfectivo += v.Total;
                    }
                    else
                    {
                        itemDoc.MontoElectronico += v.Total;
                    }
                }
            }
            else if (esAnticipo)
            {
                decimal totalPedidos = 0m;
                decimal anticipoEfectivo = 0m;
                decimal anticipoElectronico = 0m;
                decimal saldoCreditoCXC = 0m;

                foreach (var v in grupo)
                {
                    totalPedidos += v.Total;
                    decimal abonado = Math.Min(v.PagoCon ?? 0m, v.Total);
                    decimal restante = Math.Max(0m, v.Total - abonado);
                    saldoCreditoCXC += restante;

                    if (v.MetodoPago == "Efectivo")
                        anticipoEfectivo += abonado;
                    else
                        anticipoElectronico += abonado;
                }

                itemDoc.MontoEfectivo = Math.Round(anticipoEfectivo, 3, MidpointRounding.AwayFromZero);
                itemDoc.MontoElectronico = Math.Round(anticipoElectronico, 3, MidpointRounding.AwayFromZero);
                itemDoc.MontoCreditoCXC = Math.Round(saldoCreditoCXC, 3, MidpointRounding.AwayFromZero);

                resumen.CantidadAnticipos += itemDoc.Cantidad;
                resumen.AnticiposTotalPedidos += Math.Round(totalPedidos, 3, MidpointRounding.AwayFromZero);
                resumen.AnticiposCobradoEfectivo += itemDoc.MontoEfectivo;
                resumen.AnticiposCobradoElectronico += itemDoc.MontoElectronico;
                resumen.AnticiposSaldoCXC += itemDoc.MontoCreditoCXC;

                resumen.TotalVentasEfectivo += itemDoc.MontoEfectivo;
                if (anticipoElectronico > 0m)
                {
                    // Asignar según método predominante
                    resumen.TotalVentasTarjetas += itemDoc.MontoElectronico;
                }
                resumen.TotalVentasCreditoCXC += itemDoc.MontoCreditoCXC;
            }
            else
            {
                // Ventas regulares (Ticket, Factura, CCF 03, Sujeto Excluido 14, etc.)
                foreach (var v in grupo)
                {
                    decimal vTotal = Math.Round(v.Total, 3, MidpointRounding.AwayFromZero);
                    if (v.MetodoPago == "Efectivo")
                    {
                        itemDoc.MontoEfectivo += vTotal;
                        resumen.TotalVentasEfectivo += vTotal;
                    }
                    else if (v.MetodoPago == "Tarjeta")
                    {
                        itemDoc.MontoElectronico += vTotal;
                        resumen.TotalVentasTarjetas += vTotal;
                    }
                    else if (v.MetodoPago == "Transferencia")
                    {
                        itemDoc.MontoElectronico += vTotal;
                        resumen.TotalVentasTransferencias += vTotal;
                    }
                    else if (v.MetodoPago == "Credito")
                    {
                        itemDoc.MontoCreditoCXC += vTotal;
                        resumen.TotalVentasCreditoCXC += vTotal;
                    }
                    else
                    {
                        itemDoc.MontoEfectivo += vTotal;
                        resumen.TotalVentasEfectivo += vTotal;
                    }
                }
            }

            resumen.Documentos.Add(itemDoc);
        }

        // 2. Abonos a Cuentas por Cobrar recibidos en el período
        resumen.CantidadAbonos = abonos.Count;
        resumen.TotalAbonosEfectivo = Math.Round(abonos.Where(a => a.MetodoPago == "Efectivo").Sum(a => a.Monto), 3, MidpointRounding.AwayFromZero);
        resumen.TotalAbonosElectronico = Math.Round(abonos.Where(a => a.MetodoPago != "Efectivo").Sum(a => a.Monto), 3, MidpointRounding.AwayFromZero);

        // 3. Movimientos de Caja
        resumen.TotalIngresosExtras = Math.Round(movimientos.Where(m => m.Tipo == "Ingreso").Sum(m => m.Monto), 3, MidpointRounding.AwayFromZero);
        resumen.TotalRetiros = Math.Round(movimientos.Where(m => m.Tipo == "Retiro").Sum(m => m.Monto), 3, MidpointRounding.AwayFromZero);
        resumen.TotalGastos = Math.Round(movimientos.Where(m => m.Tipo == "Gasto").Sum(m => m.Monto), 3, MidpointRounding.AwayFromZero);
        resumen.TotalDevolucionesEfectivo = Math.Round(resumen.TotalDevolucionesEfectivo, 3, MidpointRounding.AwayFromZero);

        // 4. Conteo Físico
        if (desgloseFisico != null)
        {
            resumen.DesgloseFisico = desgloseFisico;
            resumen.EfectivoContado = desgloseFisico.TotalFisicoContado;
        }
        else if (corte.MontoFinal.HasValue)
        {
            resumen.EfectivoContado = corte.MontoFinal.Value;
        }

        return resumen;
    }

    public async Task<(bool Success, string Message, CorteCaja? Corte)> CerrarCajaAsync(int idCorte, decimal montoFinal, decimal? diferencia = null)
    {
        if (montoFinal < 0)
            return (false, "El conteo físico de dinero no puede ser negativo.", null);

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            var corte = await context.CortesCaja
                .Include(c => c.Usuario)
                .FirstOrDefaultAsync(c => c.IdCorte == idCorte);

            if (corte == null) return (false, "Turno de caja no encontrado.", null);
            if (corte.Estado == "Cerrada") return (false, "Este turno ya se encuentra cerrado.", null);

            // Generar el balance integral de efectivo para calcular la diferencia matemática exacta
            var resumen = await GenerarResumenCorteAsync(idCorte, "CORTE Z");
            decimal esperado = resumen.EfectivoEsperado;
            decimal diff = diferencia ?? (montoFinal - esperado);

            corte.MontoFinal = montoFinal;
            corte.Diferencia = diff;
            corte.TotalVentas = resumen.TotalFacturadoNeto;
            corte.FechaCierre = DateTime.Now;
            corte.Estado = "Cerrada";

            await context.SaveChangesAsync();

            string balanceMsg = diff == 0
                ? "Caja cuadrada exactamente."
                : (diff > 0 ? $"Sobrante de +${diff:F2}" : $"Faltante de -${Math.Abs(diff):F2}");

            return (true, $"Caja cerrada con éxito. {balanceMsg}", corte);
        }
        catch (Exception ex)
        {
            return (false, $"Error al cerrar caja: {ex.Message}", null);
        }
    }

    public async Task<List<CorteCaja>> GetHistorialCortesAsync()
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.CortesCaja
            .Include(c => c.Usuario)
            .OrderByDescending(c => c.FechaApertura)
            .Take(60)
            .ToListAsync();
    }
}
