USE [Coreas_ERP];
GO
-- ================================================================
-- CARGA MASIVA DE PRODUCTOS DESDE INVENTARIO EXCEL (invennn.xlsx)
-- Estructura compatible con CoreasERP: EsGranel (bit), PrecioGranel (decimal)
-- ================================================================

SET NOCOUNT ON;
BEGIN TRANSACTION;

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '753081044721')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'FAMA SPAGUETI 200G 15/5 Unidad',
        [PrecioCompra] = 2.15,
        [PrecioVenta] = 0.55,
        [PrecioGranel] = 0.55,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '753081044721';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '753081044721', 'FAMA SPAGUETI 200G 15/5 Unidad', 2.15, 0.55, 12.000, 5.000, 1, 'Unidad', 0.55, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7416502201587')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ENCANTO CLASICO 250 HOJAS 12x4',
        [PrecioCompra] = 0.76,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7416502201587';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7416502201587', 'ENCANTO CLASICO 250 HOJAS 12x4', 0.76, 1.25, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7416502202386')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ENCANTO MEGA TOALLA 180HD 1/20 PAQUETE',
        [PrecioCompra] = 0.89,
        [PrecioVenta] = 1.05,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Paquete',
        [Stock] = 10.000,
        [Estado] = 1
    WHERE [Codigo] = '7416502202386';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7416502202386', 'ENCANTO MEGA TOALLA 180HD 1/20 PAQUETE', 0.89, 1.05, 10.000, 5.000, 0, 'Paquete', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '8445291730199')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'NESCAFE LISTO TRADIC. 26x60 DISPENSADOR',
        [PrecioCompra] = 2.96,
        [PrecioVenta] = 0.12,
        [PrecioGranel] = 0.12,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 30.000,
        [Estado] = 1
    WHERE [Codigo] = '8445291730199';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '8445291730199', 'NESCAFE LISTO TRADIC. 26x60 DISPENSADOR', 2.96, 0.12, 30.000, 5.000, 1, 'Unidad', 0.12, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411800416961')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'RIKO CAFE 24x50 DISPENSADOR',
        [PrecioCompra] = 4.57,
        [PrecioVenta] = 0.12,
        [PrecioGranel] = 0.12,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7411800416961';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411800416961', 'RIKO CAFE 24x50 DISPENSADOR', 4.57, 0.12, 12.000, 5.000, 1, 'Unidad', 0.12, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001693247')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'RINSO 700G NATURAL TIERRA VIVA DETERG 1/10 UNIDAD',
        [PrecioCompra] = 3.85,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001693247';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001693247', 'RINSO 700G NATURAL TIERRA VIVA DETERG 1/10 UNIDAD', 3.85, 1.25, 6.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001693254')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'RINSO 700G NATURAL DE ORQUIDEAS DETERG 1/10 UNIDAD',
        [PrecioCompra] = 0.96,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 5.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001693254';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001693254', 'RINSO 700G NATURAL DE ORQUIDEAS DETERG 1/10 UNIDAD', 0.96, 1.25, 5.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001681411')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ULTRAKLIN DET 700G VERDE FN 1/10 UNIDAD',
        [PrecioCompra] = 0.96,
        [PrecioVenta] = 1.10,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 5.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001681411';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001681411', 'ULTRAKLIN DET 700G VERDE FN 1/10 UNIDAD', 0.96, 1.10, 5.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = 'SKU-ULTRAKLIN')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ULTRAKLIN DET 700G DE ORQUIDEAS 1/10 UNIDAD',
        [PrecioCompra] = 0.85,
        [PrecioVenta] = 1.10,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = 'SKU-ULTRAKLIN';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, 'SKU-ULTRAKLIN', 'ULTRAKLIN DET 700G DE ORQUIDEAS 1/10 UNIDAD', 0.85, 1.10, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001681428')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ULTRAKLIN DET 700G MORADO FI 1/10 UNIDAD',
        [PrecioCompra] = 0.85,
        [PrecioVenta] = 1.10,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001681428';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001681428', 'ULTRAKLIN DET 700G MORADO FI 1/10 UNIDAD', 0.85, 1.10, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001681435')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ULTRAKLIN DET 700G ROJO FE 1/10 UNIDAD',
        [PrecioCompra] = 0.85,
        [PrecioVenta] = 1.10,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001681435';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001681435', 'ULTRAKLIN DET 700G ROJO FE 1/10 UNIDAD', 0.85, 1.10, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001681541')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ULTRAKLIN DET 700G ROSADO/ANARANJADO FS 1/10 UNIDAD',
        [PrecioCompra] = 0.85,
        [PrecioVenta] = 1.10,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001681541';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001681541', 'ULTRAKLIN DET 700G ROSADO/ANARANJADO FS 1/10 UNIDAD', 0.85, 1.10, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001681572')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ULTRAKLIN DET 700G AZUL FT 1/10 UNIDAD',
        [PrecioCompra] = 0.85,
        [PrecioVenta] = 1.10,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001681572';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001681572', 'ULTRAKLIN DET 700G AZUL FT 1/10 UNIDAD', 0.85, 1.10, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000346884')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'RINSO 115G ROSAS Y LILAS DETERG 1/32 UNIDAD',
        [PrecioCompra] = 0.27,
        [PrecioVenta] = 0.35,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000346884';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000346884', 'RINSO 115G ROSAS Y LILAS DETERG 1/32 UNIDAD', 0.27, 0.35, 6.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000366141')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'RINSO 115G NATURAL ORQUIDEAS DETERG 1/30 UNIDAD',
        [PrecioCompra] = 0.25,
        [PrecioVenta] = 0.35,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000366141';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000366141', 'RINSO 115G NATURAL ORQUIDEAS DETERG 1/30 UNIDAD', 0.25, 0.35, 6.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001693650')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'SURF DETER 115G ROSAS 1/30 Unidad',
        [PrecioCompra] = 0.24,
        [PrecioVenta] = 0.35,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001693650';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001693650', 'SURF DETER 115G ROSAS 1/30 Unidad', 0.24, 0.35, 6.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000300138')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'SURF DETER 115G AZUL 1/30 Unidad',
        [PrecioCompra] = 0.24,
        [PrecioVenta] = 0.35,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000300138';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000300138', 'SURF DETER 115G AZUL 1/30 Unidad', 0.24, 0.35, 6.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7509546662930')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'SUAVITEL 80ML FRESCA PRIMAVERA 1/72 UNIDAD',
        [PrecioCompra] = 0.21,
        [PrecioVenta] = 0.30,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7509546662930';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7509546662930', 'SUAVITEL 80ML FRESCA PRIMAVERA 1/72 UNIDAD', 0.21, 0.30, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7501019006623')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'SABA BUENAS  NOCHES  C/ALAS 25X8 UNIDAD',
        [PrecioCompra] = 2.10,
        [PrecioVenta] = 2.50,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7501019006623';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7501019006623', 'SABA BUENAS  NOCHES  C/ALAS 25X8 UNIDAD', 2.10, 2.50, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7421001650026')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'LIMPIOX JABON DISCO ALEO VERA 108G 1/72 UNIDAD',
        [PrecioCompra] = 0.16,
        [PrecioVenta] = 0.30,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7421001650026';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7421001650026', 'LIMPIOX JABON DISCO ALEO VERA 108G 1/72 UNIDAD', 0.16, 0.30, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '99176261308')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'AXION DISCO 115GRS 1/72 UNIDAD',
        [PrecioCompra] = 0.21,
        [PrecioVenta] = 0.30,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '99176261308';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '99176261308', 'AXION DISCO 115GRS 1/72 UNIDAD', 0.21, 0.30, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '764246002906')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PLATO TERMO FOM HONDO n6 20x25 PAQUETE',
        [PrecioCompra] = 0.46,
        [PrecioVenta] = 0.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Paquete',
        [Stock] = 10.000,
        [Estado] = 1
    WHERE [Codigo] = '764246002906';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '764246002906', 'PLATO TERMO FOM HONDO n6 20x25 PAQUETE', 0.46, 0.60, 10.000, 5.000, 0, 'Paquete', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7441057267085')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'SABA CLASICA C/ALAS 24x10 Unidad',
        [PrecioCompra] = 0.79,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7441057267085';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7441057267085', 'SABA CLASICA C/ALAS 24x10 Unidad', 0.79, 1.00, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '764246002821')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'BANDEJA TERMOFOM n2 10x50',
        [PrecioCompra] = 1.05,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 10.000,
        [Estado] = 1
    WHERE [Codigo] = '764246002821';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '764246002821', 'BANDEJA TERMOFOM n2 10x50', 1.05, 1.25, 10.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000344941')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CONTINENTAL SABROS MI ARROZ 20x36 DISPENSADOR',
        [PrecioCompra] = 4.91,
        [PrecioVenta] = 0.20,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000344941';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000344941', 'CONTINENTAL SABROS MI ARROZ 20x36 DISPENSADOR', 4.91, 0.20, 1.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '8445291293014')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'COFFEE MATE DISP ORIGINAL 18x40 UNIDAD',
        [PrecioCompra] = 3.12,
        [PrecioVenta] = 0.10,
        [PrecioGranel] = 0.10,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '8445291293014';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '8445291293014', 'COFFEE MATE DISP ORIGINAL 18x40 UNIDAD', 3.12, 0.10, 1.000, 5.000, 1, 'Unidad', 0.10, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000345078')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'NATURAS FRIJOLES VOLT 380G 1/24 Unidad',
        [PrecioCompra] = 1.42,
        [PrecioVenta] = 1.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000345078';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000345078', 'NATURAS FRIJOLES VOLT 380G 1/24 Unidad', 1.42, 1.60, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411002505609')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DE LA FAMILIA GELATINA FRAMBUESA 450G 1/28 Unidad',
        [PrecioCompra] = 1.60,
        [PrecioVenta] = 1.75,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '7411002505609';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411002505609', 'DE LA FAMILIA GELATINA FRAMBUESA 450G 1/28 Unidad', 1.60, 1.75, 1.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411400800627')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DOÑA BLANCA AVENA MOSH 360G 1/30 UNIDAD',
        [PrecioCompra] = 0.95,
        [PrecioVenta] = 1.20,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '7411400800627';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411400800627', 'DOÑA BLANCA AVENA MOSH 360G 1/30 UNIDAD', 0.95, 1.20, 6.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '8719200245914')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'MIRASOL MARGARINA 400G 24x5 DISP',
        [PrecioCompra] = 1.66,
        [PrecioVenta] = 0.40,
        [PrecioGranel] = 0.40,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '8719200245914';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '8719200245914', 'MIRASOL MARGARINA 400G 24x5 DISP', 1.66, 0.40, 6.000, 5.000, 1, 'Unidad', 0.40, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7412903900128')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'AUSTRALIAN ENTERA BOLSA 350G 1/24 UNIDAD',
        [PrecioCompra] = 3.24,
        [PrecioVenta] = 3.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '7412903900128';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7412903900128', 'AUSTRALIAN ENTERA BOLSA 350G 1/24 UNIDAD', 3.24, 3.60, 6.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7415600102031')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'SUPERPAC TENEDORES GRANDE 40x25',
        [PrecioCompra] = 0.23,
        [PrecioVenta] = 0.35,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 40.000,
        [Estado] = 1
    WHERE [Codigo] = '7415600102031';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7415600102031', 'SUPERPAC TENEDORES GRANDE 40x25', 0.23, 0.35, 40.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7415600102048')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'SUPERPAC CUCHARA GRANDE 40x25',
        [PrecioCompra] = 0.25,
        [PrecioVenta] = 0.40,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 40.000,
        [Estado] = 1
    WHERE [Codigo] = '7415600102048';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7415600102048', 'SUPERPAC CUCHARA GRANDE 40x25', 0.25, 0.40, 40.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411400804892')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DOÑA BLANCA HARINA EXTRA SUAVE 820G 1/10',
        [PrecioCompra] = 1.14,
        [PrecioVenta] = 1.35,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 10.000,
        [Estado] = 1
    WHERE [Codigo] = '7411400804892';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411400804892', 'DOÑA BLANCA HARINA EXTRA SUAVE 820G 1/10', 1.14, 1.35, 10.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '97294000830')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DEL COMAL HARINA XTRA SUAVE 820G 1/10',
        [PrecioCompra] = 1.11,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 10.000,
        [Estado] = 1
    WHERE [Codigo] = '97294000830';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '97294000830', 'DEL COMAL HARINA XTRA SUAVE 820G 1/10', 1.11, 1.25, 10.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7404001800011')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'LAKY VASO POLLO 75G 1/12 UNIDAD',
        [PrecioCompra] = 0.74,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 3.000,
        [Estado] = 1
    WHERE [Codigo] = '7404001800011';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7404001800011', 'LAKY VASO POLLO 75G 1/12 UNIDAD', 0.74, 1.00, 3.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7404001800028')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'LAKY VASO CAMARON 75G 1/12 UNIDAD',
        [PrecioCompra] = 0.74,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 3.000,
        [Estado] = 1
    WHERE [Codigo] = '7404001800028';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7404001800028', 'LAKY VASO CAMARON 75G 1/12 UNIDAD', 0.74, 1.00, 3.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7404001800035')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'LAKY VASO RES 75G 1/12 UNIDAD',
        [PrecioCompra] = 0.74,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 3.000,
        [Estado] = 1
    WHERE [Codigo] = '7404001800035';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7404001800035', 'LAKY VASO RES 75G 1/12 UNIDAD', 0.74, 1.00, 3.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7404001800387')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'LAKY VASO JAIBA CON LIMON 75G 1/12 UND UNIDAD',
        [PrecioCompra] = 0.74,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 3.000,
        [Estado] = 1
    WHERE [Codigo] = '7404001800387';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7404001800387', 'LAKY VASO JAIBA CON LIMON 75G 1/12 UND UNIDAD', 0.74, 1.00, 3.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7404001800097')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'LAKY BOLSA POLLO 85G 1/24 UNIDAD',
        [PrecioCompra] = 0.37,
        [PrecioVenta] = 0.50,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 8.000,
        [Estado] = 1
    WHERE [Codigo] = '7404001800097';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7404001800097', 'LAKY BOLSA POLLO 85G 1/24 UNIDAD', 0.37, 0.50, 8.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7404001800080')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'LAKY BOLSA RES 85G 1/24 UNIDAD',
        [PrecioCompra] = 0.37,
        [PrecioVenta] = 0.50,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 8.000,
        [Estado] = 1
    WHERE [Codigo] = '7404001800080';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7404001800080', 'LAKY BOLSA RES 85G 1/24 UNIDAD', 0.37, 0.50, 8.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7404001800073')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'LAKY BOLSA CAMARON 85G 1/24 UNIDAD',
        [PrecioCompra] = 0.37,
        [PrecioVenta] = 0.50,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 8.000,
        [Estado] = 1
    WHERE [Codigo] = '7404001800073';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7404001800073', 'LAKY BOLSA CAMARON 85G 1/24 UNIDAD', 0.37, 0.50, 8.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7413100033053')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ORISOL CLASIC BOLSA 700ML 1/20',
        [PrecioCompra] = 1.69,
        [PrecioVenta] = 2.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 20.000,
        [Estado] = 1
    WHERE [Codigo] = '7413100033053';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7413100033053', 'ORISOL CLASIC BOLSA 700ML 1/20', 1.69, 2.25, 20.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401006801531')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CAPULLO ACEITE BOLSA 750ML DOYPACK 1/20',
        [PrecioCompra] = 1.73,
        [PrecioVenta] = 2.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 20.000,
        [Estado] = 1
    WHERE [Codigo] = '7401006801531';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401006801531', 'CAPULLO ACEITE BOLSA 750ML DOYPACK 1/20', 1.73, 2.00, 20.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7410030774797')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'MAXI SOL LEJIA 200G 6x12',
        [PrecioCompra] = 0.07,
        [PrecioVenta] = 0.10,
        [PrecioGranel] = 0.10,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 72.000,
        [Estado] = 1
    WHERE [Codigo] = '7410030774797';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7410030774797', 'MAXI SOL LEJIA 200G 6x12', 0.07, 0.10, 72.000, 5.000, 1, 'Unidad', 0.10, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '803275305876')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'QUAKER AVENAS MOSH 350G 4x25 BOLSA',
        [PrecioCompra] = 1.41,
        [PrecioVenta] = 1.70,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '803275305876';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '803275305876', 'QUAKER AVENAS MOSH 350G 4x25 BOLSA', 1.41, 1.70, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '803275305005')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'QUAKER AVENA MOLIDA 200G 1/108 Unidad',
        [PrecioCompra] = 1.34,
        [PrecioVenta] = 1.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '803275305005';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '803275305005', 'QUAKER AVENA MOLIDA 200G 1/108 Unidad', 1.34, 1.60, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7441008101796')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'SCOTT 2 EN1 AMARILLO 180 HOJAS 12x4',
        [PrecioCompra] = 0.77,
        [PrecioVenta] = 1.10,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7441008101796';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7441008101796', 'SCOTT 2 EN1 AMARILLO 180 HOJAS 12x4', 0.77, 1.10, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '99176480518')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'COLGATE KIT CEPILLO+PAS. 22ML 1/144 UNIDAD',
        [PrecioCompra] = 0.65,
        [PrecioVenta] = 0.90,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '99176480518';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '99176480518', 'COLGATE KIT CEPILLO+PAS. 22ML 1/144 UNIDAD', 0.65, 0.90, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '161')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CAL BOLSA 50 LOS PANCHOS',
        [PrecioCompra] = 0.09,
        [PrecioVenta] = 0.15,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 50.000,
        [Estado] = 1
    WHERE [Codigo] = '161';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '161', 'CAL BOLSA 50 LOS PANCHOS', 0.09, 0.15, 50.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7410630200241')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PANDA SERVILLETAS 10x100',
        [PrecioCompra] = 0.32,
        [PrecioVenta] = 0.45,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 10.000,
        [Estado] = 1
    WHERE [Codigo] = '7410630200241';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7410630200241', 'PANDA SERVILLETAS 10x100', 0.32, 0.45, 10.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7410030200005')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CUSCATLECA SERVILLETAS 10x100',
        [PrecioCompra] = 0.51,
        [PrecioVenta] = 0.65,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 10.000,
        [Estado] = 1
    WHERE [Codigo] = '7410030200005';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7410030200005', 'CUSCATLECA SERVILLETAS 10x100', 0.51, 0.65, 10.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7502268548186')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ELECTROLIT SUERO COCO 625ML 1/12 UNIDAD',
        [PrecioCompra] = 2.01,
        [PrecioVenta] = 2.50,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 4.000,
        [Estado] = 1
    WHERE [Codigo] = '7502268548186';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7502268548186', 'ELECTROLIT SUERO COCO 625ML 1/12 UNIDAD', 2.01, 2.50, 4.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7502268547172')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ELECTROLIT SUERO FRESA 625ML 1/12 UNIDAD',
        [PrecioCompra] = 2.01,
        [PrecioVenta] = 2.50,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 4.000,
        [Estado] = 1
    WHERE [Codigo] = '7502268547172';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7502268547172', 'ELECTROLIT SUERO FRESA 625ML 1/12 UNIDAD', 2.01, 2.50, 4.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7502268548193')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ELECTROLIT SUERO MARACUYÁ 625ML 1/12 UNIDAD',
        [PrecioCompra] = 2.01,
        [PrecioVenta] = 2.50,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 4.000,
        [Estado] = 1
    WHERE [Codigo] = '7502268548193';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7502268548193', 'ELECTROLIT SUERO MARACUYÁ 625ML 1/12 UNIDAD', 2.01, 2.50, 4.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '97294742631')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'FAMA CODITOS GRANDE 200G 1/48 BOLSA',
        [PrecioCompra] = 0.53,
        [PrecioVenta] = 0.65,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '97294742631';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '97294742631', 'FAMA CODITOS GRANDE 200G 1/48 BOLSA', 0.53, 0.65, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '759362140083')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PLATO GRACO FOAM n9 20x25',
        [PrecioCompra] = 0.58,
        [PrecioVenta] = 0.75,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 20.000,
        [Estado] = 1
    WHERE [Codigo] = '759362140083';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '759362140083', 'PLATO GRACO FOAM n9 20x25', 0.58, 0.75, 20.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '263')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'BOLSA GABACHA COLOR n1 100x100 CIEN',
        [PrecioCompra] = 1.04,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 10.000,
        [Estado] = 1
    WHERE [Codigo] = '263';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '263', 'BOLSA GABACHA COLOR n1 100x100 CIEN', 1.04, 1.25, 10.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '147')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'BOLSA GABACHA COLOR n2 50x100 CIEN',
        [PrecioCompra] = 1.89,
        [PrecioVenta] = 2.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 10.000,
        [Estado] = 1
    WHERE [Codigo] = '147';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '147', 'BOLSA GABACHA COLOR n2 50x100 CIEN', 1.89, 2.25, 10.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7415602002698')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'BOLSA TERMO TRANSP 6X10 1/150 CIEN',
        [PrecioCompra] = 0.66,
        [PrecioVenta] = 0.85,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 10.000,
        [Estado] = 1
    WHERE [Codigo] = '7415602002698';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7415602002698', 'BOLSA TERMO TRANSP 6X10 1/150 CIEN', 0.66, 0.85, 10.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7415602002674')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'BOLSA TERMO TRANSP 5X8 1/200 CIEN',
        [PrecioCompra] = 0.46,
        [PrecioVenta] = 0.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 10.000,
        [Estado] = 1
    WHERE [Codigo] = '7415602002674';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7415602002674', 'BOLSA TERMO TRANSP 5X8 1/200 CIEN', 0.46, 0.60, 10.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7441002607256')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'VERDEMAR SARDINAS TOMATE 75G 1/48 Unidad',
        [PrecioCompra] = 0.91,
        [PrecioVenta] = 1.10,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7441002607256';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7441002607256', 'VERDEMAR SARDINAS TOMATE 75G 1/48 Unidad', 0.91, 1.10, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7441002607263')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'VERDEMAR SARDINAS PICANTE 75G 1/48 Unidad',
        [PrecioCompra] = 0.91,
        [PrecioVenta] = 1.10,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7441002607263';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7441002607263', 'VERDEMAR SARDINAS PICANTE 75G 1/48 Unidad', 0.91, 1.10, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '781974000578')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'RUFO ADULTO 1LB 1/12',
        [PrecioCompra] = 0.71,
        [PrecioVenta] = 0.95,
        [PrecioGranel] = NULL,
        [EsGranel] = 1,
        [UnidadMedida] = 'Libra',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '781974000578';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '781974000578', 'RUFO ADULTO 1LB 1/12', 0.71, 0.95, 12.000, 5.000, 1, 'Libra', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001665725')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'KLINPIAX LAVAPLATOS CREMA LIMON 1 K 1/12 UNIDAD',
        [PrecioCompra] = 1.32,
        [PrecioVenta] = 1.70,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001665725';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001665725', 'KLINPIAX LAVAPLATOS CREMA LIMON 1 K 1/12 UNIDAD', 1.32, 1.70, 6.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7501032900281')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'OKO AEROSOL 400ML 1/12',
        [PrecioCompra] = 1.93,
        [PrecioVenta] = 2.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7501032900281';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7501032900281', 'OKO AEROSOL 400ML 1/12', 1.93, 2.25, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '759364921338')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ESCOBA SUPER NENA KALY 1/12',
        [PrecioCompra] = 1.73,
        [PrecioVenta] = 2.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '759364921338';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '759364921338', 'ESCOBA SUPER NENA KALY 1/12', 1.73, 2.25, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7613035396203')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'MAGGI SOPA POLLO C/FIDEOS 55G 12x12 Unidad',
        [PrecioCompra] = 0.33,
        [PrecioVenta] = 0.40,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '7613035396203';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7613035396203', 'MAGGI SOPA POLLO C/FIDEOS 55G 12x12 Unidad', 0.33, 0.40, 1.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '13117017823')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'FIORE ANATOMICA C/A TOALLA SANIT 12x8',
        [PrecioCompra] = 0.49,
        [PrecioVenta] = 0.70,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '13117017823';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '13117017823', 'FIORE ANATOMICA C/A TOALLA SANIT 12x8', 0.49, 0.70, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '13117017830')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'FIORE ANATOMICA S/A TOALLA SANIT 12x8',
        [PrecioCompra] = 0.44,
        [PrecioVenta] = 0.70,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '13117017830';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '13117017830', 'FIORE ANATOMICA S/A TOALLA SANIT 12x8', 0.44, 0.70, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '13117017854')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'FIORE ANATOMICA NOCTURNA C/A 12x8',
        [PrecioCompra] = 0.90,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '13117017854';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '13117017854', 'FIORE ANATOMICA NOCTURNA C/A 12x8', 0.90, 1.00, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '748757005731')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DIANA JALAPEÑOS 21G',
        [PrecioCompra] = 1.50,
        [PrecioVenta] = 1.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 4.000,
        [Estado] = 1
    WHERE [Codigo] = '748757005731';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '748757005731', 'DIANA JALAPEÑOS 21G', 1.50, 1.60, 4.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '748757008688')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DIANA KORCHIPS CON QUESO 29G PEQ TIRA',
        [PrecioCompra] = 1.50,
        [PrecioVenta] = 1.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '748757008688';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '748757008688', 'DIANA KORCHIPS CON QUESO 29G PEQ TIRA', 1.50, 1.60, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '748757008909')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DIANA KORCHIPS CON CHILE 29G PEQ TIRA',
        [PrecioCompra] = 1.50,
        [PrecioVenta] = 1.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '748757008909';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '748757008909', 'DIANA KORCHIPS CON CHILE 29G PEQ TIRA', 1.50, 1.60, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '748757011381')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DIANA MAIZ CHINO PICANTE 12G TIRA',
        [PrecioCompra] = 1.50,
        [PrecioVenta] = 1.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '748757011381';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '748757011381', 'DIANA MAIZ CHINO PICANTE 12G TIRA', 1.50, 1.60, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '748757005441')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DIANA MANI C/LIMON 17G PEQ TIRA',
        [PrecioCompra] = 1.50,
        [PrecioVenta] = 1.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 3.000,
        [Estado] = 1
    WHERE [Codigo] = '748757005441';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '748757005441', 'DIANA MANI C/LIMON 17G PEQ TIRA', 1.50, 1.60, 3.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '748757008411')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DIANA MANI JAPONES 20G PEQ TIRA',
        [PrecioCompra] = 1.50,
        [PrecioVenta] = 1.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 3.000,
        [Estado] = 1
    WHERE [Codigo] = '748757008411';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '748757008411', 'DIANA MANI JAPONES 20G PEQ TIRA', 1.50, 1.60, 3.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '748757005748')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DIANA NACHOS 21G PEQ 1/24 TIRA',
        [PrecioCompra] = 1.50,
        [PrecioVenta] = 1.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '748757005748';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '748757005748', 'DIANA NACHOS 21G PEQ 1/24 TIRA', 1.50, 1.60, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '748757007346')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DIANA PALITOS 21G TIRA',
        [PrecioCompra] = 1.50,
        [PrecioVenta] = 1.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '748757007346';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '748757007346', 'DIANA PALITOS 21G TIRA', 1.50, 1.60, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '748757006417')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DIANA QUESITO 17G PEQ TIRA',
        [PrecioCompra] = 1.50,
        [PrecioVenta] = 1.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '748757006417';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '748757006417', 'DIANA QUESITO 17G PEQ TIRA', 1.50, 1.60, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '748757005847')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DIANA TOZTECA PIZZA 21G TIRA',
        [PrecioCompra] = 1.50,
        [PrecioVenta] = 1.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '748757005847';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '748757005847', 'DIANA TOZTECA PIZZA 21G TIRA', 1.50, 1.60, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000204337')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DEL CHEF MAYONESA BOLSA 180G 1/28 Unidad',
        [PrecioCompra] = 1.05,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000204337';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000204337', 'DEL CHEF MAYONESA BOLSA 180G 1/28 Unidad', 1.05, 1.25, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000204467')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DEL CHEF MAYONESA BOLSA 350G 1/15',
        [PrecioCompra] = 1.71,
        [PrecioVenta] = 2.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 15.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000204467';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000204467', 'DEL CHEF MAYONESA BOLSA 350G 1/15', 1.71, 2.00, 15.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000204351')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DEL CHEF MOSTAZA BOLSA 180G 1/28 Unidad',
        [PrecioCompra] = 0.48,
        [PrecioVenta] = 0.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000204351';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000204351', 'DEL CHEF MOSTAZA BOLSA 180G 1/28 Unidad', 0.48, 0.60, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000204436')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DEL CHEF MOSTAZA BOLSA 350G 1/15',
        [PrecioCompra] = 0.89,
        [PrecioVenta] = 1.10,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 15.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000204436';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000204436', 'DEL CHEF MOSTAZA BOLSA 350G 1/15', 0.89, 1.10, 15.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000204344')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DEL CHEF SANDWICH BOLSA 180G 1/28 Unidad',
        [PrecioCompra] = 1.33,
        [PrecioVenta] = 1.55,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000204344';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000204344', 'DEL CHEF SANDWICH BOLSA 180G 1/28 Unidad', 1.33, 1.55, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000204429')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DEL CHEF SANDWICH BOLSA 350G 1/15',
        [PrecioCompra] = 2.25,
        [PrecioVenta] = 2.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 15.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000204429';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000204429', 'DEL CHEF SANDWICH BOLSA 350G 1/15', 2.25, 2.60, 15.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7410031393713')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CALVO MAIZ DULCE 241 GR 1/24 UNIDAD',
        [PrecioCompra] = 0.97,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '7410031393713';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7410031393713', 'CALVO MAIZ DULCE 241 GR 1/24 UNIDAD', 0.97, 1.25, 6.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411002518081')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DE LA FAMILIA CONSOME POLLO 400G 1/28 Unidad',
        [PrecioCompra] = 1.04,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 3.000,
        [Estado] = 1
    WHERE [Codigo] = '7411002518081';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411002518081', 'DE LA FAMILIA CONSOME POLLO 400G 1/28 Unidad', 1.04, 1.25, 3.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411002518098')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DE LA FAMILIA CONSOME RES 400G 1/28 Unidad',
        [PrecioCompra] = 1.04,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 3.000,
        [Estado] = 1
    WHERE [Codigo] = '7411002518098';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411002518098', 'DE LA FAMILIA CONSOME RES 400G 1/28 Unidad', 1.04, 1.25, 3.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000300541')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CONTINENTAL CARNE 12x60 DISPENSADOR',
        [PrecioCompra] = 8.02,
        [PrecioVenta] = 0.20,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000300541';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000300541', 'CONTINENTAL CARNE 12x60 DISPENSADOR', 8.02, 0.20, 1.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000364635')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CONTINENTAL POLLO 12x60+6 DISPENSADOR',
        [PrecioCompra] = 8.02,
        [PrecioVenta] = 0.20,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000364635';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000364635', 'CONTINENTAL POLLO 12x60+6 DISPENSADOR', 8.02, 0.20, 1.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7421000101994')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'FOSFOROS GATO NEGRO 10x10 PAQUETE',
        [PrecioCompra] = 0.34,
        [PrecioVenta] = 0.50,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Paquete',
        [Stock] = 30.000,
        [Estado] = 1
    WHERE [Codigo] = '7421000101994';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7421000101994', 'FOSFOROS GATO NEGRO 10x10 PAQUETE', 0.34, 0.50, 30.000, 5.000, 0, 'Paquete', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '2241')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'BOLSA 1/2 JARDIN 24X32 100/10 Unidad',
        [PrecioCompra] = 0.53,
        [PrecioVenta] = 0.70,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 10.000,
        [Estado] = 1
    WHERE [Codigo] = '2241';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '2241', 'BOLSA 1/2 JARDIN 24X32 100/10 Unidad', 0.53, 0.70, 10.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '15062')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'BOLSA JARDINERA 34X52 100X5 UND Unidad',
        [PrecioCompra] = 0.65,
        [PrecioVenta] = 0.80,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '15062';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '15062', 'BOLSA JARDINERA 34X52 100X5 UND Unidad', 0.65, 0.80, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7468572205552')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'VASO PLASTIFAR SOPERO 32ONZ 10x25',
        [PrecioCompra] = 3.73,
        [PrecioVenta] = 4.10,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 10.000,
        [Estado] = 1
    WHERE [Codigo] = '7468572205552';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7468572205552', 'VASO PLASTIFAR SOPERO 32ONZ 10x25', 3.73, 4.10, 10.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7406007080213')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'GRAN DIA CORN FLAKES 180G 1/24 UNIDAD',
        [PrecioCompra] = 0.98,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7406007080213';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7406007080213', 'GRAN DIA CORN FLAKES 180G 1/24 UNIDAD', 0.98, 1.25, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7501008000731')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'KELLOGGS 150G CORN FLAKES 1/28 UNIDAD',
        [PrecioCompra] = 1.46,
        [PrecioVenta] = 1.65,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7501008000731';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7501008000731', 'KELLOGGS 150G CORN FLAKES 1/28 UNIDAD', 1.46, 1.65, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7441163700162')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'MINI GELATINA 24/7 BOLSA 330G 30x20 UND BOLSA',
        [PrecioCompra] = 0.73,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7441163700162';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7441163700162', 'MINI GELATINA 24/7 BOLSA 330G 30x20 UND BOLSA', 0.73, 1.00, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7622202231889')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CLORETS VERDE 32x60 DISPENSADOR',
        [PrecioCompra] = 2.76,
        [PrecioVenta] = 0.08,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 3.000,
        [Estado] = 1
    WHERE [Codigo] = '7622202231889';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7622202231889', 'CLORETS VERDE 32x60 DISPENSADOR', 2.76, 0.08, 3.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7441001611933')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DOS PINOS PINITO POLVO 350G 1/24 UNIDAD',
        [PrecioCompra] = 3.49,
        [PrecioVenta] = 3.80,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '7441001611933';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7441001611933', 'DOS PINOS PINITO POLVO 350G 1/24 UNIDAD', 3.49, 3.80, 6.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7412904000049')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'IRA 26 NUTRI INSTANTANEA 360G 1/24 UNIDAD',
        [PrecioCompra] = 1.82,
        [PrecioVenta] = 2.10,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7412904000049';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7412904000049', 'IRA 26 NUTRI INSTANTANEA 360G 1/24 UNIDAD', 1.82, 2.10, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '88313237740')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DUCAL KETCHUP BOTE PLAST 14ONZ 1/24 BOTE',
        [PrecioCompra] = 1.34,
        [PrecioVenta] = 1.55,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '88313237740';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '88313237740', 'DUCAL KETCHUP BOTE PLAST 14ONZ 1/24 BOTE', 1.34, 1.55, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7509546078151')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PALMOLIVE SH 200ML CERAMIDAS 1/15 UNIDAD',
        [PrecioCompra] = 1.27,
        [PrecioVenta] = 1.45,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '7509546078151';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7509546078151', 'PALMOLIVE SH 200ML CERAMIDAS 1/15 UNIDAD', 1.27, 1.45, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7509546698472')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PALMOLIVE SH 200ML HYALURONIC 1/15 UNIDAD',
        [PrecioCompra] = 1.27,
        [PrecioVenta] = 1.45,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '7509546698472';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7509546698472', 'PALMOLIVE SH 200ML HYALURONIC 1/15 UNIDAD', 1.27, 1.45, 1.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7509546692364')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PALMOLIVE SH 200ML AGUACATE Y SABILA 1/15 UNIDAD',
        [PrecioCompra] = 1.27,
        [PrecioVenta] = 1.45,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '7509546692364';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7509546692364', 'PALMOLIVE SH 200ML AGUACATE Y SABILA 1/15 UNIDAD', 1.27, 1.45, 1.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7509546078144')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PALMOLIVE SH 200ML ANTICASPA 1/15 UNIDAD',
        [PrecioCompra] = 1.27,
        [PrecioVenta] = 1.45,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '7509546078144';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7509546078144', 'PALMOLIVE SH 200ML ANTICASPA 1/15 UNIDAD', 1.27, 1.45, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7509546077123')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PALMOLIVE SH 750ML ANTI CAIDA 1/12 UNIDAD',
        [PrecioCompra] = 3.50,
        [PrecioVenta] = 3.95,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 5.000,
        [Estado] = 1
    WHERE [Codigo] = '7509546077123';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7509546077123', 'PALMOLIVE SH 750ML ANTI CAIDA 1/12 UNIDAD', 3.50, 3.95, 5.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7509546077109')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PALMOLIVE SH 750ML CERAMIDAS 1/12 UNIDAD',
        [PrecioCompra] = 3.50,
        [PrecioVenta] = 3.95,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 7.000,
        [Estado] = 1
    WHERE [Codigo] = '7509546077109';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7509546077109', 'PALMOLIVE SH 750ML CERAMIDAS 1/12 UNIDAD', 3.50, 3.95, 7.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7500435248228')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PANTENE SH 10ML RIZOS DEFINIDOS 24x24 TIRA',
        [PrecioCompra] = 3.22,
        [PrecioVenta] = 0.20,
        [PrecioGranel] = 0.20,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 3.000,
        [Estado] = 1
    WHERE [Codigo] = '7500435248228';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7500435248228', 'PANTENE SH 10ML RIZOS DEFINIDOS 24x24 TIRA', 3.22, 0.20, 3.000, 5.000, 1, 'Unidad', 0.20, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7500435236270')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PANTENE CR 10ML RIZOS DEFINIDOS 24x24 DISP',
        [PrecioCompra] = 3.11,
        [PrecioVenta] = 0.20,
        [PrecioGranel] = 0.20,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 3.000,
        [Estado] = 1
    WHERE [Codigo] = '7500435236270';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7500435236270', 'PANTENE CR 10ML RIZOS DEFINIDOS 24x24 DISP', 3.11, 0.20, 3.000, 5.000, 1, 'Unidad', 0.20, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '4719867213268')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'SUPER GLUE PEGAMENTO TIRA 120x12 TIRA',
        [PrecioCompra] = 1.33,
        [PrecioVenta] = 0.15,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '4719867213268';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '4719867213268', 'SUPER GLUE PEGAMENTO TIRA 120x12 TIRA', 1.33, 0.15, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7410010941003')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'EL GENIO SAL  1LB 460G 1/25',
        [PrecioCompra] = 0.14,
        [PrecioVenta] = 0.20,
        [PrecioGranel] = NULL,
        [EsGranel] = 1,
        [UnidadMedida] = 'Libra',
        [Stock] = 50.000,
        [Estado] = 1
    WHERE [Codigo] = '7410010941003';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7410010941003', 'EL GENIO SAL  1LB 460G 1/25', 0.14, 0.20, 50.000, 5.000, 1, 'Libra', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7419900001025')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DIPSA VASO 8 ONZ. 40x25 UND',
        [PrecioCompra] = 0.60,
        [PrecioVenta] = 0.75,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 40.000,
        [Estado] = 1
    WHERE [Codigo] = '7419900001025';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7419900001025', 'DIPSA VASO 8 ONZ. 40x25 UND', 0.60, 0.75, 40.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000343777')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'MAIZENA FRESA 47G 16x12 UNIDAD',
        [PrecioCompra] = 0.75,
        [PrecioVenta] = 0.90,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 4.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000343777';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000343777', 'MAIZENA FRESA 47G 16x12 UNIDAD', 0.75, 0.90, 4.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000343784')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'MAIZENA VAINILLA 47G 16x12 Unidad',
        [PrecioCompra] = 0.75,
        [PrecioVenta] = 0.90,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 4.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000343784';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000343784', 'MAIZENA VAINILLA 47G 16x12 Unidad', 0.75, 0.90, 4.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000343791')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'MAIZENA BANANO 47G 16x12 UNIDAD',
        [PrecioCompra] = 0.75,
        [PrecioVenta] = 0.90,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 4.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000343791';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000343791', 'MAIZENA BANANO 47G 16x12 UNIDAD', 0.75, 0.90, 4.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7410010192559')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PAJILLAS FORRADAS MARLIN 1/50 PAQUETE',
        [PrecioCompra] = 0.34,
        [PrecioVenta] = 0.45,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Paquete',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7410010192559';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7410010192559', 'PAJILLAS FORRADAS MARLIN 1/50 PAQUETE', 0.34, 0.45, 12.000, 5.000, 0, 'Paquete', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '756956777779')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CHOCOPANDA 14G 25x12 TIRA',
        [PrecioCompra] = 1.01,
        [PrecioVenta] = 0.12,
        [PrecioGranel] = 0.12,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '756956777779';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '756956777779', 'CHOCOPANDA 14G 25x12 TIRA', 1.01, 0.12, 12.000, 5.000, 1, 'Unidad', 0.12, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '365498')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ALCOHOL-RAP 120ML PEQ 90º 1/100 Unidad',
        [PrecioCompra] = 0.37,
        [PrecioVenta] = 0.55,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '365498';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '365498', 'ALCOHOL-RAP 120ML PEQ 90º 1/100 Unidad', 0.37, 0.55, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '2645')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ALCOHOL-RAP 240ML 90 BELEN UNIDAD',
        [PrecioCompra] = 0.82,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '2645';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '2645', 'ALCOHOL-RAP 240ML 90 BELEN UNIDAD', 0.82, 1.00, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '760861002697')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'TORO CAFE 30x16 Unidad',
        [PrecioCompra] = 4.06,
        [PrecioVenta] = 0.30,
        [PrecioGranel] = 0.30,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '760861002697';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '760861002697', 'TORO CAFE 30x16 Unidad', 4.06, 0.30, 6.000, 5.000, 1, 'Unidad', 0.30, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '750894640683')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ZIXX JABON 400GR VERDE 6x3 OFERTA',
        [PrecioCompra] = 3.03,
        [PrecioVenta] = 1.15,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '750894640683';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '750894640683', 'ZIXX JABON 400GR VERDE 6x3 OFERTA', 3.03, 1.15, 1.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '750894640959')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ZIXX JABON 400GR ROSADO 6x3 Unidad',
        [PrecioCompra] = 3.03,
        [PrecioVenta] = 1.15,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '750894640959';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '750894640959', 'ZIXX JABON 400GR ROSADO 6x3 Unidad', 3.03, 1.15, 1.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '750894642991')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ZIXX JABON 400GR PEPINO 6x3 OFERTA',
        [PrecioCompra] = 3.03,
        [PrecioVenta] = 1.15,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '750894642991';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '750894642991', 'ZIXX JABON 400GR PEPINO 6x3 OFERTA', 3.03, 1.15, 1.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '750894640676')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ZIXX JABON 400GR BLANCO 6x3 Unidad',
        [PrecioCompra] = 3.03,
        [PrecioVenta] = 1.15,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '750894640676';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '750894640676', 'ZIXX JABON 400GR BLANCO 6x3 Unidad', 3.03, 1.15, 1.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '750894641833')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ZIXX JABON 400GR NENITOS 6x3 OFERTA',
        [PrecioCompra] = 3.03,
        [PrecioVenta] = 1.15,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '750894641833';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '750894641833', 'ZIXX JABON 400GR NENITOS 6x3 OFERTA', 3.03, 1.15, 1.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '750894643516')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ZIXX JABON 400GR DURAZNO 6x3 OFERTA',
        [PrecioCompra] = 3.03,
        [PrecioVenta] = 1.15,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '750894643516';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '750894643516', 'ZIXX JABON 400GR DURAZNO 6x3 OFERTA', 3.03, 1.15, 1.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001680728')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'XTRA 400GR JABON BLANCO ALOE VERA 6x3 Unidad',
        [PrecioCompra] = 3.07,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = 1.25,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001680728';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001680728', 'XTRA 400GR JABON BLANCO ALOE VERA 6x3 Unidad', 3.07, 1.25, 1.000, 5.000, 1, 'Unidad', 1.25, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001686041')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'XTRA 400GR JABON LILA BEBE 6x3 Unidad',
        [PrecioCompra] = 3.07,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = 1.25,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001686041';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001686041', 'XTRA 400GR JABON LILA BEBE 6x3 Unidad', 3.07, 1.25, 1.000, 5.000, 1, 'Unidad', 1.25, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001680889')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'XTRA 400GR JABON MORADO TOQUE SUAVIZANTE 6x3 Unidad',
        [PrecioCompra] = 3.07,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = 1.25,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001680889';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001680889', 'XTRA 400GR JABON MORADO TOQUE SUAVIZANTE 6x3 Unidad', 3.07, 1.25, 1.000, 5.000, 1, 'Unidad', 1.25, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001680735')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'XTRA 400GR JABON AZUL PROTECCION COLOR 6x3 Unidad',
        [PrecioCompra] = 3.07,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = 1.25,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001680735';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001680735', 'XTRA 400GR JABON AZUL PROTECCION COLOR 6x3 Unidad', 3.07, 1.25, 1.000, 5.000, 1, 'Unidad', 1.25, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001680742')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'XTRA 400GR JABON ROSADO PASION FRUTAL 6x3 Unidad',
        [PrecioCompra] = 3.07,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = 1.25,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001680742';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001680742', 'XTRA 400GR JABON ROSADO PASION FRUTAL 6x3 Unidad', 3.07, 1.25, 1.000, 5.000, 1, 'Unidad', 1.25, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001686041')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'XTRA 400GR JABON LILA BEBE 6x3 Unidad',
        [PrecioCompra] = 3.07,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = 1.25,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 1.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001686041';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001686041', 'XTRA 400GR JABON LILA BEBE 6x3 Unidad', 3.07, 1.25, 1.000, 5.000, 1, 'Unidad', 1.25, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '240404201')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'VENENO PARA HORMIGAS 1x50 LIB UNIDAD',
        [PrecioCompra] = 0.77,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '240404201';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '240404201', 'VENENO PARA HORMIGAS 1x50 LIB UNIDAD', 0.77, 1.00, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7503004425020')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'C-REAL B GRANULADO 50GR 1/ 40 UND',
        [PrecioCompra] = 1.37,
        [PrecioVenta] = 1.50,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7503004425020';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7503004425020', 'C-REAL B GRANULADO 50GR 1/ 40 UND', 1.37, 1.50, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '72003')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'COLPAC PROTEMAS SOYA MORENA 1/26 LB LIBRA',
        [PrecioCompra] = 1.09,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 1,
        [UnidadMedida] = 'Libra',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '72003';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '72003', 'COLPAC PROTEMAS SOYA MORENA 1/26 LB LIBRA', 1.09, 1.25, 12.000, 5.000, 1, 'Libra', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7415005100281')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DIAPACK PAPEL ALUMINIO 25FT 1/24 UNIDAD',
        [PrecioCompra] = 0.79,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '7415005100281';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7415005100281', 'DIAPACK PAPEL ALUMINIO 25FT 1/24 UNIDAD', 0.79, 1.00, 6.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7415005100298')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DIAPACK PAPEL ALUMINIO 75 FT 1/24 UNIDAD',
        [PrecioCompra] = 2.02,
        [PrecioVenta] = 2.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '7415005100298';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7415005100298', 'DIAPACK PAPEL ALUMINIO 75 FT 1/24 UNIDAD', 2.02, 2.25, 6.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '2201')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'POLIPEL ROLLO TERMO ECONOMICO 1/32 UNIDAD',
        [PrecioCompra] = 2.05,
        [PrecioVenta] = 2.30,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '2201';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '2201', 'POLIPEL ROLLO TERMO ECONOMICO 1/32 UNIDAD', 2.05, 2.30, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7622201393274')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'TANG 13G PIÑA 12x12 DISPENSADOR',
        [PrecioCompra] = 0.26,
        [PrecioVenta] = 0.35,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7622201393274';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7622201393274', 'TANG 13G PIÑA 12x12 DISPENSADOR', 0.26, 0.35, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7622201393465')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'TANG 13G LIMON 12x12 DISPENSADOR',
        [PrecioCompra] = 0.26,
        [PrecioVenta] = 0.35,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7622201393465';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7622201393465', 'TANG 13G LIMON 12x12 DISPENSADOR', 0.26, 0.35, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7622201393243')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'TANG 13G NARANJA 12x12 DISPENSADOR',
        [PrecioCompra] = 0.26,
        [PrecioVenta] = 0.35,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7622201393243';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7622201393243', 'TANG 13G NARANJA 12x12 DISPENSADOR', 0.26, 0.35, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7622201393380')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'TANG 13G FRESA 12x12 Unidad',
        [PrecioCompra] = 0.26,
        [PrecioVenta] = 0.35,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7622201393380';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7622201393380', 'TANG 13G FRESA 12x12 Unidad', 0.26, 0.35, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7622201393380')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'TANG 13G FRESA 12x12 Unidad',
        [PrecioCompra] = 0.26,
        [PrecioVenta] = 0.35,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7622201393380';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7622201393380', 'TANG 13G FRESA 12x12 Unidad', 0.26, 0.35, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7622201393359')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'TANG 13G PONCHE DE FRUTAS 12x12 DISPENSADOR',
        [PrecioCompra] = 0.26,
        [PrecioVenta] = 0.35,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7622201393359';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7622201393359', 'TANG 13G PONCHE DE FRUTAS 12x12 DISPENSADOR', 0.26, 0.35, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '759364921055')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CEPILLO P/ROPA ESCOPLANCHA 1/72 UNIDAD',
        [PrecioCompra] = 1.59,
        [PrecioVenta] = 1.90,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '759364921055';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '759364921055', 'CEPILLO P/ROPA ESCOPLANCHA 1/72 UNIDAD', 1.59, 1.90, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '764246002869')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'BANDEJA TERMOFOM 8x8 C/DIVISION 4x50',
        [PrecioCompra] = 4.14,
        [PrecioVenta] = 4.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 4.000,
        [Estado] = 1
    WHERE [Codigo] = '764246002869';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '764246002869', 'BANDEJA TERMOFOM 8x8 C/DIVISION 4x50', 4.14, 4.60, 4.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7506306251786')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'EGO GEL ATRACCION 10ML 20x15 TIRA',
        [PrecioCompra] = 3.19,
        [PrecioVenta] = 0.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '7506306251786';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7506306251786', 'EGO GEL ATRACCION 10ML 20x15 TIRA', 3.19, 0.25, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7410030770997')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'MAXI SPLASH DETERG LIQ 120ML 14x5',
        [PrecioCompra] = 0.79,
        [PrecioVenta] = 0.25,
        [PrecioGranel] = 0.25,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 14.000,
        [Estado] = 1
    WHERE [Codigo] = '7410030770997';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7410030770997', 'MAXI SPLASH DETERG LIQ 120ML 14x5', 0.79, 0.25, 14.000, 5.000, 1, 'Unidad', 0.25, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '714258002326')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DON JULIO SALSA PICANTE 460ML 1/24 UNIDAD',
        [PrecioCompra] = 1.08,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '714258002326';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '714258002326', 'DON JULIO SALSA PICANTE 460ML 1/24 UNIDAD', 1.08, 1.25, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411400100581')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'AS DE OROS HARINA DE ARROZ 2LB 1/10',
        [PrecioCompra] = 1.31,
        [PrecioVenta] = 1.50,
        [PrecioGranel] = NULL,
        [EsGranel] = 1,
        [UnidadMedida] = 'Libra',
        [Stock] = 10.000,
        [Estado] = 1
    WHERE [Codigo] = '7411400100581';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411400100581', 'AS DE OROS HARINA DE ARROZ 2LB 1/10', 1.31, 1.50, 10.000, 5.000, 1, 'Libra', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '24474333013')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CALIFORNIA LATA MANZANA 340ML 1/24',
        [PrecioCompra] = 0.40,
        [PrecioVenta] = 0.65,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 24.000,
        [Estado] = 1
    WHERE [Codigo] = '24474333013';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '24474333013', 'CALIFORNIA LATA MANZANA 340ML 1/24', 0.40, 0.65, 24.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '24474333020')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CALIFORNIA LATA DURAZNO 340ML 1/24',
        [PrecioCompra] = 0.40,
        [PrecioVenta] = 0.65,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 24.000,
        [Estado] = 1
    WHERE [Codigo] = '24474333020';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '24474333020', 'CALIFORNIA LATA DURAZNO 340ML 1/24', 0.40, 0.65, 24.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '24474333037')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CALIFORNIA LATA PERA 340ML 1/24',
        [PrecioCompra] = 0.40,
        [PrecioVenta] = 0.65,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 24.000,
        [Estado] = 1
    WHERE [Codigo] = '24474333037';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '24474333037', 'CALIFORNIA LATA PERA 340ML 1/24', 0.40, 0.65, 24.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411001802068')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DEL VALLE JUGO MANDARINA 500ML 1/12',
        [PrecioCompra] = 0.48,
        [PrecioVenta] = 0.65,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 48.000,
        [Estado] = 1
    WHERE [Codigo] = '7411001802068';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411001802068', 'DEL VALLE JUGO MANDARINA 500ML 1/12', 0.48, 0.65, 48.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411001805588')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DEL VALLE JUGO DE CITRICOS 500ML 1/12',
        [PrecioCompra] = 0.48,
        [PrecioVenta] = 0.65,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 24.000,
        [Estado] = 1
    WHERE [Codigo] = '7411001805588';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411001805588', 'DEL VALLE JUGO DE CITRICOS 500ML 1/12', 0.48, 0.65, 24.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411001806301')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DEL VALLE JUGO DE MANDARINA 1.5L 1/6',
        [PrecioCompra] = 0.98,
        [PrecioVenta] = 1.30,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 18.000,
        [Estado] = 1
    WHERE [Codigo] = '7411001806301';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411001806301', 'DEL VALLE JUGO DE MANDARINA 1.5L 1/6', 0.98, 1.30, 18.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '400003216840')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CASCADA SURTIDA SURTIDO 12OZ 1/24',
        [PrecioCompra] = 0.25,
        [PrecioVenta] = 0.35,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 48.000,
        [Estado] = 1
    WHERE [Codigo] = '400003216840';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '400003216840', 'CASCADA SURTIDA SURTIDO 12OZ 1/24', 0.25, 0.35, 48.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '731809002598')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CASCADA UVA 1.25 LT 1/12',
        [PrecioCompra] = 0.64,
        [PrecioVenta] = 0.90,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '731809002598';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '731809002598', 'CASCADA UVA 1.25 LT 1/12', 0.64, 0.90, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '731809002581')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CASCADA FRESA 1.25 LITROS 1/12',
        [PrecioCompra] = 0.64,
        [PrecioVenta] = 0.90,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '731809002581';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '731809002581', 'CASCADA FRESA 1.25 LITROS 1/12', 0.64, 0.90, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '731809002550')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'SALVA COLA 1.25 LITROS 1/12',
        [PrecioCompra] = 0.64,
        [PrecioVenta] = 0.70,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '731809002550';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '731809002550', 'SALVA COLA 1.25 LITROS 1/12', 0.64, 0.70, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '731809002574')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CASCADA ORANGE 1.25 LITROS 1/12',
        [PrecioCompra] = 0.64,
        [PrecioVenta] = 0.90,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '731809002574';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '731809002574', 'CASCADA ORANGE 1.25 LITROS 1/12', 0.64, 0.90, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '753079000708')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CAN CAN XTRA CHOCOVAINILLA GAMA 16x12',
        [PrecioCompra] = 1.72,
        [PrecioVenta] = 2.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 16.000,
        [Estado] = 1
    WHERE [Codigo] = '753079000708';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '753079000708', 'CAN CAN XTRA CHOCOVAINILLA GAMA 16x12', 1.72, 2.00, 16.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7413400502044')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'LIDO MARGARITA GALLETA 1/100 UND',
        [PrecioCompra] = 0.14,
        [PrecioVenta] = 0.20,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 100.000,
        [Estado] = 1
    WHERE [Codigo] = '7413400502044';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7413400502044', 'LIDO MARGARITA GALLETA 1/100 UND', 0.14, 0.20, 100.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7590011151110')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'OREO ORIGINAL 432G 12x12 PAQUETE',
        [PrecioCompra] = 3.24,
        [PrecioVenta] = 3.45,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Paquete',
        [Stock] = 3.000,
        [Estado] = 1
    WHERE [Codigo] = '7590011151110';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7590011151110', 'OREO ORIGINAL 432G 12x12 PAQUETE', 3.24, 3.45, 3.000, 5.000, 0, 'Paquete', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '86581010881')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'CHIKY CHOCOLATE 16x12 Unidad',
        [PrecioCompra] = 2.53,
        [PrecioVenta] = 2.75,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 3.000,
        [Estado] = 1
    WHERE [Codigo] = '86581010881';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '86581010881', 'CHIKY CHOCOLATE 16x12 Unidad', 2.53, 2.75, 3.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '753081008914')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'GAMA CLUB MAX 1/24 Unidad',
        [PrecioCompra] = 1.29,
        [PrecioVenta] = 1.45,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '753081008914';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '753081008914', 'GAMA CLUB MAX 1/24 Unidad', 1.29, 1.45, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7401001503065')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'MANTECA NIEVE 200G 1/72 UNIDAD',
        [PrecioCompra] = 0.55,
        [PrecioVenta] = 0.65,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '7401001503065';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7401001503065', 'MANTECA NIEVE 200G 1/72 UNIDAD', 0.55, 0.65, 6.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '24474312070')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PETIT 200ML SURTIDO CAJITA 6 PACK 1/24',
        [PrecioCompra] = 1.81,
        [PrecioVenta] = 0.40,
        [PrecioGranel] = 0.40,
        [EsGranel] = 1,
        [UnidadMedida] = 'Unidad',
        [Stock] = 4.000,
        [Estado] = 1
    WHERE [Codigo] = '24474312070';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '24474312070', 'PETIT 200ML SURTIDO CAJITA 6 PACK 1/24', 1.81, 0.40, 4.000, 5.000, 1, 'Unidad', 0.40, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7410031470445')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'FRUTTI FRESH SIX PACK SURTIDO 235ML',
        [PrecioCompra] = 0.75,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 8.000,
        [Estado] = 1
    WHERE [Codigo] = '7410031470445';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7410031470445', 'FRUTTI FRESH SIX PACK SURTIDO 235ML', 0.75, 1.00, 8.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '14701')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'LA PALMA BIDON ACEITE 24 BOT REFIL BOTELLA',
        [PrecioCompra] = 1.68,
        [PrecioVenta] = 1.80,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '14701';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '14701', 'LA PALMA BIDON ACEITE 24 BOT REFIL BOTELLA', 1.68, 1.80, 6.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7506195163702')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'MAJIA BLANCA LEJIA 200ML BOLSITA 1/72',
        [PrecioCompra] = 0.17,
        [PrecioVenta] = 0.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 72.000,
        [Estado] = 1
    WHERE [Codigo] = '7506195163702';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7506195163702', 'MAJIA BLANCA LEJIA 200ML BOLSITA 1/72', 0.17, 0.25, 72.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000344859')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'NATURAS SALSITA RANCHERA 90G 1/96 UNIDAD',
        [PrecioCompra] = 0.57,
        [PrecioVenta] = 0.70,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 24.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000344859';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000344859', 'NATURAS SALSITA RANCHERA 90G 1/96 UNIDAD', 0.57, 0.70, 24.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411000344842')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'NATURAS SALSITA C/ QUESO 90G 1/96 UNIDAD',
        [PrecioCompra] = 0.57,
        [PrecioVenta] = 0.70,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 24.000,
        [Estado] = 1
    WHERE [Codigo] = '7411000344842';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411000344842', 'NATURAS SALSITA C/ QUESO 90G 1/96 UNIDAD', 0.57, 0.70, 24.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411500000927')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DEL CAÑAL AZUCAR 1/2 KG 1/50',
        [PrecioCompra] = 0.54,
        [PrecioVenta] = 0.65,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 50.000,
        [Estado] = 1
    WHERE [Codigo] = '7411500000927';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411500000927', 'DEL CAÑAL AZUCAR 1/2 KG 1/50', 0.54, 0.65, 50.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411500000934')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DEL CAÑAL AZUCAR 1 KG 1/25',
        [PrecioCompra] = 1.03,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 25.000,
        [Estado] = 1
    WHERE [Codigo] = '7411500000934';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411500000934', 'DEL CAÑAL AZUCAR 1 KG 1/25', 1.03, 1.25, 25.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411400700019')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ARROZ SAN PEDRO PRECOCIDO 1L 1/25',
        [PrecioCompra] = 0.57,
        [PrecioVenta] = 0.70,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 25.000,
        [Estado] = 1
    WHERE [Codigo] = '7411400700019';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411400700019', 'ARROZ SAN PEDRO PRECOCIDO 1L 1/25', 0.57, 0.70, 25.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7411400802669')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'ARROZ SAN PEDRO BLANCO 1LB 1/25',
        [PrecioCompra] = 0.57,
        [PrecioVenta] = 0.70,
        [PrecioGranel] = NULL,
        [EsGranel] = 1,
        [UnidadMedida] = 'Libra',
        [Stock] = 25.000,
        [Estado] = 1
    WHERE [Codigo] = '7411400802669';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7411400802669', 'ARROZ SAN PEDRO BLANCO 1LB 1/25', 0.57, 0.70, 25.000, 5.000, 1, 'Libra', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7509546654263')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'SUAVITEL 670ML FRESCA PRIMAVERA DOY PACK 1/12 Unidad',
        [PrecioCompra] = 1.28,
        [PrecioVenta] = 1.60,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 6.000,
        [Estado] = 1
    WHERE [Codigo] = '7509546654263';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7509546654263', 'SUAVITEL 670ML FRESCA PRIMAVERA DOY PACK 1/12 Unidad', 1.28, 1.60, 6.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '9917622773')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PROTEX JAB 110G OMEGA 3 1/96 UNIDAD',
        [PrecioCompra] = 0.86,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '9917622773';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '9917622773', 'PROTEX JAB 110G OMEGA 3 1/96 UNIDAD', 0.86, 1.00, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '750954666828')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PROTEX JAB 110G DUO PROTECT 1/96 UNIDAD',
        [PrecioCompra] = 0.86,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '750954666828';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '750954666828', 'PROTEX JAB 110G DUO PROTECT 1/96 UNIDAD', 0.86, 1.00, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '99176922384')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PROTEX JAB 110G ALOE 1/96 UNIDAD',
        [PrecioCompra] = 0.86,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '99176922384';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '99176922384', 'PROTEX JAB 110G ALOE 1/96 UNIDAD', 0.86, 1.00, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '9917622575')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PROTEX JAB 110G LIMPIEZA PROF 1/96 UNIDAD',
        [PrecioCompra] = 0.86,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '9917622575';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '9917622575', 'PROTEX JAB 110G LIMPIEZA PROF 1/96 UNIDAD', 0.86, 1.00, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '9917622247')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PROTEX JAB 110G FRESH 1/96 UNIDAD',
        [PrecioCompra] = 0.86,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '9917622247';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '9917622247', 'PROTEX JAB 110G FRESH 1/96 UNIDAD', 0.86, 1.00, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '99176922346')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PROTEX JAB 110G AVENA 1/96 UNIDAD',
        [PrecioCompra] = 0.86,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '99176922346';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '99176922346', 'PROTEX JAB 110G AVENA 1/96 UNIDAD', 0.86, 1.00, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7509546075549')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PALMOLIVE JAB 100G TONO PERFECTO 1/96 UNIDAD',
        [PrecioCompra] = 0.74,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 4.000,
        [Estado] = 1
    WHERE [Codigo] = '7509546075549';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7509546075549', 'PALMOLIVE JAB 100G TONO PERFECTO 1/96 UNIDAD', 0.74, 1.00, 4.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7509546075488')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PALMOLIVE JAB 100G AVENA Y AZUCAR 1/96 UNIDAD',
        [PrecioCompra] = 0.74,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 4.000,
        [Estado] = 1
    WHERE [Codigo] = '7509546075488';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7509546075488', 'PALMOLIVE JAB 100G AVENA Y AZUCAR 1/96 UNIDAD', 0.74, 1.00, 4.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '99176818288')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PALMOLIVE JAB 100G TYOGHURT Y FRUTAS 1/96 UNIDAD',
        [PrecioCompra] = 0.74,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '99176818288';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '99176818288', 'PALMOLIVE JAB 100G TYOGHURT Y FRUTAS 1/96 UNIDAD', 0.74, 1.00, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7509546075495')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'PALMOLIVE JAB 100G ACEITE/ALMED & OMEGA 1/96 UNIDAD',
        [PrecioCompra] = 0.74,
        [PrecioVenta] = 1.00,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 2.000,
        [Estado] = 1
    WHERE [Codigo] = '7509546075495';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7509546075495', 'PALMOLIVE JAB 100G ACEITE/ALMED & OMEGA 1/96 UNIDAD', 0.74, 1.00, 2.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '99176300397')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'COLGATE PASTA DOBLE FRES 75ML 1/72 Unidad',
        [PrecioCompra] = 1.07,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '99176300397';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '99176300397', 'COLGATE PASTA DOBLE FRES 75ML 1/72 Unidad', 1.07, 1.25, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7509546009179')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'COLGATE PASTA ORIGINAL 75ML 1/72 Unidad',
        [PrecioCompra] = 1.07,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7509546009179';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7509546009179', 'COLGATE PASTA ORIGINAL 75ML 1/72 Unidad', 1.07, 1.25, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7509546000985')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'COLGATE PASTA TRIPLE AC 75ML 1/72 Unidad',
        [PrecioCompra] = 1.07,
        [PrecioVenta] = 1.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7509546000985';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7509546000985', 'COLGATE PASTA TRIPLE AC 75ML 1/72 Unidad', 1.07, 1.25, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7441001601118')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'DOS PINOS PINTO TETRA LIQ LITRO 1/12',
        [PrecioCompra] = 1.82,
        [PrecioVenta] = 2.25,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7441001601118';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7441001601118', 'DOS PINOS PINTO TETRA LIQ LITRO 1/12', 1.82, 2.25, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

