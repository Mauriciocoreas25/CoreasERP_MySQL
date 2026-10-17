using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using CoreasERP.Models;
using CoreasERP.Models.Api;

namespace CoreasERP.Services.ApiClients;

internal static class ApiHttpHelper
{
    public static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = true,
        ReferenceHandler = ReferenceHandler.IgnoreCycles
    };

    public static HttpClient CreateClient(IConnectionConfigService config)
    {
        var baseUrl = config.GetApiBaseUrl().TrimEnd('/') + "/";
        return new HttpClient
        {
            BaseAddress = new Uri(baseUrl),
            Timeout = TimeSpan.FromSeconds(25)
        };
    }
}

public class HybridAuthService : IAuthService
{
    private readonly AuthService _direct;
    private readonly IConnectionConfigService _config;
    private Usuario? _apiUser;

    public HybridAuthService(AuthService direct, IConnectionConfigService config)
    {
        _direct = direct;
        _config = config;
        _direct.OnAuthStateChanged += () => OnAuthStateChanged?.Invoke();
    }

    public Usuario? CurrentUser => _config.IsApiModeEnabled() ? _apiUser : _direct.CurrentUser;
    public bool IsAuthenticated => CurrentUser != null;
    public bool IsAdmin => CurrentUser?.IdRol == 1 || CurrentUser?.Rol?.Nombre.Equals("Administrador", StringComparison.OrdinalIgnoreCase) == true;
    public bool IsSupervisor => CurrentUser?.IdRol == 2 || CurrentUser?.Rol?.Nombre.Equals("Supervisor", StringComparison.OrdinalIgnoreCase) == true || CurrentUser?.Rol?.Nombre.Equals("Gerente", StringComparison.OrdinalIgnoreCase) == true;
    public bool IsCajero => CurrentUser?.IdRol == 3 || CurrentUser?.Rol?.Nombre.Equals("Cajero", StringComparison.OrdinalIgnoreCase) == true;
    public bool PuedeAdministrar => IsAdmin || IsSupervisor;

    public event Action? OnAuthStateChanged;

    public async Task<(bool Success, string Message, Usuario? User)> LoginAsync(string username, string password)
    {
        if (!_config.IsApiModeEnabled())
            return await _direct.LoginAsync(username, password);

        try
        {
            using var http = ApiHttpHelper.CreateClient(_config);
            var resp = await http.PostAsJsonAsync("api/auth/login", new LoginRequestDto { Username = username, Password = password });
            var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<Usuario>>(ApiHttpHelper.JsonOptions);
            if (res != null && res.Success && res.Data != null)
            {
                _apiUser = res.Data;
                OnAuthStateChanged?.Invoke();
                return (true, res.Message, res.Data);
            }
            return (false, res?.Message ?? "Error de autenticación con la API.", null);
        }
        catch (Exception ex)
        {
            return (false, $"Error conectando a la API: {ex.Message}", null);
        }
    }

    public void Logout()
    {
        _apiUser = null;
        _direct.Logout();
        OnAuthStateChanged?.Invoke();
    }

    public async Task<bool> VerifyUserPasswordAsync(int idUsuario, string password)
    {
        if (!_config.IsApiModeEnabled())
            return await _direct.VerifyUserPasswordAsync(idUsuario, password);

        try
        {
            using var http = ApiHttpHelper.CreateClient(_config);
            var resp = await http.PostAsJsonAsync("api/auth/verify-password", new VerifyPasswordRequestDto { IdUsuario = idUsuario, Password = password });
            var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<bool>>(ApiHttpHelper.JsonOptions);
            return res?.Success == true && res.Data;
        }
        catch
        {
            return false;
        }
    }

    public async Task<(bool Success, string Message, Usuario? SupervisorUser)> VerifySupervisorOrAdminCredentialsAsync(string username, string password)
    {
        if (!_config.IsApiModeEnabled())
            return await _direct.VerifySupervisorOrAdminCredentialsAsync(username, password);

        try
        {
            using var http = ApiHttpHelper.CreateClient(_config);
            var resp = await http.PostAsJsonAsync("api/auth/verify-supervisor", new LoginRequestDto { Username = username, Password = password });
            var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<Usuario>>(ApiHttpHelper.JsonOptions);
            if (res != null)
                return (res.Success, res.Message, res.Data);
            return (false, "Respuesta inválida de la API.", null);
        }
        catch (Exception ex)
        {
            return (false, $"Error de conexión con la API: {ex.Message}", null);
        }
    }
}

