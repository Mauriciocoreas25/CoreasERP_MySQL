using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Services;

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

        // Servicios de persistencia y configuración SQL Server
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

        // Servicios para los 11 módulos principales
        builder.Services.AddScoped<IUserService, UserService>();
        builder.Services.AddScoped<IPurchaseService, PurchaseService>();
        builder.Services.AddScoped<ICreditService, CreditService>();
        builder.Services.AddScoped<IPromotionService, PromotionService>();
        builder.Services.AddScoped<ISettingsService, SettingsService>();
        builder.Services.AddScoped<IPriceChangeService, PriceChangeService>();
        builder.Services.AddScoped<IExcelExportService, ExcelExportService>();
        // Facturación Electrónica (DTE El Salvador - FelSv)
        builder.Services.AddHttpClient();
        builder.Services.AddScoped<CoreasERP.Services.Dte.IDteJsonBuilderService, CoreasERP.Services.Dte.DteJsonBuilderService>();
        builder.Services.AddScoped<CoreasERP.Services.Dte.IFelSvApiService, CoreasERP.Services.Dte.FelSvApiService>();

        return builder.Build();
    }
}