IF EXISTS (SELECT 1 FROM [dbo].[Productos] WHERE [Codigo] = '7406249000413')
BEGIN
    UPDATE [dbo].[Productos]
    SET [Nombre] = 'AUSTRALIAN LECHE ENTERA 1LT 1/12',
        [PrecioCompra] = 1.38,
        [PrecioVenta] = 1.75,
        [PrecioGranel] = NULL,
        [EsGranel] = 0,
        [UnidadMedida] = 'Unidad',
        [Stock] = 12.000,
        [Estado] = 1
    WHERE [Codigo] = '7406249000413';
END
ELSE
BEGIN
    INSERT INTO [dbo].[Productos]
    ([IdCategoria], [Codigo], [Nombre], [PrecioCompra], [PrecioVenta], [Stock], [StockMinimo], [EsGranel], [UnidadMedida], [PrecioGranel], [MargenExcepcion], [Estado], [FechaCreacion])
    VALUES
    (1, '7406249000413', 'AUSTRALIAN LECHE ENTERA 1LT 1/12', 1.38, 1.75, 12.000, 5.000, 0, 'Unidad', NULL, 0.00, 1, CURRENT_TIMESTAMP);
END

COMMIT TRANSACTION;
PRINT 'Carga de productos completada exitosamente en Coreas_ERP.';
GO