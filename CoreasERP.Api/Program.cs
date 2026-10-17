using System.Text.Json.Serialization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Models;
using CoreasERP.Models.Api;
using CoreasERP.Services;
using CoreasERP.Services.Dte;

var builder = WebApplication.CreateBuilder(args);

// Configurar serialización JSON ignorando ciclos de referencias de Entity Framework
builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
    options.SerializerOptions.PropertyNameCaseInsensitive = true;
});

builder.Services.AddControllers().AddJsonOptions(options =>
{
    options.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles;
    options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
});

// Habilitar CORS para App Móvil, Web y clientes remotos
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader());
});

// Resolver cadena de conexión MySQL (soporta archivo .env, variables DB_HOST/DB_USER/DB_PASSWORD, MYSQL_CONNECTION_STRING o appsettings.json)
ConnectionConfigService.EnsureDotEnvLoaded();
string envConn = ConnectionConfigService.ResolveEnvConnectionString();
string rawConn = (!envConn.Contains("Server=127.0.0.1;Port=3306;Database=Coreas_ERP;User=root;Password=;"))
    ? envConn
    : (builder.Configuration.GetConnectionString("DefaultConnection") ?? envConn);

string connectionString = NormalizeMySqlConnectionString(rawConn);

var serverVersion = new MySqlServerVersion(new Version(8, 0, 36));

builder.Services.AddDbContextFactory<AppDbContext>(options =>
{
    options.UseMySql(connectionString, serverVersion);
});

builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseMySql(connectionString, serverVersion);
}, ServiceLifetime.Transient);

// Registrar Servicios de Negocio
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<ICategoryService, CategoryService>();
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<ICustomerService, CustomerService>();
builder.Services.AddScoped<IPosService, PosService>();
builder.Services.AddScoped<ICashRegisterService, CashRegisterService>();
builder.Services.AddScoped<IPurchaseService, PurchaseService>();
builder.Services.AddScoped<IPriceChangeService, PriceChangeService>();
builder.Services.AddScoped<ICreditService, CreditService>();
builder.Services.AddScoped<IPromotionService, PromotionService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<ISettingsService, SettingsService>();
builder.Services.AddScoped<IDashboardService, DashboardService>();
builder.Services.AddScoped<IDteJsonBuilderService, DteJsonBuilderService>();
builder.Services.AddHttpClient<IFelSvApiService, FelSvApiService>();

// Swagger / OpenAPI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new()
    {
        Title = "CoreasERP Cloud REST API (MySQL)",
        Version = "v1",
        Description = "API intermediaria unificada para CoreasERP Escritorio y App Móvil conectada a MySQL en la nube."
    });
});

var app = builder.Build();

string webUploadsDir = Path.Combine(app.Environment.ContentRootPath, "wwwroot", "uploads", "products");
if (!Directory.Exists(webUploadsDir))
{
    Directory.CreateDirectory(webUploadsDir);
}

app.UseCors("AllowAll");
app.UseStaticFiles();
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "CoreasERP API v1");
    c.RoutePrefix = "swagger";
});

// Inicializar base de datos MySQL al arrancar si el servidor está disponible
using (var scope = app.Services.CreateScope())
{
    try
    {
        var dbFactory = scope.ServiceProvider.GetRequiredService<IDbContextFactory<AppDbContext>>();
        await using var context = await dbFactory.CreateDbContextAsync();
        await DbInitializer.InitializeAsync(context);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"[CoreasERP.Api] Aviso al inicializar BD en arranque: {ex.Message}");
    }
}

// ============================================================================
// 0. HEALTH CHECK & INICIALIZACIÓN
// ============================================================================
app.MapGet("/", () => Results.Redirect("/swagger"));

app.MapGet("/api/health", async (IDbContextFactory<AppDbContext> dbFactory) =>
{
    try
    {
        await using var db = await dbFactory.CreateDbContextAsync();
        bool canConnect = await db.Database.CanConnectAsync();
        return Results.Ok(new ApiResultDto
        {
            Success = canConnect,
            Message = canConnect
                ? "CoreasERP API activa y conectada exitosamente a MySQL."
                : "CoreasERP API activa, pero no se pudo conectar al servidor MySQL."
        });
    }
    catch (Exception ex)
    {
        return Results.Ok(new ApiResultDto { Success = false, Message = $"Error MySQL: {ex.Message}" });
    }
}).WithTags("Sistema");

