using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Models;

namespace CoreasERP.Services;

public interface ICreditService
{
    Task<List<CuentaCobrar>> GetCuentasAsync(string? busqueda = null, string? estado = null);
    Task<CuentaCobrar?> GetCuentaByIdAsync(int idCuentaCobrar);
    Task<(bool Success, string Message, Abono? Abono)> RegistrarAbonoAsync(
        int idCuentaCobrar,
        int idUsuario,
        decimal monto,
        string metodoPago,
        string? notas);
}

public class CreditService : ICreditService
{
    private readonly IDbContextFactory<AppDbContext> _contextFactory;

    public CreditService(IDbContextFactory<AppDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public async Task<List<CuentaCobrar>> GetCuentasAsync(string? busqueda = null, string? estado = null)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        var query = context.CuentasCobrar
            .Include(c => c.Cliente)
            .Include(c => c.Venta)
            .Include(c => c.Abonos)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(estado) && estado != "Todos")
        {
            query = query.Where(c => c.Estado == estado);
        }

        if (!string.IsNullOrWhiteSpace(busqueda))
        {
            var search = busqueda.Trim().ToLower();
            query = query.Where(c =>
                (c.Cliente != null && c.Cliente.Nombre.ToLower().Contains(search)) ||
                (c.Venta != null && c.Venta.NumComprobante.ToLower().Contains(search)));
        }

        return await query.OrderByDescending(c => c.FechaEmision).ToListAsync();
    }

    public async Task<CuentaCobrar?> GetCuentaByIdAsync(int idCuentaCobrar)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.CuentasCobrar
            .Include(c => c.Cliente)
            .Include(c => c.Venta)
            .Include(c => c.Abonos)
                .ThenInclude(a => a.Usuario)
            .FirstOrDefaultAsync(c => c.IdCuentaCobrar == idCuentaCobrar);
    }

    public async Task<(bool Success, string Message, Abono? Abono)> RegistrarAbonoAsync(
        int idCuentaCobrar,
        int idUsuario,
        decimal monto,
        string metodoPago,
        string? notas)
    {
        if (monto <= 0)
            return (false, "El monto del abono debe ser mayor a cero.", null);

        await using var context = await _contextFactory.CreateDbContextAsync();
        var strategy = context.Database.CreateExecutionStrategy();
        (bool Success, string Message, Abono? Abono) result = (false, "No se pudo registrar el abono.", null);

        try
        {
            await strategy.ExecuteAsync(async () =>
            {
                await using var transaction = await context.Database.BeginTransactionAsync();

                var cuenta = await context.CuentasCobrar.FindAsync(idCuentaCobrar);
                if (cuenta == null)
                {
                    await transaction.RollbackAsync();
                    result = (false, "Cuenta por cobrar no encontrada.", null);
                    return;
                }

                if (cuenta.Estado == "Pagada")
                {
                    await transaction.RollbackAsync();
                    result = (false, "Esta cuenta ya se encuentra totalmente saldada.", null);
                    return;
                }

                if (monto > cuenta.SaldoPendiente)
                {
                    await transaction.RollbackAsync();
                    result = (false, $"El abono (${monto:F2}) excede el saldo pendiente (${cuenta.SaldoPendiente:F2}).", null);
                    return;
                }

                var abono = new Abono
                {
                    IdCuentaCobrar = idCuentaCobrar,
                    IdUsuario = idUsuario,
                    Monto = monto,
                    MetodoPago = metodoPago,
                    FechaHora = DateTime.Now,
                    Notas = notas
                };

                await context.Abonos.AddAsync(abono);

                cuenta.SaldoPendiente -= monto;
                if (cuenta.SaldoPendiente <= 0)
                {
                    cuenta.SaldoPendiente = 0;
                    cuenta.Estado = "Pagada";
                }

                await context.SaveChangesAsync();
                await transaction.CommitAsync();

                result = (true, "Abono registrado exitosamente.", abono);
            });

            return result;
        }
        catch (Exception ex)
        {
            return (false, $"Error al registrar abono: {ex.Message}", null);
        }
    }
}
