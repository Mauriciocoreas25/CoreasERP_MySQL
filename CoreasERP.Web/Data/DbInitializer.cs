using Microsoft.EntityFrameworkCore;
using CoreasERP.Models;

namespace CoreasERP.Data;

public static class DbInitializer
{
    public static async Task InitializeAsync(AppDbContext context)
    {
        // 1. Verificar si la base de datos ya existe y es accesible
        bool dbExists = false;
        try
        {
            dbExists = await context.Database.CanConnectAsync();
        }
        catch
        {
            dbExists = false;
        }

        // 2. Si no existe, crear automáticamente la base de datos y todas sus tablas
        if (!dbExists)
        {
            try
            {
                await context.Database.EnsureCreatedAsync();
            }
            catch (Exception ex)
            {
                throw new Exception($"No se pudo crear automáticamente la base de datos en SQL Server ({ex.Message}). Para solucionarlo: ejecuta la aplicación como Administrador (clic derecho -> Ejecutar como Administrador) o crea la base con el script Coreas_ERP_Database.sql en SSMS.", ex);
            }
        }

        // 3. Garantizar que las columnas y tablas nuevas existan (Migración automática segura)
        await EnsureSchemaUpToDateAsync(context);

        // 1. Roles
        if (!await context.Roles.AnyAsync())
        {
            var roles = new List<Rol>
            {
                new() { Nombre = "Administrador", Descripcion = "Acceso total a todos los módulos y configuraciones" },
                new() { Nombre = "Supervisor", Descripcion = "Supervisión de caja, anulación y reportes" },
                new() { Nombre = "Cajero", Descripcion = "Operación del punto de venta y turnos de caja" }
            };
            await context.Roles.AddRangeAsync(roles);
            await context.SaveChangesAsync();
        }

        // 2. Usuarios iniciales (Solo usuario admin)
        if (!await context.Usuarios.AnyAsync())
        {
            var adminRol = await context.Roles.FirstAsync(r => r.Nombre == "Administrador");

            var adminUser = new Usuario
            {
                IdRol = adminRol.IdRol,
                NombreUsuario = "admin",
                Nombre = "Administrador General",
                Email = "admin@coreaserp.com",
                Telefono = "7000-0000",
                Clave = BCrypt.Net.BCrypt.HashPassword("admin123"),
                Estado = true
            };
            await context.Usuarios.AddAsync(adminUser);
            await context.SaveChangesAsync();
        }

        // 3. Clientes (Consumidor Final obligatorio con IdCliente = 1 para ventas rápidas)
        if (!await context.Clientes.AnyAsync())
        {
            var consumidorFinal = new Cliente
            {
                TipoPersona = "Natural",
                Nombre = "Consumidor Final",
                TipoDocumento = "DUI",
                NumDocumento = "00000000-0",
                Telefono = "0000-0000",
                Email = "consumidorfinal@coreaserp.com",
                Direccion = "San Salvador"
            };
            await context.Clientes.AddAsync(consumidorFinal);
            await context.SaveChangesAsync();
        }

        // 4. Categoría inicial base
        if (!await context.Categorias.AnyAsync())
        {
            var catGeneral = new Categoria
            {
                Nombre = "General",
                Descripcion = "Categoría General",
                Estado = true,
                Icono = "fa-box"
            };
            await context.Categorias.AddAsync(catGeneral);
            await context.SaveChangesAsync();
        }

        // 6. Configuración Inicial del Negocio
        if (!await context.ConfiguracionNegocio.AnyAsync())
        {
            var config = new ConfiguracionNegocio
            {
                NombreNegocio = "Coreas ERP",
                Propietario = "Jostin Alexander Amaya Chavez",
                Telefono = "7007-9140",
                Email = "info@coreaserp.com",
                Direccion = "San Miguel, El Salvador",
                Nrc = "389607-9",
                Nit = "06898170-7",
                TasaIva = 13.00m,
                MensajeTicket = "¡Gracias por su compra! Vuelva pronto",
                HabilitarDte = true,
                FelSvApiUrl = "http://localhost:5000",
                FelSvTenantId = "772e934a-320b-4891-a245-f2dd7911c994",
                FelSvAmbiente = "00",
                CodEstablecimiento = "M001",
                CodPuntoVenta = "P001",
                CatDepartamento = "12",
                CatMunicipio = "1201"
            };
            await context.ConfiguracionNegocio.AddAsync(config);
            await context.SaveChangesAsync();
        }
    }