app.MapPost("/api/init", async (IDbContextFactory<AppDbContext> dbFactory) =>
{
    try
    {
        await using var db = await dbFactory.CreateDbContextAsync();
        await DbInitializer.InitializeAsync(db);
        return Results.Ok(new ApiResultDto { Success = true, Message = "Base de datos MySQL verificada e inicializada." });
    }
    catch (Exception ex)
    {
        return Results.Ok(new ApiResultDto { Success = false, Message = ex.Message });
    }
}).WithTags("Sistema");

// ============================================================================
// 1. AUTENTICACIÓN (/api/auth)
// ============================================================================
var authGroup = app.MapGroup("/api/auth").WithTags("Autenticación");

authGroup.MapPost("/login", async ([FromBody] LoginRequestDto req, IAuthService authService) =>
{
    var res = await authService.LoginAsync(req.Username, req.Password);
    return Results.Ok(new ApiResultDto<Usuario> { Success = res.Success, Message = res.Message, Data = res.User });
});

authGroup.MapPost("/verify-password", async ([FromBody] VerifyPasswordRequestDto req, IAuthService authService) =>
{
    bool valid = await authService.VerifyUserPasswordAsync(req.IdUsuario, req.Password);
    return Results.Ok(new ApiResultDto<bool> { Success = valid, Message = valid ? "Contraseña válida" : "Contraseña inválida", Data = valid });
});

authGroup.MapPost("/verify-supervisor", async ([FromBody] LoginRequestDto req, IAuthService authService) =>
{
    var res = await authService.VerifySupervisorOrAdminCredentialsAsync(req.Username, req.Password);
    return Results.Ok(new ApiResultDto<Usuario> { Success = res.Success, Message = res.Message, Data = res.SupervisorUser });
});

// ============================================================================
// 2. CATEGORÍAS (/api/categorias)
// ============================================================================
var catGroup = app.MapGroup("/api/categorias").WithTags("Categorías");

catGroup.MapGet("/", async (ICategoryService service) =>
    Results.Ok(await service.GetAllAsync()));

catGroup.MapGet("/with-count", async (ICategoryService service) =>
    Results.Ok(await service.GetAllWithCountAsync()));

