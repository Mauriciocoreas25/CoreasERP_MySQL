typedef SavedGpsAddress = SavedAddressModel;

String? _resolveImageUrl(dynamic raw) {
  if (raw == null) return null;
  final s = raw.toString().trim();
  if (s.isEmpty) return null;
  if (s.startsWith('http://') || s.startsWith('https://')) {
    return s;
  }
  final clean = s.replaceAll('\\', '/').replaceFirst(RegExp(r'^/+'), '');
  return 'http://coreaserp.runasp.net/$clean';
}

class CategoriaModel {
  final int idCategoria;
  final String nombre;
  final String? descripcion;
  final String icono;
  final String? imagenUrl;
  final bool estado;
  final int totalProductos;

  CategoriaModel({
    required this.idCategoria,
    required this.nombre,
    this.descripcion,
    required this.icono,
    this.imagenUrl,
    required this.estado,
    required this.totalProductos,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      idCategoria: json['idCategoria'] ?? 0,
      nombre: json['nombre'] ?? 'General',
      descripcion: json['descripcion'],
      icono: json['icono'] ?? 'fa-box',
      imagenUrl: _resolveImageUrl(json['imagenUrl']),
      estado: json['estado'] ?? true,
      totalProductos: json['totalProductos'] ?? 0,
    );
  }
}

class ProductoModel {
  final int idProducto;
  final int idCategoria;
  final String codigo;
  final String nombre;
  final String? descripcion;
  final double precioCompra;
  final double precioVenta;
  final double? precioGranel;
  final double? cantidadPorEmpaque;
  final double stock;
  final double stockMinimo;
  final bool esGranel;
  final String unidadMedida;
  final String? imagenUrl;
  final bool estado;
  final String? categoriaNombre;

  ProductoModel({
    required this.idProducto,
    required this.idCategoria,
    required this.codigo,
    required this.nombre,
    this.descripcion,
    required this.precioCompra,
    required this.precioVenta,
    this.precioGranel,
    this.cantidadPorEmpaque,
    required this.stock,
    required this.stockMinimo,
    required this.esGranel,
    required this.unidadMedida,
    this.imagenUrl,
    required this.estado,
    this.categoriaNombre,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    final cat = json['categoria'] as Map<String, dynamic>?;
    return ProductoModel(
      idProducto: json['idProducto'] ?? 0,
      idCategoria: json['idCategoria'] ?? 1,
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      precioCompra: (json['precioCompra'] as num?)?.toDouble() ?? 0.0,
      precioVenta: (json['precioVenta'] as num?)?.toDouble() ?? 0.0,
      precioGranel: (json['precioGranel'] as num?)?.toDouble(),
      cantidadPorEmpaque: (json['cantidadPorEmpaque'] as num?)?.toDouble() ?? 1.0,
      stock: (json['stock'] as num?)?.toDouble() ?? 0.0,
      stockMinimo: (json['stockMinimo'] as num?)?.toDouble() ?? 5.0,
      esGranel: json['esGranel'] ?? false,
      unidadMedida: json['unidadMedida'] ?? 'Unidad',
      imagenUrl: _resolveImageUrl(json['imagenUrl'] ?? json['imagen']),
      estado: json['estado'] ?? true,
      categoriaNombre: cat != null ? cat['nombre']?.toString() : null,
    );
  }
}

class PromocionModel {
  final int idPromocion;
  final String nombre;
  final String? descripcion;
  final String tipoDescuento;
  final double valor;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool estado;
  final int? idProducto;

  PromocionModel({
    required this.idPromocion,
    required this.nombre,
    this.descripcion,
    required this.tipoDescuento,
    required this.valor,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    this.idProducto,
  });

  factory PromocionModel.fromJson(Map<String, dynamic> json) {
    return PromocionModel(
      idPromocion: json['idPromocion'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'],
      tipoDescuento: json['tipoDescuento'] ?? 'Porcentaje',
      valor: (json['valor'] as num?)?.toDouble() ?? 0.0,
      fechaInicio: DateTime.tryParse(json['fechaInicio']?.toString() ?? '') ?? DateTime.now(),
      fechaFin: DateTime.tryParse(json['fechaFin']?.toString() ?? '') ??
          DateTime.now().add(const Duration(days: 30)),
      estado: json['estado'] ?? true,
      idProducto: json['idProducto'],
    );
  }
}

class CartItemModel {
  final ProductoModel producto;
  double cantidad;
  bool modoGranel;
  double descuentoUnitario;