public class HybridCategoryService : ICategoryService
{
    private readonly CategoryService _direct;
    private readonly IConnectionConfigService _config;

    public HybridCategoryService(CategoryService direct, IConnectionConfigService config)
    {
        _direct = direct;
        _config = config;
    }

    public async Task<List<CategoriaDto>> GetAllWithCountAsync()
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetAllWithCountAsync();
        using var http = ApiHttpHelper.CreateClient(_config);
        return await http.GetFromJsonAsync<List<CategoriaDto>>("api/categorias/with-count", ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<List<Categoria>> GetAllAsync()
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetAllAsync();
        using var http = ApiHttpHelper.CreateClient(_config);
        return await http.GetFromJsonAsync<List<Categoria>>("api/categorias", ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<(bool Success, string Message)> SaveAsync(Categoria categoria)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.SaveAsync(categoria);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/categorias", categoria);
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al guardar categoría vía API.");
    }

    public async Task<(bool Success, string Message)> DeleteAsync(int id)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.DeleteAsync(id);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.DeleteAsync($"api/categorias/{id}");
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al eliminar categoría vía API.");
    }

    public Task<string> GuardarImagenCategoriaAsync(Stream stream, string fileName)
        => _direct.GuardarImagenCategoriaAsync(stream, fileName);
}

public class HybridProductService : IProductService
{
    private readonly ProductService _direct;
    private readonly IConnectionConfigService _config;

    public HybridProductService(ProductService direct, IConnectionConfigService config)
    {
        _direct = direct;
        _config = config;
    }

    public async Task<List<Producto>> GetAllAsync(string? busqueda = null, int? idCategoria = null, bool? soloActivos = null)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetAllAsync(busqueda, idCategoria, soloActivos);
        using var http = ApiHttpHelper.CreateClient(_config);
        var q = new List<string>();
        if (!string.IsNullOrWhiteSpace(busqueda)) q.Add($"busqueda={Uri.EscapeDataString(busqueda)}");
        if (idCategoria.HasValue) q.Add($"idCategoria={idCategoria.Value}");
        if (soloActivos.HasValue) q.Add($"soloActivos={soloActivos.Value}");
        string url = "api/productos" + (q.Count > 0 ? "?" + string.Join("&", q) : "");
        return await http.GetFromJsonAsync<List<Producto>>(url, ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<Producto?> GetByIdAsync(int id)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetByIdAsync(id);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.GetAsync($"api/productos/{id}");
        if (!resp.IsSuccessStatusCode) return null;
        return await resp.Content.ReadFromJsonAsync<Producto>(ApiHttpHelper.JsonOptions);
    }

