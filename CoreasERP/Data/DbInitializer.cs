using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Storage;
using MySqlConnector;
using CoreasERP.Models;

namespace CoreasERP.Data;

public static class DbInitializer
{
    public static async Task InitializeAsync(AppDbContext context)
    {
        // 1. Verificar si las tablas ya existen en la base de datos actual (compatible con Cloud MySQL como MonsterASP.NET donde la BD ya viene creada)
        bool tablesExist = false;
        try
        {
            _ = await context.Roles.AnyAsync();
            tablesExist = true;
        }
        catch
        {
            tablesExist = false;
        }

        if (!tablesExist)
        {
            try
            {
                // Intentar crear las tablas directamente en la base de datos asignada sin requerir permisos de root (CREATE DATABASE)
                var databaseCreator = context.Database.GetService<IRelationalDatabaseCreator>();
                await databaseCreator.CreateTablesAsync();
            }
            catch
            {
                // Si la BD local aún no existe (ej. XAMPP/Laragon local), EnsureCreatedAsync la crea junto con sus tablas
                await context.Database.EnsureCreatedAsync();
            }
        }

        // 2. Garantizar que las columnas y tablas nuevas existan (Migración automática segura para MySQL)
        await EnsureSchemaUpToDateAsync(context);

        // 3. Roles
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

        // 4. Usuarios iniciales (Solo usuario admin)
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

        // 5. Clientes (Consumidor Final obligatorio con IdCliente = 1 para ventas rápidas)
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

        // 6. Categoría inicial base
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

        // 7. Configuración Inicial del Negocio
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
        try
        {
            // Verificar rápido si la última columna de migración (CortarPapel) y tabla Mermas ya existen para evitar 13 llamadas de red innecesarias
            await context.Database.ExecuteSqlRawAsync("SELECT `CortarPapel` FROM `ConfiguracionNegocio` LIMIT 1;");
            await context.Database.ExecuteSqlRawAsync("SELECT `IdMerma` FROM `Mermas` LIMIT 1;");
            return;
        }
        catch
        {
            // Si falta alguna columna o tabla de versiones anteriores, aplicar migraciones
        }

        var migrations = new[]
        {
            // Productos
            "ALTER TABLE `Productos` ADD COLUMN `EsGranel` TINYINT(1) NOT NULL DEFAULT 0;",
            "ALTER TABLE `Productos` ADD COLUMN `PrecioGranel` DECIMAL(10, 2) NULL;",
            "ALTER TABLE `Productos` ADD COLUMN `CostoGranel` DECIMAL(10, 4) NULL;",
            "ALTER TABLE `Productos` ADD COLUMN `CantidadPorEmpaque` DECIMAL(10, 2) NULL DEFAULT 1.00;",
            "ALTER TABLE `Productos` ADD COLUMN `UnidadMedida` VARCHAR(30) NOT NULL DEFAULT 'Unidad';",
            "ALTER TABLE `Productos` ADD COLUMN `MargenExcepcion` DECIMAL(5, 2) NOT NULL DEFAULT 0.00;",
            "ALTER TABLE `Productos` ADD COLUMN `ImagenUrl` VARCHAR(500) NULL;",

            // Categorias
            "ALTER TABLE `Categorias` ADD COLUMN `Icono` VARCHAR(50) NOT NULL DEFAULT 'box-seam';",

            // ConfiguracionNegocio
            "ALTER TABLE `ConfiguracionNegocio` ADD COLUMN `NombreImpresora` VARCHAR(150) NULL;",
            "ALTER TABLE `ConfiguracionNegocio` ADD COLUMN `NombreImpresoraDocumentos` VARCHAR(150) NULL;",
            "ALTER TABLE `ConfiguracionNegocio` ADD COLUMN `AnchoPapelMm` INT NOT NULL DEFAULT 80;",
            "ALTER TABLE `ConfiguracionNegocio` ADD COLUMN `ImpresionDirecta` TINYINT(1) NOT NULL DEFAULT 1;",
            "ALTER TABLE `ConfiguracionNegocio` ADD COLUMN `CortarPapel` TINYINT(1) NOT NULL DEFAULT 1;",

            // Tabla dedicada de Mermas (para pérdidas por plagas, roturas, vencimiento, consumo interno)
            @"CREATE TABLE IF NOT EXISTS `Mermas` (
                `IdMerma` INT AUTO_INCREMENT NOT NULL,
                `IdProducto` INT NOT NULL,
                `IdUsuarioSupervisor` INT NOT NULL,
                `IdUsuarioCajero` INT NULL,
                `Cantidad` DECIMAL(12, 3) NOT NULL,
                `CantidadBaseStock` DECIMAL(12, 3) NOT NULL,
                `CostoUnitario` DECIMAL(10, 4) NOT NULL,
                `CostoTotal` DECIMAL(12, 2) NOT NULL,
                `Motivo` VARCHAR(100) NOT NULL,
                `Observaciones` VARCHAR(500) NULL,
                `FechaHora` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
                PRIMARY KEY (`IdMerma`),
                CONSTRAINT `FK_Mermas_Productos_IdProducto` FOREIGN KEY (`IdProducto`) REFERENCES `Productos` (`IdProducto`),
                CONSTRAINT `FK_Mermas_Usuarios_IdUsuarioSupervisor` FOREIGN KEY (`IdUsuarioSupervisor`) REFERENCES `Usuarios` (`IdUsuario`),
                CONSTRAINT `FK_Mermas_Usuarios_IdUsuarioCajero` FOREIGN KEY (`IdUsuarioCajero`) REFERENCES `Usuarios` (`IdUsuario`)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;"
        };

        foreach (var sql in migrations)
        {
            try
            {
                await context.Database.ExecuteSqlRawAsync(sql);
            }
            catch
            {
                // Si la columna o tabla ya existe en MySQL, continuar con la siguiente
            }
        }
    }
}
