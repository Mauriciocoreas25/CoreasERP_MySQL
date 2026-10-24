using System.Diagnostics;
using System.Net.Http.Json;
using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Models;

namespace CoreasERP.Services;

public interface IProductService
{
    Task<List<Producto>> GetAllAsync(string? busqueda = null, int? idCategoria = null, bool? soloActivos = null);
    Task<Producto?> GetByIdAsync(int id);
    Task<Producto?> GetByCodigoAsync(string codigo);
    Task<(bool Success, string Message, Producto? Producto)> SaveAsync(Producto producto);
    Task<(bool Success, string Message)> ToggleEstadoAsync(int id);
    Task<(bool CanDelete, string Message)> PuedeEliminarProductoAsync(int id);
    Task<(bool Success, string Message)> DeleteAsync(int id);
    Task<(bool Success, string Message)> AjustarStockSupervisadoAsync(int idProducto, decimal nuevoStock, string motivo, string usuarioSupervisor, string claveSupervisor);
    Task<List<ProductoMaterial>> GetMaterialesAsync(int idProductoPadre);
    Task<(bool Success, string Message)> AgregarMaterialAsync(int idProductoPadre, int idProductoInsumo, decimal cantidad);
    Task<(bool Success, string Message)> EliminarMaterialAsync(int idProductoMaterial);
    Task<List<Producto>> GetLowStockAsync();
    Task<List<Producto>> SearchAsync(string? busqueda, int limit = 50, bool? soloActivos = null, bool? soloConStock = null);
    string GenerateRandomBarcode();
    Task<string> GuardarImagenProductoAsync(Stream stream, string fileName);
    bool AbrirCarpetaImagenesLocal();
}

public class ProductService : IProductService
{
    public const string CarpetaImagenesLocalFija = @"C:\CoreasERP\uploads\products";
    private readonly IDbContextFactory<AppDbContext> _contextFactory;

    public ProductService(IDbContextFactory<AppDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
        SincronizarCarpetaImagenesLocal();
    }

    public async Task<List<Producto>> GetAllAsync(string? busqueda = null, int? idCategoria = null, bool? soloActivos = null)
    {
        SincronizarCarpetaImagenesLocal();
        await using var context = await _contextFactory.CreateDbContextAsync();
        var query = context.Productos
            .AsNoTracking()
            .Include(p => p.Categoria)
            .AsQueryable();

        if (soloActivos.HasValue)
        {
            query = query.Where(p => p.Estado == soloActivos.Value);
        }

        if (idCategoria.HasValue && idCategoria.Value > 0)
        {
            query = query.Where(p => p.IdCategoria == idCategoria.Value);
        }

        if (!string.IsNullOrWhiteSpace(busqueda))
        {
            var search = busqueda.Trim().ToLower();
            query = query.Where(p => p.Nombre.ToLower().Contains(search) || p.Codigo.ToLower().Contains(search));
        }

        return await query.OrderByDescending(p => p.IdProducto).ToListAsync();
    }

