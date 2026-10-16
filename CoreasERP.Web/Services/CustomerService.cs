using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Models;

namespace CoreasERP.Services;

public interface ICustomerService
{
    Task<List<Cliente>> GetAllAsync(string? busqueda = null, string? tipoPersona = null);
    Task<Cliente?> GetByIdAsync(int id);
    Task<(bool Success, string Message, Cliente? Cliente)> SaveAsync(Cliente cliente);
    Task<(bool Success, string Message)> DeleteAsync(int id);
}

public class CustomerService : ICustomerService
{
    private readonly IDbContextFactory<AppDbContext> _contextFactory;

    public CustomerService(IDbContextFactory<AppDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public async Task<List<Cliente>> GetAllAsync(string? busqueda = null, string? tipoPersona = null)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        var query = context.Clientes.AsQueryable();

        if (!string.IsNullOrWhiteSpace(tipoPersona) && tipoPersona != "Todos")
        {
            query = query.Where(c => c.TipoPersona == tipoPersona);
        }

        if (!string.IsNullOrWhiteSpace(busqueda))
        {
            var search = busqueda.Trim().ToLower();
            query = query.Where(c =>
                c.Nombre.ToLower().Contains(search) ||
                (c.NumDocumento != null && c.NumDocumento.ToLower().Contains(search)) ||
                (c.Telefono != null && c.Telefono.ToLower().Contains(search)) ||
                (c.Nrc != null && c.Nrc.ToLower().Contains(search)));
        }

        return await query.OrderBy(c => c.Nombre).ToListAsync();
    }

    public async Task<Cliente?> GetByIdAsync(int id)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.Clientes.FindAsync(id);
    }

    public async Task<(bool Success, string Message, Cliente? Cliente)> SaveAsync(Cliente cliente)
    {
        if (string.IsNullOrWhiteSpace(cliente.Nombre))
            return (false, "El nombre o razón social del cliente es obligatorio.", null);

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();

            if (cliente.IdCliente == 0)
            {
                cliente.Nombre = cliente.Nombre.Trim();
                cliente.FechaCreacion = DateTime.Now;
                await context.Clientes.AddAsync(cliente);
            }
            else
            {
                var existing = await context.Clientes.FindAsync(cliente.IdCliente);
                if (existing == null) return (false, "Cliente no encontrado.", null);

                existing.TipoPersona = cliente.TipoPersona;
                existing.Nombre = cliente.Nombre.Trim();
                existing.TipoDocumento = cliente.TipoDocumento;
                existing.NumDocumento = cliente.NumDocumento?.Trim();
                existing.Telefono = cliente.Telefono?.Trim();
                existing.Email = cliente.Email?.Trim();
                existing.Direccion = cliente.Direccion?.Trim();
                existing.Nrc = cliente.Nrc?.Trim();
                existing.Giro = cliente.Giro?.Trim();
            }

            await context.SaveChangesAsync();
            return (true, "Cliente guardado exitosamente.", cliente);
        }
        catch (Exception ex)
        {
            return (false, $"Error al guardar cliente: {ex.Message}", null);
        }
    }

    public async Task<(bool Success, string Message)> DeleteAsync(int id)
    {
        if (id == 1)
        {
            return (false, "No se puede eliminar el cliente 'Consumidor Final' obligatorio.");
        }

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            var cliente = await context.Clientes
                .Include(c => c.Ventas)
                .FirstOrDefaultAsync(c => c.IdCliente == id);

            if (cliente == null) return (false, "Cliente no encontrado.");

            if (cliente.Ventas.Any())
            {
                return (false, "No se puede eliminar el cliente porque tiene ventas registradas.");
            }

            context.Clientes.Remove(cliente);
            await context.SaveChangesAsync();
            return (true, "Cliente eliminado exitosamente.");
        }
        catch (Exception ex)
        {
            return (false, $"Error al eliminar cliente: {ex.Message}");
        }
    }
}
