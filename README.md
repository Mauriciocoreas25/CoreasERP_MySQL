# Coreas ERP — Sistema de Inventario, POS, Facturación Electrónica (DTE) y Control de Caja

Repositorio oficial del código fuente, scripts de base de datos y documentación maestra de lógica de negocio de **Coreas ERP**, diseñado para su mantenimiento y replicación en otras plataformas (Web, Móvil, Desktop).

---

## 📚 Documentación de Lógica de Negocio y Replicación

Para replicar el sistema en otra tecnología o plataforma, consulta los siguientes documentos incluidos en la raíz de este repositorio:

1. 📄 **[DOCUMENTO_LOGICA_DE_NEGOCIO_COREAS_ERP.md](./DOCUMENTO_LOGICA_DE_NEGOCIO_COREAS_ERP.md)**
   - **Especificación Maestra Agnóstica:** Contiene las 19 entidades del modelo de datos, todas las fórmulas matemáticas (inventario fraccionado/granel, márgenes, desglose de IVA 13%, anticipos, cotizaciones, mermas valuadas al costo, arqueo ciego y libros de IVA), diagramas de flujo y matriz de permisos por rol.
2. 📄 **[GUIA_MAESTRA_SISTEMA_Y_REPLICACION_ALMACEN_IN.md](./GUIA_MAESTRA_SISTEMA_Y_REPLICACION_ALMACEN_IN.md)**
   - Catálogo detallado de las 13 pantallas, los 20 modales del sistema y ejemplos de implementación en arquitectura N-Capas (PHP / MySQL / JS).
3. 📄 **[DOCUMENTACION_SISTEMA_COMPLETO.md](./DOCUMENTACION_SISTEMA_COMPLETO.md)**
   - Especificación de contratos REST API (JSON de entrada/salida) e integración con módulo Ecommerce.
4. 📄 **[MANUAL_INTEGRACION_POS.md](./MANUAL_INTEGRACION_POS.md)** & **[CAMPOS_DTE_REFERENCIA_POS.md](./CAMPOS_DTE_REFERENCIA_POS.md)**
   - Manual técnico de Facturación Electrónica (DTE El Salvador - Ministerio de Hacienda / API FelSv) para los 8 tipos de documentos tributarios, manejo de contingencia offline e invalidaciones.
5. 🗄️ **[Coreas_ERP_Database.sql](./Coreas_ERP_Database.sql)**
   - Script DDL completo de creación de base de datos, tablas, llaves foráneas, valores por defecto y datos semilla (`Roles`, `Usuario Admin`, `Consumidor Final`).

---

## 🏗️ Estructura del Proyecto (`CoreasERP/`)

- **`CoreasERP/Models/`**: Entidades de dominio (`Producto`, `Venta`, `DetalleVenta`, `Compra`, `CorteCaja`, `MovimientoCaja`, `CuentaCobrar`, `Abono`, `Merma`, `AjusteInventario`, `CambioPrecio`, `Promocion`, etc.).
- **`CoreasERP/Data/AppDbContext.cs`**: Configuración relacional con Entity Framework Core.
- **`CoreasERP/Services/`**: Capa de lógica de negocio transaccional:
  - `PosService.cs`: Registro de ventas, descuento proporcional de stock (empaque vs. granel), anticipos, cotizaciones, anulaciones y registro de mermas en lote.
  - `ProductService.cs`: Gestión de catálogo, recetas/materiales (BOM), generación de códigos EAN-13 y ajustes de inventario supervisados con BCrypt.
  - `PurchaseService.cs` & `PriceChangeService.cs`: Ingreso de compras a proveedores, incremento de stock y detección automática de cambios de costo con sugerencia de nuevos precios de venta.
  - `CashRegisterService.cs`: Apertura de turno, movimientos manuales, Corte X, Arqueo Ciego por denominaciones y Corte Z.
  - `CreditService.cs`: Gestión de cuentas por cobrar y amortización de abonos.
  - `DashboardService.cs`: KPIs financieros, utilidad bruta, pérdidas por mermas y Libro de IVA (Débito vs. Crédito Fiscal).
  - `Dte/`: Construcción de JSON y comunicación con API de Facturación Electrónica (`FelSvApiService`, `DteJsonBuilderService`).
- **`CoreasERP/Components/`**: Interfaces de usuario y modales interactivos en Blazor Hybrid.