    public async Task<Producto?> GetByIdAsync(int id)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.Productos
            .Include(p => p.Categoria)
            .Include(p => p.Materiales)
                .ThenInclude(m => m.ProductoInsumo)
            .FirstOrDefaultAsync(p => p.IdProducto == id);
    }

    public async Task<Producto?> GetByCodigoAsync(string codigo)
    {
        if (string.IsNullOrWhiteSpace(codigo)) return null;
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.Productos
            .Include(p => p.Categoria)
            .FirstOrDefaultAsync(p => p.Codigo == codigo.Trim() && p.Estado);
    }

    public async Task<(bool Success, string Message, Producto? Producto)> SaveAsync(Producto producto)
    {
        if (string.IsNullOrWhiteSpace(producto.Codigo))
            return (false, "El código de barras / SKU es requerido.", null);
        if (string.IsNullOrWhiteSpace(producto.Nombre))
            return (false, "El nombre del producto es requerido.", null);
        if (producto.IdCategoria <= 0)
            return (false, "Debe seleccionar una categoría válida.", null);
        if (producto.Stock < 0)
            return (false, "El stock no puede ser negativo.", null);

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();

            // Validar unicidad de código
            var existeCodigo = await context.Productos.AnyAsync(p =>
                p.Codigo == producto.Codigo.Trim() && p.IdProducto != producto.IdProducto);
            if (existeCodigo)
                return (false, "Ya existe otro producto registrado con este código de barras.", null);

            producto.PrecioCompra = Math.Round(Math.Max(0m, producto.PrecioCompra), 3, MidpointRounding.AwayFromZero);
            producto.PrecioVenta = Math.Round(Math.Max(0m, producto.PrecioVenta), 3, MidpointRounding.AwayFromZero);
            producto.PrecioGranel = producto.PrecioGranel.HasValue ? Math.Round(producto.PrecioGranel.Value, 3, MidpointRounding.AwayFromZero) : null;
            producto.CantidadPorEmpaque = producto.CantidadPorEmpaque.HasValue && producto.CantidadPorEmpaque.Value > 0
                ? Math.Round(producto.CantidadPorEmpaque.Value, 3, MidpointRounding.AwayFromZero)
                : 1.000m;
            if (producto.CostoGranel.HasValue && producto.CostoGranel.Value > 0)
            {
                producto.CostoGranel = Math.Round(producto.CostoGranel.Value, 3, MidpointRounding.AwayFromZero);
            }
            else if (producto.PrecioCompra > 0 && producto.CantidadPorEmpaque > 1)
            {
                producto.CostoGranel = Math.Round(producto.PrecioCompra / producto.CantidadPorEmpaque.Value, 3, MidpointRounding.AwayFromZero);
            }
            producto.Stock = Math.Round(producto.Stock, 3, MidpointRounding.AwayFromZero);
            producto.StockMinimo = Math.Round(producto.StockMinimo, 3, MidpointRounding.AwayFromZero);
            producto.MargenExcepcion = Math.Round(producto.MargenExcepcion, 3, MidpointRounding.AwayFromZero);

            if (producto.IdProducto == 0)
            {
                producto.Codigo = producto.Codigo.Trim();
                producto.Nombre = producto.Nombre.Trim();
                producto.FechaCreacion = DateTime.Now;
                producto.Estado = true;
                if (string.IsNullOrWhiteSpace(producto.UnidadMedida)) producto.UnidadMedida = "Unidad";
                if (producto.PrecioGranel.HasValue && producto.PrecioGranel.Value > 0) producto.EsGranel = true;
                await context.Productos.AddAsync(producto);
            }
            else
            {
                var existing = await context.Productos.FindAsync(producto.IdProducto);
                if (existing == null)
                    return (false, "Producto no encontrado.", null);

                existing.IdCategoria = producto.IdCategoria;
                existing.Codigo = producto.Codigo.Trim();
                existing.Nombre = producto.Nombre.Trim();
                existing.Descripcion = producto.Descripcion;
                existing.PrecioCompra = producto.PrecioCompra;
                existing.PrecioVenta = producto.PrecioVenta;
                existing.PrecioGranel = producto.PrecioGranel;
                existing.CostoGranel = producto.CostoGranel;
                existing.CantidadPorEmpaque = producto.CantidadPorEmpaque;
                existing.EsGranel = producto.EsGranel || (producto.PrecioGranel.HasValue && producto.PrecioGranel.Value > 0);
                existing.UnidadMedida = string.IsNullOrWhiteSpace(producto.UnidadMedida) ? "Unidad" : producto.UnidadMedida;
                existing.Stock = producto.Stock;
                existing.StockMinimo = producto.StockMinimo;
                existing.MargenExcepcion = producto.MargenExcepcion;
                existing.Imagen = producto.Imagen;
                existing.ImagenUrl = producto.ImagenUrl;
            }

            await context.SaveChangesAsync();
            return (true, "Producto guardado exitosamente.", producto);
        }
        catch (Exception ex)
        {
            return (false, $"Error al guardar producto: {ex.Message}", null);
        }
    }

    public async Task<(bool Success, string Message)> ToggleEstadoAsync(int id)
    {
        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            var prod = await context.Productos.FindAsync(id);
            if (prod == null) return (false, "Producto no encontrado.");

            prod.Estado = !prod.Estado;
            await context.SaveChangesAsync();
            return (true, $"Producto {(prod.Estado ? "activado" : "desactivado")} exitosamente.");
        }
        catch (Exception ex)
        {
            return (false, $"Error al cambiar estado del producto: {ex.Message}");
        }
    }

    public async Task<(bool CanDelete, string Message)> PuedeEliminarProductoAsync(int id)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        var tieneVentas = await context.DetalleVentas.AnyAsync(d => d.IdProducto == id);
        if (tieneVentas)
        {
            return (false, "No es posible eliminar este producto porque posee historial de ventas vinculado a comprobantes contables. Debe desactivarlo.");
        }
        return (true, "El producto no posee ventas y puede ser eliminado de forma segura.");
    }

    public async Task<(bool Success, string Message)> DeleteAsync(int id)
    {
        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            var prod = await context.Productos.FindAsync(id);
            if (prod == null) return (false, "Producto no encontrado.");

            // Regla estricta: NO eliminar si tiene ventas históricas
            var tieneVentas = await context.DetalleVentas.AnyAsync(d => d.IdProducto == id);
            if (tieneVentas)
            {
                return (false, "No se puede eliminar el producto porque está vinculado al historial de ventas y facturación. Para darlo de baja, utilice la opción Desactivar.");
            }

            // Si no tiene ventas, se procede con eliminación física
            context.Productos.Remove(prod);
            await context.SaveChangesAsync();
            return (true, "Producto eliminado exitosamente del catálogo.");
        }
        catch (Exception ex)
        {
            return (false, $"Error al eliminar producto: {ex.Message}");
        }
    }

    public async Task<(bool Success, string Message)> AjustarStockSupervisadoAsync(int idProducto, decimal nuevoStock, string motivo, string usuarioSupervisor, string claveSupervisor)
    {
        if (string.IsNullOrWhiteSpace(usuarioSupervisor))
            return (false, "Debe ingresar el usuario supervisor.");
        if (string.IsNullOrWhiteSpace(claveSupervisor))
            return (false, "Debe ingresar la contraseña de autorización.");
        if (string.IsNullOrWhiteSpace(motivo))
            return (false, "Debe especificar el motivo del ajuste de inventario.");
        if (nuevoStock < 0)
            return (false, "El stock no puede ser un valor negativo.");

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();

            // 1. Buscar supervisor con rol autorizado (Administrador, Supervisor o Gerente)
            var supervisor = await context.Usuarios
                .Include(u => u.Rol)
                .FirstOrDefaultAsync(u => (u.NombreUsuario == usuarioSupervisor.Trim() || u.Email == usuarioSupervisor.Trim()) && u.Estado);

            if (supervisor == null)
            {
                return (false, "Credenciales inválidas: Usuario no encontrado o inactivo.");
            }

            string rolNombre = supervisor.Rol?.Nombre ?? "";
            if (!rolNombre.Equals("Administrador", StringComparison.OrdinalIgnoreCase) &&
                !rolNombre.Equals("Supervisor", StringComparison.OrdinalIgnoreCase) &&
                !rolNombre.Equals("Gerente", StringComparison.OrdinalIgnoreCase))
            {
                return (false, $"El usuario '{supervisor.Nombre}' no cuenta con privilegios de Supervisor o Administrador para autorizar ajustes.");
            }

            // 2. Verificar contraseña con BCrypt
            bool claveCorrecta = false;
            try
            {
                claveCorrecta = BCrypt.Net.BCrypt.Verify(claveSupervisor, supervisor.Clave);
            }
            catch
            {
                claveCorrecta = false;
            }

            if (!claveCorrecta)
            {
                return (false, "Autorización denegada: Contraseña incorrecta.");
            }

            // 3. Obtener producto y aplicar ajuste con bitácora
            var prod = await context.Productos.FindAsync(idProducto);
            if (prod == null) return (false, "Producto no encontrado.");

            decimal stockAnterior = prod.Stock;
            decimal diferencia = nuevoStock - stockAnterior;

            var ajuste = new AjusteInventario
            {
                IdProducto = idProducto,
                IdUsuarioSupervisor = supervisor.IdUsuario,
                StockAnterior = stockAnterior,
                StockNuevo = nuevoStock,
                Diferencia = diferencia,
                Motivo = motivo.Trim(),
                FechaHora = DateTime.Now
            };

            prod.Stock = nuevoStock;
            await context.AjustesInventario.AddAsync(ajuste);
            await context.SaveChangesAsync();

            return (true, $"Stock ajustado exitosamente de {stockAnterior} a {nuevoStock} unidades. Autorizado por: {supervisor.Nombre}.");
        }
        catch (Exception ex)
        {
            return (false, $"Error al aplicar ajuste de stock: {ex.Message}");
        }
    }

    public async Task<List<ProductoMaterial>> GetMaterialesAsync(int idProductoPadre)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.ProductoMateriales
            .Include(m => m.ProductoInsumo)
                .ThenInclude(i => i!.Categoria)
            .Where(m => m.IdProductoPadre == idProductoPadre)
            .OrderBy(m => m.ProductoInsumo != null ? m.ProductoInsumo.Nombre : "")
            .ToListAsync();
    }

    public async Task<(bool Success, string Message)> AgregarMaterialAsync(int idProductoPadre, int idProductoInsumo, decimal cantidad)
    {
        if (idProductoPadre == idProductoInsumo)
            return (false, "Un producto no puede ser material o insumo de sí mismo.");
        if (cantidad <= 0)
            return (false, "La cantidad de material debe ser mayor a 0.");

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();

            var existente = await context.ProductoMateriales
                .FirstOrDefaultAsync(m => m.IdProductoPadre == idProductoPadre && m.IdProductoInsumo == idProductoInsumo);

            if (existente != null)
            {
                existente.Cantidad = cantidad;
            }
            else
            {
                await context.ProductoMateriales.AddAsync(new ProductoMaterial
                {
                    IdProductoPadre = idProductoPadre,
                    IdProductoInsumo = idProductoInsumo,
                    Cantidad = cantidad,
                    FechaCreacion = DateTime.Now
                });
            }

            await context.SaveChangesAsync();
            return (true, "Material vinculado exitosamente.");
        }
        catch (Exception ex)
        {
            return (false, $"Error al vincular material: {ex.Message}");
        }
    }

    public async Task<(bool Success, string Message)> EliminarMaterialAsync(int idProductoMaterial)
    {
        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            var mat = await context.ProductoMateriales.FindAsync(idProductoMaterial);
            if (mat == null) return (false, "Material no encontrado.");

            context.ProductoMateriales.Remove(mat);
            await context.SaveChangesAsync();
            return (true, "Material retirado de la composición del producto.");
        }
        catch (Exception ex)
        {
            return (false, $"Error al retirar material: {ex.Message}");
        }
    }

    public async Task<List<Producto>> GetLowStockAsync()
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        return await context.Productos
            .Include(p => p.Categoria)
            .Where(p => p.Estado && p.Stock <= p.StockMinimo)
            .OrderBy(p => p.Stock)
            .ToListAsync();
    }
    public async Task<List<Producto>> SearchAsync(string? busqueda, int limit = 50, bool? soloActivos = null, bool? soloConStock = null)
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        var query = context.Productos
            .Include(p => p.Categoria)
            .AsNoTracking()
            .AsQueryable();

        if (soloActivos.HasValue)
        {
            query = query.Where(p => p.Estado == soloActivos.Value);
        }

        if (soloConStock.HasValue && soloConStock.Value)
        {
            query = query.Where(p => p.Stock > 0);
        }

        if (!string.IsNullOrWhiteSpace(busqueda))
        {
            var search = busqueda.Trim().ToLower();
            query = query.Where(p => p.Nombre.ToLower().Contains(search) || p.Codigo.ToLower().Contains(search));
        }

        return await query
            .OrderBy(p => p.Nombre)
            .Take(limit)
            .ToListAsync();
    }

    public string GenerateRandomBarcode()
    {
        var random = new Random();
        long nueveDigitos = random.NextInt64(100000000L, 999999999L);
        string code12 = $"750{nueveDigitos}";

        int sum = 0;
        for (int i = 0; i < 12; i++)
        {
            int d = code12[i] - '0';
            sum += (i % 2 == 0) ? d : d * 3;
        }
        int check = (10 - (sum % 10)) % 10;
        return code12 + check.ToString();
    }

    public static void SincronizarCarpetaImagenesLocal()
    {
        try
        {
            if (!Directory.Exists(CarpetaImagenesLocalFija))
            {
                Directory.CreateDirectory(CarpetaImagenesLocalFija);
            }

            string runtimeDir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "wwwroot", "uploads", "products");
            if (!Directory.Exists(runtimeDir))
            {
                Directory.CreateDirectory(runtimeDir);
            }

            // Copiar cualquier imagen de C:\CoreasERP\uploads\products al wwwroot del ejecutable
            foreach (var file in Directory.GetFiles(CarpetaImagenesLocalFija))
            {
                string fileName = Path.GetFileName(file);
                string destPath = Path.Combine(runtimeDir, fileName);
                if (!File.Exists(destPath) || File.GetLastWriteTimeUtc(file) > File.GetLastWriteTimeUtc(destPath))
                {
                    File.Copy(file, destPath, overwrite: true);
                }
            }
        }
        catch
        {
            // Ignorar errores de permisos en sincronización silenciosa
        }
    }

    public static async Task SubirImagenAlServidorCloudAsync(string fileName, byte[] bytes)
    {
        try
        {
            using var http = new HttpClient { Timeout = TimeSpan.FromSeconds(15) };
            var payload = new
            {
                NombreArchivo = fileName,
                ContenidoBase64 = Convert.ToBase64String(bytes)
            };
            await http.PostAsJsonAsync("http://coreaserp.runasp.net/api/productos/upload-imagen", payload);
        }
        catch
        {
            // Si no hay internet en el momento o la API no responde, continúa sin bloquear el sistema local
        }
    }

    public bool AbrirCarpetaImagenesLocal()
    {
        try
        {
            SincronizarCarpetaImagenesLocal();
            Process.Start("explorer.exe", CarpetaImagenesLocalFija);
            return true;
        }
        catch
        {
            return false;
        }
    }

    public async Task<string> GuardarImagenProductoAsync(Stream stream, string fileName)
    {
        string ext = Path.GetExtension(fileName);
        if (string.IsNullOrWhiteSpace(ext)) ext = ".jpg";
        string cleanName = Path.GetFileNameWithoutExtension(fileName);
        // Si el archivo ya viene con código o nombre limpio, conservarlo o generar único seguro
        string safeBase = System.Text.RegularExpressions.Regex.Replace(cleanName, @"[^a-zA-Z0-9_\-]", "_");
        if (string.IsNullOrWhiteSpace(safeBase)) safeBase = $"prod_{DateTime.Now:yyyyMMdd_HHmmss}";
        string uniqueName = $"{safeBase}{ext}";
        string relativePath = $"uploads/products/{uniqueName}";

        using var ms = new MemoryStream();
        await stream.CopyToAsync(ms);
        byte[] bytes = ms.ToArray();

        // 1. Guardar en la carpeta fija del Disco Local C: (C:\CoreasERP\uploads\products)
        if (!Directory.Exists(CarpetaImagenesLocalFija))
        {
            Directory.CreateDirectory(CarpetaImagenesLocalFija);
        }
        await File.WriteAllBytesAsync(Path.Combine(CarpetaImagenesLocalFija, uniqueName), bytes);

        // 2. Guardar en wwwroot de ejecución del ejecutable instalado
        string runtimeDir = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "wwwroot", "uploads", "products");
        if (!Directory.Exists(runtimeDir))
        {
            Directory.CreateDirectory(runtimeDir);
        }
        await File.WriteAllBytesAsync(Path.Combine(runtimeDir, uniqueName), bytes);

        // 3. Guardar también en el proyecto fuente si existe (modo desarrollo)
        try
        {
            string baseDir = AppContext.BaseDirectory;
            string projectDir = Path.GetFullPath(Path.Combine(baseDir, "..", "..", "..", "..", "..", "wwwroot", "uploads", "products"));
            if (Directory.Exists(Path.GetDirectoryName(projectDir)))
            {
                if (!Directory.Exists(projectDir)) Directory.CreateDirectory(projectDir);
                await File.WriteAllBytesAsync(Path.Combine(projectDir, uniqueName), bytes);
            }
        }
        catch
        {
        }

        // 4. Sincronizar archivo hacia la carpeta uploads/products del servidor web para la App Móvil
        await SubirImagenAlServidorCloudAsync(uniqueName, bytes);

        return relativePath;
    }
}