  CartItemModel({
    required this.producto,
    this.cantidad = 1.0,
    this.modoGranel = false,
    this.descuentoUnitario = 0.0,
  });

  bool get esGranel => modoGranel;
  String get unidadLabel => producto.unidadMedida;

  double get precioUnitario =>
      (modoGranel && producto.esGranel && (producto.precioGranel ?? 0) > 0)
          ? producto.precioGranel!
          : producto.precioVenta;

  double get descuentoTotal => descuentoUnitario * cantidad;

  double get subtotal => (precioUnitario * cantidad) - descuentoTotal;

  Map<String, dynamic> toApiCartItemDto() {
    return {
      'idProducto': producto.idProducto,
      'codigo': producto.codigo,
      'nombre': producto.nombre,
      'precio': precioUnitario,
      'cantidad': cantidad,
      'descuento': descuentoTotal,
      'stockDisponible': producto.stock,
      'esGranel': modoGranel,
      'cantidadPorEmpaque': producto.cantidadPorEmpaque ?? 1.0,
      'unidadMedida': modoGranel ? producto.unidadMedida : 'Unidad',
      'costoUnitario': producto.precioCompra,
    };
  }
}

class SavedAddressModel {
  final String etiqueta;
  final String referencia;
  final double latitud;
  final double longitud;
  final bool esPrincipal;

  SavedAddressModel({
    required this.etiqueta,
    required this.referencia,
    required this.latitud,
    required this.longitud,
    this.esPrincipal = false,
  });

  double get lat => latitud;
  double get lng => longitud;

  String get googleMapsUrl =>
      'https://www.google.com/maps/search/?api=1&query=${latitud.toStringAsFixed(6)},${longitud.toStringAsFixed(6)}';

  String toCompactDbString() {
    final latStr = latitud.toStringAsFixed(5);
    final lngStr = longitud.toStringAsFixed(5);
    final refClean = referencia.length > 160 ? referencia.substring(0, 160) : referencia;
    return '[$etiqueta|$latStr,$lngStr] $refClean';
  }

  factory SavedAddressModel.fromCompactDbString(String raw) {
    final trimmed = raw.trim();
    if (trimmed.startsWith('[') && trimmed.contains(']')) {
      final closeIdx = trimmed.indexOf(']');
      final inside = trimmed.substring(1, closeIdx);
      final ref = trimmed.substring(closeIdx + 1).trim();
      final parts = inside.split('|');
      final tag = parts.isNotEmpty && parts[0].isNotEmpty ? parts[0] : 'Casa';
      double parsedLat = 13.69294;
      double parsedLng = -89.21819;
      if (parts.length > 1) {
        final coords = parts[1].split(',');
        if (coords.length == 2) {
          parsedLat = double.tryParse(coords[0]) ?? parsedLat;
          parsedLng = double.tryParse(coords[1]) ?? parsedLng;
        }
      }
      return SavedAddressModel(
        etiqueta: tag,
        referencia: ref,
        latitud: parsedLat,
        longitud: parsedLng,
        esPrincipal: true,
      );
    }
    return SavedAddressModel(
      etiqueta: 'Casa',
      referencia: trimmed,
      latitud: 13.69294,
      longitud: -89.21819,
      esPrincipal: true,
    );
  }

  String get coordsShort => '${latitud.toStringAsFixed(5)}, ${longitud.toStringAsFixed(5)}';

  Map<String, dynamic> toJson() => {
        'etiqueta': etiqueta,
        'referencia': referencia,
        'latitud': latitud,
        'longitud': longitud,
        'esPrincipal': esPrincipal,
      };