    private static async Task EnsureSchemaUpToDateAsync(AppDbContext context)
    {
        var migrations = new[]
        {
            // Productos
            "IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Productos]') AND name = 'EsGranel') ALTER TABLE [dbo].[Productos] ADD [EsGranel] [bit] NOT NULL DEFAULT(0);",
            "IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Productos]') AND name = 'PrecioGranel') ALTER TABLE [dbo].[Productos] ADD [PrecioGranel] [decimal](10, 2) NULL;",
            "IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Productos]') AND name = 'CostoGranel') ALTER TABLE [dbo].[Productos] ADD [CostoGranel] [decimal](10, 4) NULL;",
            "IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Productos]') AND name = 'CantidadPorEmpaque') ALTER TABLE [dbo].[Productos] ADD [CantidadPorEmpaque] [decimal](10, 2) NULL DEFAULT(1.00);",
            "IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Productos]') AND name = 'UnidadMedida') ALTER TABLE [dbo].[Productos] ADD [UnidadMedida] [varchar](30) NOT NULL DEFAULT('Unidad');",
            "IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Productos]') AND name = 'MargenExcepcion') ALTER TABLE [dbo].[Productos] ADD [MargenExcepcion] [decimal](5, 2) NOT NULL DEFAULT(0.00);",
            "IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Productos]') AND name = 'ImagenUrl') ALTER TABLE [dbo].[Productos] ADD [ImagenUrl] [varchar](500) NULL;",

            // Categorias
            "IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Categorias]') AND name = 'Icono') ALTER TABLE [dbo].[Categorias] ADD [Icono] [varchar](50) NOT NULL DEFAULT('box-seam');",

            // ConfiguracionNegocio
            "IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ConfiguracionNegocio]') AND name = 'NombreImpresora') ALTER TABLE [dbo].[ConfiguracionNegocio] ADD [NombreImpresora] [varchar](150) NULL;",
            "IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ConfiguracionNegocio]') AND name = 'NombreImpresoraDocumentos') ALTER TABLE [dbo].[ConfiguracionNegocio] ADD [NombreImpresoraDocumentos] [varchar](150) NULL;",
            "IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ConfiguracionNegocio]') AND name = 'AnchoPapelMm') ALTER TABLE [dbo].[ConfiguracionNegocio] ADD [AnchoPapelMm] [int] NOT NULL DEFAULT(80);",
            "IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ConfiguracionNegocio]') AND name = 'ImpresionDirecta') ALTER TABLE [dbo].[ConfiguracionNegocio] ADD [ImpresionDirecta] [bit] NOT NULL DEFAULT(1);",
            "IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[ConfiguracionNegocio]') AND name = 'CortarPapel') ALTER TABLE [dbo].[ConfiguracionNegocio] ADD [CortarPapel] [bit] NOT NULL DEFAULT(1);",

            // Tabla dedicada de Mermas (para pérdidas por plagas, roturas, vencimiento, consumo interno)
            @"IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Mermas')
            BEGIN
                CREATE TABLE [dbo].[Mermas] (
                    [IdMerma] INT IDENTITY(1,1) NOT NULL,
                    [IdProducto] INT NOT NULL,
                    [IdUsuarioSupervisor] INT NOT NULL,
                    [IdUsuarioCajero] INT NULL,
                    [Cantidad] DECIMAL(12, 3) NOT NULL,
                    [CantidadBaseStock] DECIMAL(12, 3) NOT NULL,
                    [CostoUnitario] DECIMAL(10, 4) NOT NULL,
                    [CostoTotal] DECIMAL(12, 2) NOT NULL,
                    [Motivo] VARCHAR(100) NOT NULL,
                    [Observaciones] VARCHAR(500) NULL,
                    [FechaHora] DATETIME2 NOT NULL DEFAULT(CURRENT_TIMESTAMP),
                    CONSTRAINT [PK_Mermas] PRIMARY KEY CLUSTERED ([IdMerma] ASC),
                    CONSTRAINT [FK_Mermas_Productos_IdProducto] FOREIGN KEY ([IdProducto]) REFERENCES [dbo].[Productos] ([IdProducto]),
                    CONSTRAINT [FK_Mermas_Usuarios_IdUsuarioSupervisor] FOREIGN KEY ([IdUsuarioSupervisor]) REFERENCES [dbo].[Usuarios] ([IdUsuario]),
                    CONSTRAINT [FK_Mermas_Usuarios_IdUsuarioCajero] FOREIGN KEY ([IdUsuarioCajero]) REFERENCES [dbo].[Usuarios] ([IdUsuario])
                );
            END"
        };

        foreach (var sql in migrations)
        {
            try
            {
                await context.Database.ExecuteSqlRawAsync(sql);
            }
            catch
            {
                // Si un cambio ya fue aplicado o falla, continuar con los siguientes para no bloquear el inicio
            }
        }
    }
}
