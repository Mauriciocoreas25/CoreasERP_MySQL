-- ====================================================================
-- SCRIPT DE LIMPIEZA DE VENTAS DE PRUEBA - COREAS ERP
-- ====================================================================
-- Este script elimina ÚNICAMENTE las transacciones de ventas y turnos
-- de prueba para comenzar a operar en vivo desde el ticket #1.
--
-- NO TOCA: Productos, Categorías, Clientes, Proveedores, Compras,
--          Usuarios, Roles ni Configuración del Negocio.
-- ====================================================================

USE [Coreas_ERP];
GO

PRINT 'Iniciando limpieza de ventas de prueba...';
GO

-- 1. Eliminar Abonos y Cuentas por Cobrar generadas en pruebas
DELETE FROM [dbo].[Abonos];
IF EXISTS (SELECT * FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Abonos'))
    DBCC CHECKIDENT ('dbo.Abonos', RESEED, 0);

DELETE FROM [dbo].[CuentasCobrar];
IF EXISTS (SELECT * FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.CuentasCobrar'))
    DBCC CHECKIDENT ('dbo.CuentasCobrar', RESEED, 0);

-- 2. Desvincular órdenes web si alguna hace referencia a ventas de prueba
IF OBJECT_ID('dbo.OrdenesWeb', 'U') IS NOT NULL
    UPDATE [dbo].[OrdenesWeb] SET IdVenta = NULL;

-- 3. Eliminar Detalle de Ventas (líneas de productos vendidos en pruebas)
DELETE FROM [dbo].[DetalleVentas];
IF EXISTS (SELECT * FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.DetalleVentas'))
    DBCC CHECKIDENT ('dbo.DetalleVentas', RESEED, 0);

-- 4. Eliminar Ventas Principales
DELETE FROM [dbo].[Ventas];
IF EXISTS (SELECT * FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.Ventas'))
    DBCC CHECKIDENT ('dbo.Ventas', RESEED, 0);

-- 5. Reiniciar Turnos y Movimientos de Caja (para que el primer cajero inicie su turno real en .00)
DELETE FROM [dbo].[MovimientosCaja];
IF EXISTS (SELECT * FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.MovimientosCaja'))
    DBCC CHECKIDENT ('dbo.MovimientosCaja', RESEED, 0);

DELETE FROM [dbo].[CortesCaja];
IF EXISTS (SELECT * FROM sys.identity_columns WHERE object_id = OBJECT_ID('dbo.CortesCaja'))
    DBCC CHECKIDENT ('dbo.CortesCaja', RESEED, 0);

PRINT 'Limpieza completada con éxito. Las ventas han quedado en cero y listas para operar.';
GO