    public async Task<Producto?> GetByCodigoAsync(string codigo)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetByCodigoAsync(codigo);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.GetAsync($"api/productos/by-codigo/{Uri.EscapeDataString(codigo)}");
        if (!resp.IsSuccessStatusCode) return null;
        return await resp.Content.ReadFromJsonAsync<Producto>(ApiHttpHelper.JsonOptions);
    }

    public async Task<(bool Success, string Message, Producto? Producto)> SaveAsync(Producto producto)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.SaveAsync(producto);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/productos", producto);
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<Producto>>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al guardar producto vía API.", res?.Data);
    }

    public async Task<(bool Success, string Message)> ToggleEstadoAsync(int id)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.ToggleEstadoAsync(id);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsync($"api/productos/{id}/toggle-estado", null);
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error vía API.");
    }

    public async Task<(bool CanDelete, string Message)> PuedeEliminarProductoAsync(int id)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.PuedeEliminarProductoAsync(id);
        using var http = ApiHttpHelper.CreateClient(_config);
        var res = await http.GetFromJsonAsync<ApiResultDto>($"api/productos/{id}/can-delete", ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "");
    }

    public async Task<(bool Success, string Message)> DeleteAsync(int id)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.DeleteAsync(id);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.DeleteAsync($"api/productos/{id}");
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al eliminar producto vía API.");
    }

    public async Task<(bool Success, string Message)> AjustarStockSupervisadoAsync(int idProducto, decimal nuevoStock, string motivo, string usuarioSupervisor, string claveSupervisor)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.AjustarStockSupervisadoAsync(idProducto, nuevoStock, motivo, usuarioSupervisor, claveSupervisor);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/productos/ajustar-stock", new AjusteStockSupervisadoRequestDto
        {
            IdProducto = idProducto,
            NuevoStock = nuevoStock,
            Motivo = motivo,
            UsuarioSupervisor = usuarioSupervisor,
            ClaveSupervisor = claveSupervisor
        });
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al ajustar stock vía API.");
    }

    public async Task<List<ProductoMaterial>> GetMaterialesAsync(int idProductoPadre)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetMaterialesAsync(idProductoPadre);
        using var http = ApiHttpHelper.CreateClient(_config);
        return await http.GetFromJsonAsync<List<ProductoMaterial>>($"api/productos/{idProductoPadre}/materiales", ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<(bool Success, string Message)> AgregarMaterialAsync(int idProductoPadre, int idProductoInsumo, decimal cantidad)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.AgregarMaterialAsync(idProductoPadre, idProductoInsumo, cantidad);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/productos/materiales", new AgregarMaterialRequestDto
        {
            IdProductoPadre = idProductoPadre,
            IdProductoInsumo = idProductoInsumo,
            Cantidad = cantidad
        });
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al agregar insumo vía API.");
    }

    public async Task<(bool Success, string Message)> EliminarMaterialAsync(int idProductoMaterial)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.EliminarMaterialAsync(idProductoMaterial);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.DeleteAsync($"api/productos/materiales/{idProductoMaterial}");
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al eliminar insumo vía API.");
    }

    public async Task<List<Producto>> GetLowStockAsync()
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetLowStockAsync();
        using var http = ApiHttpHelper.CreateClient(_config);
        return await http.GetFromJsonAsync<List<Producto>>("api/productos/low-stock", ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<List<Producto>> SearchAsync(string? busqueda, int limit = 50, bool? soloActivos = null, bool? soloConStock = null)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.SearchAsync(busqueda, limit, soloActivos, soloConStock);
        using var http = ApiHttpHelper.CreateClient(_config);
        var q = new List<string> { $"limit={limit}" };
        if (!string.IsNullOrWhiteSpace(busqueda)) q.Add($"busqueda={Uri.EscapeDataString(busqueda)}");
        if (soloActivos.HasValue) q.Add($"soloActivos={soloActivos.Value}");
        if (soloConStock.HasValue) q.Add($"soloConStock={soloConStock.Value}");
        return await http.GetFromJsonAsync<List<Producto>>("api/productos/search?" + string.Join("&", q), ApiHttpHelper.JsonOptions) ?? new();
    }

    public string GenerateRandomBarcode() => _direct.GenerateRandomBarcode();

    public Task<string> GuardarImagenProductoAsync(Stream stream, string fileName)
        => _direct.GuardarImagenProductoAsync(stream, fileName);

    public bool AbrirCarpetaImagenesLocal() => _direct.AbrirCarpetaImagenesLocal();
}

public class HybridCustomerService : ICustomerService
{
    private readonly CustomerService _direct;
    private readonly IConnectionConfigService _config;

    public HybridCustomerService(CustomerService direct, IConnectionConfigService config)
    {
        _direct = direct;
        _config = config;
    }

    public async Task<List<Cliente>> GetAllAsync(string? busqueda = null, string? tipoPersona = null)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetAllAsync(busqueda, tipoPersona);
        using var http = ApiHttpHelper.CreateClient(_config);
        var q = new List<string>();
        if (!string.IsNullOrWhiteSpace(busqueda)) q.Add($"busqueda={Uri.EscapeDataString(busqueda)}");
        if (!string.IsNullOrWhiteSpace(tipoPersona)) q.Add($"tipoPersona={Uri.EscapeDataString(tipoPersona)}");
        string url = "api/clientes" + (q.Count > 0 ? "?" + string.Join("&", q) : "");
        return await http.GetFromJsonAsync<List<Cliente>>(url, ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<Cliente?> GetByIdAsync(int id)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetByIdAsync(id);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.GetAsync($"api/clientes/{id}");
        if (!resp.IsSuccessStatusCode) return null;
        return await resp.Content.ReadFromJsonAsync<Cliente>(ApiHttpHelper.JsonOptions);
    }