  factory SavedAddressModel.fromJson(Map<String, dynamic> json) {
    return SavedAddressModel(
      etiqueta: json['etiqueta'] ?? 'Casa',
      referencia: json['referencia'] ?? '',
      latitud: (json['latitud'] as num?)?.toDouble() ?? 13.69294,
      longitud: (json['longitud'] as num?)?.toDouble() ?? -89.21819,
      esPrincipal: json['esPrincipal'] ?? false,
    );
  }
}

class CustomerProfileModel {
  int idCliente;
  String tipoPersona;
  String nombre;
  String tipoDocumento;
  String numDocumento;
  String telefono;
  String email;
  String? nrc;
  String? giro;

  CustomerProfileModel({
    this.idCliente = 0,
    this.tipoPersona = 'Natural',
    this.nombre = '',
    this.tipoDocumento = 'DUI',
    this.numDocumento = '',
    this.telefono = '',
    this.email = '',
    this.nrc,
    this.giro,
  });

  Map<String, dynamic> toJson(String compactAddress) => {
        'idCliente': idCliente,
        'tipoPersona': tipoPersona,
        'nombre': nombre,
        'tipoDocumento': tipoDocumento,
        'numDocumento': numDocumento,
        'telefono': telefono,
        'email': email,
        'direccion': compactAddress,
        'nrc': nrc,
        'giro': giro,
      };

  factory CustomerProfileModel.fromJson(Map<String, dynamic> json) {
    return CustomerProfileModel(
      idCliente: json['idCliente'] ?? 0,
      tipoPersona: json['tipoPersona'] ?? 'Natural',
      nombre: json['nombre'] ?? '',
      tipoDocumento: json['tipoDocumento'] ?? 'DUI',
      numDocumento: json['numDocumento'] ?? '',
      telefono: json['telefono'] ?? '',
      email: json['email'] ?? '',
      nrc: json['nrc'],
      giro: json['giro'],
    );
  }
}

class BannerConfigModel {
  String titulo;
  String subtitulo;
  String textoBoton;
  String etiquetaDescuento;
  String imagenUrl;
  bool usarTonoRosa;

  BannerConfigModel({
    this.titulo = 'Ofertas Especiales para Ti',
    this.subtitulo = 'Realiza tu pedido desde tu celular con entrega a domicilio o retiro en tienda',
    this.textoBoton = 'Ver Productos',
    this.etiquetaDescuento = 'PROMOCIÓN',
    this.imagenUrl = '',
    this.usarTonoRosa = false,
  });

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'subtitulo': subtitulo,
        'textoBoton': textoBoton,
        'etiquetaDescuento': etiquetaDescuento,
        'imagenUrl': imagenUrl,
        'usarTonoRosa': usarTonoRosa,
      };

  factory BannerConfigModel.fromJson(Map<String, dynamic> json) => BannerConfigModel(
        titulo: json['titulo'] ?? 'Ofertas Especiales para Ti',
        subtitulo: json['subtitulo'] ??
            'Realiza tu pedido desde tu celular con entrega a domicilio o retiro en tienda',
        textoBoton: json['textoBoton'] ?? 'Ver Productos',
        etiquetaDescuento: json['etiquetaDescuento'] ?? 'PROMOCIÓN',
        imagenUrl: json['imagenUrl'] ?? '',
        usarTonoRosa: json['usarTonoRosa'] ?? false,
      );
}

class DetalleVentaItemModel {
  final int idProducto;
  final String codigo;
  final String nombre;
  final String unidadMedida;
  final double cantidad;
  final double precioUnitario;
  final double descuento;
  final double subtotal;

  DetalleVentaItemModel({
    required this.idProducto,
    required this.codigo,
    required this.nombre,
    required this.unidadMedida,
    required this.cantidad,
    required this.precioUnitario,
    required this.descuento,
    required this.subtotal,
  });

  Map<String, dynamic> toJson() => {
        'idProducto': idProducto,
        'codigo': codigo,
        'nombre': nombre,
        'unidadMedida': unidadMedida,
        'cantidad': cantidad,
        'precio': precioUnitario,
        'descuento': descuento,
        'subtotal': subtotal,
      };

