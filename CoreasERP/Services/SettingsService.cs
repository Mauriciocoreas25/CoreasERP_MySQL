using Microsoft.EntityFrameworkCore;
using CoreasERP.Data;
using CoreasERP.Models;

namespace CoreasERP.Services;

public interface ISettingsService
{
    Task<ConfiguracionNegocio> GetConfiguracionAsync();
    Task<(bool Success, string Message)> SaveConfiguracionAsync(ConfiguracionNegocio config);
}

public class SettingsService : ISettingsService
{
    private readonly IDbContextFactory<AppDbContext> _contextFactory;

    public SettingsService(IDbContextFactory<AppDbContext> contextFactory)
    {
        _contextFactory = contextFactory;
    }

    public async Task<ConfiguracionNegocio> GetConfiguracionAsync()
    {
        await using var context = await _contextFactory.CreateDbContextAsync();
        var config = await context.ConfiguracionNegocio.FirstOrDefaultAsync();
        if (config == null)
        {
            config = new ConfiguracionNegocio();
            await context.ConfiguracionNegocio.AddAsync(config);
            await context.SaveChangesAsync();
        }
        return config;
    }

    public async Task<(bool Success, string Message)> SaveConfiguracionAsync(ConfiguracionNegocio config)
    {
        if (string.IsNullOrWhiteSpace(config.NombreNegocio))
            return (false, "El nombre del negocio es obligatorio.");

        try
        {
            await using var context = await _contextFactory.CreateDbContextAsync();
            var existing = await context.ConfiguracionNegocio.FirstOrDefaultAsync();
            if (existing == null)
            {
                await context.ConfiguracionNegocio.AddAsync(config);
            }
            else
            {
                existing.NombreNegocio = config.NombreNegocio.Trim();
                existing.Propietario = config.Propietario?.Trim();
                existing.Telefono = config.Telefono?.Trim();
                existing.Email = config.Email?.Trim();
                existing.Direccion = config.Direccion?.Trim();
                existing.Nrc = config.Nrc?.Trim();
                existing.Nit = config.Nit?.Trim();
                existing.TasaIva = config.TasaIva;
                existing.MensajeTicket = config.MensajeTicket.Trim();

                // Parámetros Facturación Electrónica FelSv
                existing.HabilitarDte = config.HabilitarDte;
                existing.FelSvApiUrl = string.IsNullOrWhiteSpace(config.FelSvApiUrl) ? "http://localhost:5000" : config.FelSvApiUrl.Trim();
                existing.FelSvTenantId = string.IsNullOrWhiteSpace(config.FelSvTenantId) ? "772e934a-320b-4891-a245-f2dd7911c994" : config.FelSvTenantId.Trim();
                existing.FelSvAmbiente = string.IsNullOrWhiteSpace(config.FelSvAmbiente) ? "00" : config.FelSvAmbiente.Trim();
                existing.CodEstablecimiento = string.IsNullOrWhiteSpace(config.CodEstablecimiento) ? "M001" : config.CodEstablecimiento.Trim();
                existing.CodPuntoVenta = string.IsNullOrWhiteSpace(config.CodPuntoVenta) ? "P001" : config.CodPuntoVenta.Trim();
                existing.CatDepartamento = string.IsNullOrWhiteSpace(config.CatDepartamento) ? "12" : config.CatDepartamento.Trim();
                existing.CatMunicipio = string.IsNullOrWhiteSpace(config.CatMunicipio) ? "1201" : config.CatMunicipio.Trim();

                // Parámetros de Impresión Térmica y Documentos Carta
                existing.NombreImpresora = config.NombreImpresora?.Trim() ?? "";
                existing.NombreImpresoraDocumentos = config.NombreImpresoraDocumentos?.Trim() ?? "";
                existing.AnchoPapelMm = config.AnchoPapelMm is 58 ? 58 : 80;
                existing.ImpresionDirecta = config.ImpresionDirecta;
            }

            await context.SaveChangesAsync();
            return (true, "Configuración guardada exitosamente.");
        }
        catch (Exception ex)
        {
            return (false, $"Error al guardar configuración: {ex.Message}");
        }
    }
}