    public async Task<(bool Success, string Message, Cliente? Cliente)> SaveAsync(Cliente cliente)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.SaveAsync(cliente);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/clientes", cliente);
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<Cliente>>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al guardar cliente vía API.", res?.Data);
    }

    public async Task<(bool Success, string Message)> DeleteAsync(int id)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.DeleteAsync(id);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.DeleteAsync($"api/clientes/{id}");
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al eliminar cliente vía API.");
    }
}

public class HybridPosService : IPosService
{
    private readonly PosService _direct;
    private readonly IConnectionConfigService _config;

    public HybridPosService(PosService direct, IConnectionConfigService config)
    {
        _direct = direct;
        _config = config;
    }

    public async Task<(bool Success, string Message, Venta? Venta)> RegistrarVentaAsync(int idCliente, int idUsuario, string tipoComprobante, string metodoPago, decimal pagoCon, List<CartItemDto> items)
    {
        if (!_config.IsApiModeEnabled())
            return await _direct.RegistrarVentaAsync(idCliente, idUsuario, tipoComprobante, metodoPago, pagoCon, items);

        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/ventas", new RegistrarVentaRequestDto
        {
            IdCliente = idCliente,
            IdUsuario = idUsuario,
            TipoComprobante = tipoComprobante,
            MetodoPago = metodoPago,
            PagoCon = pagoCon,
            Items = items
        });
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<Venta>>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al registrar venta vía API.", res?.Data);
    }

    public async Task<(bool Success, string Message)> AnularVentaAsync(int idVenta)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.AnularVentaAsync(idVenta);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsync($"api/ventas/{idVenta}/anular", null);
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al anular venta vía API.");
    }

    public async Task<List<Venta>> GetVentasAsync(DateTime? fecha = null, string? busqueda = null)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetVentasAsync(fecha, busqueda);
        using var http = ApiHttpHelper.CreateClient(_config);
        var q = new List<string>();
        if (fecha.HasValue) q.Add($"fecha={fecha.Value:yyyy-MM-dd}");
        if (!string.IsNullOrWhiteSpace(busqueda)) q.Add($"busqueda={Uri.EscapeDataString(busqueda)}");
        string url = "api/ventas" + (q.Count > 0 ? "?" + string.Join("&", q) : "");
        return await http.GetFromJsonAsync<List<Venta>>(url, ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<Venta?> GetVentaByIdAsync(int idVenta)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetVentaByIdAsync(idVenta);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.GetAsync($"api/ventas/{idVenta}");
        if (!resp.IsSuccessStatusCode) return null;
        return await resp.Content.ReadFromJsonAsync<Venta>(ApiHttpHelper.JsonOptions);
    }

    public async Task<(bool Success, string Message, decimal TotalCostoMerma, List<Merma> Mermas)> RegistrarMermaLoteAsync(List<CartItemDto> items, string motivo, int idSupervisor, int idCajero, string? notaAdicional = null)
    {
        if (!_config.IsApiModeEnabled())
            return await _direct.RegistrarMermaLoteAsync(items, motivo, idSupervisor, idCajero, notaAdicional);

        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/ventas/mermas-lote", new RegistrarMermaLoteRequestDto
        {
            Items = items,
            Motivo = motivo,
            IdSupervisor = idSupervisor,
            IdCajero = idCajero,
            NotaAdicional = notaAdicional
        });
        var res = await resp.Content.ReadFromJsonAsync<MermaLoteResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al registrar merma vía API.", res?.TotalCostoMerma ?? 0m, res?.Mermas ?? new());
    }
}

