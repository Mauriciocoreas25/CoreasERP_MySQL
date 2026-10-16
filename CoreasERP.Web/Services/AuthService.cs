using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Models;

namespace CoreasERP.Services;

public interface IAuthService
{
    Usuario? CurrentUser { get; }
    bool IsAuthenticated { get; }
    bool IsAdmin { get; }
    bool IsSupervisor { get; }
    bool IsCajero { get; }
    bool PuedeAdministrar { get; }
    event Action? OnAuthStateChanged;

    Task<(bool Success, string Message, Usuario? User)> LoginAsync(string username, string password);
    void Logout();
    Task<bool> VerifyUserPasswordAsync(int idUsuario, string password);
    Task<(bool Success, string Message, Usuario? SupervisorUser)> VerifySupervisorOrAdminCredentialsAsync(string username, string password);
}

public class AuthService : IAuthService
{
    private readonly IDbContextFactory<AppDbContext> _contextFactory;

    public Usuario? CurrentUser { get; private set; }
    public bool IsAuthenticated => CurrentUser != null;
    public bool IsAdmin => CurrentUser?.IdRol == 1 || CurrentUser?.Rol?.Nombre.Equals("Administrador", StringComparison.OrdinalIgnoreCase) == true;
    public bool IsSupervisor => CurrentUser?.IdRol == 2 || CurrentUser?.Rol?.Nombre.Equals("Supervisor", StringComparison.OrdinalIgnoreCase) == true || CurrentUser?.Rol?.Nombre.Equals("Gerente", StringComparison.OrdinalIgnoreCase) == true;
    public bool IsCajero => CurrentUser?.IdRol == 3 || CurrentUser?.Rol?.Nombre.Equals("Cajero", StringComparison.OrdinalIgnoreCase) == true;
    public bool PuedeAdministrar => IsAdmin || IsSupervisor;

    public event Action? OnAuthStateChanged;

    public AuthService(IDbContextFactory<AppDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public async Task<(bool Success, string Message, Usuario? User)> LoginAsync(string username, string password)
    {
        if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
            return (false, "Debe ingresar el usuario y la contraseña.", null);

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            var user = await context.Usuarios
                .Include(u => u.Rol)
                .FirstOrDefaultAsync(u => u.NombreUsuario == username.Trim() && u.Estado);

            if (user == null)
            {
                return (false, "Usuario o contraseña incorrectos.", null);
            }

            // Validar clave mediante BCrypt con tolerancia a texto plano para pruebas
            bool passwordValid = false;
            try
            {
                passwordValid = BCrypt.Net.BCrypt.Verify(password, user.Clave);
            }
            catch
            {
                passwordValid = (user.Clave == password);
            }

            if (!passwordValid)
            {
                return (false, "Usuario o contraseña incorrectos.", null);
            }

            CurrentUser = user;
            OnAuthStateChanged?.Invoke();
            return (true, $"¡Bienvenido {user.Nombre}!", user);
        }
        catch (Exception ex)
        {
            return (false, $"Error de autenticación: {ex.Message}", null);
        }
    }

    public void Logout()
    {
        CurrentUser = null;
        OnAuthStateChanged?.Invoke();
    }

    public async Task<bool> VerifyUserPasswordAsync(int idUsuario, string password)
    {
        if (string.IsNullOrWhiteSpace(password)) return false;
        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            var user = await context.Usuarios.FindAsync(idUsuario);
            if (user == null || !user.Estado) return false;

            try { return BCrypt.Net.BCrypt.Verify(password, user.Clave); }
            catch { return user.Clave == password; }
        }
        catch { return false; }
    }

    public async Task<(bool Success, string Message, Usuario? SupervisorUser)> VerifySupervisorOrAdminCredentialsAsync(string username, string password)
    {
        if (string.IsNullOrWhiteSpace(username) || string.IsNullOrWhiteSpace(password))
            return (false, "Debe ingresar el usuario y la contraseña del Administrador / Supervisor.", null);

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            var user = await context.Usuarios
                .Include(u => u.Rol)
                .FirstOrDefaultAsync(u => u.NombreUsuario == username.Trim() && u.Estado);

            if (user == null)
                return (false, "Usuario Administrador o Supervisor no encontrado.", null);

            bool esAdminOSupervisor = user.IdRol == 1 || user.IdRol == 2 ||
                user.Rol?.Nombre.Equals("Administrador", StringComparison.OrdinalIgnoreCase) == true ||
                user.Rol?.Nombre.Equals("Supervisor", StringComparison.OrdinalIgnoreCase) == true ||
                user.Rol?.Nombre.Equals("Gerente", StringComparison.OrdinalIgnoreCase) == true;

            if (!esAdminOSupervisor)
                return (false, "El usuario ingresado no posee permisos de Administrador o Supervisor.", null);

            bool passwordValid = false;
            try { passwordValid = BCrypt.Net.BCrypt.Verify(password, user.Clave); }
            catch { passwordValid = (user.Clave == password); }

            if (!passwordValid)
                return (false, "Contraseña de Administrador / Supervisor incorrecta.", null);

            return (true, "Autorización concedida.", user);
        }
        catch (Exception ex)
        {
            return (false, $"Error al verificar credenciales: {ex.Message}", null);
        }
    }
}