catGroup.MapPost("/", async ([FromBody] Categoria categoria, ICategoryService service) =>
{
    var res = await service.SaveAsync(categoria);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

catGroup.MapDelete("/{id:int}", async (int id, ICategoryService service) =>
{
    var res = await service.DeleteAsync(id);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

// ============================================================================
// 3. PRODUCTOS E INVENTARIO (/api/productos)
// ============================================================================
var prodGroup = app.MapGroup("/api/productos").WithTags("Productos");

prodGroup.MapGet("/", async ([FromQuery] string? busqueda, [FromQuery] int? idCategoria, [FromQuery] bool? soloActivos, IProductService service) =>
    Results.Ok(await service.GetAllAsync(busqueda, idCategoria, soloActivos)));

prodGroup.MapGet("/search", async ([FromQuery] string? busqueda, [FromQuery] int? limit, [FromQuery] bool? soloActivos, [FromQuery] bool? soloConStock, IProductService service) =>
    Results.Ok(await service.SearchAsync(busqueda, limit ?? 50, soloActivos, soloConStock)));

prodGroup.MapGet("/low-stock", async (IProductService service) =>
    Results.Ok(await service.GetLowStockAsync()));

prodGroup.MapGet("/{id:int}", async (int id, IProductService service) =>
{
    var prod = await service.GetByIdAsync(id);
    return prod != null ? Results.Ok(prod) : Results.NotFound();
});

prodGroup.MapGet("/by-codigo/{codigo}", async (string codigo, IProductService service) =>
{
    var prod = await service.GetByCodigoAsync(Uri.UnescapeDataString(codigo));
    return prod != null ? Results.Ok(prod) : Results.NotFound();
});

prodGroup.MapPost("/", async ([FromBody] Producto producto, IProductService service) =>
{
    var res = await service.SaveAsync(producto);
    return Results.Ok(new ApiResultDto<Producto> { Success = res.Success, Message = res.Message, Data = res.Producto });
});

prodGroup.MapPost("/{id:int}/toggle-estado", async (int id, IProductService service) =>
{
    var res = await service.ToggleEstadoAsync(id);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

prodGroup.MapGet("/{id:int}/can-delete", async (int id, IProductService service) =>
{
    var res = await service.PuedeEliminarProductoAsync(id);
    return Results.Ok(new ApiResultDto { Success = res.CanDelete, Message = res.Message });
});

prodGroup.MapDelete("/{id:int}", async (int id, IProductService service) =>
{
    var res = await service.DeleteAsync(id);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

prodGroup.MapPost("/ajustar-stock", async ([FromBody] AjusteStockSupervisadoRequestDto req, IProductService service) =>
{
    var res = await service.AjustarStockSupervisadoAsync(req.IdProducto, req.NuevoStock, req.Motivo, req.UsuarioSupervisor, req.ClaveSupervisor);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

prodGroup.MapGet("/{idPadre:int}/materiales", async (int idPadre, IProductService service) =>
    Results.Ok(await service.GetMaterialesAsync(idPadre)));

prodGroup.MapPost("/materiales", async ([FromBody] AgregarMaterialRequestDto req, IProductService service) =>
{
    var res = await service.AgregarMaterialAsync(req.IdProductoPadre, req.IdProductoInsumo, req.Cantidad);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

prodGroup.MapDelete("/materiales/{idProductoMaterial:int}", async (int idProductoMaterial, IProductService service) =>
{
    var res = await service.EliminarMaterialAsync(idProductoMaterial);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

prodGroup.MapPost("/upload-imagen", async ([FromBody] UploadImagenProductoDto req, IWebHostEnvironment env) =>
{
    if (string.IsNullOrWhiteSpace(req.NombreArchivo) || string.IsNullOrWhiteSpace(req.ContenidoBase64))
    {
        return Results.Ok(new ApiResultDto<string> { Success = false, Message = "Datos de imagen incompletos." });
    }

    try
    {
        string safeFileName = Path.GetFileName(req.NombreArchivo);
        string dir = Path.Combine(env.ContentRootPath, "wwwroot", "uploads", "products");
        if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);

        byte[] bytes = Convert.FromBase64String(req.ContenidoBase64);
        await File.WriteAllBytesAsync(Path.Combine(dir, safeFileName), bytes);

        string relativePath = $"uploads/products/{safeFileName}";
        return Results.Ok(new ApiResultDto<string>
        {
            Success = true,
            Message = "Imagen guardada en uploads/products.",
            Data = relativePath
        });
    }
    catch (Exception ex)
    {
        return Results.Ok(new ApiResultDto<string> { Success = false, Message = ex.Message });
    }
});

// ============================================================================
// 4. CLIENTES (/api/clientes)
// ============================================================================
var cliGroup = app.MapGroup("/api/clientes").WithTags("Clientes");

cliGroup.MapGet("/", async ([FromQuery] string? busqueda, [FromQuery] string? tipoPersona, ICustomerService service) =>
    Results.Ok(await service.GetAllAsync(busqueda, tipoPersona)));

cliGroup.MapGet("/{id:int}", async (int id, ICustomerService service) =>
{
    var cli = await service.GetByIdAsync(id);
    return cli != null ? Results.Ok(cli) : Results.NotFound();
});

cliGroup.MapPost("/", async ([FromBody] Cliente cliente, ICustomerService service) =>
{
    var res = await service.SaveAsync(cliente);
    return Results.Ok(new ApiResultDto<Cliente> { Success = res.Success, Message = res.Message, Data = res.Cliente });
});

cliGroup.MapDelete("/{id:int}", async (int id, ICustomerService service) =>
{
    var res = await service.DeleteAsync(id);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

// ============================================================================
// 5. PUNTO DE VENTA, VENTAS Y MERMAS (/api/ventas)
// ============================================================================
var posGroup = app.MapGroup("/api/ventas").WithTags("Ventas y POS");

posGroup.MapGet("/", async ([FromQuery] DateTime? fecha, [FromQuery] string? busqueda, IPosService service) =>
    Results.Ok(await service.GetVentasAsync(fecha, busqueda)));

posGroup.MapGet("/{id:int}", async (int id, IPosService service) =>
{
    var venta = await service.GetVentaByIdAsync(id);
    return venta != null ? Results.Ok(venta) : Results.NotFound();
});

posGroup.MapPost("/", async ([FromBody] RegistrarVentaRequestDto req, IPosService service) =>
{
    var res = await service.RegistrarVentaAsync(req.IdCliente, req.IdUsuario, req.TipoComprobante, req.MetodoPago, req.PagoCon, req.Items);
    return Results.Ok(new ApiResultDto<Venta> { Success = res.Success, Message = res.Message, Data = res.Venta });
});

posGroup.MapPost("/{id:int}/anular", async (int id, IPosService service) =>
{
    var res = await service.AnularVentaAsync(id);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

posGroup.MapPost("/mermas-lote", async ([FromBody] RegistrarMermaLoteRequestDto req, IPosService service) =>
{
    var res = await service.RegistrarMermaLoteAsync(req.Items, req.Motivo, req.IdSupervisor, req.IdCajero, req.NotaAdicional);
    return Results.Ok(new MermaLoteResultDto
    {
        Success = res.Success,
        Message = res.Message,
        TotalCostoMerma = res.TotalCostoMerma,
        Mermas = res.Mermas
    });
});

// ============================================================================
// 6. CORTES Y MOVIMIENTOS DE CAJA (/api/caja)
// ============================================================================
var cajaGroup = app.MapGroup("/api/caja").WithTags("Caja y Cortes");

cajaGroup.MapGet("/activo", async ([FromQuery] int? idUsuario, ICashRegisterService service) =>
    Results.Ok(await service.GetCorteActivoAsync(idUsuario)));

cajaGroup.MapGet("/historial", async (ICashRegisterService service) =>
    Results.Ok(await service.GetHistorialCortesAsync()));

cajaGroup.MapPost("/abrir", async ([FromBody] AbrirCajaRequestDto req, ICashRegisterService service) =>
{
    var res = await service.AbrirCajaAsync(req.IdUsuario, req.MontoInicial);
    return Results.Ok(new ApiResultDto<CorteCaja> { Success = res.Success, Message = res.Message, Data = res.Corte });
});

cajaGroup.MapPost("/actualizar-monto-inicial", async ([FromBody] ActualizarMontoInicialRequestDto req, ICashRegisterService service) =>
{
    var res = await service.ActualizarMontoInicialAsync(req.IdCorte, req.NuevoMontoInicial);
    return Results.Ok(new ApiResultDto<CorteCaja> { Success = res.Success, Message = res.Message, Data = res.Corte });
});

cajaGroup.MapPost("/cerrar", async ([FromBody] CerrarCajaRequestDto req, ICashRegisterService service) =>
{
    var res = await service.CerrarCajaAsync(req.IdCorte, req.MontoFinal, req.Diferencia);
    return Results.Ok(new ApiResultDto<CorteCaja> { Success = res.Success, Message = res.Message, Data = res.Corte });
});

cajaGroup.MapGet("/movimientos", async ([FromQuery] int? idCorte, [FromQuery] DateTime? fechaDesde, [FromQuery] DateTime? fechaHasta, ICashRegisterService service) =>
    Results.Ok(await service.GetMovimientosCajaAsync(idCorte, fechaDesde, fechaHasta)));

cajaGroup.MapPost("/movimientos", async ([FromBody] RegistrarMovimientoCajaRequestDto req, ICashRegisterService service) =>
{
    var res = await service.RegistrarMovimientoCajaAsync(req.IdUsuario, req.Tipo, req.Monto, req.Motivo, req.IdCorte);
    return Results.Ok(new ApiResultDto<MovimientoCaja> { Success = res.Success, Message = res.Message, Data = res.Movimiento });
});

cajaGroup.MapPost("/resumen", async ([FromBody] GenerarResumenCorteRequestDto req, ICashRegisterService service) =>
    Results.Ok(await service.GenerarResumenCorteAsync(req.IdCorte, req.TipoCorte, req.DesgloseFisico)));

// ============================================================================
// 7. COMPRAS Y PROVEEDORES (/api/compras)
// ============================================================================
var compGroup = app.MapGroup("/api/compras").WithTags("Compras y Proveedores");

compGroup.MapGet("/proveedores", async (IPurchaseService service) =>
    Results.Ok(await service.GetProveedoresAsync()));

compGroup.MapPost("/proveedores", async ([FromBody] Proveedor proveedor, IPurchaseService service) =>
{
    var res = await service.SaveProveedorAsync(proveedor);
    return Results.Ok(new ApiResultDto<Proveedor> { Success = res.Success, Message = res.Message, Data = res.Proveedor });
});

compGroup.MapGet("/", async ([FromQuery] DateTime? fecha, [FromQuery] string? busqueda, IPurchaseService service) =>
    Results.Ok(await service.GetComprasAsync(fecha, busqueda)));

compGroup.MapGet("/{id:int}", async (int id, IPurchaseService service) =>
{
    var comp = await service.GetCompraByIdAsync(id);
    return comp != null ? Results.Ok(comp) : Results.NotFound();
});

compGroup.MapPost("/", async ([FromBody] RegistrarCompraRequestDto req, IPurchaseService service) =>
{
    var res = await service.RegistrarCompraAsync(req.IdProveedor, req.IdUsuario, req.NumFactura, req.Observaciones, req.Items);
    return Results.Ok(new ApiResultDto<Compra> { Success = res.Success, Message = res.Message, Data = res.Compra });
});

compGroup.MapPost("/{id:int}/anular", async (int id, IPurchaseService service) =>
{
    var res = await service.AnularCompraAsync(id);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

// ============================================================================
// 8. CUENTAS POR COBRAR Y ABONOS (/api/creditos)
// ============================================================================
var credGroup = app.MapGroup("/api/creditos").WithTags("Cuentas por Cobrar");

credGroup.MapGet("/", async ([FromQuery] string? busqueda, [FromQuery] string? estado, ICreditService service) =>
    Results.Ok(await service.GetCuentasAsync(busqueda, estado)));

credGroup.MapGet("/{id:int}", async (int id, ICreditService service) =>
{
    var cta = await service.GetCuentaByIdAsync(id);
    return cta != null ? Results.Ok(cta) : Results.NotFound();
});

credGroup.MapPost("/abonos", async ([FromBody] RegistrarAbonoRequestDto req, ICreditService service) =>
{
    var res = await service.RegistrarAbonoAsync(req.IdCuentaCobrar, req.IdUsuario, req.Monto, req.MetodoPago, req.Notas);
    return Results.Ok(new ApiResultDto<Abono> { Success = res.Success, Message = res.Message, Data = res.Abono });
});

// ============================================================================
// 9. CAMBIOS DE PRECIO (/api/cambios-precio)
// ============================================================================
var cpGroup = app.MapGroup("/api/cambios-precio").WithTags("Cambios de Precio");

cpGroup.MapGet("/pendientes", async (IPriceChangeService service) =>
    Results.Ok(await service.GetPendientesAsync()));

cpGroup.MapGet("/pendientes/count", async (IPriceChangeService service) =>
    Results.Ok(await service.GetPendientesCountAsync()));

cpGroup.MapGet("/aplicados", async ([FromQuery] int? limit, IPriceChangeService service) =>
    Results.Ok(await service.GetAplicadosRecientesAsync(limit ?? 50)));

cpGroup.MapPost("/aplicar", async ([FromBody] AplicarCambioPrecioRequestDto req, IPriceChangeService service) =>
{
    var res = await service.AplicarCambioAsync(req.IdCambioPrecio, req.PrecioVentaFinal);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

cpGroup.MapPost("/{id:int}/descartar", async (int id, IPriceChangeService service) =>
{
    var res = await service.DescartarCambioAsync(id);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

cpGroup.MapPost("/aplicar-todos", async (IPriceChangeService service) =>
{
    var res = await service.AplicarTodosPendientesAsync();
    return Results.Ok(new ApiResultDto<int> { Success = res.Success, Message = res.Message, Data = res.TotalAplicados });
});

// ============================================================================
// 10. PROMOCIONES (/api/promociones)
// ============================================================================
var promoGroup = app.MapGroup("/api/promociones").WithTags("Promociones");

promoGroup.MapGet("/", async (IPromotionService service) =>
    Results.Ok(await service.GetAllAsync()));

promoGroup.MapGet("/activas", async (IPromotionService service) =>
    Results.Ok(await service.GetActiveAsync()));

promoGroup.MapPost("/", async ([FromBody] Promocion promocion, IPromotionService service) =>
{
    var res = await service.SaveAsync(promocion);
    return Results.Ok(new ApiResultDto<Promocion> { Success = res.Success, Message = res.Message, Data = res.Promocion });
});

promoGroup.MapPost("/{id:int}/toggle-estado", async (int id, IPromotionService service) =>
{
    var res = await service.ToggleEstadoAsync(id);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

promoGroup.MapDelete("/{id:int}", async (int id, IPromotionService service) =>
{
    var res = await service.DeleteAsync(id);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

// ============================================================================
// 11. USUARIOS Y ROLES (/api/usuarios)
// ============================================================================
var userGroup = app.MapGroup("/api/usuarios").WithTags("Usuarios y Roles");

userGroup.MapGet("/", async (IUserService service) =>
    Results.Ok(await service.GetAllAsync()));

userGroup.MapGet("/roles", async (IUserService service) =>
    Results.Ok(await service.GetRolesAsync()));

userGroup.MapPost("/", async ([FromBody] SaveUsuarioRequestDto req, IUserService service) =>
{
    var res = await service.SaveAsync(req.Usuario, req.NuevaClave);
    return Results.Ok(new ApiResultDto<Usuario> { Success = res.Success, Message = res.Message, Data = res.Usuario });
});

userGroup.MapPost("/{id:int}/toggle-estado", async (int id, IUserService service) =>
{
    var res = await service.ToggleEstadoAsync(id);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

// ============================================================================
// 12. DASHBOARD FINANCIERO (/api/dashboard)
// ============================================================================
var dashGroup = app.MapGroup("/api/dashboard").WithTags("Dashboard Financiero");

dashGroup.MapGet("/", async ([FromQuery] string? periodo, [FromQuery] DateTime? fechaDesde, [FromQuery] DateTime? fechaHasta, IDashboardService service) =>
    Results.Ok(await service.GetDashboardFinancieroAsync(periodo ?? "Mes", fechaDesde, fechaHasta)));

// ============================================================================
// 13. CONFIGURACIÓN DEL NEGOCIO (/api/configuracion)
// ============================================================================
var cfgGroup = app.MapGroup("/api/configuracion").WithTags("Configuración");

cfgGroup.MapGet("/", async (ISettingsService service) =>
    Results.Ok(await service.GetConfiguracionAsync()));

cfgGroup.MapPost("/", async ([FromBody] ConfiguracionNegocio config, ISettingsService service) =>
{
    var res = await service.SaveConfiguracionAsync(config);
    return Results.Ok(new ApiResultDto { Success = res.Success, Message = res.Message });
});

app.Run();

// Función auxiliar para soportar tanto cadenas ADO.NET como URIs mysql://user:pass@host:port/db
static string NormalizeMySqlConnectionString(string input)
{
    if (string.IsNullOrWhiteSpace(input))
        return "Server=127.0.0.1;Port=3306;Database=Coreas_ERP;User=root;Password=;AllowUserVariables=True;CharSet=utf8mb4;";

    input = input.Trim();
    if (input.StartsWith("mysql://", StringComparison.OrdinalIgnoreCase) ||
        input.StartsWith("mysqls://", StringComparison.OrdinalIgnoreCase))
    {
        var uri = new Uri(input);
        var userInfo = uri.UserInfo.Split(':', 2);
        string user = Uri.UnescapeDataString(userInfo[0]);
        string pass = userInfo.Length > 1 ? Uri.UnescapeDataString(userInfo[1]) : "";
        string db = uri.AbsolutePath.TrimStart('/');
        if (string.IsNullOrWhiteSpace(db)) db = "Coreas_ERP";
        int port = uri.Port > 0 ? uri.Port : 3306;
        return $"Server={uri.Host};Port={port};Database={db};User={user};Password={pass};SslMode=Preferred;AllowUserVariables=True;CharSet=utf8mb4;";
    }

    return input;
}
