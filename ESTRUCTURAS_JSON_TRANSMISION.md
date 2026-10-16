# 🏗️ Estructuras JSON para Transmisión DTE
> **El Salvador — Ministerio de Hacienda · API Facturación Electrónica**  
> Guía técnica de la estructura exacta de datos que el Punto de Ventas (POS) debe enviar al endpoint de transmisión, y el formato final que la API genera, firma y envía a Hacienda.

---

## 🗂️ Índice

1. [Estructura del Request API (`/api/Dtes/emit`)](#1-estructura-del-request-api-apidtesemit)
2. [Estructuras del JSON de Entrada (`rawDteJson`) por Documento](#2-estructuras-del-json-de-entrada-rawdtejson-por-documento)
   - [DTE 01 — Factura Electrónica (FE)](#dte-01--factura-electrónica-fe)
   - [DTE 03 — Comprobante de Crédito Fiscal (CCF)](#dte-03--comprobante-de-crédito-fiscal-ccf)
   - [DTE 04 — Nota de Remisión (NR)](#dte-04--nota-de-remisión-nr)
   - [DTE 05 — Nota de Crédito (NC)](#dte-05--nota-de-crédito-nc)
   - [DTE 06 — Nota de Débito (ND)](#dte-06--nota-de-débito-nd)
   - [DTE 14 — Factura Sujeto Excluido (FSE)](#dte-14--factura-sujeto-excluido-fse)
3. [Estructuras Finales Firmadas enviadas a Hacienda](#3-estructuras-finales-firmadas-enviadas-a-hacienda)
4. [Flujo de Procesamiento y Cálculos de la API](#4-flujo-de-procesamiento-y-cálculos-de-la-api)

---

## 1. Estructura del Request API (`/api/Dtes/emit`)

Para emitir cualquier documento, el POS debe realizar una petición HTTP POST al endpoint:
`POST /api/Dtes/emit`

### Payload JSON de la API (`EmitDteRequestDto`)
Este es el objeto que recibe la API directamente en el cuerpo del request:

```json
{
  "rawDteJson": "{\n  \"identificacion\": {\n    \"ambiente\": \"00\",\n    \"tipoDte\": \"01\",\n    \"codigoGeneracion\": \"C5B28B47-59A6-4A59-AC8D-0309B7743F72\",\n    \"numeroControl\": \"DTE-01-M001P001-000000000000101\"\n  },\n  \"receptor\": {\n    \"tipoDocumento\": \"13\",\n    \"numDocumento\": \"051283625\",\n    \"nombre\": \"Juan Alberto Pérez Ortiz\",\n    \"direccion\": {\n      \"catMunicipio\": \"0614\",\n      \"texto\": \"Urbanización Jardines de la Cima, Senda 3, #15\"\n    },\n    \"telefono\": \"70001234\",\n    \"correo\": \"juan.perez@gmail.com\"\n  },\n  \"cuerpoDocumento\": [\n    {\n      \"tipoItem\": 1,\n      \"codigo\": \"PROD-001\",\n      \"descripcion\": \"Camiseta de Algodón Negra L\",\n      \"cantidad\": 2.0,\n      \"uniMedida\": 59,\n      \"precioUni\": 10.00\n    }\n  ],\n  \"resumen\": {\n    \"condicionOperacion\": 1,\n    \"formaPago\": \"01\"\n  }\n}",
  "tipoDte": "01",
  "numeroControl": "DTE-01-M001P001-000000000000101",
  "receptorDocumento": "051283625",
  "receptorNombre": "Juan Alberto Pérez Ortiz",
  "montoTotal": 20.00
}
```

### Campos del Request

| Propiedad | Tipo | Descripción | Obligatorio |
|---|---|---|---|
| `rawDteJson` | `string` | **JSON del DTE en formato string** (detallado abajo). Contiene datos de venta, cliente e ítems. | Sí |
| `tipoDte` | `string` | Tipo de documento (`"01"`, `"03"`, `"04"`, `"05"`, `"06"`, `"14"`). Si viene vacío, se lee del JSON. | No |
| `numeroControl` | `string` | Código correlativo DTE. Si viene vacío, se lee del JSON. | No |
| `receptorDocumento` | `string` | DUI/NIT del cliente. Si no se pasa el objeto `receptor` en el JSON, la API usa esto. | No |
| `receptorNombre` | `string` | Nombre del cliente. Si no se pasa el objeto `receptor` en el JSON, la API usa esto. | No |
| `montoTotal` | `decimal` | Monto total de la venta. Se usa como respaldo si el JSON no tiene cuerpo detallado. | Sí |

---

## 2. Estructuras del JSON de Entrada (`rawDteJson`) por Documento

Esta es la estructura limpia y simplificada del JSON que el POS debe armar e insertar en el campo `rawDteJson` del request. 
> 💡 **Nota Importante:** La API rellenará automáticamente los datos del Emisor (`emisor`), las fechas/horas del sistema (`fecEmi`, `horEmi`), los códigos geográficos en base al municipio (`departamento`, `municipio`, `distrito`), y realizará todas las sumatorias e impuestos en la sección de `resumen`.

---

### DTE 01 — Factura Electrónica (FE)
Se utiliza para ventas a consumidor final. El receptor es opcional (si no se proporciona, se asume Consumidor Final anónimo y la API usa los datos por defecto).

```json
{
  "identificacion": {
    "ambiente": "00", 
    "tipoDte": "01",
    "codigoGeneracion": "B8B8DF9D-8EF1-4475-A186-CD321856F52A",
    "numeroControl": "DTE-01-M001P001-000000000000005"
  },
  "receptor": {
    "tipoDocumento": "13",
    "numDocumento": "051283625",
    "nombre": "Juan Alberto Pérez Ortiz",
    "direccion": {
      "catMunicipio": "0614",
      "texto": "Urbanización Jardines de la Cima, Senda 3, #15"
    },
    "telefono": "70001234",
    "correo": "juan.perez@gmail.com"
  },
  "cuerpoDocumento": [
    {
      "tipoItem": 1,
      "codigo": "P-001",
      "descripcion": "Gaseosa Cola 1.5L",
      "cantidad": 3.0,
      "uniMedida": 59,
      "precioUni": 1.50
    },
    {
      "tipoItem": 1,
      "codigo": "P-002",
      "descripcion": "Bolsa de Papas Fritas",
      "cantidad": 1.0,
      "uniMedida": 59,
      "precioUni": 0.85
    }
  ],
  "resumen": {
    "condicionOperacion": 1,
    "formaPago": "01"
  }
}
```

---

### DTE 03 — Comprobante de Crédito Fiscal (CCF)
Se utiliza para ventas a otros contribuyentes. **El objeto receptor y sus datos tributarios (NIT, NRC, actividad) son estrictamente obligatorios.**

```json
{
  "identificacion": {
    "ambiente": "00",
    "tipoDte": "03",
    "codigoGeneracion": "EE0A7C15-0816-43BA-986F-B99238E14E2F",
    "numeroControl": "DTE-03-M001P001-000000000000005"
  },
  "receptor": {
    "nit": "06141203901015",
    "nrc": "1234567",
    "nombre": "DISTRIBUIDORA SALVADOREÑA S.A. DE C.V.",
    "codActividad": "46309",
    "descActividad": "Venta al por mayor de otros productos alimenticios",
    "nombreComercial": "DISSAL",
    "direccion": {
      "catMunicipio": "0511",
      "texto": "Km 10.5 Carretera al Puerto de La Libertad"
    },
    "telefono": "22880000",
    "correo": "compras@dissal.com.sv"
  },
  "cuerpoDocumento": [
    {
      "tipoItem": 1,
      "codigo": "COD-091",
      "descripcion": "Caja de Aceite Vegetal 12 unidades",
      "cantidad": 10.0,
      "uniMedida": 59,
      "precioUni": 24.50
    }
  ],
  "resumen": {
    "condicionOperacion": 2,
    "formaPago": "05"
  }
}
```

---

### DTE 04 — Nota de Remisión (NR)
Se utiliza para el traslado de mercaderías. El receptor contiene el campo obligatorio `bienTitulo`.

```json
{
  "identificacion": {
    "ambiente": "00",
    "tipoDte": "04",
    "codigoGeneracion": "F22D89A4-6819-4F3D-B278-DCE245DE9810",
    "numeroControl": "DTE-04-M001P001-000000000000005"
  },
  "documentoRelacionado": [
    {
      "tipoDocumento": "03",
      "tipoGeneracion": 1,
      "numeroDocumento": "EE0A7C15-0816-43BA-986F-B99238E14E2F",
      "fechaEmision": "2026-07-25"
    }
  ],
  "receptor": {
    "tipoDocumento": "36",
    "numDocumento": "06141203901015",
    "nrc": "1234567",
    "nombre": "DISTRIBUIDORA SALVADOREÑA S.A. DE C.V.",
    "codActividad": "46309",
    "descActividad": "Venta al por mayor de otros productos alimenticios",
    "direccion": {
      "catMunicipio": "0511",
      "texto": "Km 10.5 Carretera al Puerto de La Libertad"
    },
    "telefono": "22880000",
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
      "precioUni": 24.50
    }
  ],
  "resumen": {
    "condicionOperacion": 1
  }
}
```

---

### DTE 05 — Nota de Crédito (NC)
Se utiliza para realizar descuentos, devoluciones o anulaciones referenciando a un Crédito Fiscal (`03`) emitido anteriormente.

```json
{
  "identificacion": {
    "ambiente": "00",
    "tipoDte": "05",
    "codigoGeneracion": "A009C72F-1109-4A73-A33E-F9473859BC10",
    "numeroControl": "DTE-05-M001P001-000000000000005"
  },
  "documentoRelacionado": [
    {
      "tipoDocumento": "03",
      "tipoGeneracion": 1,
      "numeroDocumento": "EE0A7C15-0816-43BA-986F-B99238E14E2F",
      "fechaEmision": "2026-07-25"
    }
  ],
  "receptor": {
    "tipoDocumento": "36",
    "numDocumento": "06141203901015",
    "nrc": "1234567",
    "nombre": "DISTRIBUIDORA SALVADOREÑA S.A. DE C.V.",
    "codActividad": "46309",
    "descActividad": "Venta al por mayor de otros productos alimenticios",
    "direccion": {
      "catMunicipio": "0511",
      "texto": "Km 10.5 Carretera al Puerto de La Libertad"
    },
    "telefono": "22880000",
    "correo": "compras@dissal.com.sv"
  },
  "cuerpoDocumento": [
    {
      "tipoItem": 1,
      "codigo": "COD-091",
      "descripcion": "Devolución de Caja de Aceite Vegetal (Vencido)",
      "cantidad": 2.0,
      "uniMedida": 59,
      "precioUni": 24.50
    }
  ],
  "resumen": {
    "condicionOperacion": 1,
    "totalGravada": 49.00
  }
}
```

---

### DTE 06 — Nota de Débito (ND)
Se utiliza para cobrar cargos financieros, intereses o diferencias en precios de un Crédito Fiscal previo.

```json
{
  "identificacion": {
    "ambiente": "00",
    "tipoDte": "06",
    "codigoGeneracion": "EE81C7A9-F2E5-45C6-A1D1-7394AEE4890F",
    "numeroControl": "DTE-06-M001P001-000000000000005"
  },
  "documentoRelacionado": [
    {
      "tipoDocumento": "03",
      "tipoGeneracion": 1,
      "numeroDocumento": "EE0A7C15-0816-43BA-986F-B99238E14E2F",
      "fechaEmision": "2026-07-25"
    }
  ],
  "receptor": {
    "tipoDocumento": "36",
    "numDocumento": "06141203901015",
    "nrc": "1234567",
    "nombre": "DISTRIBUIDORA SALVADOREÑA S.A. DE C.V.",
    "codActividad": "46309",
    "descActividad": "Venta al por mayor de otros productos alimenticios",
    "direccion": {
      "catMunicipio": "0511",
      "texto": "Km 10.5 Carretera al Puerto de La Libertad"
    },
    "telefono": "22880000",
    "correo": "compras@dissal.com.sv"
  },
  "cuerpoDocumento": [
    {
      "tipoItem": 2,
      "codigo": "SERV-MORA",
      "descripcion": "Intereses por mora de pago en factura",
      "cantidad": 1.0,
      "uniMedida": 59,
      "precioUni": 15.00
    }
  ],
  "resumen": {
    "condicionOperacion": 1,
    "totalGravada": 15.00
  }
}
```

---

### DTE 14 — Factura Sujeto Excluido (FSE)
Se utiliza cuando una empresa registrada le compra bienes o servicios a una persona natural no registrada en IVA (Sujeto Excluido). El emisor es el comprador y el receptor es el vendedor.

```json
{
  "identificacion": {
    "ambiente": "00",
    "tipoDte": "14",
    "codigoGeneracion": "0B12F7C2-7901-44B9-A23E-B3948A2292E4",
    "numeroControl": "DTE-14-M001P001-000000000000005"
  },
  "receptor": {
    "tipoDocumento": "13",
    "numDocumento": "012345678",
    "nombre": "Carlos Manuel Rivas",
    "codActividad": "62020",
    "descActividad": "Consultoría en tecnología de la información",
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
      "descripcion": "Servicios de mantenimiento y limpieza de servidores",
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

## 3. Estructuras Finales Firmadas enviadas a Hacienda

La API intercepta el JSON anterior, consulta los datos del Tenant (Emisor), mapea el municipio a los 3 códigos requeridos por el MH (`departamento`, `municipio`, `distrito`), realiza las operaciones matemáticas e impuestos, y construye el JSON final. 

A continuación, se muestra el ejemplo final de un **DTE 03 (Crédito Fiscal)** ya procesado, antes de ser firmado digitalmente en JWS:

```json
{
  "identificacion": {
    "version": 4,
    "ambiente": "00",
    "tipoDte": "03",
    "numeroControl": "DTE-03-M001P001-000000000000005",
    "codigoGeneracion": "EE0A7C15-0816-43BA-986F-B99238E14E2F",
    "tipoModelo": 1,
    "tipoOperacion": 1,
    "tipoContingencia": null,
    "motivoContin": null,
    "fecEmi": "2026-07-25",
    "horEmi": "15:33:45",
    "tipoMoneda": "USD"
  },
  "documentoRelacionado": null,
  "emisor": {
    "nit": "06141234561011",
    "nrc": "123456",
    "nombre": "Empresa Test S.A.",
    "codActividad": "62010",
    "descActividad": "Servicios de TI",
    "nombreComercial": "Empresa Test S.A.",
    "direccion": {
      "departamento": "06",
      "municipio": "14",
      "distrito": "01",
      "complemento": "San Salvador"
    },
    "telefono": "22550000",
    "correo": "facturacion@empresatest.com",
    "codEstable": "0001",
    "codPuntoVenta": "0002"
  },
  "receptor": {
    "nit": "06141203901015",
    "nrc": "1234567",
    "nombre": "DISTRIBUIDORA SALVADOREÑA S.A. DE C.V.",
    "codActividad": "46309",
    "descActividad": "Venta al por mayor de otros productos alimenticios",
    "nombreComercial": "DISSAL",
    "direccion": {
      "departamento": "05",
      "municipio": "11",
      "distrito": "10",
      "complemento": "Km 10.5 Carretera al Puerto de La Libertad"
    },
    "telefono": "22880000",
    "correo": "compras@dissal.com.sv"
  },
  "otrosDocumentos": null,
  "ventaTercero": null,
  "cuerpoDocumento": [
    {
      "numItem": 1,
      "tipoItem": 1,
      "numeroDocumento": null,
      "codigo": "COD-091",
      "codTributo": null,
      "descripcion": "Caja de Aceite Vegetal 12 unidades",
      "cantidad": 10.0,
      "uniMedida": 59,
      "precioUni": 21.681416,
      "montoDescu": 0.0,
      "ventaNoSuj": 0.0,
      "ventaExenta": 0.0,
      "ventaGravada": 216.81,
      "tributos": [
        "20"
      ],
      "psv": 0.0,
      "noGravado": 0.0
    }
  ],
  "resumen": {
    "totalNoSuj": 0.0,
    "totalExenta": 0.0,
    "totalGravada": 216.81,
    "subTotalVentas": 216.81,
    "descuNoSuj": 0.0,
    "descuExenta": 0.0,
    "descuGravada": 0.0,
    "porcentajeDescuento": 0.0,
    "totalDescu": 0.0,
    "tributos": [
      {
        "codigo": "20",
        "descripcion": "Impuesto al Valor Agregado",
        "valor": 28.19
      }
    ],
    "subTotal": 216.81,
    "ivaPerci": 0.0,
    "ivaRete": 0.0,
    "montoTotalOperacion": 245.00,
    "totalNoGravado": 0.0,
    "totalPagar": 245.00,
    "totalLetras": "SON 245.00 DOLARES DE LOS ESTADOS UNIDOS DE AMERICA",
    "saldoFavor": 0.0,
    "condicionOperacion": 2,
    "pagos": [
      {
        "codigo": "05",
        "montoPago": 245.00,
        "referencia": null,
        "plazo": null,
        "periodo": null
      }
    ],
    "numPagoElectronico": null,
    "observaciones": null
  },
  "apendice": null
}
```

---

## 4. Flujo de Procesamiento y Cálculos de la API

La API realiza las siguientes acciones automáticamente al recibir el JSON de entrada:

### A. Geocodificación (Municipio a Dept/Muni/Dist)
El MH requiere códigos departamentales, municipales y distritales (de 2 dígitos cada uno). El POS envía un código tradicional de 4 dígitos (`catMunicipio`, ej: `"0614"`). La API usa la clase interna `GeocodesMapping` para resolverlo al instante:
* Entrada POS: `"0614"` (San Salvador)
* Mapeo MH: Departamento = `"06"`, Municipio = `"14"`, Distrito = `"01"`

### B. Cálculo de IVA y Precios Unitarios Netos
1. **DTE 01 (Factura) y DTE 04 (Remisión):** El precio en el punto de venta incluye IVA. La API calcula el IVA por ítem internamente (`precioUni * cantidad * 0.13 / 1.13`) para completar los reportes de Hacienda, pero el precio unitario neto guardado es el precio bruto.
2. **DTE 03 (CCF) y DTE 05 / 06 (NC / ND):** El Ministerio de Hacienda exige que los precios unitarios y totales de los artículos en la sección `cuerpoDocumento` se envíen **sin impuestos (precio neto)**. La API automáticamente detecta si es CCF/NC/ND y calcula:
   - Precio Unitario Neto = `precioUni / 1.13`
   - Venta Gravada = `Precio Unitario Neto * cantidad`
   - IVA del Ítem (13%) = `Venta Gravada * 0.13`
   La API sumará el IVA acumulado y lo agregará en el bloque de `resumen.tributos` con el código `"20"`.

### C. Conversión de Totales a Letras
La API calcula el monto total (`totalPagar`) y genera la cadena técnica en letras requerida por el Ministerio de Hacienda en la propiedad `totalLetras`.
* Ejemplo: `245.00` -> `"SON 245.00 DOLARES DE LOS ESTADOS UNIDOS DE AMERICA"`.
