// Funciones de Impresión y Descargas Web para Coreas ERP

// 1. Impresión de Ticket Térmico con iframe aislado
window.coreasPrintReceipt = function (elementId) {
    var printContents = document.getElementById(elementId);
    if (!printContents) {
        console.error("Elemento no encontrado para imprimir:", elementId);
        return;
    }

    var oldIframe = document.getElementById('coreas-print-frame');
    if (oldIframe && oldIframe.parentNode) {
        oldIframe.parentNode.removeChild(oldIframe);
    }

    var iframe = document.createElement('iframe');
    iframe.id = 'coreas-print-frame';
    iframe.style.position = 'fixed';
    iframe.style.left = '0';
    iframe.style.top = '0';
    iframe.style.width = '100vw';
    iframe.style.height = '100vh';
    iframe.style.border = 'none';
    iframe.style.opacity = '0';
    iframe.style.pointerEvents = 'none';
    iframe.style.zIndex = '-9999';
    document.body.appendChild(iframe);

    var doc = iframe.contentWindow.document;
    doc.open();
    doc.write('<!DOCTYPE html><html><head><title>Ticket - Coreas ERP</title>');
    doc.write('<style>');
    doc.write(`
        @page { margin: 0 !important; size: auto; }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        html, body { 
            font-family: 'Courier New', Courier, monospace; 
            font-size: 11px; 
            margin: 0 !important; 
            padding: 2mm 2mm 30mm 2mm !important; 
            color: #000; 
            background: #fff; 
            width: 100% !important; 
            max-width: 72mm !important;
            -webkit-print-color-adjust: exact !important; 
            print-color-adjust: exact !important; 
        }
        #thermal-receipt {
            width: 100% !important; 
            max-width: 100% !important; 
            margin: 0 auto !important; 
            padding: 0 0 25mm 0 !important; 
            border: none !important; 
            box-shadow: none !important; 
            background: transparent !important; 
        }
        .ticket-header { text-align: center; margin-bottom: 6px; border-bottom: 1px dashed #000; padding-bottom: 4px; }
        .ticket-title { font-size: 13px; font-weight: bold; margin-bottom: 2px; }
        .ticket-info { font-size: 10.5px; margin-bottom: 4px; line-height: 1.3; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 6px; font-size: 10.5px; table-layout: fixed; }
        th { border-bottom: 1px dashed #000; text-align: left; padding: 2px 0; font-size: 10px; }
        td { padding: 2px 0; vertical-align: top; word-break: break-word; }
        .text-right { text-align: right; }
        .text-center { text-align: center; }
        .ticket-totals { border-top: 1px dashed #000; padding-top: 4px; font-size: 11px; margin-bottom: 6px; }
        .total-row { font-size: 13px; font-weight: bold; border-top: 1px solid #000; padding-top: 3px; }
        .ticket-footer { text-align: center; font-size: 10.5px; border-top: 1px dashed #000; padding-top: 4px; line-height: 1.3; margin-bottom: 25mm; }
        img { max-width: 100% !important; height: auto !important; display: block; margin: 0 auto; }
    `);
    doc.write('</style></head><body>');
    doc.write(printContents.innerHTML);
    doc.write('</body></html>');
    doc.close();

    setTimeout(function () {
        try {
            iframe.contentWindow.focus();
            iframe.contentWindow.print();
        } catch (e) {
            console.error("Error al imprimir ticket:", e);
        } finally {
            setTimeout(function () {
                if (iframe && iframe.parentNode) iframe.parentNode.removeChild(iframe);
            }, 2000);
        }
    }, 250);
};