public class HybridCashRegisterService : ICashRegisterService
{
    private readonly CashRegisterService _direct;
    private readonly IConnectionConfigService _config;

    public HybridCashRegisterService(CashRegisterService direct, IConnectionConfigService config)
    {
        _direct = direct;
        _config = config;
    }

    public async Task<CorteCaja?> GetCorteActivoAsync(int? idUsuario = null)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetCorteActivoAsync(idUsuario);
        using var http = ApiHttpHelper.CreateClient(_config);
        string url = "api/caja/activo" + (idUsuario.HasValue ? $"?idUsuario={idUsuario.Value}" : "");
        var resp = await http.GetAsync(url);
        if (!resp.IsSuccessStatusCode || resp.StatusCode == System.Net.HttpStatusCode.NoContent) return null;
        var text = await resp.Content.ReadAsStringAsync();
        if (string.IsNullOrWhiteSpace(text) || text == "null") return null;
        return JsonSerializer.Deserialize<CorteCaja>(text, ApiHttpHelper.JsonOptions);
    }

    public async Task<(bool Success, string Message, CorteCaja? Corte)> AbrirCajaAsync(int idUsuario, decimal montoInicial)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.AbrirCajaAsync(idUsuario, montoInicial);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/caja/abrir", new AbrirCajaRequestDto { IdUsuario = idUsuario, MontoInicial = montoInicial });
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<CorteCaja>>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al abrir caja vía API.", res?.Data);
    }

    public async Task<(bool Success, string Message, CorteCaja? Corte)> ActualizarMontoInicialAsync(int idCorte, decimal nuevoMontoInicial)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.ActualizarMontoInicialAsync(idCorte, nuevoMontoInicial);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/caja/actualizar-monto-inicial", new ActualizarMontoInicialRequestDto { IdCorte = idCorte, NuevoMontoInicial = nuevoMontoInicial });
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<CorteCaja>>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error vía API.", res?.Data);
    }

    public async Task<(bool Success, string Message, CorteCaja? Corte)> CerrarCajaAsync(int idCorte, decimal montoFinal, decimal? diferencia = null)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.CerrarCajaAsync(idCorte, montoFinal, diferencia);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/caja/cerrar", new CerrarCajaRequestDto { IdCorte = idCorte, MontoFinal = montoFinal, Diferencia = diferencia });
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<CorteCaja>>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al cerrar caja vía API.", res?.Data);
    }

    public async Task<(bool Success, string Message, MovimientoCaja? Movimiento)> RegistrarMovimientoCajaAsync(int idUsuario, string tipo, decimal monto, string motivo, int? idCorte = null)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.RegistrarMovimientoCajaAsync(idUsuario, tipo, monto, motivo, idCorte);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/caja/movimientos", new RegistrarMovimientoCajaRequestDto
        {
            IdUsuario = idUsuario,
            Tipo = tipo,
            Monto = monto,
            Motivo = motivo,
            IdCorte = idCorte
        });
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<MovimientoCaja>>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error vía API.", res?.Data);
    }

    public async Task<List<MovimientoCaja>> GetMovimientosCajaAsync(int? idCorte = null, DateTime? fechaDesde = null, DateTime? fechaHasta = null)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetMovimientosCajaAsync(idCorte, fechaDesde, fechaHasta);
        using var http = ApiHttpHelper.CreateClient(_config);
        var q = new List<string>();
        if (idCorte.HasValue) q.Add($"idCorte={idCorte.Value}");
        if (fechaDesde.HasValue) q.Add($"fechaDesde={fechaDesde.Value:yyyy-MM-dd}");
        if (fechaHasta.HasValue) q.Add($"fechaHasta={fechaHasta.Value:yyyy-MM-dd}");
        string url = "api/caja/movimientos" + (q.Count > 0 ? "?" + string.Join("&", q) : "");
        return await http.GetFromJsonAsync<List<MovimientoCaja>>(url, ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<ResumenCorteDto> GenerarResumenCorteAsync(int idCorte, string tipoCorte = "CORTE X", DesgloseDenominacionDto? desgloseFisico = null)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GenerarResumenCorteAsync(idCorte, tipoCorte, desgloseFisico);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/caja/resumen", new GenerarResumenCorteRequestDto
        {
            IdCorte = idCorte,
            TipoCorte = tipoCorte,
            DesgloseFisico = desgloseFisico
        });
        return await resp.Content.ReadFromJsonAsync<ResumenCorteDto>(ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<List<CorteCaja>> GetHistorialCortesAsync()
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetHistorialCortesAsync();
        using var http = ApiHttpHelper.CreateClient(_config);
        return await http.GetFromJsonAsync<List<CorteCaja>>("api/caja/historial", ApiHttpHelper.JsonOptions) ?? new();
    }
}

