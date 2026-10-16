using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Models;

namespace CoreasERP.Services;

public class CategoriaDto
{
    public int IdCategoria { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public string? Descripcion { get; set; }
    public string Icono { get; set; } = "fa-box";
    public string? ImagenUrl { get; set; }
    public bool Estado { get; set; }
    public int TotalProductos { get; set; }
}

public interface ICategoryService
{
    Task<List<CategoriaDto>> GetAllWithCountAsync();
    Task<List<Categoria>> GetAllAsync();
    Task<(bool Success, string Message)> SaveAsync(Categoria categoria);
    Task<(bool Success, string Message)> DeleteAsync(int id);
    Task<string> GuardarImagenCategoriaAsync(Stream stream, string fileName);
}

public class CategoryService : ICategoryService
{
    private readonly IDbContextFactory<AppDbContext> _contextFactory;

    public CategoryService(IDbContextFactory<AppDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public async Task<List<CategoriaDto>> GetAllWithCountAsync()
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.Categorias
            .Where(c => c.Estado)
            .Select(c => new CategoriaDto
            {
                IdCategoria = c.IdCategoria,
                Nombre = c.Nombre,
                Descripcion = c.Descripcion,
                Icono = string.IsNullOrEmpty(c.Icono) ? "fa-box" : c.Icono,
                ImagenUrl = c.ImagenUrl,
                Estado = c.Estado,
                TotalProductos = c.Productos.Count(p => p.Estado)
            })
            .OrderBy(c => c.Nombre)
            .ToListAsync();
    }

    public async Task<List<Categoria>> GetAllAsync()
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.Categorias
            .Where(c => c.Estado)
            .OrderBy(c => c.Nombre)
            .ToListAsync();
    }

    public async Task<(bool Success, string Message)> SaveAsync(Categoria categoria)
    {
        if (string.IsNullOrWhiteSpace(categoria.Nombre))
            return (false, "El nombre de la categoría es obligatorio.");

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            if (string.IsNullOrWhiteSpace(categoria.Icono))
            {
                categoria.Icono = "fa-box";
            }

            if (categoria.IdCategoria == 0)
            {
                categoria.Nombre = categoria.Nombre.Trim();
                categoria.Estado = true;
                await context.Categorias.AddAsync(categoria);
            }
            else
            {
                var existing = await context.Categorias.FindAsync(categoria.IdCategoria);
                if (existing == null) return (false, "Categoría no encontrada.");
                existing.Nombre = categoria.Nombre.Trim();
                existing.Descripcion = categoria.Descripcion;
                existing.Icono = categoria.Icono;
                existing.ImagenUrl = categoria.ImagenUrl;
            }

            await context.SaveChangesAsync();
            return (true, "Categoría guardada exitosamente.");
        }
        catch (Exception ex)
        {
            return (false, $"Error al guardar categoría: {ex.Message}");
        }
    }

    public async Task<(bool Success, string Message)> DeleteAsync(int id)
    {
        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            var cat = await context.Categorias
                .Include(c => c.Productos)
                .FirstOrDefaultAsync(c => c.IdCategoria == id);

            if (cat == null) return (false, "Categoría no encontrada.");

            if (cat.Productos.Any(p => p.Estado))
            {
                return (false, "No se puede eliminar la categoría porque contiene productos activos.");
            }

            cat.Estado = false;
            await context.SaveChangesAsync();
            return (true, "Categoría eliminada exitosamente.");
        }
        catch (Exception ex)
        {
            return (false, $"Error al eliminar categoría: {ex.Message}");
        }
    }

    public async Task<string> GuardarImagenCategoriaAsync(Stream stream, string fileName)
    {
        string ext = Path.GetExtension(fileName);
        if (string.IsNullOrWhiteSpace(ext)) ext = ".jpg";
        string uniqueName = $"cat_{DateTime.Now:yyyyMMdd_HHmmss}_{Guid.NewGuid().ToString("N")[..6]}{ext}";
        string relativePath = $"uploads/categories/{uniqueName}";

        string runtimeDir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "wwwroot", "uploads", "categories");
        if (!Directory.Exists(runtimeDir))
        {
            Directory.CreateDirectory(runtimeDir);
        }
        string runtimePath = Path.Combine(runtimeDir, uniqueName);

        using var ms = new MemoryStream();
        await stream.CopyToAsync(ms);
        byte[] bytes = ms.ToArray();

        await File.WriteAllBytesAsync(runtimePath, bytes);

        try
        {
            string baseDir = AppContext.BaseDirectory;
            string projectDir = Path.GetFullPath(Path.Combine(baseDir, "..", "..", "..", "..", "..", "wwwroot", "uploads", "categories"));
            if (Directory.Exists(Path.GetDirectoryName(projectDir)))
            {
                if (!Directory.Exists(projectDir)) Directory.CreateDirectory(projectDir);
                await File.WriteAllBytesAsync(Path.Combine(projectDir, uniqueName), bytes);
            }
        }
        catch
        {
            // Ignorar fallback
        }

        return relativePath;
    }
}
