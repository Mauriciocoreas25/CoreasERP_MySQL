# 📘 Manual Técnico Oficial e Integración API Facturación Electrónica (FelSv)
> **Versión de la API:** 1.0 (Producción / Homologación MH)  
> **Normativa:** Ministerio de Hacienda de El Salvador — Transmisión v2.0 / v4.0  
> **Dirigido a:** Desarrolladores e Integradores de Puntos de Venta (POS Windows Forms, Web, Móvil, ERPs).

---

## 📋 Tabla de Contenidos

1. [Arquitectura General y Flujo de Comunicación](#1-arquitectura-general-y-flujo-de-comunicación)
2. [Conexión, Endpoints y Encabezados](#2-conexión-endpoints-y-encabezados)
3. [Reglas Exactas de Procesamiento en el Backend](#3-reglas-exactas-de-procesamiento-en-el-backend)
   - [3.1 Autocompletado del Emisor (Tenant)](#31-autocompletado-del-emisor-tenant)
   - [3.2 Fechas, Horas y Fechas de Emisión](#32-fechas-horas-y-fechas-de-emisión)
   - [3.3 Geocodificación Automática (Municipios a Depto/Muni/Dist)](#33-geocodificación-automática-municipios-a-deptomunidist)
   - [3.4 Asignación de Versión y Modelo DTE](#34-asignación-de-versión-y-modelo-dte)
   - [3.5 Cálculo de Impuestos (IVA, ISR, Retenciones)](#35-cálculo-de-impuestos-iva-isr-retenciones)
4. [Estructura del Payload REST (`EmitDteRequestDto`)](#4-estructura-del-payload-rest-emitdterequestdto)
5. [Estructuras JSON (`rawDteJson`) Exactas para los 8 Documentos](#5-estructuras-json-rawdtejson-exactas-para-los-8-documentos)
   - [5.1 DTE 01 — Factura Electrónica (FE)](#51-dte-01--factura-electrónica-fe)
   - [5.2 DTE 03 — Comprobante de Crédito Fiscal (CCF)](#52-dte-03--comprobante-de-crédito-fiscal-ccf)
   - [5.3 DTE 04 — Nota de Remisión (NR)](#53-dte-04--nota-de-remisión-nr)
   - [5.4 DTE 05 — Nota de Crédito (NC)](#54-dte-05--nota-de-crédito-nc)
   - [5.5 DTE 06 — Nota de Débito (ND)](#55-dte-06--nota-de-débito-nd)
   - [5.6 DTE 11 — Factura de Exportación (FEX)](#56-dte-11--factura-de-exportación-fex)
   - [5.7 DTE 14 — Factura Sujeto Excluido (FSE)](#57-dte-14--factura-sujeto-excluido-fse)
   - [5.8 DTE 15 — Comprobante de Retención (CR)](#58-dte-15--comprobante-de-retención-cr)
6. [Validaciones Strictas y Errores (Códigos 400 y 503)](#6-validaciones-strictas-y-errores-códigos-400-y-503)
7. [Ejemplos Completos de Integración por Lenguaje](#7-ejemplos-completos-de-integración-por-lenguaje)

---

## 1. Arquitectura General y Flujo de Comunicación

El sistema POS (Windows Forms, Web App o Móvil) **NO realiza el firmado encriptado en formato JWS ni gestiona la comunicación directa con el Ministerio de Hacienda (MH)**.

Toda la lógica de encriptación, llaves X.509, autocompletado de emisor, geocodificación de municipios, cálculo de IVA/ISR y transmisión la gestiona la **API de FelSv**.

```
┌────────────────────────────────┐                 ┌────────────────────────────────┐
│        SISTEMA POS             │                 │           API FELSV            │
│ (WinForms / Web / Android/iOS) │                 │          (C# .NET 8)           │
└───────────────┬────────────────┘                 └───────────────┬────────────────┘
                │                                                  │
                │ 1. POST /api/Dtes/emit                           │
                ├─────────────────────────────────────────────────►│
                │    (JSON simplificado rawDteJson)                │ 2. Carga datos del Tenant (Emisor)
                │                                                  │ 3. Geocodifica municipios
                │                                                  │ 4. Calcula precios netos e IVA (13%)
                │                                                  │ 5. Asigna firma digital JWS (CRT)
                │                                                  │ 6. Transmite a MH El Salvador
                │ 7. Devuelve Sello + ID PDF/Ticket                │
                │◄─────────────────────────────────────────────────┤
┌───────────────┴────────────────┐                 ┌───────────────┴────────────────┐
│      IMPRESIÓN / ALMACENADO    │                 │   MINISTERIO DE HACIENDA (MH)  │
│ POS consume /pdf o /ticket     │                 │   Devuelve Sello de Recepción   │
└────────────────────────────────┘                 └────────────────────────────────┘
```

---

## 2. Conexión, Endpoints y Encabezados

### Base URL
* **Desarrollo / Local:** `http://localhost:5023`
* **Producción:** `http://<IP_O_DOMINIO_DEL_SERVIDOR>:5023`

### Headers Obligatorios para TODAS las peticiones
| Header | Valor | Descripción |
|---|---|---|
| `Content-Type` | `application/json` | Formato de la petición |
| `X-Tenant-Id` | `<GUID_O_NOMBRE_TENANT>` | Identificador único de la sucursal/empresa emisora |

---

## 3. Reglas Exactas de Procesamiento en el Backend

El backend ejecuta las siguientes transformaciones automáticas sobre el JSON enviado por el POS:

### 3.1 Autocompletado del Emisor (Tenant)
El POS **NO necesita incluir los datos del emisor en el JSON**. El backend lee la sucursal activa según el header `X-Tenant-Id` e inyecta automáticamente:
- `emisor.nit`: NIT limpio sin guiones.
- `emisor.nrc`: NRC del contribuyente emisor.
- `emisor.nombre`: Razón Social registrada.
- `emisor.codActividad` y `descActividad`: Actividad económica según catálogo MH.
- `emisor.direccion`: Departamento, municipio y distrito procesados.
- `emisor.telefono` y `correo`: Datos de contacto registrados.
- `emisor.codEstable` y `codPuntoVenta`: Códigos de sucursal y caja (ej. `"M001"`, `"P001"`).

### 3.2 Fechas, Horas y Fechas de Emisión
La API asigna automáticamente:
- `identificacion.fecEmi`: Fecha actual en zona horaria El Salvador (`Central America Standard Time`) en formato `YYYY-MM-DD`.
- `identificacion.horEmi`: Hora actual El Salvador en formato `HH:mm:ss`.

### 3.3 Geocodificación Automática (Municipios a Depto/Muni/Dist)
El Ministerio de Hacienda exige códigos geográficos de 2 dígitos para `departamento`, `municipio` y `distrito`.
El POS solo envía el código de municipio de 4 dígitos en `catMunicipio` (ej. `"0614"` para San Salvador o `"1201"` para San Miguel). El backend utiliza la clase `GeocodesMapping` para descomponerlo automáticamente:
- Entrada POS: `"catMunicipio": "0614"`
- Resultado API: `departamento: "06"`, `municipio: "14"`, `distrito: "01"`

### 3.4 Asignación de Versión y Modelo DTE
La API normaliza las versiones según exigencia del MH:
- **DTE 01 (Factura):** Versión `2`
- **DTE 03 (CCF):** Versión `4`
- **DTE 04 (Remisión):** Versión `4`
- **DTE 05 (Nota de Crédito):** Versión `4`
- **DTE 06 (Nota de Débito):** Versión `4`
- **DTE 11 (Exportación):** Versión `1`
- **DTE 14 (Sujeto Excluido):** Versión `2`
- **DTE 15 (Retención):** Versión `1`

### 3.5 Cálculo de Impuestos (IVA, ISR, Retenciones)

#### A. Factura Electrónica (`tipoDte: "01"`)
- Los precios en el POS incluyen IVA.
- La API calcula para cada ítem:
  $$\text{ivaItem} = \text{round}\left(\frac{\text{precioUni} \times \text{cantidad} \times 0.13}{1.13}, 2\right)$$
  $$\text{ventaGravada} = \text{round}(\text{precioUni} \times \text{cantidad}, 2)$$
- El resumen suma `totalGravada`, `totalIva` (código de tributo `"20"`) y asigna `totalPagar = totalGravada`.

#### B. Crédito Fiscal (`tipoDte: "03"`)
- Si el POS envía el precio con IVA en `precioUni`, el backend lo convierte a **Precio Unitario Neto sin IVA**:
  $$\text{priceNet} = \text{round}\left(\frac{\text{precioUni}}{1.13}, 6\right)$$
  $$\text{ventaGravada} = \text{round}(\text{cantidad} \times \text{priceNet}, 2)$$
  $$\text{iva13Item} = \text{round}(\text{ventaGravada} \times 0.13, 2)$$
- En el resumen, agrega el bloque de tributo `"20"` (*Impuesto al Valor Agregado 13%*) y calcula:
  $$\text{totalPagar} = \text{subTotal} + \text{totalIva}$$

#### C. Nota de Crédito / Débito (`tipoDte: "05"` y `"06"`)
- El resumen calcula el tributo IVA 13% sobre `totalGravada`.
- El campo `totalIva` del resumen representa la sumatoria de IVA Retenido (`ivaRete`), NO el IVA 13%.
- Genera automáticamente `totalLetras` en formato oficial: `"SON XXX.XX DOLARES DE LOS ESTADOS UNIDOS DE AMERICA"`.

#### D. Factura Sujeto Excluido (`tipoDte: "14"`)
- Calcula o recibe `reteRenta` (Retención de ISR 10%).
- Calcula:
  $$\text{totalPagar} = \text{totalCompra} - \text{reteRenta}$$

---

## 4. Estructura del Payload REST (`EmitDteRequestDto`)

Para emitir cualquier documento, el POS debe realizar una petición HTTP `POST` a `/api/Dtes/emit` con la siguiente estructura Wrapper:

```json
{
  "rawDteJson": "{\n  \"identificacion\": {\n    \"ambiente\": \"00\",\n    \"tipoDte\": \"01\",\n    \"numeroControl\": \"DTE-01-M001P001-000000000000001\",\n    \"codigoGeneracion\": \"9B7E3E5B-0123-4ABC-8DEF-1234567890AB\"\n  },\n  \"receptor\": {\n    \"tipoDocumento\": \"13\",\n    \"numDocumento\": \"012345678\",\n    \"nombre\": \"JUAN PEREZ\",\n    \"direccion\": {\n      \"catMunicipio\": \"0614\",\n      \"texto\": \"Colonia Escalón #45, San Salvador\"\n    }\n  },\n  \"cuerpoDocumento\": [\n    {\n      \"tipoItem\": 1,\n      \"codigo\": \"PROD-001\",\n      \"descripcion\": \"Camiseta Algodón L\",\n      \"cantidad\": 1.0,\n      \"uniMedida\": 59,\n      \"precioUni\": 113.00\n    }\n  ],\n  \"resumen\": {\n    \"condicionOperacion\": 1,\n    \"formaPago\": \"01\"\n  }\n}",
  "tipoDte": "01",
  "numeroControl": "DTE-01-M001P001-000000000000001",
  "receptorDocumento": "012345678",
  "receptorNombre": "JUAN PEREZ",
  "montoTotal": 113.00
}
```

---

## 5. Estructuras JSON (`rawDteJson`) Exactas para los 8 Documentos

A continuación se detallan las estructuras exactas que el POS debe armar e insertar en el campo string `rawDteJson`.

---

### 5.1 DTE 01 — Factura Electrónica (FE)
> **Uso:** Ventas a Consumidor Final (Precios con IVA).

```json
{
  "identificacion": {
    "ambiente": "00",
    "tipoDte": "01",
    "numeroControl": "DTE-01-M001P001-000000000000001",
    "codigoGeneracion": "9B7E3E5B-0123-4ABC-8DEF-1234567890AB"
  },
  "receptor": {
    "tipoDocumento": "13",
    "numDocumento": "012345678",
    "nombre": "JUAN PEREZ",
    "direccion": {
      "catMunicipio": "0614",
      "texto": "Colonia Escalón #45, San Salvador"
    },
    "telefono": "77778888",
    "correo": "juan.perez@email.com"
  },
  "cuerpoDocumento": [
    {
      "tipoItem": 1,
      "codigo": "PROD-001",
      "descripcion": "Camiseta de Algodón Negra L",
      "cantidad": 1.0,
      "uniMedida": 59,
      "precioUni": 113.00
    }
  ],
  "resumen": {
    "condicionOperacion": 1,
    "formaPago": "01"
  }
}
```

---

### 5.2 DTE 03 — Comprobante de Crédito Fiscal (CCF)
> **Uso:** Ventas a Contribuyentes / Empresas (Requiere NIT, NRC, Razón Social).

```json
{
  "identificacion": {
    "ambiente": "00",
    "tipoDte": "03",
    "numeroControl": "DTE-03-M001P001-000000000000001",
    "codigoGeneracion": "A1B2C3D4-E5F6-7890-ABCD-EF1234567890"
  },
  "receptor": {
    "nit": "06141505901018",
    "nrc": "9876543",
    "nombre": "DISTRIBUIDORA SALVADOREÑA S.A. DE C.V.",
    "codActividad": "46309",
    "descActividad": "Venta al por mayor de alimentos",
    "nombreComercial": "DISSAL",
    "direccion": {
      "catMunicipio": "0511",
      "texto": "Km 10.5 Carretera al Puerto de La Libertad"
    },
    "telefono": "25000000",
    "correo": "compras@dissal.com.sv"
  },
  "cuerpoDocumento": [
    {
      "tipoItem": 1,
      "codigo": "COD-091",
      "descripcion": "Caja de Aceite Vegetal 12 unidades",
      "cantidad": 10.0,
      "uniMedida": 59,
      "precioUni": 113.00
    }
  ],
  "resumen": {
    "condicionOperacion": 2,
    "formaPago": "05"
  }
}
```

---

### 5.3 DTE 04 — Nota de Remisión (NR)
> **Uso:** Traslado de mercadería. Requiere `documentoRelacionado` (UUID de CCF) y `bienTitulo` en el receptor (`"01"` = Propiedad).

```json
{
  "identificacion": {
    "ambiente": "00",
    "tipoDte": "04",
    "numeroControl": "DTE-04-M001P001-000000000000001",
    "codigoGeneracion": "F22D89A4-6819-4F3D-B278-DCE245DE9810"
  },
  "documentoRelacionado": [
    {
      "tipoDocumento": "03",
      "tipoGeneracion": 1,
      "numeroDocumento": "A1B2C3D4-E5F6-7890-ABCD-EF1234567890",
      "fechaEmision": "2026-08-04"
    }
  ],
  "receptor": {
    "tipoDocumento": "36",
    "numDocumento": "06141505901018",
    "nrc": "9876543",
    "nombre": "DISTRIBUIDORA SALVADOREÑA S.A. DE C.V.",
    "codActividad": "46309",
    "descActividad": "Venta al por mayor de alimentos",
    "direccion": {
      "catMunicipio": "0511",
      "texto": "Km 10.5 Carretera al Puerto de La Libertad"
    },
    "telefono": "25000000",
    "correo": "compras@dissal.com.sv",
    "bienTitulo": "01"
  },
  "cuerpoDocumento": [
    {
      "tipoItem": 1,
      "codigo": "COD-091",
      "descripcion": "Caja de Aceite Vegetal 12 unidades",
      "cantidad": 10.0,
      "uniMedida": 59,
      "precioUni": 100.00
    }
  ],
  "resumen": {
    "condicionOperacion": 1
  }
}
```

---

### 5.4 DTE 05 — Nota de Crédito (NC)
> **Uso:** Devolución o descuento sobre un CCF emito previamente. Obligatorio incluir `documentoRelacionado`.

```json
{
  "identificacion": {
    "ambiente": "00",
    "tipoDte": "05",
    "numeroControl": "DTE-05-M001P001-000000000000001",
    "codigoGeneracion": "A009C72F-1109-4A73-A33E-F9473859BC10"
  },
  "documentoRelacionado": [
    {
      "tipoDocumento": "03",
      "tipoGeneracion": 1,
      "numeroDocumento": "A1B2C3D4-E5F6-7890-ABCD-EF1234567890",
      "fechaEmision": "2026-08-04"
    }
  ],
  "receptor": {
    "tipoDocumento": "36",
    "numDocumento": "06141505901018",
    "nrc": "9876543",
    "nombre": "DISTRIBUIDORA SALVADOREÑA S.A. DE C.V.",
    "codActividad": "46309",
    "descActividad": "Venta al por mayor de alimentos",
    "direccion": {
      "catMunicipio": "0511",
      "texto": "Km 10.5 Carretera al Puerto de La Libertad"
    },
    "telefono": "25000000",
    "correo": "compras@dissal.com.sv"
  },
  "cuerpoDocumento": [
    {
      "tipoItem": 1,
      "numeroDocumento": "A1B2C3D4-E5F6-7890-ABCD-EF1234567890",
      "codigo": "COD-091",
      "descripcion": "Devolución de 2 Cajas de Aceite Vegetal",
      "cantidad": 2.0,
      "uniMedida": 59,
      "precioUni": 100.00,
      "ventaGravada": 200.00
    }
  ],
  "resumen": {
    "condicionOperacion": 1,
    "totalGravada": 200.00
  }
}
```

---

### 5.5 DTE 06 — Nota de Débito (ND)
> **Uso:** Recargos por mora o diferencias en precios sobre un CCF previo.

```json
{
  "identificacion": {
    "ambiente": "00",
    "tipoDte": "06",
    "numeroControl": "DTE-06-M001P001-000000000000001",
    "codigoGeneracion": "EE81C7A9-F2E5-45C6-A1D1-7394AEE4890F"
  },
  "documentoRelacionado": [
    {
      "tipoDocumento": "03",
      "tipoGeneracion": 1,
      "numeroDocumento": "A1B2C3D4-E5F6-7890-ABCD-EF1234567890",
      "fechaEmision": "2026-08-04"
    }
  ],
  "receptor": {
    "tipoDocumento": "36",
    "numDocumento": "06141505901018",
    "nrc": "9876543",
    "nombre": "DISTRIBUIDORA SALVADOREÑA S.A. DE C.V.",
    "codActividad": "46309",
    "descActividad": "Venta al por mayor de alimentos",
    "direccion": {
      "catMunicipio": "0511",
      "texto": "Km 10.5 Carretera al Puerto de La Libertad"
    },
    "telefono": "25000000",
    "correo": "compras@dissal.com.sv"
  },
  "cuerpoDocumento": [
    {
      "tipoItem": 2,
      "numeroDocumento": "A1B2C3D4-E5F6-7890-ABCD-EF1234567890",
      "codigo": "SERV-MORA",
      "descripcion": "Intereses por pago extemporáneo",
      "cantidad": 1.0,
      "uniMedida": 59,
      "precioUni": 25.00,
      "ventaGravada": 25.00
    }
  ],
  "resumen": {
    "condicionOperacion": 1,
    "totalGravada": 25.00
  }
}
```

---

### 5.6 DTE 11 — Factura de Exportación (FEX)
> **Uso:** Exportación de bienes/servicios a clientes en el extranjero.

```json
{
  "identificacion": {
    "ambiente": "00",
    "tipoDte": "11",
    "numeroControl": "DTE-11-M001P001-000000000000001",
    "codigoGeneracion": "C77A88F1-2299-4A73-B11E-F9473859BC99"
  },
  "receptor": {
    "nombre": "GLOBAL CORP LLC",
    "tipoDocumento": "37",
    "numDocumento": "9988776655",
    "nombreComercial": "GLOBAL CORP",
    "codPais": "9304",
    "nombrePais": "ESTADOS UNIDOS",
    "complemento": "123 Wall Street, New York, NY",
    "tipoPersona": 2,
    "telefono": "+12125550199",
    "correo": "exports@globalcorp.com"
  },
  "cuerpoDocumento": [
    {
      "tipoItem": 1,
      "codigo": "EXP-101",
      "descripcion": "Lote de Café Orgánico 500Kg",
      "cantidad": 1.0,
      "uniMedida": 51,
      "precioUni": 3500.00,
      "ventaGravada": 3500.00
    }
  ],
  "resumen": {
    "condicionOperacion": 1,
    "codIncoterms": "FOB",
    "descIncoterms": "Free on Board"
  }
}
```

---

### 5.7 DTE 14 — Factura Sujeto Excluido (FSE)
> **Uso:** Compras a personas naturales que no poseen IVA (Retención de 10% ISR).

```json
{
  "identificacion": {
    "ambiente": "00",
    "tipoDte": "14",
    "numeroControl": "DTE-14-M001P001-000000000000001",
    "codigoGeneracion": "0B12F7C2-7901-44B9-A23E-B3948A2292E4"
  },
  "receptor": {
    "tipoDocumento": "13",
    "numDocumento": "012345678",
    "nombre": "Carlos Manuel Rivas",
    "codActividad": "62020",
    "descActividad": "Consultoría en TI",
    "direccion": {
      "catMunicipio": "0606",
      "texto": "Colonia Escalón, Calle Nueva 1, Casa 12"
    },
    "telefono": "71112222",
    "correo": "carlos.rivas@hotmail.com"
  },
  "cuerpoDocumento": [
    {
      "tipoItem": 2,
      "codigo": "SERV-001",
      "descripcion": "Servicio de Limpieza y Mantenimiento",
      "cantidad": 1.0,
      "uniMedida": 59,
      "precioUni": 250.00
    }
  ],
  "resumen": {
    "condicionOperacion": 1,
    "formaPago": "01",
    "reteRenta": 25.00
  }
}
```

---

### 5.8 DTE 15 — Comprobante de Retención (CR)
> **Uso:** Emisión por Grandes Contribuyentes al retener el 1% de IVA a proveedores.

```json
{
  "identificacion": {
    "ambiente": "00",
    "tipoDte": "15",
    "numeroControl": "DTE-15-M001P001-000000000000001",
    "codigoGeneracion": "F998877A-1122-3344-5566-778899AABBCC"
  },
  "receptor": {
    "tipoDocumento": "36",
    "numDocumento": "06140101001011",
    "nrc": "1234567",
    "nombre": "PROVEEDOR INDUSTRIAL S.A. DE C.V.",
    "codActividad": "46590",
    "descActividad": "Venta de maquinaria",
    "direccion": {
      "catMunicipio": "0614",
      "texto": "Zona Industrial Merliot"
    },
    "telefono": "22334455",
    "correo": "cobros@proveedor.com"
  },
  "cuerpoDocumento": [
    {
      "numItem": 1,
      "tipoDoc": "03",
      "numDocumento": "A1B2C3D4-E5F6-7890-ABCD-EF1234567890",
      "fechaEmision": "2026-08-04",
      "montoSujeto": 1000.00,
      "codigoRetencionMH": "22",
      "ivaRetenido": 10.00
    }
  ],
  "resumen": {
    "totalMontoSujeto": 1000.00,
    "totalIVARetenido": 10.00
  }
}
```

---

## 6. Validaciones Estrictas y Errores (Códigos 400 y 503)

La API devuelve errores descriptivos cuando un payload no cumple con las reglas:

### Error HTTP 400 (Bad Request)
Provocado por inconsistencias en el JSON del POS:
* **Falta de Identificación:** `El nombre del receptor es obligatorio.`
* **Receptor sin NRC en Crédito Fiscal (`03`):** `El número de registro de contribuyente (NRC) del receptor es obligatorio para Crédito Fiscal.`
* **Código Geográfico Inválido:** `El código de municipio del receptor debe tener entre 2 y 4 dígitos (CAT-013).`
* **Emisor Incompleto:** `El NIT del emisor es obligatorio y no puede estar vacío.` (Configurar en base de datos del Tenant).

### Error HTTP 503 (Service Unavailable)
Indica indisponibilidad de los servidores de Hacienda. Devuelve el siguiente payload controlado:
```json
{
  "errorCode": "HACIENDA_UNAVAILABLE",
  "message": "Hacienda API is currently unavailable."
}
```

---

## 7. Ejemplos Completos de Integración por Lenguaje

### C# (.NET / Windows Forms / Desktop)

```csharp
using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

public class FelSvService
{
    private static readonly HttpClient _client = new HttpClient();
    private const string ApiUrl = "http://localhost:5023/api/Dtes/emit";
    private const string TenantId = "SUCURSAL-01";

    public async Task<string> EmitirFacturaEjemplo()
    {
        var rawDteObject = new
        {
            identificacion = new
            {
                ambiente = "00",
                tipoDte = "01",
                numeroControl = "DTE-01-M001P001-000000000000001",
                codigoGeneracion = Guid.NewGuid().ToString().ToUpper()
            },
            receptor = new
            {
                tipoDocumento = "13",
                numDocumento = "012345678",
                nombre = "JUAN PEREZ",
                direccion = new { catMunicipio = "0614", texto = "San Salvador" }
            },
            cuerpoDocumento = new[]
            {
                new { tipoItem = 1, codigo = "P1", descripcion = "Producto 1", cantidad = 1.0, uniMedida = 59, precioUni = 113.00 }
            },
            resumen = new { condicionOperacion = 1, formaPago = "01" }
        };

        string jsonInterno = JsonSerializer.Serialize(rawDteObject);

        var wrapperPayload = new
        {
            rawDteJson = jsonInterno,
            tipoDte = "01",
            numeroControl = "DTE-01-M001P001-000000000000001",
            receptorDocumento = "012345678",
            receptorNombre = "JUAN PEREZ",
            montoTotal = 113.00m
        };

        var requestMessage = new HttpRequestMessage(HttpMethod.Post, ApiUrl);
        requestMessage.Headers.Add("X-Tenant-Id", TenantId);
        requestMessage.Content = new StringContent(JsonSerializer.Serialize(wrapperPayload), Encoding.UTF8, "application/json");

        var response = await _client.SendAsync(requestMessage);
        return await response.Content.ReadAsStringAsync();
    }
}
```

---

## 8. ⚠️ Gestión de Eventos de Contingencia (Offline / Diferido)

Cuando ocurran incidentes que impidan la transmisión normal y en tiempo real de los DTEs (pérdida de conectividad a internet, fallos del suministro eléctrico, caídas del servicio del Ministerio de Hacienda, etc.), el sistema POS debe entrar en **Modo Contingencia**.

El backend de **FelSv** provee endpoints especializados para controlar este flujo y un procesador en segundo plano para garantizar que los DTEs diferidos se transmitan y firmen correctamente una vez restablecido el servicio.

### 8.1 Flujo de Trabajo en Contingencia

```
   [Iniciar Contingencia] ──► [Emitir DTEs en Local] ──► [Cerrar Contingencia] ──► [Transmisión en Lote]
   POST /api/Contingency/start     DTEs guardados como      POST /api/Contingency/stop     Procesador en background
  (Establece Motivo CAT-005)     'Contingencia_Pendiente'                             envía Evento y luego DTEs
```

### 8.2 Endpoints de Control de Contingencia

#### A. Iniciar Contingencia
Declara un estado de contingencia activo en el emisor.
* **POST** `/api/Contingency/start`
* **Request Body:**
```json
{
  "codigoMotivo": "3",
  "descripcionMotivo": "Pérdida de conectividad a internet de la sucursal"
}
```
* **Códigos de Motivo (CAT-005):**
  * `1` = No disponibilidad de los sistemas del emisor.
  * `2` = Falla de suministro de energía eléctrica que impida la transmisión.
  * `3` = Pérdida de conectividad a internet del emisor.
  * `4` = No disponibilidad de los sistemas de Hacienda.
  * `5` = Otro (especificar en la descripción).

#### B. Consultar Contingencia Activa
* **GET** `/api/Contingency/active`
* **Response (Si hay contingencia activa):**
```json
{
  "active": true,
  "eventDetails": {
    "id": "6ff98a07-ef7d-42e1-a04a-6189accdc5fb",
    "codigoMotivo": "3",
    "descripcionMotivo": "Pérdida de conectividad a internet de la sucursal",
    "estado": "Pendiente",
    "fechaInicio": "2026-08-23T00:10:06.688Z",
    "fechaFin": null
  }
}
```

#### C. Finalizar / Detener Contingencia
Cierra el evento de contingencia actual, lo que desencadena de forma inmediata el procesamiento y la transmisión diferida en segundo plano de todos los documentos acumulados.
* **POST** `/api/Contingency/stop`
* **Response:**
```json
{
  "message": "Contingency event closed successfully. Background transmission started."
}
```

---

### 8.3 Reglas de Negocio Aplicadas a DTEs en Contingencia
Mientras un evento de contingencia esté **activo** en el backend:
1. **No se realiza transmisión inmediata a Hacienda:** Las peticiones a `/api/Dtes/emit` responderán con éxito de forma local, guardando el DTE en la base de datos con estado `Contingencia_Pendiente`.
2. **Estructura Especial del JSON:** El JSON original del DTE se modifica automáticamente para reflejar el estado diferido:
   * `identificacion.tipoModelo` se establece en `2` (Diferido/Offline).
   * `identificacion.tipoOperacion` se establece en `2` (Transmisión en Contingencia).
   * `identificacion.tipoContingencia` se inyecta con el código del catálogo CAT-005.
   * `identificacion.motivoContin` se inyecta con la descripción del motivo ingresado.

---

### 8.4 Procesamiento en Segundo Plano (`DteQueueProcessor`)
El procesador en segundo plano realiza los siguientes pasos de forma secuencial y automática una vez cerrada la contingencia:
1. **Transmisión del Evento de Contingencia:** Firma y envía el evento de contingencia conformado según `contingencia-schema-v4.json`. 
   * *Resiliencia:* Si Hacienda responde indicando que el evento de contingencia ya existe (ej. debido a un fallo previo de red en la confirmación de recepción), el procesador marcará el evento localmente como `Transmitido` y procederá sin detenerse.
2. **Refirmado Automático del DTE:** Si por algún error de la integración o del POS el JSON original del DTE contenía configuraciones de transmisión normal (`tipoModelo: 1` o campos de contingencia nulos), el procesador realiza una **corrección en caliente**: inyecta los valores correctos de contingencia y vuelve a firmar digitalmente el DTE usando el certificado del emisor antes de enviarlo.
3. **Transmisión de los DTEs asociados:** Se envían en orden cronológico a la pasarela de Hacienda. Al completarse exitosamente, el estado del DTE cambia a `Transmitido` y se almacena su respectivo `SelloRecepcion`. Si son rechazados, quedan registrados como `Rechazado` con la observación de Hacienda para facilitar auditorías.

---

## 9. 🚫 Gestión de Anulación / Invalidación de DTEs

La normativa tributaria de El Salvador permite a los emisores invalidar (anular) documentos que ya han sido transmitidos y recibidos exitosamente por el Ministerio de Hacienda (por ejemplo, por errores en la digitación, devolución total de mercancías, o cancelaciones de servicios).

### 9.1 Plazos Permitidos
* Para documentos de tipo Factura (`01`), Crédito Fiscal (`03`) y Sujeto Excluido (`14`), el plazo límite para la anulación es típicamente **de 24 horas** contadas a partir de la fecha y hora de emisión del documento.

### 9.2 Endpoint de Invalidación
* **POST** `/api/Invalidation`
* **Request Body (InvalidateDteRequestDto):**
```json
{
  "dteId": "5e0f6f29-0ef2-4af4-b6c8-5a84bfa76094",
  "tipoAnulacion": 2,
  "motivoAnulacion": "El cliente solicitó cambio de datos de facturación e identificación",
  "nombreResponsable": "Carlos Perez (Cajero)",
  "tipDocResponsable": "36",
  "numDocResponsable": "068981707",
  "nombreSolicita": "Mauricio Enrique Coreas",
  "tipDocSolicita": "13",
  "numDocSolicita": "047525635",
  "codigoGeneracionR": null
}
```

### 9.3 Especificaciones de Campos y Catálogos

| Campo | Tipo | Catálogo / Descripción |
|---|---|---|
| `dteId` | GUID | ID único del DTE en la base de datos de FelSv. |
| `tipoAnulacion` | Integer | **Catálogo CAT-024:**<br>`1` = Responsabilidad del emisor<br>`2` = Solicitud del receptor<br>`3` = Sin efecto la operación<br>`4` = Otros |
| `motivoAnulacion` | String | Descripción detallada de la causa de anulación (Mín. 15 caracteres). |
| `nombreResponsable` | String | Nombre completo de la persona de la empresa emisora que autoriza la anulación. |
| `tipDocResponsable` | String | **Catálogo CAT-022:** Tipo de documento de identificación del responsable (ej. `"36"` = NIT, `"13"` = DUI). |
| `numDocResponsable` | String | Número del documento de identificación del responsable (limpio de guiones). |
| `nombreSolicita` | String | Nombre del receptor/cliente que solicita o acepta la anulación. |
| `tipDocSolicita` | String | **Catálogo CAT-022:** Tipo de documento del solicitante (ej. `"13"` = DUI, `"36"` = NIT, `"02"` = Pasaporte). |
| `numDocSolicita` | String | Número del documento de identificación del solicitante (limpio de guiones). |
| `codigoGeneracionR` | String (Opt) | Código de generación del DTE que sustituye al DTE anulado (si aplica). |

### 9.4 Flujo Interno en la API
Al procesarse la solicitud:
1. La API valida que el DTE original se encuentre en estado `Transmitido`.
2. Genera el JSON de invalidación conforme al esquema de anulación de Hacienda.
3. Lo firma digitalmente usando la clave criptográfica del contribuyente.
4. Lo transmite al endpoint de anulación de Hacienda.
5. Al recibir la confirmación de Hacienda, actualiza el estado del DTE en la base de datos local a `Invalidado`, guardando el respectivo sello de anulación de Hacienda.
