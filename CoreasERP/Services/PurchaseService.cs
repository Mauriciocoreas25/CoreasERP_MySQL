using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Models;

namespace CoreasERP.Services;

public class PurchaseItemDto
{
    public int IdProducto { get; set; }
    public string Codigo { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public decimal Cantidad { get; set; } = 1.000m;
    public decimal PrecioCompra { get; set; }
    public decimal Subtotal => Math.Round(Cantidad * PrecioCompra, 3, MidpointRounding.AwayFromZero);
}

public interface IPurchaseService
{
    Task<List<Proveedor>> GetProveedoresAsync();
    Task<(bool Success, string Message, Proveedor? Proveedor)> SaveProveedorAsync(Proveedor proveedor);
    Task<List<Compra>> GetComprasAsync(DateTime? fecha = null, string? busqueda = null);
    Task<Compra?> GetCompraByIdAsync(int idCompra);
    Task<(bool Success, string Message, Compra? Compra)> RegistrarCompraAsync(
        int idProveedor,
        int idUsuario,
        string numFactura,
        string? observaciones,
        List<PurchaseItemDto> items);
    Task<(bool Success, string Message)> AnularCompraAsync(int idCompra);
}

public class PurchaseService : IPurchaseService
{
    private readonly IDbContextFactory<AppDbContext> _contextFactory;

    public PurchaseService(IDbContextFactory<AppDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public async Task<List<Proveedor>> GetProveedoresAsync()
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.Proveedores
            .Where(p => p.Estado)
            .OrderBy(p => p.Nombre)
            .ToListAsync();
    }

    public async Task<(bool Success, string Message, Proveedor? Proveedor)> SaveProveedorAsync(Proveedor proveedor)
    {
        if (string.IsNullOrWhiteSpace(proveedor.Nombre))
            return (false, "El nombre del proveedor es obligatorio.", null);

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            if (proveedor.IdProveedor == 0)
            {
                proveedor.Nombre = proveedor.Nombre.Trim();
                proveedor.FechaCreacion = DateTime.Now;
                await context.Proveedores.AddAsync(proveedor);
            }
            else
            {
                var existing = await context.Proveedores.FindAsync(proveedor.IdProveedor);
                if (existing == null) return (false, "Proveedor no encontrado.", null);

                existing.Nombre = proveedor.Nombre.Trim();
                existing.Contacto = proveedor.Contacto?.Trim();
                existing.Telefono = proveedor.Telefono?.Trim();
                existing.Email = proveedor.Email?.Trim();
                existing.Direccion = proveedor.Direccion?.Trim();
                existing.Nrc = proveedor.Nrc?.Trim();
                existing.Nit = proveedor.Nit?.Trim();
            }

            await context.SaveChangesAsync();
            return (true, "Proveedor guardado exitosamente.", proveedor);
        }
        catch (Exception ex)
        {
            return (false, $"Error al guardar proveedor: {ex.Message}", null);
        }
    }

    public async Task<List<Compra>> GetComprasAsync(DateTime? fecha = null, string? busqueda = null)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        var query = context.Compras
            .Include(c => c.Proveedor)
            .Include(c => c.Usuario)
            .Include(c => c.DetalleCompras)
                .ThenInclude(d => d.Producto)
            .AsQueryable();

        if (fecha.HasValue)
        {
            var date = fecha.Value.Date;
            query = query.Where(c => c.FechaHora.Date == date);
        }

        if (!string.IsNullOrWhiteSpace(busqueda))
        {
            var search = busqueda.Trim().ToLower();
            query = query.Where(c =>
                c.NumFactura.ToLower().Contains(search) ||
                (c.Proveedor != null && c.Proveedor.Nombre.ToLower().Contains(search)));
        }

