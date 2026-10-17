using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Services;
using CoreasERP.Services.ApiClients;

namespace CoreasERP;

public static class MauiProgram
{
    public static MauiApp CreateMauiApp()
    {
        var builder = MauiApp.CreateBuilder();
        builder
            .UseMauiApp<App>()
            .ConfigureFonts(fonts =>
            {
                fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
            });

        builder.Services.AddMauiBlazorWebView();

        builder.Services.AddBlazorWebViewDeveloperTools();
#if DEBUG
        builder.Logging.AddDebug();
#endif

        // Servicios de persistencia y configuración Híbrida (MySQL Directo + API REST Cloud)
        builder.Services.AddSingleton<IConnectionConfigService, ConnectionConfigService>();

        builder.Services.AddDbContextFactory<AppDbContext>((sp, options) =>
        {
            var configService = sp.GetRequiredService<IConnectionConfigService>();
            var connectionString = configService.GetConnectionString();
            var serverVersion = new MySqlServerVersion(new Version(8, 0, 36));
            options.UseMySql(connectionString, serverVersion);
        });

        // Implementaciones Directas MySQL (usadas cuando Modo API está desactivado)
        builder.Services.AddSingleton<AuthService>();
        builder.Services.AddScoped<ProductService>();
        builder.Services.AddScoped<CategoryService>();
        builder.Services.AddScoped<CustomerService>();
        builder.Services.AddScoped<CashRegisterService>();
        builder.Services.AddScoped<PosService>();
        builder.Services.AddScoped<DashboardService>();
        builder.Services.AddScoped<UserService>();
        builder.Services.AddScoped<PurchaseService>();
        builder.Services.AddScoped<CreditService>();
        builder.Services.AddScoped<PromotionService>();
        builder.Services.AddScoped<SettingsService>();
        builder.Services.AddScoped<PriceChangeService>();

        // Enrutadores Híbridos Inteligentes (cambian en caliente entre MySQL Directo y CoreasERP.Api REST)
        builder.Services.AddSingleton<IAuthService, HybridAuthService>();
        builder.Services.AddScoped<IProductService, HybridProductService>();
        builder.Services.AddScoped<ICategoryService, HybridCategoryService>();
        builder.Services.AddScoped<ICustomerService, HybridCustomerService>();
        builder.Services.AddScoped<ICashRegisterService, HybridCashRegisterService>();
        builder.Services.AddScoped<IPosService, HybridPosService>();
        builder.Services.AddScoped<IDashboardService, HybridDashboardService>();
        builder.Services.AddScoped<IUserService, HybridUserService>();
        builder.Services.AddScoped<IPurchaseService, HybridPurchaseService>();
        builder.Services.AddScoped<ICreditService, HybridCreditService>();
        builder.Services.AddScoped<IPromotionService, HybridPromotionService>();
        builder.Services.AddScoped<ISettingsService, HybridSettingsService>();
        builder.Services.AddScoped<IPriceChangeService, HybridPriceChangeService>();

        // Impresión, QR y Excel
        builder.Services.AddSingleton<IPrintService, PrintService>();
        builder.Services.AddSingleton<IQrCodeService, QrCodeService>();
        builder.Services.AddScoped<IExcelExportService, ExcelExportService>();

        // Facturación Electrónica (DTE El Salvador - FelSv)
        builder.Services.AddHttpClient();
        builder.Services.AddScoped<CoreasERP.Services.Dte.IDteJsonBuilderService, CoreasERP.Services.Dte.DteJsonBuilderService>();
        builder.Services.AddScoped<CoreasERP.Services.Dte.IFelSvApiService, CoreasERP.Services.Dte.FelSvApiService>();

        // Crear y sincronizar carpeta fija C:\CoreasERP\uploads\products al iniciar el ejecutable
        ProductService.SincronizarCarpetaImagenesLocal();

        return builder.Build();
    }
}
