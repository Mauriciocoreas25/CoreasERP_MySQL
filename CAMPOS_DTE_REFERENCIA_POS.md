# 📋 Campos Técnicos DTE — Referencia Completa para Punto de Ventas
> **El Salvador — Ministerio de Hacienda · API Facturación Electrónica**  
> Referencia extraída directamente de los JSON Schemas oficiales del proyecto.

---

## 🗂️ Índice

1. [Sección Transversal: `identificacion`](#1-sección-transversal-identificacion)
2. [Sección Transversal: `emisor`](#2-sección-transversal-emisor)
3. [Sección Transversal: `documentoRelacionado`](#3-sección-transversal-documentorelacionado)
4. [Sección Transversal: `ventaTercero`](#4-sección-transversal-ventatercero)
5. [Sección Transversal: `apendice`](#5-sección-transversal-apendice)
6. [DTE 01 — Factura Electrónica (FE)](#6-dte-01--factura-electrónica-fe)
7. [DTE 03 — Comprobante de Crédito Fiscal (CCF)](#7-dte-03--comprobante-de-crédito-fiscal-ccf)
8. [DTE 04 — Nota de Remisión (NR)](#8-dte-04--nota-de-remisión-nr)
9. [DTE 05 — Nota de Crédito (NC)](#9-dte-05--nota-de-crédito-nc)
10. [DTE 06 — Nota de Débito (ND)](#10-dte-06--nota-de-débito-nd)
11. [DTE 14 — Factura Sujeto Excluido (FSE)](#11-dte-14--factura-sujeto-excluido-fse)
12. [Tabla de Catálogos y Valores Permitidos](#12-tabla-de-catálogos-y-valores-permitidos)
13. [Campos Adicionales del POS (No-JSON)](#13-campos-adicionales-del-pos-no-json)

---

## ❗ Convenciones

| Símbolo | Significado |
|---------|-------------|
| **R** | Campo **requerido** (obligatorio) |
| **O** | Campo **opcional** (puede ser `null`) |
| `string` | Texto |
| `number` | Número decimal |
| `integer` | Número entero |
| `date` | Fecha formato `YYYY-MM-DD` |
| `time` | Hora formato `HH:mm:ss` |

---

## 1. Sección Transversal: `identificacion`

> Esta sección va en **todos** los DTEs. La mayoría de campos son **fijos** y los genera automáticamente el sistema. Solo `fecEmi` y `horEmi` vienen del POS.

| Campo JSON | Descripción | Tipo | Req | Notas / Valores |
|---|---|---|---|---|
| `version` | Versión del esquema | `integer` | **R** | Auto. FE=2, CCF=4, NR=4, NC=4, ND=4, FSE=2 |
| `ambiente` | Ambiente de destino | `string` | **R** | `"00"` = Pruebas · `"01"` = Producción |
| `tipoDte` | Tipo de documento | `string` | **R** | Auto. `"01"` FE · `"03"` CCF · `"04"` NR · `"05"` NC · `"06"` ND · `"14"` FSE |
| `numeroControl` | Número de control DTE | `string(31)` | **R** | Auto. Patrón: `DTE-XX-MXXXPXXX-000000000000000` |
| `codigoGeneracion` | UUID único del documento | `string(36)` | **R** | Auto. UUID v4 en mayúsculas |
| `tipoModelo` | Modelo de facturación | `integer` | **R** | `1` = Previo · `2` = Diferido |
| `tipoOperacion` | Tipo de transmisión | `integer` | **R** | `1` = Normal · `2` = Contingencia |
| `tipoContingencia` | Tipo de contingencia | `integer\|null` | **R** | `null` si no aplica. Valores: 1–5 |
| `motivoContin` | Motivo de contingencia | `string\|null` | **R** | `null` si no es contingencia. Max 500 chars |
| `fecEmi` | **Fecha de emisión** | `string` (date) | **R** | **Viene del POS** · Formato: `YYYY-MM-DD` |
| `horEmi` | **Hora de emisión** | `string` (time) | **R** | **Viene del POS** · Formato: `HH:mm:ss` |
| `tipoMoneda` | Moneda | `string` | **R** | Siempre `"USD"` |
| `fusion` | NIT de fusión *(solo NC y ND)* | `string\|null` | **R** | Aplica para NC (`tipoDte:"05"`) y ND (`tipoDte:"06"`) · `null` si no aplica |

> NOTA: `numeroControl` y `codigoGeneracion` los genera el sistema automáticamente. El POS solo necesita enviar `fecEmi`, `horEmi`, `ambiente`, `tipoModelo`, `tipoOperacion`, y en contingencia los campos de contingencia.

---

## 2. Sección Transversal: `emisor`

> El emisor es el **contribuyente registrado**. Estos datos son fijos y se configuran una sola vez en el sistema (Tenant). El POS los hereda automáticamente.

| Campo JSON | Descripción | Tipo | Req | Longitud | Notas |
|---|---|---|---|---|---|
| `nit` | NIT del emisor | `string` | **R** | Max 14 | Sin guiones. Ej: `06140101001011` |
| `nrc` | NRC del emisor | `string` | **R** | 2–8 | Sin guiones. Ej: `123456-7` → `"1234567"` |
| `nombre` | Razón social del emisor | `string` | **R** | 1–250 | Nombre legal del contribuyente |
| `codActividad` | Código de actividad económica | `string` | **R** | 5–6 | Del catálogo MH. Ej: `"47111"` |
| `descActividad` | Descripción de actividad económica | `string` | **R** | 5–150 | Ej: `"Venta al por menor de productos alimenticios"` |
| `nombreComercial` | Nombre comercial del negocio | `string\|null` | **R** | 1–150 | Puede ser `null` si no tiene |
| `direccion.departamento` | Código de departamento | `string` | **R** | 2 | Del catálogo MH. Ej: `"06"` = San Salvador |
| `direccion.municipio` | Código de municipio | `string` | **R** | 2 | Del catálogo MH. Ej: `"14"` = San Salvador |
| `direccion.distrito` | Código de distrito | `string` | **R** | 2 | Del catálogo MH |
| `direccion.complemento` | Dirección detallada | `string` | **R** | 1–200 | Calle, colonia, etc. |
| `telefono` | Teléfono del emisor | `string` | **R** | 8–30 | Sin guiones. Ej: `"22221234"` |
| `correo` | Correo electrónico del emisor | `string` | **R** | 6–100 | Email válido |
| `codEstable` | Código de establecimiento | `string\|null` | **R** | 4 exactos | `null` si no aplica. Asignado por el contribuyente |
| `codPuntoVenta` | Código del punto de venta | `string\|null` | **R** | 1–15 | `null` si no aplica. **Viene del POS** |

> IMPORTANTE: `codEstable` y `codPuntoVenta` se usan en FE, CCF, NR y FSE. En NC y ND NO se incluyen.
> El campo `codPuntoVenta` es el identificador único de cada caja registradora o terminal del POS.

---

## 3. Sección Transversal: `documentoRelacionado`

> Requerido cuando el DTE reemplaza o hace referencia a otro documento. En NC y ND es **obligatorio y no puede ser null**.

| Campo JSON | Descripción | Tipo | Req | Notas |
|---|---|---|---|---|
| `tipoDocumento` | Tipo del doc relacionado | `string` | **R** | Código DTE. Ej: `"03"` para CCF |
| `tipoGeneracion` | Tipo de generación del doc relacionado | `integer` | **R** | `1` = Electrónico · `2` = Físico |
| `numeroDocumento` | Número o UUID del doc relacionado | `string` | **R** | 1–36 chars. UUID si electrónico |
| `fechaEmision` | Fecha de emisión del doc relacionado | `string` (date) | **R** | Formato `YYYY-MM-DD` |

---

## 4. Sección Transversal: `ventaTercero`

> Solo aplica cuando la venta es **por cuenta de un tercero**. Puede ser `null`.

| Campo JSON | Descripción | Tipo | Req | Notas |
|---|---|---|---|---|
| `nit` | NIT del tercero | `string\|null` | **R** | `null` si no aplica |
| `nombre` | Nombre del tercero | `string` | **R** | 1–250 chars |
| `codDomiciliado` | Domicilio fiscal | `integer\|null` | **R** | `1`= Domiciliado · `2`= No domiciliado · `null` si no aplica |

---

## 5. Sección Transversal: `apendice`

> Datos adicionales opcionales (puede ser `null`). Máximo 10 items.

| Campo JSON | Descripción | Tipo | Req | Notas |
|---|---|---|---|---|
| `campo` | Nombre del campo personalizado | `string` | **R** | Max 25 chars |
| `etiqueta` | Etiqueta descriptiva | `string` | **R** | Max 50 chars |
| `valor` | Valor del campo | `string` | **R** | Max 150 chars |

---

## 6. DTE 01 — Factura Electrónica (FE)

**`tipoDte: "01"` · Schema versión 2**

### `receptor` (cliente / consumidor final)

| Campo JSON | Descripción | Tipo | Req | Longitud | Notas |
|---|---|---|---|---|---|
| `tipoDocumento` | Tipo doc de identificación | `string\|null` | **R** | — | Del catálogo. `"13"` DUI · `"36"` NIT · `"02"` CC · `"03"` Pasaporte · `null` si consumidor final |
| `numDocumento` | Número de documento | `string\|null` | **R** | 1–20 | `null` si consumidor final |
| `nrc` | NRC del receptor | `string\|null` | **R** | 2–8 | `null` para personas naturales |
| `nombre` | Nombre del receptor | `string\|null` | **R** | 1–250 | `null` si consumidor final |
| `codActividad` | Código actividad económica | `string\|null` | **R** | 5–6 | `null` si no aplica |
| `descActividad` | Descripción actividad económica | `string\|null` | **R** | 5–150 | `null` si no aplica |
| `direccion` | Dirección del receptor | `object\|null` | **R** | — | `null` si consumidor final |
| `direccion.departamento` | Departamento | `string` | **R** | — | Código catálogo MH |
| `direccion.municipio` | Municipio | `string` | **R** | — | Código catálogo MH |
| `direccion.distrito` | Distrito | `string` | **R** | — | Código catálogo MH |
| `direccion.complemento` | Dirección detallada | `string` | **R** | 1–200 | Calle, colonia, etc. |
| `telefono` | Teléfono | `string\|null` | **R** | 8–30 | `null` si no tiene |
| `correo` | Email | `string\|null` | **R** | 6–100 | `null` si no tiene |

### `cuerpoDocumento` (líneas de producto/servicio)

| Campo JSON | Descripción | Tipo | Req | Notas |
|---|---|---|---|---|
| `numItem` | Número de línea (1,2,3...) | `integer` | **R** | 1–2000 |
| `tipoItem` | Tipo de ítem | `integer` | **R** | `1`=Bien · `2`=Servicio · `3`=Uso o consumo · `4`=Otros |
| `numeroDocumento` | Número doc relacionado al ítem | `string\|null` | **R** | 1–36 · `null` si no aplica |
| `codigo` | Código interno del producto | `string\|null` | **R** | 1–25 · SKU del POS |
| `codTributo` | Tributo especial (no-IVA) | `string\|null` | **R** | 2 chars. `null` si aplica IVA normal |
| `uniMedida` | Unidad de medida | `integer` | **R** | Del catálogo. `59`=Unidad · `46`=Litro · etc. |
| `descripcion` | Descripción del producto/servicio | `string` | **R** | 1–1500 |
| `cantidad` | Cantidad | `number` | **R** | > 0 · hasta 8 decimales |
| `precioUni` | Precio unitario | `number` | **R** | Hasta 8 decimales |
| `montoDescu` | Descuento por ítem | `number` | **R** | 0 si no hay descuento |
| `ventaNoSuj` | Monto venta no sujeta | `number` | **R** | 0 si no aplica |
| `ventaExenta` | Monto venta exenta | `number` | **R** | 0 si no aplica |
| `ventaGravada` | Monto venta gravada (con IVA) | `number` | **R** | Precio sin IVA x cantidad - descuento |
| `tributos` | Códigos de tributos aplicados | `array\|null` | **R** | `["20"]` para IVA · `null` si no aplica |
| `psv` | Precio sugerido de venta | `number` | **R** | 0 si no aplica |
| `noGravado` | Cargos/abonos no imponibles | `number` | **R** | 0 si no aplica |
| `ivaItem` | IVA calculado por ítem | `number` | **R** | ventaGravada x 0.13 |

### `resumen` (totales de la factura)

| Campo JSON | Descripción | Tipo | Req | Notas |
|---|---|---|---|---|
| `totalNoSuj` | Total ventas no sujetas | `number` | **R** | Suma de `ventaNoSuj` |
| `totalExenta` | Total ventas exentas | `number` | **R** | Suma de `ventaExenta` |
| `totalGravada` | Total ventas gravadas | `number` | **R** | Suma de `ventaGravada` |
| `subTotalVentas` | Subtotal (noSuj+exenta+gravada) | `number` | **R** | |
| `descuNoSuj` | Descuento global no sujetas | `number` | **R** | 0 si no aplica |
| `descuExenta` | Descuento global exentas | `number` | **R** | 0 si no aplica |
| `descuGravada` | Descuento global gravadas | `number` | **R** | 0 si no aplica |
| `porcentajeDescuento` | % descuento global | `number` | **R** | 0–100 · 0 si no aplica |
| `totalDescu` | Total descuentos | `number` | **R** | |
| `tributos` | Resumen de tributos aplicados | `array\|null` | **R** | Ver estructura abajo |
| `tributos[].codigo` | Código del tributo | `string` | **R** | Ej: `"20"` = IVA |
| `tributos[].descripcion` | Nombre del tributo | `string` | **R** | Ej: `"Impuesto al Valor Agregado 13%"` |
| `tributos[].valor` | Monto del tributo | `number` | **R** | Monto total de ese tributo |
| `subTotal` | Sub-total después de descuentos | `number` | **R** | |
| `ivaRete` | IVA retenido | `number` | **R** | 0 si no aplica |
| `montoTotalOperacion` | Total de la operación con impuestos | `number` | **R** | |
| `totalNoGravado` | Total cargos/abonos no imponibles | `number` | **R** | 0 si no aplica |
| `totalPagar` | **Total a pagar** | `number` | **R** | |
| `totalLetras` | Total en letras | `string\|null` | **R** | Ej: `"CIEN DOLARES CON 00/100"` |
| `totalIva` | IVA total (13%) | `number` | **R** | |
| `saldoFavor` | Saldo a favor (negativo) | `number` | **R** | 0 si no aplica |
| `condicionOperacion` | Condición de pago | `number` | **R** | `1`=Contado · `2`=Crédito · `3`=Otro |
| `pagos` | Formas de pago | `array\|null` | **R** | Ver estructura abajo |
| `pagos[].codigo` | Código forma de pago | `string\|null` | **R** | Del catálogo. `"01"`=Efectivo · `"02"`=Tarjeta |
| `pagos[].montoPago` | Monto por esa forma de pago | `number` | **R** | |
| `pagos[].referencia` | Referencia (número de tarjeta, etc.) | `string\|null` | **R** | `null` si no aplica |
| `pagos[].plazo` | Plazo de crédito | `string\|null` | **R** | `"01"`=Días · `"02"`=Meses · `"03"`=Años · `null` |
| `pagos[].periodo` | Período del plazo | `number\|null` | **R** | Cantidad de días/meses/años · `null` si contado |
| `numPagoElectronico` | Número de pago electrónico | `string\|null` | **R** | Nro de referencia. `null` si no aplica |
| `observaciones` | Observaciones | `string\|null` | **R** | Max 3000 chars · `null` si no aplica |

---

## 7. DTE 03 — Comprobante de Crédito Fiscal (CCF)

**`tipoDte: "03"` · Schema versión 4**

> IMPORTANTE: El CCF se emite a **contribuyentes (empresas con NIT y NRC)**. El receptor DEBE tener NIT.

### `receptor` (empresa receptora del CCF)

| Campo JSON | Descripción | Tipo | Req | Longitud | Notas |
|---|---|---|---|---|---|
| `nit` | NIT del receptor | `string` | **R** | — | **Obligatorio** en CCF |
| `nrc` | NRC del receptor | `string\|null` | **R** | 2–8 | `null` si no tiene |
| `nombre` | Nombre/razón social | `string` | **R** | 1–250 | |
| `codActividad` | Código actividad económica | `string` | **R** | 5–6 | Del catálogo MH |
| `descActividad` | Descripción actividad | `string` | **R** | 5–150 | |
| `nombreComercial` | Nombre comercial | `string\|null` | **R** | 1–150 | `null` si no tiene |
| `direccion.departamento` | Departamento | `string` | **R** | — | Código catálogo MH |
| `direccion.municipio` | Municipio | `string` | **R** | — | Código catálogo MH |
| `direccion.distrito` | Distrito | `string` | **R** | — | Código catálogo MH |
| `direccion.complemento` | Dirección detallada | `string` | **R** | 1–200 | |
| `telefono` | Teléfono | `string\|null` | **R** | 8–30 | `null` si no tiene |
| `correo` | Email | `string\|null` | **R** | 1–100 | `null` si no tiene |

### `cuerpoDocumento` (líneas del CCF)

> Igual que FE pero SIN el campo `ivaItem`.

| Campo JSON | Descripción | Tipo | Req | Notas |
|---|---|---|---|---|
| `numItem` | Número de línea | `integer` | **R** | 1–2000 |
| `tipoItem` | Tipo de ítem | `integer` | **R** | `1`=Bien · `2`=Servicio · `3`=Uso/consumo · `4`=Otros |
| `numeroDocumento` | Doc relacionado al ítem | `string\|null` | **R** | `null` si no aplica |
| `codigo` | Código del producto (SKU) | `string\|null` | **R** | 1–25 |
| `codTributo` | Tributo especial | `string\|null` | **R** | `null` para IVA normal |
| `descripcion` | Descripción | `string` | **R** | 1–1500 |
| `cantidad` | Cantidad | `number` | **R** | > 0 |
| `uniMedida` | Unidad de medida | `integer` | **R** | Catálogo MH |
| `precioUni` | Precio unitario | `number` | **R** | Precio **sin IVA** |
| `montoDescu` | Descuento por ítem | `number` | **R** | 0 si no aplica |
| `ventaNoSuj` | Venta no sujeta | `number` | **R** | 0 si no aplica |
| `ventaExenta` | Venta exenta | `number` | **R** | 0 si no aplica |
| `ventaGravada` | Venta gravada (sin IVA) | `number` | **R** | |
| `tributos` | Códigos tributos | `array\|null` | **R** | `["20"]` para IVA |
| `psv` | Precio sugerido de venta | `number` | **R** | 0 si no aplica |
| `noGravado` | Cargos no imponibles | `number` | **R** | 0 si no aplica |

### `resumen` (totales CCF)

> Igual que FE pero agrega `ivaPerci`.

| Campo JSON | Descripción | Tipo | Req | Notas |
|---|---|---|---|---|
| `totalNoSuj` | Total no sujetas | `number` | **R** | |
| `totalExenta` | Total exentas | `number` | **R** | |
| `totalGravada` | Total gravadas (sin IVA) | `number` | **R** | |
| `subTotalVentas` | Subtotal ventas | `number` | **R** | |
| `descuNoSuj` | Descuento global no sujetas | `number` | **R** | |
| `descuExenta` | Descuento global exentas | `number` | **R** | |
| `descuGravada` | Descuento global gravadas | `number` | **R** | |
| `porcentajeDescuento` | % descuento | `number` | **R** | |
| `totalDescu` | Total descuentos | `number` | **R** | |
| `tributos` | Resumen tributos | `array\|null` | **R** | |
| `subTotal` | Subtotal después descuentos | `number` | **R** | |
| `ivaPerci` | IVA percibido | `number` | **R** | 0 si no aplica |
| `ivaRete` | IVA retenido | `number` | **R** | 0 si no aplica |
| `montoTotalOperacion` | Total con IVA | `number` | **R** | |
| `totalNoGravado` | Total no imponibles | `number` | **R** | |
| `totalPagar` | **Total a pagar** | `number` | **R** | |
| `totalLetras` | Total en letras | `string\|null` | **R** | |
| `saldoFavor` | Saldo a favor | `number` | **R** | 0 si no aplica |
| `condicionOperacion` | Condición de pago | `number` | **R** | `1`=Contado · `2`=Crédito · `3`=Otro |
| `pagos` | Formas de pago | `array\|null` | **R** | Igual que FE |
| `numPagoElectronico` | Ref. pago electrónico | `string\|null` | **R** | |
| `observaciones` | Observaciones | `string\|null` | **R** | |

---

## 8. DTE 04 — Nota de Remisión (NR)

**`tipoDte: "04"` · Schema versión 4**

> Se usa para amparar traslado de mercaderías. El `receptor` tiene un campo adicional: `bienTitulo`.

### `receptor` (destinatario de los bienes)

| Campo JSON | Descripción | Tipo | Req | Notas |
|---|---|---|---|---|
| `tipoDocumento` | Tipo doc identificación | `string` | **R** | |
| `numDocumento` | Número doc identificación | `string` | **R** | 1–20 |
| `nrc` | NRC | `string\|null` | **R** | |
| `nombre` | Nombre | `string` | **R** | 1–250 |
| `codActividad` | Código actividad | `string` | **R** | 5–6 |
| `descActividad` | Descripción actividad | `string` | **R** | 5–150 |
| `nombreComercial` | Nombre comercial | `string\|null` | **R** | |
| `direccion.departamento` | Departamento | `string` | **R** | |
| `direccion.municipio` | Municipio | `string` | **R** | |
| `direccion.distrito` | Distrito | `string` | **R** | |
| `direccion.complemento` | Complemento | `string` | **R** | 1–200 |
| `telefono` | Teléfono | `string\|null` | **R** | |
| `correo` | Email | `string\|null` | **R** | |
| **`bienTitulo`** | **Bienes remitidos a título de** | `string` | **R** | Catálogo MH. `"01"`=Propiedad · `"02"`=Consignación · etc. |

### `cuerpoDocumento` (bienes remitidos)

| Campo JSON | Descripción | Tipo | Req | Notas |
|---|---|---|---|---|
| `numItem` | Número de línea | `integer` | **R** | |
| `tipoItem` | Tipo de ítem | `integer` | **R** | |
| `numeroDocumento` | Doc relacionado | `string\|null` | **R** | |
| `codigo` | Código producto | `string\|null` | **R** | |
| `codTributo` | Tributo especial | `string\|null` | **R** | |
| `descripcion` | Descripción | `string` | **R** | 1–1500 |
| `cantidad` | Cantidad | `number` | **R** | |
| `uniMedida` | Unidad de medida | `integer` | **R** | |
| `precioUni` | Precio unitario | `number` | **R** | |
| `montoDescu` | Descuento | `number` | **R** | |
| `ventaNoSuj` | Venta no sujeta | `number` | **R** | |
| `ventaExenta` | Venta exenta | `number` | **R** | |
| `ventaGravada` | Venta gravada | `number` | **R** | |
| `tributos` | Tributos | `array\|null` | **R** | |

### `resumen` (totales NR)

| Campo JSON | Descripción | Tipo | Req |
|---|---|---|---|
| `totalNoSuj` | Total no sujetas | `number` | **R** |
| `totalExenta` | Total exentas | `number` | **R** |
| `totalGravada` | Total gravadas | `number` | **R** |
| `subTotalVentas` | Subtotal ventas | `number` | **R** |
| `descuNoSuj` | Descuento no sujetas | `number` | **R** |
| `descuExenta` | Descuento exentas | `number` | **R** |
| `descuGravada` | Descuento gravadas | `number` | **R** |
| `porcentajeDescuento` | % descuento | `number` | **R** |
| `totalDescu` | Total descuentos | `number` | **R** |
| `tributos` | Resumen tributos | `array\|null` | **R** |
| `subTotal` | Subtotal | `number` | **R** |
| `montoTotalOperacion` | Total operación | `number` | **R** |
| `totalLetras` | Total en letras | `string\|null` | **R** |
| `observaciones` | Observaciones | `string\|null` | **R** |

---

## 9. DTE 05 — Nota de Crédito (NC)

**`tipoDte: "05"` · Schema versión 4**

> IMPORTANTE: La NC **siempre requiere** `documentoRelacionado` apuntando al CCF original que corrige. El campo `fusion` en `identificacion` es requerido.

### `receptor` (igual que CCF pero con `tipoDocumento` y `numDocumento`)

| Campo JSON | Descripción | Tipo | Req | Notas |
|---|---|---|---|---|
| `tipoDocumento` | Tipo doc identificación | `string` | **R** | |
| `numDocumento` | Número doc identificación | `string` | **R** | |
| `nrc` | NRC | `string\|null` | **R** | |
| `nombre` | Nombre | `string` | **R** | |
| `codActividad` | Código actividad | `string` | **R** | |
| `descActividad` | Descripción actividad | `string` | **R** | |
| `nombreComercial` | Nombre comercial | `string\|null` | **R** | |
| `direccion.departamento` | Departamento | `string` | **R** | |
| `direccion.municipio` | Municipio | `string` | **R** | |
| `direccion.distrito` | Distrito | `string` | **R** | |
| `direccion.complemento` | Complemento | `string` | **R** | 1–200 |
| `telefono` | Teléfono | `string\|null` | **R** | |
| `correo` | Email | `string\|null` | **R** | |

### `cuerpoDocumento` (ítems a acreditar)

| Campo JSON | Descripción | Tipo | Req | Notas |
|---|---|---|---|---|
| `numItem` | Número de línea | `integer` | **R** | |
| `tipoItem` | Tipo de ítem | `integer` | **R** | |
| `numeroDocumento` | Doc relacionado (UUID del CCF) | `string` | **R** | **Obligatorio en NC** |
| `cantidad` | Cantidad a acreditar | `number` | **R** | |
| `codigo` | Código producto | `string\|null` | **R** | |
| `codTributo` | Tributo especial | `string\|null` | **R** | |
| `uniMedida` | Unidad de medida | `integer` | **R** | |
| `descripcion` | Descripción del ajuste | `string` | **R** | |
| `precioUni` | Precio unitario | `number` | **R** | |
| `montoDescu` | Descuento | `number` | **R** | |
| `ventaNoSuj` | No sujeta | `number` | **R** | |
| `ventaExenta` | Exenta | `number` | **R** | |
| `ventaGravada` | Gravada | `number` | **R** | |
| `tributos` | Tributos | `array\|null` | **R** | |
| `noGravado` | No imponible | `number` | **R** | |
| `ivaPerci` | IVA percibido | `number` | **R** | |
| `totalIva` | IVA 13% | `number` | **R** | |
| `ivaRete` | IVA retenido | `number` | **R** | |

### `resumen` (totales NC)

| Campo JSON | Descripción | Tipo | Req |
|---|---|---|---|
| `totalNoSuj` | Total no sujetas | `number` | **R** |
| `totalExenta` | Total exentas | `number` | **R** |
| `totalGravada` | Total gravadas | `number` | **R** |
| `subTotalVentas` | Subtotal | `number` | **R** |
| `totalDescu` | Total descuentos | `number` | **R** |
| `tributos` | Resumen tributos | `array\|null` | **R** |
| `montoTotalOperacion` | Total operación | `number` | **R** |
| `ivaPerci` | IVA percibido | `number` | **R** |
| `totalIva` | IVA 13% | `number` | **R** |
| `ivaRete` | IVA retenido | `number` | **R** |
| `totalNoGravado` | Total no imponibles | `number` | **R** |
| `totalPagar` | **Total a pagar/acreditar** | `number` | **R** |
| `totalLetras` | Total en letras | `string\|null` | **R** |
| `condicionOperacion` | Condición de pago | `number` | **R** |
| `observaciones` | Observaciones | `string\|null` | **R** |
| `codigoRetencionMH` | Código retención MH | `string\|null` | **R** |

---

## 10. DTE 06 — Nota de Débito (ND)

**`tipoDte: "06"` · Schema versión 4**

> IMPORTANTE: La ND **siempre requiere** `documentoRelacionado`. El `receptor`, `cuerpoDocumento` y `resumen` son idénticos a NC.

**`identificacion`** → Igual que NC con `fusion` (requerido).

**`receptor`** → Igual que NC.

**`cuerpoDocumento`** → Igual que NC (mismos campos):
`numItem`, `tipoItem`, `numeroDocumento`, `codigo`, `codTributo`, `descripcion`, `cantidad`, `uniMedida`, `precioUni`, `montoDescu`, `ventaNoSuj`, `ventaExenta`, `ventaGravada`, `tributos`, `noGravado`, `ivaPerci`, `totalIva`, `ivaRete`

**`resumen`** → Igual que NC pero agrega `numPagoElectronico`:
`totalNoSuj`, `totalExenta`, `totalGravada`, `subTotalVentas`, `totalDescu`, `tributos`, `ivaPerci`, `totalIva`, `ivaRete`, `montoTotalOperacion`, `totalNoGravado`, `totalPagar`, `totalLetras`, `condicionOperacion`, **`numPagoElectronico`**, `observaciones`, `codigoRetencionMH`

---

## 11. DTE 14 — Factura Sujeto Excluido (FSE)

**`tipoDte: "14"` · Schema versión 2**

> Para compras a **sujetos excluidos** (no inscritos en IVA). El emisor es el comprador.

### `receptor` (sujeto excluido)

| Campo JSON | Descripción | Tipo | Req | Notas |
|---|---|---|---|---|
| `tipoDocumento` | Tipo doc identificación | `string` | **R** | |
| `numDocumento` | Número de documento | `string` | **R** | 1–20 |
| `nombre` | Nombre del sujeto excluido | `string` | **R** | 1–250 |
| `codActividad` | Código actividad | `string\|null` | **R** | |
| `descActividad` | Descripción actividad | `string\|null` | **R** | |
| `direccion.departamento` | Departamento | `string` | **R** | |
| `direccion.municipio` | Municipio | `string` | **R** | |
| `direccion.distrito` | Distrito | `string` | **R** | |
| `direccion.complemento` | Dirección | `string` | **R** | 1–200 |
| `telefono` | Teléfono | `string\|null` | **R** | |
| `correo` | Email | `string\|null` | **R** | |

### `cuerpoDocumento` (compras al sujeto excluido)

| Campo JSON | Descripción | Tipo | Req | Notas |
|---|---|---|---|---|
| `numItem` | Número de línea | `integer` | **R** | |
| `tipoItem` | Tipo de ítem | `integer` | **R** | |
| `cantidad` | Cantidad | `number` | **R** | |
| `codigo` | Código | `string\|null` | **R** | |
| `uniMedida` | Unidad de medida | `integer` | **R** | |
| `descripcion` | Descripción | `string` | **R** | |
| `precioUni` | Precio unitario | `number` | **R** | |
| `montoDescu` | Descuento | `number` | **R** | |
| **`compra`** | **Monto de compra** | `number` | **R** | Campo único de FSE |

### `resumen` (totales FSE)

| Campo JSON | Descripción | Tipo | Req | Notas |
|---|---|---|---|---|
| `totalCompra` | Total de operaciones | `number` | **R** | Campo único de FSE |
| `descu` | Descuento global | `number` | **R** | |
| `totalDescu` | Total descuentos | `number` | **R** | |
| `subTotal` | Subtotal | `number` | **R** | |
| `reteRenta` | Retención de renta | `number` | **R** | |
| `totalPagar` | **Total a pagar** | `number` | **R** | |
| `totalLetras` | Total en letras | `string\|null` | **R** | |
| `condicionOperacion` | Condición de pago | `number` | **R** | |
| `pagos` | Formas de pago | `array\|null` | **R** | Igual estructura que FE |
| `observaciones` | Observaciones | `string\|null` | **R** | |

---

## 12. Tabla de Catálogos y Valores Permitidos

### `ambiente`
| Código | Descripción |
|--------|-------------|
| `"00"` | Pruebas (Homologación) |
| `"01"` | Producción |

### `tipoDte`
| Código | Documento |
|--------|-----------|
| `"01"` | Factura Electrónica |
| `"03"` | Comprobante de Crédito Fiscal |
| `"04"` | Nota de Remisión |
| `"05"` | Nota de Crédito |
| `"06"` | Nota de Débito |
| `"11"` | Factura de Exportación |
| `"14"` | Factura Sujeto Excluido |

### `tipoModelo`
| Valor | Descripción |
|-------|-------------|
| `1` | Transmisión Normal (Previo) |
| `2` | Transmisión Diferida |

### `tipoOperacion`
| Valor | Descripción |
|-------|-------------|
| `1` | Transmisión Normal |
| `2` | Transmisión por Contingencia |

### `tipoContingencia`
| Valor | Descripción |
|-------|-------------|
| `null` | Sin contingencia |
| `1` | No disponibilidad del sistema MH |
| `2` | Falla en conexión a internet del emisor |
| `3` | Falla en el servicio del proveedor |
| `4` | Caso fortuito o fuerza mayor |
| `5` | Otros |

### `tipoDocumento` (Receptor — tipo de ID)
| Código | Descripción |
|--------|-------------|
| `"13"` | DUI |
| `"36"` | NIT |
| `"02"` | Carnet de residente |
| `"03"` | Pasaporte |
| `"37"` | Otro documento |

### `tipoItem`
| Valor | Descripción |
|-------|-------------|
| `1` | Bienes |
| `2` | Servicios |
| `3` | Ambos (bienes y servicios) |
| `4` | Uso o consumo propio |

### `condicionOperacion`
| Valor | Descripción |
|-------|-------------|
| `1` | Contado |
| `2` | Crédito |
| `3` | Otro |

### `pagos[].codigo` (Formas de pago)
| Código | Descripción |
|--------|-------------|
| `"01"` | Billetes y monedas (Efectivo) |
| `"02"` | Tarjeta Débito |
| `"03"` | Tarjeta Crédito |
| `"04"` | Cheque |
| `"05"` | Transferencia/depósito bancario |
| `"06"` | Vale de canasta |
| `"07"` | Dinero electrónico |
| `"08"` | Giro bancario |
| `"09"` | Compensación |
| `"99"` | Otro |

### `pagos[].plazo`
| Valor | Descripción |
|-------|-------------|
| `"01"` | Días |
| `"02"` | Meses |
| `"03"` | Años |

### `uniMedida` (Unidades de medida — más comunes)
| Código | Descripción |
|--------|-------------|
| `12` | Docena |
| `13` | Gruesa |
| `20` | Libra |
| `24` | Galón |
| `32` | Milímetro |
| `33` | Centímetro |
| `34` | Metro |
| `36` | Pulgada |
| `46` | Litro |
| `51` | Kilogramo |
| `55` | Gramo |
| `59` | Unidad |
| `99` | Otro |

### `bienTitulo` (Nota de Remisión)
| Código | Descripción |
|--------|-------------|
| `"01"` | Propiedad |
| `"02"` | Consignación |
| `"03"` | Demostración |
| `"04"` | Préstamo |
| `"05"` | Traslado interno |

### `direccion.departamento`
| Código | Departamento |
|--------|-------------|
| `"01"` | Ahuachapán |
| `"02"` | Santa Ana |
| `"03"` | Sonsonate |
| `"04"` | Chalatenango |
| `"05"` | La Libertad |
| `"06"` | San Salvador |
| `"07"` | Cuscatlán |
| `"08"` | La Paz |
| `"09"` | Cabañas |
| `"10"` | San Vicente |
| `"11"` | Usulután |
| `"12"` | San Miguel |
| `"13"` | Morazán |
| `"14"` | La Unión |

---

## 13. Campos Adicionales del POS (No-JSON)

> Estos son campos que el POS debe **almacenar internamente** o **gestionar** para construir correctamente los JSON, pero no van directamente en el cuerpo del DTE.

### Configuración del Emisor (una sola vez)
| Campo en POS | Descripción | Mapea a JSON |
|---|---|---|
| `emisor_nit` | NIT del negocio | `emisor.nit` |
| `emisor_nrc` | NRC del negocio | `emisor.nrc` |
| `emisor_nombre` | Razón social | `emisor.nombre` |
| `emisor_nombre_comercial` | Nombre del negocio | `emisor.nombreComercial` |
| `emisor_cod_actividad` | Código actividad MH | `emisor.codActividad` |
| `emisor_desc_actividad` | Descripción actividad | `emisor.descActividad` |
| `emisor_departamento` | Código depto MH | `emisor.direccion.departamento` |
| `emisor_municipio` | Código municipio MH | `emisor.direccion.municipio` |
| `emisor_distrito` | Código distrito MH | `emisor.direccion.distrito` |
| `emisor_direccion_complemento` | Dirección física | `emisor.direccion.complemento` |
| `emisor_telefono` | Teléfono | `emisor.telefono` |
| `emisor_correo` | Email del negocio | `emisor.correo` |
| `emisor_cod_estable` | Código establecimiento (4 dígitos) | `emisor.codEstable` |
| `emisor_cod_punto_venta` | Código de esta caja/terminal | `emisor.codPuntoVenta` |
| `ambiente` | `"00"` pruebas o `"01"` producción | `identificacion.ambiente` |

### Registro de Clientes (Receptores)
| Campo en POS | Descripción | Mapea a JSON |
|---|---|---|
| `cliente_tipo_doc` | Tipo de documento ID | `receptor.tipoDocumento` |
| `cliente_num_doc` | Número de documento | `receptor.numDocumento` |
| `cliente_nit` | NIT (solo para CCF/NC/ND) | `receptor.nit` |
| `cliente_nrc` | NRC (solo para CCF) | `receptor.nrc` |
| `cliente_nombre` | Nombre o razón social | `receptor.nombre` |
| `cliente_nombre_comercial` | Nombre comercial | `receptor.nombreComercial` |
| `cliente_cod_actividad` | Código actividad MH | `receptor.codActividad` |
| `cliente_desc_actividad` | Descripción actividad | `receptor.descActividad` |
| `cliente_departamento` | Código depto MH | `receptor.direccion.departamento` |
| `cliente_municipio` | Código municipio MH | `receptor.direccion.municipio` |
| `cliente_distrito` | Código distrito MH | `receptor.direccion.distrito` |
| `cliente_complemento` | Dirección física | `receptor.direccion.complemento` |
| `cliente_telefono` | Teléfono | `receptor.telefono` |
| `cliente_correo` | Email | `receptor.correo` |
| `cliente_tipo_contribuyente` | `CF`=Consumidor Final · `CCF`=Empresa | Define si emitir FE o CCF |

### Registro de Productos (Catálogo)
| Campo en POS | Descripción | Mapea a JSON |
|---|---|---|
| `producto_codigo` | Código SKU interno | `cuerpoDocumento[].codigo` |
| `producto_descripcion` | Nombre/descripción | `cuerpoDocumento[].descripcion` |
| `producto_precio` | Precio de venta | `cuerpoDocumento[].precioUni` |
| `producto_tipo_item` | `1`=Bien · `2`=Servicio | `cuerpoDocumento[].tipoItem` |
| `producto_uni_medida` | Código unidad MH | `cuerpoDocumento[].uniMedida` |
| `producto_cod_tributo` | Tributo especial | `cuerpoDocumento[].codTributo` |
| `producto_exento` | Si está exento de IVA | Determina `ventaExenta` vs `ventaGravada` |
| `producto_no_sujeto` | Si es no sujeto | Determina `ventaNoSuj` |

### Por cada Venta/Transacción
| Campo en POS | Descripción | Mapea a JSON |
|---|---|---|
| `venta_fecha` | Fecha de la venta | `identificacion.fecEmi` |
| `venta_hora` | Hora de la venta | `identificacion.horEmi` |
| `venta_tipo_dte` | Tipo de DTE a emitir | `identificacion.tipoDte` |
| `venta_condicion_pago` | `1`=Contado · `2`=Crédito | `resumen.condicionOperacion` |
| `venta_forma_pago` | Código forma de pago | `resumen.pagos[].codigo` |
| `venta_monto_pago` | Monto pagado | `resumen.pagos[].montoPago` |
| `venta_referencia_pago` | Número de tarjeta/cheque | `resumen.pagos[].referencia` |
| `venta_observaciones` | Notas de la venta | `resumen.observaciones` |
| `venta_doc_relacionado` | UUID del DTE que se anula/corrige | `documentoRelacionado[].numeroDocumento` |

---

## FLUJO RECOMENDADO EN EL POS

1. El cajero selecciona cliente → el POS autocompleta todos los campos del receptor.
2. El cajero agrega productos → el POS calcula `ventaGravada`, `ventaExenta`, `ivaItem` automaticamente.
3. El cajero selecciona forma de pago → el POS llena el array `pagos[]`.
4. El POS construye el JSON completo y lo envía al endpoint de la API.
5. La API firma, sella y transmite al MH. Devuelve el sello de recepción.