// 1.1 Impresión de Facturas, Créditos Fiscales y Documentos Tributarios en Tamaño Carta (Letter / PDF)
window.coreasPrintInvoiceLetter = function (elementId) {
    var printContents = document.getElementById(elementId);
    if (!printContents) {
        console.error("Elemento carta no encontrado:", elementId);
        return;
    }

    var oldIframe = document.getElementById('coreas-print-letter-frame');
    if (oldIframe && oldIframe.parentNode) {
        oldIframe.parentNode.removeChild(oldIframe);
    }

    var iframe = document.createElement('iframe');
    iframe.id = 'coreas-print-letter-frame';
    iframe.style.position = 'fixed';
    iframe.style.left = '0';
    iframe.style.top = '0';
    iframe.style.width = '100vw';
    iframe.style.height = '100vh';
    iframe.style.border = 'none';
    iframe.style.opacity = '0';
    iframe.style.pointerEvents = 'none';
    iframe.style.zIndex = '-9999';
    document.body.appendChild(iframe);

    var doc = iframe.contentWindow.document;
    doc.open();
    doc.write('<!DOCTYPE html><html><head><title>Documento Fiscal - Coreas ERP</title>');
    doc.write('<link rel="stylesheet" href="css/bootstrap/bootstrap.min.css" />');
    doc.write('<style>');
    doc.write(`
        @page { size: letter portrait; margin: 10mm 12mm; }
        * { box-sizing: border-box; }
        html, body {
            font-family: 'Segoe UI', -apple-system, BlinkMacSystemFont, Roboto, Helvetica, Arial, sans-serif;
            font-size: 11px;
            color: #0f172a;
            background: #fff;
            margin: 0;
            padding: 0;
            -webkit-print-color-adjust: exact !important;
            print-color-adjust: exact !important;
        }
        .invoice-letter-container {
            width: 100% !important;
            max-width: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
            box-shadow: none !important;
            border: none !important;
        }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 4px 6px; }
        img { max-width: 100%; height: auto; }
    `);
    doc.write('</style></head><body>');
    doc.write(printContents.innerHTML);
    doc.write('</body></html>');
    doc.close();

    setTimeout(function () {
        try {
            iframe.contentWindow.focus();
            iframe.contentWindow.print();
        } catch (e) {
            console.error("Error al imprimir documento carta:", e);
        } finally {
            setTimeout(function () {
                if (iframe && iframe.parentNode) iframe.parentNode.removeChild(iframe);
            }, 2500);
        }
    }, 300);
};

// 1.2 Impresión de Cortes X y Z en rollo térmico (iframe aislado)
window.coreasPrintCorte = function (elementId) {
    var printContents = document.getElementById(elementId);
    if (!printContents) {
        console.error("Elemento corte no encontrado:", elementId);
        return;
    }

    var oldIframe = document.getElementById('coreas-print-corte-frame');
    if (oldIframe && oldIframe.parentNode) {
        oldIframe.parentNode.removeChild(oldIframe);
    }

    var iframe = document.createElement('iframe');
    iframe.id = 'coreas-print-corte-frame';
    iframe.style.position = 'fixed';
    iframe.style.left = '0';
    iframe.style.top = '0';
    iframe.style.width = '100vw';
    iframe.style.height = '100vh';
    iframe.style.border = 'none';
    iframe.style.opacity = '0';
    iframe.style.pointerEvents = 'none';
    iframe.style.zIndex = '-9999';
    document.body.appendChild(iframe);

    var doc = iframe.contentWindow.document;
    doc.open();
    doc.write('<!DOCTYPE html><html><head><title>Corte de Caja - Coreas ERP</title>');
    doc.write(`
        <style>
        @page { margin: 0 !important; size: auto; }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        html, body {
            font-family: 'Courier New', Courier, monospace;
            font-size: 11px;
            margin: 0 !important;
            padding: 3mm 4mm !important;
            color: #000;
            background: #fff;
            width: 76mm !important;
            max-width: 76mm !important;
            -webkit-print-color-adjust: exact !important;
            print-color-adjust: exact !important;
        }
        .corte-container {
            width: 100% !important;
            max-width: 72mm !important;
            margin: 0 auto !important;
            padding: 0 !important;
            border: none !important;
        }
        table { width: 100%; border-collapse: collapse; margin-bottom: 6px; font-size: 10.5px; }
        th, td { padding: 2px 0; vertical-align: top; }
        .text-right { text-align: right; }
        .text-center { text-align: center; }
        .fw-bold { font-weight: bold; }
        .border-dashed { border-top: 1px dashed #000; margin: 5px 0; }
        .border-double { border-top: 2px solid #000; margin: 6px 0; }
        </style>
    `);
    doc.write('</head><body>');
    doc.write(printContents.innerHTML);
    doc.write('</body></html>');
    doc.close();

    setTimeout(function () {
        try {
            iframe.contentWindow.focus();
            iframe.contentWindow.print();
        } catch (e) {
            console.error("Error al imprimir corte:", e);
        } finally {
            setTimeout(function () {
                if (iframe && iframe.parentNode) iframe.parentNode.removeChild(iframe);
            }, 2500);
        }
    }, 250);
};