public class HybridPurchaseService : IPurchaseService
{
    private readonly PurchaseService _direct;
    private readonly IConnectionConfigService _config;

    public HybridPurchaseService(PurchaseService direct, IConnectionConfigService config)
    {
        _direct = direct;
        _config = config;
    }

    public async Task<List<Proveedor>> GetProveedoresAsync()
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetProveedoresAsync();
        using var http = ApiHttpHelper.CreateClient(_config);
        return await http.GetFromJsonAsync<List<Proveedor>>("api/compras/proveedores", ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<(bool Success, string Message, Proveedor? Proveedor)> SaveProveedorAsync(Proveedor proveedor)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.SaveProveedorAsync(proveedor);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/compras/proveedores", proveedor);
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<Proveedor>>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al guardar proveedor vía API.", res?.Data);
    }

    public async Task<List<Compra>> GetComprasAsync(DateTime? fecha = null, string? busqueda = null)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetComprasAsync(fecha, busqueda);
        using var http = ApiHttpHelper.CreateClient(_config);
        var q = new List<string>();
        if (fecha.HasValue) q.Add($"fecha={fecha.Value:yyyy-MM-dd}");
        if (!string.IsNullOrWhiteSpace(busqueda)) q.Add($"busqueda={Uri.EscapeDataString(busqueda)}");
        string url = "api/compras" + (q.Count > 0 ? "?" + string.Join("&", q) : "");
        return await http.GetFromJsonAsync<List<Compra>>(url, ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<Compra?> GetCompraByIdAsync(int idCompra)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetCompraByIdAsync(idCompra);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.GetAsync($"api/compras/{idCompra}");
        if (!resp.IsSuccessStatusCode) return null;
        return await resp.Content.ReadFromJsonAsync<Compra>(ApiHttpHelper.JsonOptions);
    }

    public async Task<(bool Success, string Message, Compra? Compra)> RegistrarCompraAsync(int idProveedor, int idUsuario, string numFactura, string? observaciones, List<PurchaseItemDto> items)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.RegistrarCompraAsync(idProveedor, idUsuario, numFactura, observaciones, items);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/compras", new RegistrarCompraRequestDto
        {
            IdProveedor = idProveedor,
            IdUsuario = idUsuario,
            NumFactura = numFactura,
            Observaciones = observaciones,
            Items = items
        });
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<Compra>>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al registrar compra vía API.", res?.Data);
    }

    public async Task<(bool Success, string Message)> AnularCompraAsync(int idCompra)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.AnularCompraAsync(idCompra);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsync($"api/compras/{idCompra}/anular", null);
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al anular compra vía API.");
    }
}

public class HybridCreditService : ICreditService
{
    private readonly CreditService _direct;
    private readonly IConnectionConfigService _config;

    public HybridCreditService(CreditService direct, IConnectionConfigService config)
    {
        _direct = direct;
        _config = config;
    }

    public async Task<List<CuentaCobrar>> GetCuentasAsync(string? busqueda = null, string? estado = null)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetCuentasAsync(busqueda, estado);
        using var http = ApiHttpHelper.CreateClient(_config);
        var q = new List<string>();
        if (!string.IsNullOrWhiteSpace(busqueda)) q.Add($"busqueda={Uri.EscapeDataString(busqueda)}");
        if (!string.IsNullOrWhiteSpace(estado)) q.Add($"estado={Uri.EscapeDataString(estado)}");
        string url = "api/creditos" + (q.Count > 0 ? "?" + string.Join("&", q) : "");
        return await http.GetFromJsonAsync<List<CuentaCobrar>>(url, ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<CuentaCobrar?> GetCuentaByIdAsync(int idCuentaCobrar)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetCuentaByIdAsync(idCuentaCobrar);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.GetAsync($"api/creditos/{idCuentaCobrar}");
        if (!resp.IsSuccessStatusCode) return null;
        return await resp.Content.ReadFromJsonAsync<CuentaCobrar>(ApiHttpHelper.JsonOptions);
    }