        return await query.OrderByDescending(c => c.FechaHora).ToListAsync();
    }

    public async Task<Compra?> GetCompraByIdAsync(int idCompra)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.Compras
            .Include(c => c.Proveedor)
            .Include(c => c.Usuario)
            .Include(c => c.DetalleCompras)
                .ThenInclude(d => d.Producto)
            .FirstOrDefaultAsync(c => c.IdCompra == idCompra);
    }

    public async Task<(bool Success, string Message, Compra? Compra)> RegistrarCompraAsync(
        int idProveedor,
        int idUsuario,
        string numFactura,
        string? observaciones,
        List<PurchaseItemDto> items)
    {
        if (idProveedor <= 0)
            return (false, "Debe seleccionar un proveedor.", null);
        if (string.IsNullOrWhiteSpace(numFactura))
            return (false, "El número de factura o comprobante es requerido.", null);
        if (items == null || !items.Any())
            return (false, "Debe agregar al menos un producto a la compra.", null);

        decimal total = Math.Round(items.Sum(i => i.Subtotal), 3, MidpointRounding.AwayFromZero);

        await using var context = await _contextFactory.CreateDbContextAsync();
        var strategy = context.Database.CreateExecutionStrategy();

        try
        {
            Compra? compraCreada = null;

            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await context.Database.BeginTransactionAsync();

                var compra = new Compra
                {
                    IdProveedor = idProveedor,
                    IdUsuario = idUsuario,
                    NumFactura = numFactura.Trim(),
                    Total = total,
                    FechaHora = DateTime.Now,
                    Estado = "Completada",
                    Observaciones = observaciones
                };

                await context.Compras.AddAsync(compra);
                await context.SaveChangesAsync();

                foreach (var item in items)
                {
                    decimal cantRedondeada = Math.Round(item.Cantidad, 3, MidpointRounding.AwayFromZero);
                    decimal costoRedondeado = Math.Round(item.PrecioCompra, 3, MidpointRounding.AwayFromZero);
                    decimal subRedondeado = Math.Round(cantRedondeada * costoRedondeado, 3, MidpointRounding.AwayFromZero);

                    var detalle = new DetalleCompra
                    {
                        IdCompra = compra.IdCompra,
                        IdProducto = item.IdProducto,
                        Cantidad = cantRedondeada,
                        PrecioCompra = costoRedondeado,
                        Subtotal = subRedondeado
                    };
                    await context.DetalleCompras.AddAsync(detalle);

                    // Incrementar inventario físico automáticamente a 3 decimales
                    var prod = await context.Productos.FindAsync(item.IdProducto);
                    if (prod != null)
                    {
                        prod.Stock = Math.Round(prod.Stock + cantRedondeada, 3, MidpointRounding.AwayFromZero);

                        // Detección automática: Solo si hay modificación en el costo unitario
                        if (costoRedondeado != prod.PrecioCompra)
                        {
                            decimal margen = prod.MargenExcepcion > 0
                                ? prod.MargenExcepcion
                                : (prod.PrecioCompra > 0 ? Math.Round(((prod.PrecioVenta - prod.PrecioCompra) / prod.PrecioCompra) * 100m, 3, MidpointRounding.AwayFromZero) : 30.000m);

                            if (margen <= 0) margen = 30.000m;

                            decimal precioVentaSugerido = Math.Round(costoRedondeado * (1m + (margen / 100m)), 3, MidpointRounding.AwayFromZero);

                            var cambioPrecio = new CambioPrecio
                            {
                                IdProducto = prod.IdProducto,
                                IdCompra = compra.IdCompra,
                                CostoAnterior = prod.PrecioCompra,
                                CostoNuevo = costoRedondeado,
                                PrecioVentaAnterior = prod.PrecioVenta,
                                PrecioVentaNuevo = precioVentaSugerido,
                                MargenPorcentaje = margen,
                                Motivo = $"Modificación de costo en Compra Factura {compra.NumFactura}",
                                FechaHora = DateTime.Now,
                                Estado = "Pendiente"
                            };
                            await context.CambiosPrecio.AddAsync(cambioPrecio);
                        }

                        prod.PrecioCompra = costoRedondeado; // Actualizar costo de adquisición
                        if (prod.CantidadPorEmpaque.HasValue && prod.CantidadPorEmpaque.Value > 1)
                        {
                            prod.CostoGranel = Math.Round(costoRedondeado / prod.CantidadPorEmpaque.Value, 3, MidpointRounding.AwayFromZero);
                        }
                    }
                }

                await context.SaveChangesAsync();
                await transaction.CommitAsync();

                compraCreada = compra;
            });

            return (true, "Compra registrada y stock actualizado exitosamente.", compraCreada);
        }
        catch (Exception ex)
        {
            return (false, $"Error al registrar compra: {ex.Message}", null);
        }
    }

    public async Task<(bool Success, string Message)> AnularCompraAsync(int idCompra)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        var strategy = context.Database.CreateExecutionStrategy();

        try
        {
            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await context.Database.BeginTransactionAsync();

                var compra = await context.Compras
                    .Include(c => c.DetalleCompras)
                    .FirstOrDefaultAsync(c => c.IdCompra == idCompra);

                if (compra == null) throw new InvalidOperationException("Compra no encontrada.");
                if (compra.Estado == "Anulada") throw new InvalidOperationException("Esta compra ya fue anulada.");

                // Descontar las existencias del stock
                foreach (var item in compra.DetalleCompras)
                {
                    var prod = await context.Productos.FindAsync(item.IdProducto);
                    if (prod != null)
                    {
                        prod.Stock = Math.Max(0m, prod.Stock - item.Cantidad);
                    }
                }

                compra.Estado = "Anulada";
                await context.SaveChangesAsync();
                await transaction.CommitAsync();
            });

            return (true, "Compra anulada y existencias ajustadas correctamente.");
        }
        catch (Exception ex)
        {
            return (false, $"Error al anular compra: {ex.Message}");
        }
    }
}
