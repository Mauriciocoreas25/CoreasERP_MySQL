# CoreasERP — Sistema de Almacén, Inventario, POS y Facturación Electrónica DTE (Edición MySQL / MariaDB)

Sistema integral de planificación de recursos empresariales (ERP) y Punto de Venta (POS) con soporte para Facturación Electrónica (DTE - Ministerio de Hacienda de El Salvador), Control de Inventario con Recetas/BOM, Cuentas por Cobrar, Compras con Costo Promedio Ponderado, Mermas, Exportación/Importación Excel Blindada y E-Commerce sincronizado.

## 📄 Documentación Completa de Lógica de Negocio
Consulta la especificación técnica completa (19 tablas, fórmulas financieras, reglas de negocio y flujos de trabajo paso a paso) en:
👉 **[DOCUMENTO_LOGICA_DE_NEGOCIO_COREAS_ERP.md](./DOCUMENTO_LOGICA_DE_NEGOCIO_COREAS_ERP.md)**

## 🛠️ Stack Tecnológico
- **Framework:** .NET 9 MAUI Blazor Hybrid (`net9.0-windows10.0.19041.0` / multiplataforma)
- **ORM:** Entity Framework Core 9 + `Pomelo.EntityFrameworkCore.MySql` (`9.0.0`) + `MySqlConnector` (`2.4.0`)
- **Base de Datos:** MySQL 8.0+ / MariaDB 10.6+ (InnoDB, `utf8mb4_unicode_ci`) — compatible con Laragon, XAMPP, WAMP o MySQL Server en red LAN.
- **Reportes:** ClosedXML (Excel `.xlsx` nativo con blindaje de importación/exportación) y QuestPDF (PDF / Tickets térmicos 80mm/58mm y Carta)

## 🗄️ Configuración de Base de Datos MySQL
1. El sistema **crea automáticamente** la base de datos `Coreas_ERP`, todas sus tablas y datos semilla al iniciar sesión por primera vez si tu servidor MySQL/MariaDB está activo.
2. También puedes ejecutar manualmente el script completo incluido en la raíz:
   - **[Coreas_ERP_MySQL.sql](./Coreas_ERP_MySQL.sql)**
3. Cadena de conexión por defecto (configurable desde el botón **Servidor MySQL** en la pantalla de Login):
   ```text
   Server=127.0.0.1;Port=3306;Database=Coreas_ERP;User=root;Password=;AllowUserVariables=True;CharSet=utf8mb4;
   ```
4. **Credenciales iniciales por defecto:**
   - **Usuario:** `admin`
   - **Contraseña:** `admin123`
