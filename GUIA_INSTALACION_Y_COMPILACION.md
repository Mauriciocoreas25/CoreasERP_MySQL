# Guía Oficial de Instalación, Compilación y Despliegue — Coreas ERP

Esta guía detalla paso a paso los requisitos del sistema, cómo compilar el proyecto desde cero y las alternativas para generar el instalador (.exe) o paquete de distribución para instalar y operar Coreas ERP en cualquier otra computadora con Windows.

---

## 1. Requisitos del Sistema

### A. Requisitos de la PC donde se va a INSTALAR (PC Cliente / Caja)
| Componente | Requisito Mínimo | Recomendado |
| :--- | :--- | :--- |
| **Sistema Operativo** | Windows 10 (versión 1809 / compilación 17763 o superior, 64-bit) | Windows 10 (21H2+) o Windows 11 (64-bit) |
| **Arquitectura** | x64 (64 bits) | x64 (Intel Core i3/i5 o AMD Ryzen) |
| **Memoria RAM** | 4 GB | 8 GB o superior |
| **Almacenamiento** | 500 MB libres para la aplicación | Unidad SSD |
| **Microsoft Edge WebView2** | Preinstalado por defecto en Windows 10/11 actualizado. Si es un Windows desactualizado, se descarga gratis el [WebView2 Evergreen Bootstrapper](https://go.microsoft.com/fwlink/p/?LinkId=2124703). | Actualizado |
| **Base de Datos** | - **Si la PC es Servidor Principal**: Requiere **SQL Server Express 2019 o 2022** (gratis).<br>- **Si la PC es solo Terminal de Caja secundaria**: **NO requiere SQL Server local**. Solo necesita conexión de red local (LAN/Wi-Fi) a la IP de la máquina Servidor. | SQL Server 2022 Express en Servidor |
| **Impresoras** | - Impresora térmica para tickets (58mm u 80mm USB o Red con su driver de Windows).<br>- Impresora láser/inyección para comprobantes tamaño carta (o Guardar como PDF nativo de Windows). | Drivers instalados |

---

### B. Requisitos de la PC donde se COMPILA (PC de Desarrollo)
1. **.NET 9.0 SDK**: Comprueba con dotnet --version (debe ser 9.0.xxx).
2. **Carga de trabajo .NET MAUI**:
   `powershell
   dotnet workload install maui-windows
   `
3. **Visual Studio 2022** (versión 17.12 o superior) con las cargas:
   - *Desarrollo de interfaz de usuario de aplicaciones multiplataforma de .NET (.NET MAUI)*.
   - *Herramientas de compilación de C++ para Windows*.

---

## 2. Cómo Compilar y Publicar el Ejecutable (.exe)

Para generar la versión de producción optimizada (Release) sin dependencias de depuración:

1. Abre una ventana de **PowerShell** o **Símbolo del sistema (CMD)** como Administrador.
2. Posiciónate en la carpeta del proyecto:
   `powershell
   cd C:\Users\jcore\Downloads\coreasERP\CoreasERP
   `
3. Ejecuta el comando oficial de publicación desempaquetada para Windows:
   `powershell
   dotnet publish -f net9.0-windows10.0.19041.0 -c Release -p:WindowsPackageType=None
   `
4. **Ubicación de salida generada**:
   Los archivos compilados, librerías y el ejecutable principal CoreasERP.exe quedan listos en:
   `	ext
   CoreasERP\bin\Release\net9.0-windows10.0.19041.0\win10-x64\publish\
   `

---

## 3. Opciones para Generar el Instalador y Llevar a Otra PC

Tienes **dos opciones prácticas y profesionales**:

### Opción 1: Paquete Portable con Instalador de Acceso Directo (La más rápida - Lista Ya)
El proyecto ya cuenta con un archivo comprimido listo para copiar en una memoria USB:
- **Ruta del paquete**: C:\Users\jcore\Downloads\coreasERP\CoreasERP_Windows_x64.zip (72 MB).

#### Pasos para instalar en la otra PC:
1. Copia CoreasERP_Windows_x64.zip a la memoria USB y pégalo en la otra PC.
2. Descomprime el contenido en una carpeta limpia y permanente, recomendada:
   `	ext
   C:\CoreasERP
   `
3. Dentro de esa carpeta, haz doble clic en el archivo:
   `	ext
   CrearAccesoDirecto.bat
   `
4. Esto creará inmediatamente el icono oficial de **Coreas ERP** en el **Escritorio** de Windows.
5. Haz doble clic en el icono del Escritorio para abrir la aplicación.

---

### Opción 2: Generar un Único Instalador Profesional CoreasERP_Setup.exe (Con Inno Setup)
Si deseas entregarle al cliente un único archivo ejecutable (ej: CoreasERP_Setup_v1.0.exe) con asistente tradicional de instalación (*Siguiente -> Siguiente -> Instalar*):

1. Descarga e instala la herramienta gratuita **Inno Setup**:
   - Enlace oficial: [https://jrsoftware.org/isdl.php](https://jrsoftware.org/isdl.php)
2. Abre el archivo de configuración que ya dejamos preparado para ti en el proyecto:
   `	ext
   C:\Users\jcore\Downloads\coreasERP\Instalador\CoreasERP_Setup.iss
   `
3. En el menú superior de Inno Setup, haz clic en **Build -> Compile** (o presiona la tecla **F9**).
4. Inno Setup empaquetará automáticamente todos los archivos de la carpeta publish\ y generará en segundos:
   `	ext
   C:\Users\jcore\Downloads\coreasERP\Instalador\Release\CoreasERP_Setup_v1.0.exe
   `
5. **Ventajas**:
   - Es un único archivo ejecutable autónomo.
   - Pide la carpeta de destino (C:\Archivos de programa\Coreas ERP).
   - Crea accesos directos en el Escritorio y en el Menú Inicio con su icono oficial.
   - Agrega la entrada de desinstalación limpia en el Panel de Control de Windows.

---

## 4. Puesta en Marcha en la Otra PC (Base de Datos y Red)

Al abrir la aplicación por primera vez en la otra PC, configuras la conexión a la base de datos:

### Caso A: Si la PC es la Central / Servidor Único
1. Instala **SQL Server Express** y abre **SQL Server Management Studio (SSMS)**.
2. Abre y ejecuta el script de base de datos incluido en la raíz del proyecto:
   `	ext
   Coreas_ERP_Database.sql
   `
3. Abre Coreas ERP -> Ve a **Configuración** -> Sección **Base de Datos**.
4. Verifica que la cadena sea:
   `	ext
   Server=.\SQLEXPRESS;Database=Coreas_ERP;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true;
   `
5. Haz clic en **Probar Conexión** y luego en **Aplicar Conexión**.

### Caso B: Si la PC es una Caja Secundaria / Terminal conectada por Red Local
1. En esta máquina **NO se instala SQL Server**.
2. Asegúrate de que esta PC esté en la misma red Wi-Fi o cableada que el Servidor.
3. En el Servidor, obtén su dirección IP local (ejemplo: 192.168.1.50).
4. Abre Coreas ERP en la terminal de caja -> Menú **Configuración** -> Sección **Base de Datos**.
5. Cambia el servidor por la IP del servidor principal:
   `	ext
   Server=192.168.1.50\SQLEXPRESS;Database=Coreas_ERP;User Id=sa;Password=TuPassword;TrustServerCertificate=True;MultipleActiveResultSets=true;
   `
6. Haz clic en **Probar Conexión** y luego en **Aplicar Conexión**.

---

## 5. Configuración de Impresoras en la PC de Caja

1. Conecta la impresora térmica por USB o Red e instala su controlador en Windows.
2. En Coreas ERP, entra a **Configuración** -> Sección **4. Impresoras del Sistema**:
   - Presiona **Detectar Impresoras**.
   - **Impresora Térmica**: Selecciona tu impresora térmica (ej. POS-80 / Epson) y ancho de 80mm o 58mm.
   - **Impresora de Documentos**: Selecciona tu impresora láser/inyección para cartas o deja *(Diálogo de Windows / Guardar en PDF)*.
   - Haz clic en **Guardar Configuración de Impresión**.
3. Presiona el botón **Imprimir Ticket de Prueba** para validar que imprima correctamente.