// 2. Impresión de Etiquetas de Precios y Banderines con iframe aislado
window.coreasPrintPriceTags = function (elementId, orientation) {
    var printContents = document.getElementById(elementId);
    if (!printContents) {
        console.error("Contenido imprimible no encontrado:", elementId);
        return;
    }

    var oldIframe = document.getElementById('coreas-print-frame');
    if (oldIframe && oldIframe.parentNode) {
        oldIframe.parentNode.removeChild(oldIframe);
    }

    var iframe = document.createElement('iframe');
    iframe.id = 'coreas-print-frame';
    iframe.style.position = 'fixed';
    iframe.style.left = '0';
    iframe.style.top = '0';
    iframe.style.width = '100vw';
    iframe.style.height = '100vh';
    iframe.style.border = 'none';
    iframe.style.opacity = '0';
    iframe.style.pointerEvents = 'none';
    iframe.style.zIndex = '-9999';
    document.body.appendChild(iframe);

    var isLandscape = (orientation === 'landscape');
    var doc = iframe.contentWindow.document;
    doc.open();
    doc.write('<!DOCTYPE html><html><head><title>Imprimir Etiquetas - Coreas ERP</title>');
    doc.write('<base href="' + document.baseURI + '" />');
    doc.write('<link rel="stylesheet" href="css/bootstrap/bootstrap.min.css" />');
    doc.write('<style>');
    doc.write(`
        @page { 
            size: letter ` + (isLandscape ? 'landscape' : 'portrait') + `; 
            margin: ` + (isLandscape ? '4mm' : '6mm') + `; 
        }
        * { box-sizing: border-box; }
        html, body { 
            margin: 0; 
            padding: 0; 
            background: #fff; 
            color: #000; 
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif; 
            -webkit-print-color-adjust: exact !important; 
            print-color-adjust: exact !important; 
        }
        .no-print { display: none !important; }
        .d-flex { display: flex !important; }
        .flex-column { flex-direction: column !important; }
        .flex-grow-1 { flex-grow: 1 !important; }
        .justify-content-between { justify-content: space-between !important; }
        .justify-content-around { justify-content: space-around !important; }
        .justify-content-center { justify-content: center !important; }
        .align-items-center { align-items: center !important; }
        .align-items-end { align-items: flex-end !important; }
        .text-center { text-align: center !important; }
        .text-end { text-align: right !important; }
        .text-truncate { overflow: hidden !important; text-overflow: ellipsis !important; white-space: nowrap !important; }
        .font-monospace { font-family: SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace !important; }
        .text-uppercase { text-transform: uppercase !important; }
        .text-decoration-line-through { text-decoration: line-through !important; }
        .fw-bold { font-weight: 700 !important; }
        .fw-bolder { font-weight: 800 !important; }
        .fw-black { font-weight: 900 !important; }
        .text-muted { color: #64748b !important; }
        .text-danger { color: #dc2626 !important; }
        .text-dark { color: #0f172a !important; }
        .text-white { color: #ffffff !important; }
        .bg-danger { background-color: #dc2626 !important; }
        .bg-warning { background-color: #fbbf24 !important; }
        .bg-success { background-color: #16a34a !important; }
        .bg-light { background-color: #f8fafc !important; }
        .border { border: 1px solid #cbd5e1 !important; }
        .border-top { border-top: 1px solid #cbd5e1 !important; }
        .border-bottom { border-bottom: 1px solid #cbd5e1 !important; }
        .rounded { border-radius: 6px !important; }
        .rounded-3 { border-radius: 8px !important; }
        .badge { display: inline-block; padding: 3px 6px; font-size: 11px; font-weight: 700; text-align: center; border-radius: 4px; }
        .w-100 { width: 100% !important; }
        .p-1 { padding: 4px !important; }
        .p-2 { padding: 8px !important; }
        .my-1 { margin-top: 4px !important; margin-bottom: 4px !important; }
        .my-2 { margin-top: 8px !important; margin-bottom: 8px !important; }
        .mt-1 { margin-top: 4px !important; }
        .pt-1 { padding-top: 4px !important; }
        .pb-1 { padding-bottom: 4px !important; }
        .mb-1 { margin-bottom: 4px !important; }
        .fs-4 { font-size: 1.5rem !important; }
        .fs-5 { font-size: 1.25rem !important; }

        .print-page {
            page-break-after: always !important;
            break-after: page !important;
            box-sizing: border-box;
            background: #fff !important;
            padding: 0 !important;
            margin: 0 !important;
            border: none !important;
            box-shadow: none !important;
            max-width: none !important;
            overflow: hidden !important;
        }
        .print-page:last-child {
            page-break-after: auto !important;
            break-after: auto !important;
        }
        .walmart-grid {
            width: 270mm;
            height: 204mm;
            display: grid !important;
            grid-template-columns: repeat(3, 1fr) !important;
            grid-template-rows: repeat(2, 1fr) !important;
            gap: 3mm !important;
            box-sizing: border-box !important;
        }
        .walmart-banner-card {
            border: 2px dashed #b91c1c !important;
            border-radius: 8px !important;
            overflow: hidden !important;
            display: flex !important;
            flex-direction: column !important;
            justify-content: space-between !important;
            background: #ffffff !important;
            box-shadow: none !important;
            box-sizing: border-box !important;
            height: 100mm !important;
            max-height: 100mm !important;
            page-break-inside: avoid !important;
            break-inside: avoid !important;
        }
        .shelf-grid {
            width: 200mm;
            display: grid !important;
            grid-template-columns: repeat(3, 1fr) !important;
            gap: 4mm !important;
            box-sizing: border-box !important;
        }
        .shelf-card {
            border: 1px dashed #475569 !important;
            border-radius: 6px !important;
            padding: 6px 8px !important;
            height: 38mm !important;
            max-height: 38mm !important;
            display: flex !important;
            flex-direction: column !important;
            justify-content: space-between !important;
            background: #ffffff !important;
            font-size: 11px !important;
            box-shadow: none !important;
            box-sizing: border-box !important;
            page-break-inside: avoid !important;
            break-inside: avoid !important;
        }
    `);
    doc.write('</style></head><body>');
    doc.write(printContents.innerHTML);
    doc.write('</body></html>');
    doc.close();

    setTimeout(function () {
        try {
            iframe.contentWindow.focus();
            iframe.contentWindow.print();
        } catch (e) {
            console.error("Error al imprimir etiquetas:", e);
        } finally {
            setTimeout(function () {
                if (iframe && iframe.parentNode) iframe.parentNode.removeChild(iframe);
            }, 2000);
        }
    }, 300);
};

// 3. Descarga de archivos Base64 en el navegador
window.downloadFileFromBase64 = function (fileName, base64Data, contentType) {
    try {
        const byteCharacters = atob(base64Data);
        const byteNumbers = new Array(byteCharacters.length);
        for (let i = 0; i < byteCharacters.length; i++) {
            byteNumbers[i] = byteCharacters.charCodeAt(i);
        }
        const byteArray = new Uint8Array(byteNumbers);
        const blob = new Blob([byteArray], { type: contentType || 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
        const blobUrl = URL.createObjectURL(blob);
        const anchorElement = document.createElement('a');
        anchorElement.href = blobUrl;
        anchorElement.download = fileName;
        anchorElement.click();
        anchorElement.remove();
        setTimeout(() => URL.revokeObjectURL(blobUrl), 1000);
        return true;
    } catch (err) {
        console.error("Error al descargar archivo en navegador:", err);
        return false;
    }
};