    public async Task<(bool Success, string Message, Abono? Abono)> RegistrarAbonoAsync(int idCuentaCobrar, int idUsuario, decimal monto, string metodoPago, string? notas)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.RegistrarAbonoAsync(idCuentaCobrar, idUsuario, monto, metodoPago, notas);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/creditos/abonos", new RegistrarAbonoRequestDto
        {
            IdCuentaCobrar = idCuentaCobrar,
            IdUsuario = idUsuario,
            Monto = monto,
            MetodoPago = metodoPago,
            Notas = notas
        });
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<Abono>>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error al registrar abono vía API.", res?.Data);
    }
}

public class HybridPriceChangeService : IPriceChangeService
{
    private readonly PriceChangeService _direct;
    private readonly IConnectionConfigService _config;

    public HybridPriceChangeService(PriceChangeService direct, IConnectionConfigService config)
    {
        _direct = direct;
        _config = config;
    }

    public async Task<List<CambioPrecio>> GetPendientesAsync()
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetPendientesAsync();
        using var http = ApiHttpHelper.CreateClient(_config);
        return await http.GetFromJsonAsync<List<CambioPrecio>>("api/cambios-precio/pendientes", ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<int> GetPendientesCountAsync()
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetPendientesCountAsync();
        using var http = ApiHttpHelper.CreateClient(_config);
        return await http.GetFromJsonAsync<int>("api/cambios-precio/pendientes/count", ApiHttpHelper.JsonOptions);
    }

    public async Task<List<CambioPrecio>> GetAplicadosRecientesAsync(int limit = 50)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetAplicadosRecientesAsync(limit);
        using var http = ApiHttpHelper.CreateClient(_config);
        return await http.GetFromJsonAsync<List<CambioPrecio>>($"api/cambios-precio/aplicados?limit={limit}", ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<(bool Success, string Message)> AplicarCambioAsync(int idCambioPrecio, decimal? precioVentaFinal = null)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.AplicarCambioAsync(idCambioPrecio, precioVentaFinal);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/cambios-precio/aplicar", new AplicarCambioPrecioRequestDto
        {
            IdCambioPrecio = idCambioPrecio,
            PrecioVentaFinal = precioVentaFinal
        });
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error vía API.");
    }

    public async Task<(bool Success, string Message)> DescartarCambioAsync(int idCambioPrecio)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.DescartarCambioAsync(idCambioPrecio);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsync($"api/cambios-precio/{idCambioPrecio}/descartar", null);
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error vía API.");
    }

    public async Task<(bool Success, string Message, int TotalAplicados)> AplicarTodosPendientesAsync()
    {
        if (!_config.IsApiModeEnabled()) return await _direct.AplicarTodosPendientesAsync();
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsync("api/cambios-precio/aplicar-todos", null);
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<int>>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error vía API.", res?.Data ?? 0);
    }
}

public class HybridPromotionService : IPromotionService
{
    private readonly PromotionService _direct;
    private readonly IConnectionConfigService _config;

    public HybridPromotionService(PromotionService direct, IConnectionConfigService config)
    {
        _direct = direct;
        _config = config;
    }

    public async Task<List<Promocion>> GetAllAsync()
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetAllAsync();
        using var http = ApiHttpHelper.CreateClient(_config);
        return await http.GetFromJsonAsync<List<Promocion>>("api/promociones", ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<List<Promocion>> GetActiveAsync()
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetActiveAsync();
        using var http = ApiHttpHelper.CreateClient(_config);
        return await http.GetFromJsonAsync<List<Promocion>>("api/promociones/activas", ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<(bool Success, string Message, Promocion? Promocion)> SaveAsync(Promocion promocion)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.SaveAsync(promocion);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/promociones", promocion);
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<Promocion>>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error vía API.", res?.Data);
    }

    public async Task<(bool Success, string Message)> ToggleEstadoAsync(int idPromocion)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.ToggleEstadoAsync(idPromocion);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsync($"api/promociones/{idPromocion}/toggle-estado", null);
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error vía API.");
    }

