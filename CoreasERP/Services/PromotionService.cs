using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Models;

namespace CoreasERP.Services;

public interface IPromotionService
{
    Task<List<Promocion>> GetAllAsync();
    Task<List<Promocion>> GetActiveAsync();
    Task<(bool Success, string Message, Promocion? Promocion)> SaveAsync(Promocion promocion);
    Task<(bool Success, string Message)> ToggleEstadoAsync(int idPromocion);
    Task<(bool Success, string Message)> DeleteAsync(int idPromocion);
}

public class PromotionService : IPromotionService
{
    private readonly IDbContextFactory<AppDbContext> _contextFactory;

    public PromotionService(IDbContextFactory<AppDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public async Task<List<Promocion>> GetAllAsync()
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.Promociones
            .Include(p => p.Producto)
            .OrderByDescending(p => p.FechaInicio)
            .ToListAsync();
    }

    public async Task<List<Promocion>> GetActiveAsync()
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        var hoy = DateTime.Now;
        return await context.Promociones
            .Include(p => p.Producto)
            .Where(p => p.Estado && p.FechaInicio <= hoy && p.FechaFin >= hoy)
            .ToListAsync();
    }

    public async Task<(bool Success, string Message, Promocion? Promocion)> SaveAsync(Promocion promocion)
    {
        if (string.IsNullOrWhiteSpace(promocion.Nombre))
            return (false, "El nombre de la promoción es obligatorio.", null);
        if (promocion.Valor <= 0)
            return (false, "El valor del descuento debe ser mayor a cero.", null);
        if (promocion.FechaFin < promocion.FechaInicio)
            return (false, "La fecha de fin no puede ser anterior a la fecha de inicio.", null);

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            if (promocion.IdPromocion == 0)
            {
                promocion.Nombre = promocion.Nombre.Trim();
                await context.Promociones.AddAsync(promocion);
            }
            else
            {
                var existing = await context.Promociones.FindAsync(promocion.IdPromocion);
                if (existing == null) return (false, "Promoción no encontrada.", null);

                existing.Nombre = promocion.Nombre.Trim();
                existing.Descripcion = promocion.Descripcion?.Trim();
                existing.TipoDescuento = promocion.TipoDescuento;
                existing.Valor = promocion.Valor;
                existing.FechaInicio = promocion.FechaInicio;
                existing.FechaFin = promocion.FechaFin;
                existing.Estado = promocion.Estado;
                existing.IdProducto = promocion.IdProducto > 0 ? promocion.IdProducto : null;
            }

            await context.SaveChangesAsync();
            return (true, "Promoción guardada exitosamente.", promocion);
        }
        catch (Exception ex)
        {
            return (false, $"Error al guardar promoción: {ex.Message}", null);
        }
    }

    public async Task<(bool Success, string Message)> ToggleEstadoAsync(int idPromocion)
    {
        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            var promo = await context.Promociones.FindAsync(idPromocion);
            if (promo == null) return (false, "Promoción no encontrada.");

            promo.Estado = !promo.Estado;
            await context.SaveChangesAsync();
            return (true, $"Promoción {(promo.Estado ? "activada" : "pausada")} correctamente.");
        }
        catch (Exception ex)
        {
            return (false, $"Error al cambiar estado: {ex.Message}");
        }
    }

    public async Task<(bool Success, string Message)> DeleteAsync(int idPromocion)
    {
        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            var promo = await context.Promociones.FindAsync(idPromocion);
            if (promo == null) return (false, "Promoción no encontrada.");

            context.Promociones.Remove(promo);
            await context.SaveChangesAsync();
            return (true, "Promoción eliminada exitosamente.");
        }
        catch (Exception ex)
        {
            return (false, $"Error al eliminar promoción: {ex.Message}");
        }
    }
}
