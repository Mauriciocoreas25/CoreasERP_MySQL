import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/erp_models.dart';

typedef ErpApiService = ApiService;

class ApiService {
  static const String baseUrl = 'http://coreaserp.runasp.net';

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
      };

  /// Genera hash SHA-256 con salt para proteger la contraseña del cliente en la base de datos
  static String hashPassword(String plainPassword) {
    final bytes = utf8.encode('STK_SALT_2026::$plainPassword');
    final digest = sha256.convert(bytes).toString();
    return 'PWD:$digest';
  }

  static String? _extractPasswordHash(String? giroField) {
    if (giroField == null || giroField.isEmpty) return null;
    final parts = giroField.split('||');
    for (final p in parts) {
      if (p.trim().startsWith('PWD:')) {
        return p.trim();
      }
    }
    return null;
  }

  static Future<bool> checkHealth() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['success'] == true;
      }
    } catch (_) {}
    return false;
  }

  static Future<List<CategoriaModel>> getCategorias() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/categorias'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list
            .map((e) => CategoriaModel.fromJson(e))
            .where((c) => c.estado)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<ProductoModel>> getProductos({
    String? busqueda,
    int? idCategoria,
  }) async {
    try {
      final params = <String, String>{'soloActivos': 'true'};
      if (busqueda != null && busqueda.trim().isNotEmpty) {
        params['busqueda'] = busqueda.trim();
      }
      if (idCategoria != null && idCategoria > 0) {
        params['idCategoria'] = idCategoria.toString();
      }
      final uri = Uri.parse('$baseUrl/api/productos').replace(queryParameters: params);
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list.map((e) => ProductoModel.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<ProductoModel?> getProductoByCodigo(String codigo) async {
    try {
      final clean = Uri.encodeComponent(codigo.trim());
      final res = await http
          .get(Uri.parse('$baseUrl/api/productos/by-codigo/$clean'))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        return ProductoModel.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }

  static Future<List<PromocionModel>> getPromocionesActivas() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/promociones/activas'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        return list
            .map((e) => PromocionModel.fromJson(e))
            .where((p) => !p.nombre.startsWith('[ORD_'))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// Autentica al cliente verificando su teléfono/correo y su contraseña cifrada (SHA-256)
  static Future<({
    bool success,
    String message,
    CustomerProfileModel? profile,
    SavedGpsAddress? gpsAddress,
  })> loginCustomerWithPassword({
    required String identifier,
    required String password,
  }) async {
    try {
      final clean = identifier.trim();
      if (clean.isEmpty || password.isEmpty) {
        return (
          success: false,
          message: 'Ingresa tu teléfono/correo y tu contraseña.',
          profile: null,
          gpsAddress: null,
        );
      }

      final allRes = await http
          .get(Uri.parse('$baseUrl/api/clientes'))
          .timeout(const Duration(seconds: 15));
      if (allRes.statusCode != 200) {
        return (
          success: false,
          message: 'No se pudo conectar con el servidor. Intenta nuevamente.',
          profile: null,
          gpsAddress: null,
        );
      }

      final List list = jsonDecode(allRes.body) as List;
      final qLower = clean.toLowerCase().replaceAll('-', '').replaceAll(' ', '');
      final inputHash = hashPassword(password);

      for (final raw in list) {
        final map = raw as Map<String, dynamic>;
        final int id = map['idCliente'] ?? 0;
        if (id <= 1) continue;

        final tel = (map['telefono']?.toString() ?? '').toLowerCase().replaceAll('-', '').replaceAll(' ', '');
        final mail = (map['email']?.toString() ?? '').toLowerCase().trim();

        if ((tel.isNotEmpty && tel == qLower) ||
            (mail.isNotEmpty && mail == clean.toLowerCase())) {
          final storedHash = _extractPasswordHash(map['giro']?.toString());

          // Validación estricta: la cuenta debe tener contraseña registrada y coincidir exactamente
          if (storedHash == null || storedHash != inputHash) {
            return (
              success: false,
              message: 'Contraseña incorrecta. Verifica tus credenciales e intenta de nuevo.',
              profile: null,
              gpsAddress: null,
            );
          }

          final profile = CustomerProfileModel(
            idCliente: id,
            nombre: map['nombre']?.toString() ?? '',
            numDocumento: map['numDocumento']?.toString() ?? '',
            telefono: map['telefono']?.toString() ?? '',
            email: map['email']?.toString() ?? '',
            nrc: map['nrc']?.toString(),
            giro: storedHash,
            tipoPersona: map['tipoPersona']?.toString() ?? 'Natural',
          );
          final dirStr = map['direccion']?.toString() ?? '';
          final gps = dirStr.isNotEmpty ? SavedGpsAddress.fromCompactDbString(dirStr) : null;

          return (
            success: true,
            message: 'Bienvenido, ${profile.nombre}',
            profile: profile,
            gpsAddress: gps,
          );
        }
      }

      return (
        success: false,
        message: 'No existe una cuenta registrada con "$clean". Crea tu cuenta en la pestaña "Crear Cuenta".',
        profile: null,
        gpsAddress: null,
      );
    } catch (_) {
      return (
        success: false,
        message: 'Error de conexión. Verifica tu internet.',
        profile: null,
        gpsAddress: null,
      );
    }
  }

  /// Verifica si ya existe un cliente con el mismo teléfono o correo antes de registrar
  static Future<bool> customerAlreadyExists(String telefono, String email) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/clientes'))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body) as List;
        final telClean = telefono.trim().toLowerCase().replaceAll('-', '').replaceAll(' ', '');
        final mailClean = email.trim().toLowerCase();

        for (final raw in list) {
          final map = raw as Map<String, dynamic>;
          final int id = map['idCliente'] ?? 0;
          if (id <= 1) continue;

          final t = (map['telefono']?.toString() ?? '').toLowerCase().replaceAll('-', '').replaceAll(' ', '');
          final m = (map['email']?.toString() ?? '').toLowerCase().trim();
          if ((telClean.isNotEmpty && t == telClean) ||
              (mailClean.isNotEmpty && m == mailClean)) {
            return true;
          }
        }
      }
    } catch (_) {}
    return false;
  }

  /// Guarda o actualiza los datos del cliente y su dirección preservando siempre su hash de contraseña
  static Future<({bool success, String message, int idCliente})> saveCustomerAndCoords({
    required CustomerProfileModel profile,
    required String compactGpsAddress,
  }) async {
    try {
      if (profile.idCliente > 1 &&
          (profile.giro == null || !profile.giro!.startsWith('PWD:'))) {
        try {
          final existingRes = await http
              .get(Uri.parse('$baseUrl/api/clientes/${profile.idCliente}'))
              .timeout(const Duration(seconds: 10));
          if (existingRes.statusCode == 200) {
            final existingMap = jsonDecode(existingRes.body) as Map<String, dynamic>;
            final existingHash = _extractPasswordHash(existingMap['giro']?.toString());
            if (existingHash != null) {
              profile.giro = existingHash;
            }
          }
        } catch (_) {}
      }

      final payload = profile.toJson(compactGpsAddress);
      if (payload['idCliente'] == 1 &&
          profile.nombre.trim().toLowerCase() != 'consumidor final') {
        payload['idCliente'] = 0;
      }

      final res = await http
          .post(
            Uri.parse('$baseUrl/api/clientes'),
            headers: _headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final bool ok = data['success'] == true;
        final String msg = data['message']?.toString() ?? 'Datos guardados correctamente.';
        final clienteData = data['data'] as Map<String, dynamic>?;
        final int newId = clienteData?['idCliente'] ?? profile.idCliente;
        return (success: ok, message: msg, idCliente: newId);
      }
      return (
        success: false,
        message: 'No se pudieron guardar los datos en este momento.',
        idCliente: profile.idCliente
      );
    } catch (_) {
      return (
        success: false,
        message: 'Verifica tu conexión a internet e intenta nuevamente.',
        idCliente: profile.idCliente
      );
    }
  }

  /// Registra el pedido móvil (Solo Ticket y Efectivo, Ventas Gravadas, Domicilio o Retiro en Tienda)
  static Future<({
    bool success,
    String message,
    String? numComprobante,
    VentaHistorialModel? pedido,
  })> registrarPedidoMovil({
    required int idCliente,
    required String tipoComprobante,
    required String metodoPago,
    required List<CartItemModel> items,
    String modalidadEntrega = 'Envío a Domicilio',
    String direccionEntrega = '',
    String clienteNombre = '',
    String clienteTelefono = '',
  }) async {
    if (items.isEmpty) {
      return (
        success: false,
        message: 'Tu carrito está vacío.',
        numComprobante: null,
        pedido: null,
      );
    }

    final detallesPedido = items
        .map(
          (it) => DetalleVentaItemModel(
            idProducto: it.producto.idProducto,
            codigo: it.producto.codigo,
            nombre: it.producto.nombre,
            unidadMedida: it.esGranel ? it.unidadLabel : 'Unidad',
            cantidad: it.cantidad,
            precioUnitario: it.precioUnitario,
            descuento: it.descuentoTotal,
            subtotal: it.subtotal,
          ),
        )
        .toList();

    try {
      await _ensureCajaAbierta();

      final totalPedido = items.fold<double>(0.0, (sum, it) => sum + it.subtotal);

      final payload = {
        'idCliente': idCliente > 0 ? idCliente : 1,
        'idUsuario': 1,
        'tipoComprobante': 'Ticket',
        'metodoPago': 'Efectivo',
        'pagoCon': totalPedido,
        'items': items.map((e) => e.toApiCartItemDto()).toList(),
      };

      final res = await http
          .post(
            Uri.parse('$baseUrl/api/ventas'),
            headers: _headers,
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final bool ok = data['success'] == true;
        final String msg = data['message']?.toString() ?? '';
        final venta = data['data'] as Map<String, dynamic>?;
        final String comprobante =
            venta?['numComprobante']?.toString() ?? _generateTicketCode();
        final int idVentaServer =
            (venta?['idVenta'] as num?)?.toInt() ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);

        if (ok) {
          final model = VentaHistorialModel(
            idVenta: idVentaServer,
            tipoComprobante: 'Ticket',
            numComprobante: comprobante,
            metodoPago: 'Efectivo',
            subtotal: totalPedido,
            impuesto: 0.0,
            total: totalPedido,
            estado: 'Pendiente',
            fechaHora: DateTime.now(),
            modalidadEntrega: modalidadEntrega,
            direccionEntrega: direccionEntrega,
            clienteNombre: clienteNombre,
            clienteTelefono: clienteTelefono,
            detalles: detallesPedido,
          );
          await _saveLocalOrderBackup(model);
          await _syncOrderToCloudErp(model, idCliente > 0 ? idCliente : 1);
          return (
            success: true,
            message: 'Tu pedido ha sido confirmado correctamente.',
            numComprobante: comprobante,
            pedido: model,
          );
        }

        if (msg.contains('MySqlRetryingExecutionStrategy') ||
            msg.contains('CreateExecutionStrategy')) {
          return await _procesarPedidoConDescuentoDirecto(
            idCliente: idCliente > 0 ? idCliente : 1,
            items: items,
            detallesPedido: detallesPedido,
            totalPedido: totalPedido,
            modalidadEntrega: modalidadEntrega,
            direccionEntrega: direccionEntrega,
            clienteNombre: clienteNombre,
            clienteTelefono: clienteTelefono,
          );
        }

        return (success: false, message: msg, numComprobante: null, pedido: null);
      }
      return (
        success: false,
        message: 'No pudimos procesar tu pedido en este momento.',
        numComprobante: null,
        pedido: null,
      );
    } catch (_) {
      return (
        success: false,
        message: 'Verifica tu conexión a internet e intenta de nuevo.',
        numComprobante: null,
        pedido: null,
      );
    }
  }

  static String _generateTicketCode() {
    final now = DateTime.now();
    final y = now.year.toString();
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final seq = (now.millisecondsSinceEpoch % 9000 + 1000).toString();
    return 'T-$y$m$d-$seq';
  }

  static Future<({
    bool success,
    String message,
    String? numComprobante,
    VentaHistorialModel? pedido,
  })> _procesarPedidoConDescuentoDirecto({
    required int idCliente,
    required List<CartItemModel> items,
    required List<DetalleVentaItemModel> detallesPedido,
    required double totalPedido,
    required String modalidadEntrega,
    required String direccionEntrega,
    required String clienteNombre,
    required String clienteTelefono,
  }) async {
    try {
      for (final item in items) {
        final prodActual = await http
            .get(Uri.parse('$baseUrl/api/productos/${item.producto.idProducto}'))
            .timeout(const Duration(seconds: 10));
        if (prodActual.statusCode == 200) {
          final map = jsonDecode(prodActual.body) as Map<String, dynamic>;
          final double stockActual = (map['stock'] as num?)?.toDouble() ?? item.producto.stock;
          final double factor =
              (item.esGranel && (item.producto.cantidadPorEmpaque ?? 1) > 1)
                  ? item.producto.cantidadPorEmpaque!
                  : 1.0;
          final double descontar = item.cantidad / factor;
          if (stockActual < descontar) {
            return (
              success: false,
              message: 'Existencias insuficientes para ${item.producto.nombre}.',
              numComprobante: null,
              pedido: null,
            );
          }
          map['stock'] = (stockActual - descontar).clamp(0.0, 999999.0);
          await http.post(
            Uri.parse('$baseUrl/api/productos'),
            headers: _headers,
            body: jsonEncode(map),
          );
        }
      }

      final ticketCode = _generateTicketCode();
      final model = VentaHistorialModel(
        idVenta: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        tipoComprobante: 'Ticket',
        numComprobante: ticketCode,
        metodoPago: 'Efectivo',
        subtotal: totalPedido,
        impuesto: 0.0,
        total: totalPedido,
        estado: 'Pendiente',
        fechaHora: DateTime.now(),
        modalidadEntrega: modalidadEntrega,
        direccionEntrega: direccionEntrega,
        clienteNombre: clienteNombre,
        clienteTelefono: clienteTelefono,
        detalles: detallesPedido,
      );
      await _saveLocalOrderBackup(model);
      await _syncOrderToCloudErp(model, idCliente);
      return (
        success: true,
        message: 'Pedido confirmado exitosamente.',
        numComprobante: ticketCode,
        pedido: model,
      );
    } catch (_) {
      return (
        success: false,
        message: 'No se pudo completar el pedido. Intenta nuevamente.',
        numComprobante: null,
        pedido: null,
      );
    }
  }

  /// Sincroniza la cabecera y líneas del pedido hacia el ERP de Escritorio (módulo Pedidos App Móvil)
  static Future<void> _syncOrderToCloudErp(VentaHistorialModel model, int idCliente) async {
    try {
      final isPickUp = model.modalidadEntrega.toLowerCase().contains('retiro') ||
          model.modalidadEntrega.toLowerCase().contains('pick');
      final modCode = isPickUp ? 'PICKUP' : 'DOMICILIO';
      final fechaIso = model.fechaHora.toIso8601String().substring(0, 16);

      String rawDesc = '${model.clienteNombre}||${model.clienteTelefono}||${model.direccionEntrega}';
      if (rawDesc.length > 250) {
        rawDesc = rawDesc.substring(0, 250);
      }

      final futureStart = DateTime.now().add(const Duration(days: 3650)).toIso8601String();
      final futureEnd = DateTime.now().add(const Duration(days: 3655)).toIso8601String();

      final headerPayload = {
        'idPromocion': 0,
        'nombre': '[ORD_HDR]|${model.numComprobante}|$idCliente|$modCode|$fechaIso',
        'descripcion': rawDesc,
        'tipoDescuento': 'Pendiente',
        'valor': model.total >= 0.01 ? model.total : 0.01,
        'fechaInicio': futureStart,
        'fechaFin': futureEnd,
        'estado': true,
        'idProducto': null,
      };

      await http.post(
        Uri.parse('$baseUrl/api/promociones'),
        headers: _headers,
        body: jsonEncode(headerPayload),
      );

      for (final d in model.detalles) {
        String itemDesc = '${d.codigo}||${d.nombre}||${d.precioUnitario.toStringAsFixed(2)}';
        if (itemDesc.length > 250) {
          itemDesc = itemDesc.substring(0, 250);
        }
        final itemPayload = {
          'idPromocion': 0,
          'nombre': '[ORD_ITM]|${model.numComprobante}|${d.cantidad}|${d.unidadMedida}',
          'descripcion': itemDesc,
          'tipoDescuento': 'Item',
          'valor': d.subtotal >= 0.01 ? d.subtotal : 0.01,
          'fechaInicio': futureStart,
          'fechaFin': futureEnd,
          'estado': true,
          'idProducto': d.idProducto > 0 ? d.idProducto : null,
        };
        await http.post(
          Uri.parse('$baseUrl/api/promociones'),
          headers: _headers,
          body: jsonEncode(itemPayload),
        );
      }
    } catch (_) {}
  }

  static Future<void> _saveLocalOrderBackup(VentaHistorialModel model) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('local_orders_history');
      final List list = raw != null ? (jsonDecode(raw) as List) : [];
      list.removeWhere((e) => (e as Map<String, dynamic>)['numComprobante'] == model.numComprobante);
      list.insert(0, model.toJson());
      await prefs.setString('local_orders_history', jsonEncode(list.take(40).toList()));
    } catch (_) {}
  }

  static Future<void> _ensureCajaAbierta() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/caja/activo?idUsuario=1'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode != 200 ||
          res.body.trim().isEmpty ||
          res.body.trim() == 'null') {
        await http.post(
          Uri.parse('$baseUrl/api/caja/abrir'),
          headers: _headers,
          body: jsonEncode({'idUsuario': 1, 'montoInicial': 100.0}),
        );
      }
    } catch (_) {}
  }

  static Future<List<VentaHistorialModel>> getHistorialPedidos({int? idCliente}) async {
    final List<VentaHistorialModel> combined = [];
    final Map<String, VentaHistorialModel> localByTicket = {};

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('local_orders_history');
      if (raw != null) {
        final List localList = jsonDecode(raw);
        for (final e in localList) {
          final model = VentaHistorialModel.fromJson(e as Map<String, dynamic>);
          if (model.numComprobante.isNotEmpty) {
            localByTicket[model.numComprobante] = model;
          }
        }
      }
    } catch (_) {}

    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/ventas'))
          .timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final List list = jsonDecode(res.body);
        for (final e in list) {
          final map = e as Map<String, dynamic>;
          if (idCliente == null || idCliente <= 1 || map['idCliente'] == idCliente) {
            final serverModel = VentaHistorialModel.fromJson(map);
            final localMatch = localByTicket[serverModel.numComprobante];
            if (localMatch != null) {
              combined.add(
                VentaHistorialModel(
                  idVenta: serverModel.idVenta,
                  tipoComprobante: 'Ticket',
                  numComprobante: serverModel.numComprobante,
                  metodoPago: 'Efectivo',
                  subtotal: serverModel.subtotal,
                  impuesto: serverModel.impuesto,
                  total: serverModel.total,
                  estado: serverModel.estado,
                  fechaHora: serverModel.fechaHora,
                  codigoGeneracion: serverModel.codigoGeneracion,
                  modalidadEntrega: localMatch.modalidadEntrega,
                  direccionEntrega: localMatch.direccionEntrega.isNotEmpty
                      ? localMatch.direccionEntrega
                      : serverModel.direccionEntrega,
                  clienteNombre: localMatch.clienteNombre.isNotEmpty
                      ? localMatch.clienteNombre
                      : serverModel.clienteNombre,
                  clienteTelefono: localMatch.clienteTelefono.isNotEmpty
                      ? localMatch.clienteTelefono
                      : serverModel.clienteTelefono,
                  detalles: serverModel.detalles.isNotEmpty
                      ? serverModel.detalles
                      : localMatch.detalles,
                ),
              );
            } else {
              combined.add(serverModel);
            }
          }
        }
      }
    } catch (_) {}

    try {
      final promoRes = await http
          .get(Uri.parse('$baseUrl/api/promociones'))
          .timeout(const Duration(seconds: 12));
      if (promoRes.statusCode == 200) {
        final List promoList = jsonDecode(promoRes.body);
        final Map<String, List<DetalleVentaItemModel>> itemsByTicket = {};

        for (final raw in promoList) {
          final m = raw as Map<String, dynamic>;
          final nombre = m['nombre']?.toString() ?? '';
          if (nombre.startsWith('[ORD_ITM]|')) {
            final nParts = nombre.split('|');
            if (nParts.length < 2) continue;
            final ticket = nParts[1].trim();
            final cant = nParts.length >= 3 ? (double.tryParse(nParts[2]) ?? 1.0) : 1.0;
            final unidad = nParts.length >= 4 ? nParts[3].trim() : 'Unidad';
            final dParts = (m['descripcion']?.toString() ?? '').split('||');
            final codigo = dParts.isNotEmpty ? dParts[0].trim() : '';
            final prodNombre = dParts.length >= 2 ? dParts[1].trim() : 'Producto';
            final subtotal = (m['valor'] as num?)?.toDouble() ?? 0.0;
            final precioUnit = dParts.length >= 3
                ? (double.tryParse(dParts[2]) ?? (cant > 0 ? subtotal / cant : subtotal))
                : (cant > 0 ? subtotal / cant : subtotal);

            itemsByTicket.putIfAbsent(ticket, () => []).add(
              DetalleVentaItemModel(
                idProducto: (m['idProducto'] as num?)?.toInt() ?? 0,
                codigo: codigo,
                nombre: prodNombre,
                unidadMedida: unidad,
                cantidad: cant,
                precioUnitario: precioUnit,
                descuento: 0.0,
                subtotal: subtotal,
              ),
            );
          }
        }

        for (final raw in promoList) {
          final m = raw as Map<String, dynamic>;
          final nombre = m['nombre']?.toString() ?? '';
          if (nombre.startsWith('[ORD_HDR]|')) {
            final nParts = nombre.split('|');
            if (nParts.length < 3) continue;
            final ticket = nParts[1].trim();
            final ordIdCliente = int.tryParse(nParts[2].trim()) ?? 1;
            if (idCliente != null && idCliente > 1 && ordIdCliente != idCliente) {
              continue;
            }
            final modCode = nParts.length >= 4 ? nParts[3].trim() : 'DOMICILIO';
            final modalidad = modCode.toUpperCase() == 'PICKUP'
                ? 'Retiro en Tienda (Pick Up)'
                : 'Envío a Domicilio';
            final fechaHora = nParts.length >= 5
                ? (DateTime.tryParse(nParts[4].trim()) ?? DateTime.now())
                : DateTime.now();

            final dParts = (m['descripcion']?.toString() ?? '').split('||');
            final cliNombre = dParts.isNotEmpty ? dParts[0].trim() : '';
            final cliTel = dParts.length >= 2 ? dParts[1].trim() : '';
            final dirEntrega = dParts.length >= 3 ? dParts[2].trim() : '';
            final total = (m['valor'] as num?)?.toDouble() ?? 0.0;
            final estado = m['tipoDescuento']?.toString() ?? 'Pendiente';

            final cloudDetails = itemsByTicket[ticket] ?? localByTicket[ticket]?.detalles ?? [];
            final cloudModel = VentaHistorialModel(
              idVenta: (m['idPromocion'] as num?)?.toInt() ?? 0,
              tipoComprobante: 'Ticket',
              numComprobante: ticket,
              metodoPago: 'Efectivo',
              subtotal: total,
              impuesto: 0.0,
              total: total,
              estado: estado,
              fechaHora: fechaHora,
              modalidadEntrega: modalidad,
              direccionEntrega: dirEntrega,
              clienteNombre: cliNombre,
              clienteTelefono: cliTel,
              detalles: cloudDetails,
            );
            localByTicket[ticket] = cloudModel;
          }
        }
      }
    } catch (_) {}

    for (final localModel in localByTicket.values) {
      if (!combined.any((c) => c.numComprobante == localModel.numComprobante)) {
        combined.add(localModel);
      }
    }

    combined.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));
    return combined;
  }
}