    public async Task<(bool Success, string Message)> DeleteAsync(int idPromocion)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.DeleteAsync(idPromocion);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.DeleteAsync($"api/promociones/{idPromocion}");
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error vía API.");
    }
}

public class HybridUserService : IUserService
{
    private readonly UserService _direct;
    private readonly IConnectionConfigService _config;

    public HybridUserService(UserService direct, IConnectionConfigService config)
    {
        _direct = direct;
        _config = config;
    }

    public async Task<List<Usuario>> GetAllAsync()
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetAllAsync();
        using var http = ApiHttpHelper.CreateClient(_config);
        return await http.GetFromJsonAsync<List<Usuario>>("api/usuarios", ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<List<Rol>> GetRolesAsync()
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetRolesAsync();
        using var http = ApiHttpHelper.CreateClient(_config);
        return await http.GetFromJsonAsync<List<Rol>>("api/usuarios/roles", ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<(bool Success, string Message, Usuario? Usuario)> SaveAsync(Usuario usuario, string? nuevaClave = null)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.SaveAsync(usuario, nuevaClave);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/usuarios", new SaveUsuarioRequestDto { Usuario = usuario, NuevaClave = nuevaClave });
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto<Usuario>>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error vía API.", res?.Data);
    }

    public async Task<(bool Success, string Message)> ToggleEstadoAsync(int idUsuario)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.ToggleEstadoAsync(idUsuario);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsync($"api/usuarios/{idUsuario}/toggle-estado", null);
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error vía API.");
    }
}

public class HybridSettingsService : ISettingsService
{
    private readonly SettingsService _direct;
    private readonly IConnectionConfigService _config;

    public HybridSettingsService(SettingsService direct, IConnectionConfigService config)
    {
        _direct = direct;
        _config = config;
    }

    public async Task<ConfiguracionNegocio> GetConfiguracionAsync()
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetConfiguracionAsync();
        using var http = ApiHttpHelper.CreateClient(_config);
        return await http.GetFromJsonAsync<ConfiguracionNegocio>("api/configuracion", ApiHttpHelper.JsonOptions) ?? new();
    }

    public async Task<(bool Success, string Message)> SaveConfiguracionAsync(ConfiguracionNegocio config)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.SaveConfiguracionAsync(config);
        using var http = ApiHttpHelper.CreateClient(_config);
        var resp = await http.PostAsJsonAsync("api/configuracion", config);
        var res = await resp.Content.ReadFromJsonAsync<ApiResultDto>(ApiHttpHelper.JsonOptions);
        return (res?.Success ?? false, res?.Message ?? "Error vía API.");
    }
}

public class HybridDashboardService : IDashboardService
{
    private readonly DashboardService _direct;
    private readonly IConnectionConfigService _config;

    public HybridDashboardService(DashboardService direct, IConnectionConfigService config)
    {
        _direct = direct;
        _config = config;
    }

    public async Task<DashboardFinancieroDto> GetDashboardFinancieroAsync(string periodo = "Mes", DateTime? fechaDesde = null, DateTime? fechaHasta = null)
    {
        if (!_config.IsApiModeEnabled()) return await _direct.GetDashboardFinancieroAsync(periodo, fechaDesde, fechaHasta);
        using var http = ApiHttpHelper.CreateClient(_config);
        var q = new List<string> { $"periodo={Uri.EscapeDataString(periodo)}" };
        if (fechaDesde.HasValue) q.Add($"fechaDesde={fechaDesde.Value:yyyy-MM-dd}");
        if (fechaHasta.HasValue) q.Add($"fechaHasta={fechaHasta.Value:yyyy-MM-dd}");
        return await http.GetFromJsonAsync<DashboardFinancieroDto>("api/dashboard?" + string.Join("&", q), ApiHttpHelper.JsonOptions) ?? new();
    }
}