  factory DetalleVentaItemModel.fromJson(Map<String, dynamic> json) {
    final prod = json['producto'] as Map<String, dynamic>?;
    final cant = (json['cantidad'] as num?)?.toDouble() ?? 1.0;
    final prec = (json['precio'] as num?)?.toDouble() ?? 0.0;
    final desc = (json['descuento'] as num?)?.toDouble() ?? 0.0;
    final sub = (json['subtotal'] as num?)?.toDouble() ?? ((cant * prec) - desc);
    return DetalleVentaItemModel(
      idProducto: json['idProducto'] ?? prod?['idProducto'] ?? 0,
      codigo: json['codigo']?.toString() ?? prod?['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? prod?['nombre']?.toString() ?? 'Producto',
      unidadMedida: json['unidadMedida']?.toString() ?? prod?['unidadMedida']?.toString() ?? 'Unidad',
      cantidad: cant,
      precioUnitario: prec,
      descuento: desc,
      subtotal: sub,
    );
  }
}

class VentaHistorialModel {
  final int idVenta;
  final String tipoComprobante;
  final String numComprobante;
  final String metodoPago;
  final double subtotal;
  final double impuesto;
  final double total;
  final String estado;
  final DateTime fechaHora;
  final String? codigoGeneracion;
  final String modalidadEntrega;
  final String direccionEntrega;
  final String clienteNombre;
  final String clienteTelefono;
  final List<DetalleVentaItemModel> detalles;

  VentaHistorialModel({
    required this.idVenta,
    required this.tipoComprobante,
    required this.numComprobante,
    required this.metodoPago,
    required this.subtotal,
    required this.impuesto,
    required this.total,
    required this.estado,
    required this.fechaHora,
    this.codigoGeneracion,
    this.modalidadEntrega = 'Envío a Domicilio',
    this.direccionEntrega = '',
    this.clienteNombre = '',
    this.clienteTelefono = '',
    this.detalles = const [],
  });

  bool get esRetiroEnTienda =>
      modalidadEntrega.toLowerCase().contains('retiro') ||
      modalidadEntrega.toLowerCase().contains('pick');

  Map<String, dynamic> toJson() => {
        'idVenta': idVenta,
        'tipoComprobante': tipoComprobante,
        'numComprobante': numComprobante,
        'metodoPago': metodoPago,
        'subtotal': subtotal,
        'impuesto': impuesto,
        'total': total,
        'estado': estado,
        'fechaHora': fechaHora.toIso8601String(),
        'codigoGeneracion': codigoGeneracion,
        'modalidadEntrega': modalidadEntrega,
        'direccionEntrega': direccionEntrega,
        'clienteNombre': clienteNombre,
        'clienteTelefono': clienteTelefono,
        'detalleVentas': detalles.map((d) => d.toJson()).toList(),
      };

  factory VentaHistorialModel.fromJson(Map<String, dynamic> json) {
    final cli = json['cliente'] as Map<String, dynamic>?;
    final rawDetalles = (json['detalleVentas'] ?? json['detalles']) as List?;
    final parsedDetalles = rawDetalles != null
        ? rawDetalles
            .map((e) => DetalleVentaItemModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <DetalleVentaItemModel>[];

    return VentaHistorialModel(
      idVenta: json['idVenta'] ?? 0,
      tipoComprobante: 'Ticket',
      numComprobante: json['numComprobante']?.toString() ?? '',
      metodoPago: json['metodoPago']?.toString() ?? 'Efectivo',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      impuesto: (json['impuesto'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado']?.toString() ?? 'Completada',
      fechaHora: DateTime.tryParse(json['fechaHora']?.toString() ?? '') ?? DateTime.now(),
      codigoGeneracion: json['codigoGeneracion']?.toString(),
      modalidadEntrega: json['modalidadEntrega']?.toString() ?? 'Envío a Domicilio',
      direccionEntrega: json['direccionEntrega']?.toString() ??
          cli?['direccion']?.toString() ??
          '',
      clienteNombre: json['clienteNombre']?.toString() ??
          cli?['nombre']?.toString() ??
          '',
      clienteTelefono: json['clienteTelefono']?.toString() ??
          cli?['telefono']?.toString() ??
          '',
      detalles: parsedDetalles,
    );
  }
}
