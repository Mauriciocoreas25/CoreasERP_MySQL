-- =====================================================================
-- COREAS ERP - SCRIPT COMPLETO DE BASE DE DATOS PARA MYSQL / MARIADB
-- Motor: InnoDB | Charset: utf8mb4 | Collation: utf8mb4_unicode_ci
-- =====================================================================

CREATE DATABASE IF NOT EXISTS `Coreas_ERP`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `Coreas_ERP`;

SET FOREIGN_KEY_CHECKS = 0;

-- 1. Tabla: Roles
CREATE TABLE IF NOT EXISTS `Roles` (
    `IdRol` INT NOT NULL AUTO_INCREMENT,
    `Nombre` VARCHAR(50) NOT NULL,
    `Descripcion` VARCHAR(150) NULL,
    PRIMARY KEY (`IdRol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Tabla: Usuarios
CREATE TABLE IF NOT EXISTS `Usuarios` (
    `IdUsuario` INT NOT NULL AUTO_INCREMENT,
    `IdRol` INT NOT NULL,
    `Usuario` VARCHAR(50) NOT NULL,
    `Nombre` VARCHAR(100) NOT NULL,
    `Email` VARCHAR(100) NULL,
    `Telefono` VARCHAR(30) NULL,
    `Clave` VARCHAR(255) NOT NULL,
    `Estado` TINYINT(1) NOT NULL DEFAULT 1,
    `FechaCreacion` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`IdUsuario`),
    UNIQUE KEY `UQ_Usuarios_Usuario` (`Usuario`),
    CONSTRAINT `FK_Usuarios_Roles` FOREIGN KEY (`IdRol`) REFERENCES `Roles` (`IdRol`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Tabla: Categorias
CREATE TABLE IF NOT EXISTS `Categorias` (
    `IdCategoria` INT NOT NULL AUTO_INCREMENT,
    `Nombre` VARCHAR(100) NOT NULL,
    `Descripcion` VARCHAR(255) NULL,
    `Estado` TINYINT(1) NOT NULL DEFAULT 1,
    `Icono` VARCHAR(50) NOT NULL DEFAULT 'fa-box',
    `ImagenUrl` VARCHAR(500) NULL,
    PRIMARY KEY (`IdCategoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Tabla: Productos
CREATE TABLE IF NOT EXISTS `Productos` (
    `IdProducto` INT NOT NULL AUTO_INCREMENT,
    `IdCategoria` INT NOT NULL,
    `Codigo` VARCHAR(100) NOT NULL,
    `Nombre` VARCHAR(150) NOT NULL,
    `Descripcion` LONGTEXT NULL,
    `PrecioCompra` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `PrecioVenta` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `Stock` DECIMAL(12, 3) NOT NULL DEFAULT 0.000,
    `StockMinimo` DECIMAL(12, 3) NOT NULL DEFAULT 5.000,
    `EsGranel` TINYINT(1) NOT NULL DEFAULT 0,
    `UnidadMedida` VARCHAR(30) NOT NULL DEFAULT 'Unidad',
    `PrecioGranel` DECIMAL(10, 2) NULL,
    `Imagen` VARCHAR(255) NULL,
    `ImagenUrl` VARCHAR(500) NULL,
    `MargenExcepcion` DECIMAL(5, 2) NOT NULL DEFAULT 0.00,
    `Estado` TINYINT(1) NOT NULL DEFAULT 1,
    `FechaCreacion` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`IdProducto`),
    UNIQUE KEY `UQ_Productos_Codigo` (`Codigo`),
    CONSTRAINT `FK_Productos_Categorias` FOREIGN KEY (`IdCategoria`) REFERENCES `Categorias` (`IdCategoria`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Tabla: ProductoMateriales (BOM / Recetas / Kits)
CREATE TABLE IF NOT EXISTS `ProductoMateriales` (
    `IdProductoMaterial` INT NOT NULL AUTO_INCREMENT,
    `IdProductoPadre` INT NOT NULL,
    `IdProductoInsumo` INT NOT NULL,
    `Cantidad` DECIMAL(10, 2) NOT NULL DEFAULT 1.00,
    `FechaCreacion` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`IdProductoMaterial`),
    CONSTRAINT `FK_ProductoMateriales_Padre` FOREIGN KEY (`IdProductoPadre`) REFERENCES `Productos` (`IdProducto`) ON DELETE CASCADE,
    CONSTRAINT `FK_ProductoMateriales_Insumo` FOREIGN KEY (`IdProductoInsumo`) REFERENCES `Productos` (`IdProducto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Tabla: Proveedores
CREATE TABLE IF NOT EXISTS `Proveedores` (
    `IdProveedor` INT NOT NULL AUTO_INCREMENT,
    `Nombre` VARCHAR(150) NOT NULL,
    `Contacto` VARCHAR(100) NULL,
    `Telefono` VARCHAR(30) NULL,
    `Email` VARCHAR(100) NULL,
    `Direccion` VARCHAR(255) NULL,
    `Nrc` VARCHAR(50) NULL,
    `Nit` VARCHAR(50) NULL,
    `Estado` TINYINT(1) NOT NULL DEFAULT 1,
    `FechaCreacion` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`IdProveedor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Tabla: Clientes
CREATE TABLE IF NOT EXISTS `Clientes` (
    `IdCliente` INT NOT NULL AUTO_INCREMENT,
    `TipoPersona` VARCHAR(30) NOT NULL DEFAULT 'Natural',
    `Nombre` VARCHAR(150) NOT NULL,
    `TipoDocumento` VARCHAR(30) NULL DEFAULT 'DUI',
    `NumDocumento` VARCHAR(50) NULL,
    `Telefono` VARCHAR(30) NULL,
    `Email` VARCHAR(100) NULL,
    `Direccion` VARCHAR(255) NULL,
    `Nrc` VARCHAR(50) NULL,
    `Giro` VARCHAR(150) NULL,
    `FechaCreacion` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`IdCliente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. Tabla: ClienteCuentas (Portal E-Commerce)
CREATE TABLE IF NOT EXISTS `ClienteCuentas` (
    `IdClienteCuenta` INT NOT NULL AUTO_INCREMENT,
    `IdCliente` INT NOT NULL,
    `Email` VARCHAR(100) NOT NULL,
    `Clave` VARCHAR(255) NOT NULL,
    `TokenRecuperacion` VARCHAR(100) NULL,
    `Estado` TINYINT(1) NOT NULL DEFAULT 1,
    `FechaRegistro` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`IdClienteCuenta`),
    UNIQUE KEY `UQ_ClienteCuentas_Email` (`Email`),
    CONSTRAINT `FK_ClienteCuentas_Clientes` FOREIGN KEY (`IdCliente`) REFERENCES `Clientes` (`IdCliente`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. Tabla: Ventas
CREATE TABLE IF NOT EXISTS `Ventas` (
    `IdVenta` INT NOT NULL AUTO_INCREMENT,
    `IdCliente` INT NOT NULL,
    `IdUsuario` INT NOT NULL,
    `TipoComprobante` VARCHAR(30) NOT NULL DEFAULT 'Ticket',
    `NumComprobante` VARCHAR(50) NOT NULL,
    `MetodoPago` VARCHAR(50) NOT NULL DEFAULT 'Efectivo',
    `Subtotal` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `Impuesto` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `Total` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `PagoCon` DECIMAL(10, 2) NULL,
    `Cambio` DECIMAL(10, 2) NULL,
    `Estado` VARCHAR(30) NOT NULL DEFAULT 'Completada',
    `FechaHora` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `CodigoGeneracion` VARCHAR(36) NULL,
    `NumeroControl` VARCHAR(35) NULL,
    `SelloRecepcion` VARCHAR(100) NULL,
    `EstadoDte` VARCHAR(30) NOT NULL DEFAULT 'No_Aplica',
    `DteId` VARCHAR(50) NULL,
    `RespuestaHacienda` VARCHAR(500) NULL,
    PRIMARY KEY (`IdVenta`),
    CONSTRAINT `FK_Ventas_Clientes` FOREIGN KEY (`IdCliente`) REFERENCES `Clientes` (`IdCliente`),
    CONSTRAINT `FK_Ventas_Usuarios` FOREIGN KEY (`IdUsuario`) REFERENCES `Usuarios` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. Tabla: DetalleVentas
CREATE TABLE IF NOT EXISTS `DetalleVentas` (
    `IdDetalle` INT NOT NULL AUTO_INCREMENT,
    `IdVenta` INT NOT NULL,
    `IdProducto` INT NOT NULL,
    `Cantidad` DECIMAL(12, 3) NOT NULL,
    `Precio` DECIMAL(10, 2) NOT NULL,
    `Descuento` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `Subtotal` DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (`IdDetalle`),
    CONSTRAINT `FK_DetalleVentas_Ventas` FOREIGN KEY (`IdVenta`) REFERENCES `Ventas` (`IdVenta`) ON DELETE CASCADE,
    CONSTRAINT `FK_DetalleVentas_Productos` FOREIGN KEY (`IdProducto`) REFERENCES `Productos` (`IdProducto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11. Tabla: Compras
CREATE TABLE IF NOT EXISTS `Compras` (
    `IdCompra` INT NOT NULL AUTO_INCREMENT,
    `IdProveedor` INT NOT NULL,
    `IdUsuario` INT NOT NULL,
    `NumFactura` VARCHAR(50) NOT NULL,
    `Total` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `FechaHora` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `Estado` VARCHAR(30) NOT NULL DEFAULT 'Completada',
    `Observaciones` LONGTEXT NULL,
    PRIMARY KEY (`IdCompra`),
    CONSTRAINT `FK_Compras_Proveedores` FOREIGN KEY (`IdProveedor`) REFERENCES `Proveedores` (`IdProveedor`),
    CONSTRAINT `FK_Compras_Usuarios` FOREIGN KEY (`IdUsuario`) REFERENCES `Usuarios` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 12. Tabla: DetalleCompras
CREATE TABLE IF NOT EXISTS `DetalleCompras` (
    `IdDetalleCompra` INT NOT NULL AUTO_INCREMENT,
    `IdCompra` INT NOT NULL,
    `IdProducto` INT NOT NULL,
    `Cantidad` DECIMAL(12, 3) NOT NULL,
    `PrecioCompra` DECIMAL(10, 2) NOT NULL,
    `Subtotal` DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (`IdDetalleCompra`),
    CONSTRAINT `FK_DetalleCompras_Compras` FOREIGN KEY (`IdCompra`) REFERENCES `Compras` (`IdCompra`) ON DELETE CASCADE,
    CONSTRAINT `FK_DetalleCompras_Productos` FOREIGN KEY (`IdProducto`) REFERENCES `Productos` (`IdProducto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 13. Tabla: CambiosPrecio
CREATE TABLE IF NOT EXISTS `CambiosPrecio` (
    `IdCambioPrecio` INT NOT NULL AUTO_INCREMENT,
    `IdProducto` INT NOT NULL,
    `IdCompra` INT NULL,
    `CostoAnterior` DECIMAL(18, 2) NOT NULL,
    `CostoNuevo` DECIMAL(18, 2) NOT NULL,
    `PrecioVentaAnterior` DECIMAL(18, 2) NOT NULL,
    `PrecioVentaNuevo` DECIMAL(18, 2) NOT NULL,
    `MargenPorcentaje` DECIMAL(18, 2) NOT NULL,
    `Motivo` VARCHAR(255) NOT NULL,
    `FechaHora` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `Estado` VARCHAR(50) NOT NULL DEFAULT 'Pendiente',
    `FechaAplicacion` DATETIME(6) NULL,
    PRIMARY KEY (`IdCambioPrecio`),
    CONSTRAINT `FK_CambiosPrecio_Productos` FOREIGN KEY (`IdProducto`) REFERENCES `Productos` (`IdProducto`),
    CONSTRAINT `FK_CambiosPrecio_Compras` FOREIGN KEY (`IdCompra`) REFERENCES `Compras` (`IdCompra`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 14. Tabla: CuentasCobrar
CREATE TABLE IF NOT EXISTS `CuentasCobrar` (
    `IdCuentaCobrar` INT NOT NULL AUTO_INCREMENT,
    `IdVenta` INT NOT NULL,
    `IdCliente` INT NOT NULL,
    `MontoTotal` DECIMAL(10, 2) NOT NULL,
    `SaldoPendiente` DECIMAL(10, 2) NOT NULL,
    `FechaEmision` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `FechaVencimiento` DATETIME(6) NULL,
    `Estado` VARCHAR(30) NOT NULL DEFAULT 'Pendiente',
    PRIMARY KEY (`IdCuentaCobrar`),
    CONSTRAINT `FK_CuentasCobrar_Ventas` FOREIGN KEY (`IdVenta`) REFERENCES `Ventas` (`IdVenta`),
    CONSTRAINT `FK_CuentasCobrar_Clientes` FOREIGN KEY (`IdCliente`) REFERENCES `Clientes` (`IdCliente`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 15. Tabla: Abonos
CREATE TABLE IF NOT EXISTS `Abonos` (
    `IdAbono` INT NOT NULL AUTO_INCREMENT,
    `IdCuentaCobrar` INT NOT NULL,
    `IdUsuario` INT NOT NULL,
    `Monto` DECIMAL(10, 2) NOT NULL,
    `MetodoPago` VARCHAR(50) NOT NULL DEFAULT 'Efectivo',
    `FechaHora` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `Notas` VARCHAR(255) NULL,
    PRIMARY KEY (`IdAbono`),
    CONSTRAINT `FK_Abonos_CuentasCobrar` FOREIGN KEY (`IdCuentaCobrar`) REFERENCES `CuentasCobrar` (`IdCuentaCobrar`) ON DELETE CASCADE,
    CONSTRAINT `FK_Abonos_Usuarios` FOREIGN KEY (`IdUsuario`) REFERENCES `Usuarios` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 16. Tabla: CortesCaja
CREATE TABLE IF NOT EXISTS `CortesCaja` (
    `IdCorte` INT NOT NULL AUTO_INCREMENT,
    `IdUsuario` INT NOT NULL,
    `MontoInicial` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `TotalVentas` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `MontoFinal` DECIMAL(10, 2) NULL,
    `Diferencia` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `FechaApertura` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `FechaCierre` DATETIME(6) NULL,
    `Estado` VARCHAR(20) NOT NULL DEFAULT 'Abierta',
    PRIMARY KEY (`IdCorte`),
    CONSTRAINT `FK_CortesCaja_Usuarios` FOREIGN KEY (`IdUsuario`) REFERENCES `Usuarios` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 17. Tabla: MovimientosCaja
CREATE TABLE IF NOT EXISTS `MovimientosCaja` (
    `IdMovimiento` INT NOT NULL AUTO_INCREMENT,
    `IdCorte` INT NULL,
    `IdUsuario` INT NOT NULL,
    `Tipo` VARCHAR(30) NOT NULL,
    `Monto` DECIMAL(10, 2) NOT NULL,
    `Motivo` VARCHAR(255) NOT NULL,
    `FechaHora` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`IdMovimiento`),
    CONSTRAINT `FK_MovimientosCaja_CortesCaja` FOREIGN KEY (`IdCorte`) REFERENCES `CortesCaja` (`IdCorte`) ON DELETE SET NULL,
    CONSTRAINT `FK_MovimientosCaja_Usuarios` FOREIGN KEY (`IdUsuario`) REFERENCES `Usuarios` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 18. Tabla: AjustesInventario
CREATE TABLE IF NOT EXISTS `AjustesInventario` (
    `IdAjuste` INT NOT NULL AUTO_INCREMENT,
    `IdProducto` INT NOT NULL,
    `IdUsuarioSupervisor` INT NOT NULL,
    `StockAnterior` DECIMAL(12, 3) NOT NULL,
    `StockNuevo` DECIMAL(12, 3) NOT NULL,
    `Diferencia` DECIMAL(12, 3) NOT NULL,
    `Motivo` VARCHAR(255) NOT NULL,
    `FechaHora` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`IdAjuste`),
    CONSTRAINT `FK_AjustesInventario_Productos` FOREIGN KEY (`IdProducto`) REFERENCES `Productos` (`IdProducto`),
    CONSTRAINT `FK_AjustesInventario_Usuarios` FOREIGN KEY (`IdUsuarioSupervisor`) REFERENCES `Usuarios` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 19. Tabla: Mermas
CREATE TABLE IF NOT EXISTS `Mermas` (
    `IdMerma` INT NOT NULL AUTO_INCREMENT,
    `IdProducto` INT NOT NULL,
    `IdUsuario` INT NOT NULL,
    `Cantidad` DECIMAL(12, 3) NOT NULL,
    `CostoUnitario` DECIMAL(10, 2) NOT NULL,
    `CostoTotal` DECIMAL(10, 2) NOT NULL,
    `TipoMerma` VARCHAR(50) NOT NULL DEFAULT 'Averia',
    `Motivo` VARCHAR(255) NOT NULL,
    `FechaHora` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (`IdMerma`),
    CONSTRAINT `FK_Mermas_Productos` FOREIGN KEY (`IdProducto`) REFERENCES `Productos` (`IdProducto`) ON DELETE CASCADE,
    CONSTRAINT `FK_Mermas_Usuarios` FOREIGN KEY (`IdUsuario`) REFERENCES `Usuarios` (`IdUsuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 20. Tabla: Promociones
CREATE TABLE IF NOT EXISTS `Promociones` (
    `IdPromocion` INT NOT NULL AUTO_INCREMENT,
    `Nombre` VARCHAR(100) NOT NULL,
    `Descripcion` VARCHAR(255) NULL,
    `TipoDescuento` VARCHAR(30) NOT NULL DEFAULT 'Porcentaje',
    `Valor` DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    `FechaInicio` DATETIME(6) NOT NULL,
    `FechaFin` DATETIME(6) NOT NULL,
    `Estado` TINYINT(1) NOT NULL DEFAULT 1,
    `IdProducto` INT NULL,
    PRIMARY KEY (`IdPromocion`),
    CONSTRAINT `FK_Promociones_Productos` FOREIGN KEY (`IdProducto`) REFERENCES `Productos` (`IdProducto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 21. Tabla: OrdenesWeb
CREATE TABLE IF NOT EXISTS `OrdenesWeb` (
    `IdOrden` INT NOT NULL AUTO_INCREMENT,
    `IdCliente` INT NOT NULL,
    `FechaOrden` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `Total` DECIMAL(10, 2) NOT NULL,
    `EstadoPago` VARCHAR(30) NOT NULL DEFAULT 'Pendiente',
    `EstadoEnvio` VARCHAR(30) NOT NULL DEFAULT 'Procesando',
    `IdVenta` INT NULL,
    PRIMARY KEY (`IdOrden`),
    CONSTRAINT `FK_OrdenesWeb_Clientes` FOREIGN KEY (`IdCliente`) REFERENCES `Clientes` (`IdCliente`),
    CONSTRAINT `FK_OrdenesWeb_Ventas` FOREIGN KEY (`IdVenta`) REFERENCES `Ventas` (`IdVenta`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 22. Tabla: DetalleOrdenesWeb
CREATE TABLE IF NOT EXISTS `DetalleOrdenesWeb` (
    `IdDetalleOrden` INT NOT NULL AUTO_INCREMENT,
    `IdOrden` INT NOT NULL,
    `IdProducto` INT NOT NULL,
    `Cantidad` DECIMAL(12, 3) NOT NULL,
    `Precio` DECIMAL(10, 2) NOT NULL,
    `Subtotal` DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (`IdDetalleOrden`),
    CONSTRAINT `FK_DetalleOrdenesWeb_OrdenesWeb` FOREIGN KEY (`IdOrden`) REFERENCES `OrdenesWeb` (`IdOrden`) ON DELETE CASCADE,
    CONSTRAINT `FK_DetalleOrdenesWeb_Productos` FOREIGN KEY (`IdProducto`) REFERENCES `Productos` (`IdProducto`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 23. Tabla: ConfiguracionNegocio
CREATE TABLE IF NOT EXISTS `ConfiguracionNegocio` (
    `IdConfig` INT NOT NULL AUTO_INCREMENT,
    `NombreNegocio` VARCHAR(150) NOT NULL DEFAULT 'Coreas ERP',
    `Propietario` VARCHAR(100) NULL,
    `Telefono` VARCHAR(50) NULL DEFAULT '7000-0000 / 2255-0000',
    `Email` VARCHAR(100) NULL DEFAULT 'info@coreaserp.com',
    `Direccion` VARCHAR(255) NULL DEFAULT 'San Salvador, El Salvador',
    `Nrc` VARCHAR(50) NULL,
    `Nit` VARCHAR(50) NULL,
    `TasaIva` DECIMAL(5, 2) NOT NULL DEFAULT 13.00,
    `MensajeTicket` VARCHAR(255) NOT NULL DEFAULT '¡Gracias por su compra! Vuelva pronto',
    `HabilitarDte` TINYINT(1) NOT NULL DEFAULT 1,
    `FelSvApiUrl` VARCHAR(255) NOT NULL DEFAULT 'http://localhost:5000',
    `FelSvTenantId` VARCHAR(50) NOT NULL DEFAULT 'SUCURSAL-01',
    `FelSvAmbiente` VARCHAR(10) NOT NULL DEFAULT '00',
    `CodEstablecimiento` VARCHAR(10) NOT NULL DEFAULT 'M001',
    `CodPuntoVenta` VARCHAR(10) NOT NULL DEFAULT 'P001',
    `CatDepartamento` VARCHAR(10) NULL DEFAULT '06',
    `CatMunicipio` VARCHAR(10) NULL DEFAULT '14',
    `NombreImpresora` VARCHAR(150) NULL,
    `NombreImpresoraDocumentos` VARCHAR(150) NULL,
    `AnchoPapelMm` INT NOT NULL DEFAULT 80,
    `ImpresionDirecta` TINYINT(1) NOT NULL DEFAULT 1,
    PRIMARY KEY (`IdConfig`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;

-- =====================================================================
-- DATOS INICIALES (SEED DATA)
-- =====================================================================

INSERT IGNORE INTO `Roles` (`IdRol`, `Nombre`, `Descripcion`) VALUES
(1, 'Administrador', 'Acceso total a todos los modulos y configuraciones'),
(2, 'Supervisor', 'Supervision de caja, anulacion y reportes'),
(3, 'Cajero', 'Operacion del punto de venta y turnos de caja');

INSERT IGNORE INTO `Usuarios` (`IdUsuario`, `IdRol`, `Usuario`, `Nombre`, `Email`, `Telefono`, `Clave`, `Estado`, `FechaCreacion`) VALUES
(1, 1, 'admin', 'Administrador General', 'admin@coreaserp.com', '7000-0000', 'admin123', 1, NOW());

INSERT IGNORE INTO `ConfiguracionNegocio` (`IdConfig`, `NombreNegocio`, `Propietario`, `Telefono`, `Email`, `Direccion`, `Nrc`, `Nit`, `TasaIva`, `MensajeTicket`, `HabilitarDte`, `FelSvApiUrl`, `FelSvTenantId`, `FelSvAmbiente`, `CodEstablecimiento`, `CodPuntoVenta`, `CatDepartamento`, `CatMunicipio`, `NombreImpresora`, `NombreImpresoraDocumentos`, `AnchoPapelMm`, `ImpresionDirecta`) VALUES
(1, 'Coreas ERP', 'Administración', '7000-0000', 'info@coreaserp.com', 'San Salvador, El Salvador', '000000-0', '0000-000000-000-0', 13.00, '¡Gracias por su compra! Vuelva pronto', 1, 'http://localhost:5000', 'SUCURSAL-01', '00', 'M001', 'P001', '06', '14', '', '', 80, 1);

INSERT IGNORE INTO `Categorias` (`IdCategoria`, `Nombre`, `Descripcion`, `Estado`, `Icono`, `ImagenUrl`) VALUES
(1, 'General', 'Categoría General', 1, 'fa-box', NULL);

INSERT IGNORE INTO `Clientes` (`IdCliente`, `TipoPersona`, `Nombre`, `TipoDocumento`, `NumDocumento`, `Telefono`, `Email`, `Direccion`, `Nrc`, `Giro`, `FechaCreacion`) VALUES
(1, 'Natural', 'Consumidor Final', 'DUI', '00000000-0', '0000-0000', 'consumidorfinal@coreaserp.com', 'San Salvador', NULL, NULL, NOW());
