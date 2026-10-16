using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Models;

namespace CoreasERP.Services;

public interface IUserService
{
    Task<List<Usuario>> GetAllAsync();
    Task<List<Rol>> GetRolesAsync();
    Task<(bool Success, string Message, Usuario? Usuario)> SaveAsync(Usuario usuario, string? nuevaClave = null);
    Task<(bool Success, string Message)> ToggleEstadoAsync(int idUsuario);
}

public class UserService : IUserService
{
    private readonly IDbContextFactory<AppDbContext> _contextFactory;

    public UserService(IDbContextFactory<AppDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public async Task<List<Usuario>> GetAllAsync()
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.Usuarios
            .Include(u => u.Rol)
            .OrderBy(u => u.Nombre)
            .ToListAsync();
    }

    public async Task<List<Rol>> GetRolesAsync()
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.Roles.OrderBy(r => r.IdRol).ToListAsync();
    }

    public async Task<(bool Success, string Message, Usuario? Usuario)> SaveAsync(Usuario usuario, string? nuevaClave = null)
    {
        if (string.IsNullOrWhiteSpace(usuario.NombreUsuario))
            return (false, "El nombre de usuario es obligatorio.", null);
        if (string.IsNullOrWhiteSpace(usuario.Nombre))
            return (false, "El nombre completo es obligatorio.", null);
        if (usuario.IdRol <= 0)
            return (false, "Debe asignar un rol válido.", null);

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();

            var existeUsername = await context.Usuarios.AnyAsync(u =>
                u.NombreUsuario == usuario.NombreUsuario.Trim() && u.IdUsuario != usuario.IdUsuario);

            if (existeUsername)
                return (false, "El nombre de usuario ya está en uso.", null);

            if (usuario.IdUsuario == 0)
            {
                if (string.IsNullOrWhiteSpace(nuevaClave))
                    return (false, "Debe ingresar una contraseña para el nuevo usuario.", null);

                usuario.NombreUsuario = usuario.NombreUsuario.Trim();
                usuario.Nombre = usuario.Nombre.Trim();
                usuario.Clave = BCrypt.Net.BCrypt.HashPassword(nuevaClave.Trim());
                usuario.FechaCreacion = DateTime.Now;
                usuario.Estado = true;

                await context.Usuarios.AddAsync(usuario);
            }
            else
            {
                var existing = await context.Usuarios.FindAsync(usuario.IdUsuario);
                if (existing == null) return (false, "Usuario no encontrado.", null);

                existing.IdRol = usuario.IdRol;
                existing.NombreUsuario = usuario.NombreUsuario.Trim();
                existing.Nombre = usuario.Nombre.Trim();
                existing.Email = usuario.Email?.Trim();
                existing.Telefono = usuario.Telefono?.Trim();
                existing.Estado = usuario.Estado;

                if (!string.IsNullOrWhiteSpace(nuevaClave))
                {
                    existing.Clave = BCrypt.Net.BCrypt.HashPassword(nuevaClave.Trim());
                }
            }

            await context.SaveChangesAsync();
            return (true, "Usuario guardado exitosamente.", usuario);
        }
        catch (Exception ex)
        {
            return (false, $"Error al guardar usuario: {ex.Message}", null);
        }
    }

    public async Task<(bool Success, string Message)> ToggleEstadoAsync(int idUsuario)
    {
        if (idUsuario == 1)
            return (false, "No se puede desactivar al Administrador Principal.");

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            var user = await context.Usuarios.FindAsync(idUsuario);
            if (user == null) return (false, "Usuario no encontrado.");

            user.Estado = !user.Estado;
            await context.SaveChangesAsync();
            return (true, $"Usuario {(user.Estado ? "activado" : "desactivado")} exitosamente.");
        }
        catch (Exception ex)
        {
            return (false, $"Error al actualizar estado: {ex.Message}");
        }
    }
}
