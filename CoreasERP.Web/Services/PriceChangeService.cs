using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Models;

namespace CoreasERP.Services;

public interface IPriceChangeService
{
    Task<List<CambioPrecio>> GetPendientesAsync();
    Task<int> GetPendientesCountAsync();
    Task<List<CambioPrecio>> GetAplicadosRecientesAsync(int limit = 50);
    Task<(bool Success, string Message)> AplicarCambioAsync(int idCambioPrecio, decimal? precioVentaFinal = null);
    Task<(bool Success, string Message)> DescartarCambioAsync(int idCambioPrecio);
    Task<(bool Success, string Message, int TotalAplicados)> AplicarTodosPendientesAsync();
}

public class PriceChangeService : IPriceChangeService
{
    private readonly IDbContextFactory<AppDbContext> _contextFactory;

    public PriceChangeService(IDbContextFactory<AppDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public async Task<List<CambioPrecio>> GetPendientesAsync()
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.CambiosPrecio
            .Include(c => c.Producto)
                .ThenInclude(p => p!.Categoria)
            .Include(c => c.Compra)
            .Where(c => c.Estado == "Pendiente")
            .OrderByDescending(c => c.FechaHora)
            .ToListAsync();
    }

    public async Task<int> GetPendientesCountAsync()
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.CambiosPrecio.CountAsync(c => c.Estado == "Pendiente");
    }

    public async Task<(bool Success, string Message)> AplicarCambioAsync(int idCambioPrecio, decimal? precioVentaFinal = null)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        var cambio = await context.CambiosPrecio
            .Include(c => c.Producto)
            .FirstOrDefaultAsync(c => c.IdCambioPrecio == idCambioPrecio);

        if (cambio == null)
            return (false, "Registro de cambio de precio no encontrado.");

        if (cambio.Producto == null)
            return (false, "El producto asociado no existe.");

        decimal nuevoPrecioVenta = precioVentaFinal ?? cambio.PrecioVentaNuevo;
        cambio.Producto.PrecioCompra = cambio.CostoNuevo;
        cambio.Producto.PrecioVenta = nuevoPrecioVenta;
        cambio.PrecioVentaNuevo = nuevoPrecioVenta;
        cambio.Estado = "Aplicado";
        cambio.FechaAplicacion = DateTime.Now;

        await context.SaveChangesAsync();
        return (true, $"Precio actualizado exitosamente para {cambio.Producto.Nombre} a ${nuevoPrecioVenta:F2}");
    }

    public async Task<(bool Success, string Message)> DescartarCambioAsync(int idCambioPrecio)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        var cambio = await context.CambiosPrecio.FindAsync(idCambioPrecio);
        if (cambio == null)
            return (false, "Registro de cambio de precio no encontrado.");

        cambio.Estado = "Descartado";
        cambio.FechaAplicacion = DateTime.Now;

        await context.SaveChangesAsync();
        return (true, "El cambio de precio ha sido descartado.");
    }

    public async Task<(bool Success, string Message, int TotalAplicados)> AplicarTodosPendientesAsync()
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        var pendientes = await context.CambiosPrecio
            .Include(c => c.Producto)
            .Where(c => c.Estado == "Pendiente")
            .ToListAsync();

        if (!pendientes.Any())
            return (true, "No hay cambios de precios pendientes para aplicar.", 0);

        int count = 0;
        foreach (var cambio in pendientes)
        {
            if (cambio.Producto != null)
            {
                cambio.Producto.PrecioCompra = cambio.CostoNuevo;
                cambio.Producto.PrecioVenta = cambio.PrecioVentaNuevo;
                cambio.Estado = "Aplicado";
                cambio.FechaAplicacion = DateTime.Now;
                count++;
            }
        }

        await context.SaveChangesAsync();
        return (true, $"Se aplicaron exitosamente {count} cambios de precio al catálogo.", count);
    }

    public async Task<List<CambioPrecio>> GetAplicadosRecientesAsync(int limit = 50)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.CambiosPrecio
            .Include(c => c.Producto)
                .ThenInclude(p => p!.Categoria)
            .Include(c => c.Compra)
            .Where(c => c.Estado == "Aplicado")
            .OrderByDescending(c => c.FechaAplicacion ?? c.FechaHora)
            .Take(limit)
            .ToListAsync();
    }
}
