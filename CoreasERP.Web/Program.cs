using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Services;
using CoreasERP.Services.Dte;
using CoreasERP.Components;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

builder.Services.AddServerSideBlazor().AddCircuitOptions(options =>
{
    options.DetailedErrors = true;
}).AddHubOptions(options =>
{
    options.MaximumReceiveMessageSize = 32 * 1024 * 1024; // 32MB
});

// Configuración de Conexión y EF Core SQL Server
builder.Services.AddSingleton<IConnectionConfigService, ConnectionConfigService>();

builder.Services.AddDbContextFactory<AppDbContext>((sp, options) =>
{
    var configService = sp.GetRequiredService<IConnectionConfigService>();
    var connectionString = configService.GetConnectionString();
    options.UseSqlServer(connectionString);
});

// Servicios de Dominio / Negocio
builder.Services.AddSingleton<IAuthService, AuthService>();
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddScoped<ICategoryService, CategoryService>();
builder.Services.AddScoped<ICustomerService, CustomerService>();
builder.Services.AddScoped<ICashRegisterService, CashRegisterService>();
builder.Services.AddScoped<IPosService, PosService>();
builder.Services.AddScoped<IDashboardService, DashboardService>();
builder.Services.AddSingleton<IPrintService, PrintService>();
builder.Services.AddSingleton<IQrCodeService, QrCodeService>();

// Servicios para los módulos extendidos
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IPurchaseService, PurchaseService>();
builder.Services.AddScoped<ICreditService, CreditService>();
builder.Services.AddScoped<IPromotionService, PromotionService>();
builder.Services.AddScoped<ISettingsService, SettingsService>();
builder.Services.AddScoped<IPriceChangeService, PriceChangeService>();
builder.Services.AddScoped<IExcelExportService, ExcelExportService>();

// Facturación Electrónica (DTE El Salvador - FelSv)
builder.Services.AddHttpClient();
builder.Services.AddScoped<IDteJsonBuilderService, DteJsonBuilderService>();
builder.Services.AddScoped<IFelSvApiService, FelSvApiService>();

var app = builder.Build();

// Inicialización de Base de Datos y validación de esquema
using (var scope = app.Services.CreateScope())
{
    try
    {
        var dbFactory = scope.ServiceProvider.GetRequiredService<IDbContextFactory<AppDbContext>>();
        await using var db = await dbFactory.CreateDbContextAsync();
        await DbInitializer.InitializeAsync(db);
    }
    catch (Exception ex)
    {
        app.Logger.LogWarning("DbInitializer aviso inicial: {Message}", ex.Message);
    }
}

// Pipeline HTTP
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseAntiforgery();

app.MapStaticAssets();
app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();
