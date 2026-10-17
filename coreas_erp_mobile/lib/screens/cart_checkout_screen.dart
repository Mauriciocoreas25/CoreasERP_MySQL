import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/erp_models.dart';
import '../services/api_service.dart';
import 'order_ticket_screen.dart';

class CartCheckoutScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final Color primaryColor;
  final SavedGpsAddress currentAddress;
  final CustomerProfileModel customerProfile;
  final bool initialPickupMode;
  final VoidCallback onCartUpdated;
  final VoidCallback onOrderCompleted;
  final VoidCallback onOpenAddressPicker;
  final void Function(int newClientId) onClientIdUpdated;

  const CartCheckoutScreen({
    super.key,
    required this.cartItems,
    required this.primaryColor,
    required this.currentAddress,
    required this.customerProfile,
    this.initialPickupMode = false,
    required this.onCartUpdated,
    required this.onOrderCompleted,
    required this.onOpenAddressPicker,
    required this.onClientIdUpdated,
  });

  @override
  State<CartCheckoutScreen> createState() => _CartCheckoutScreenState();
}

class _CartCheckoutScreenState extends State<CartCheckoutScreen> {
  bool _submitting = false;
  late bool _isPickupMode;

  @override
  void initState() {
    super.initState();
    _isPickupMode = widget.initialPickupMode;
  }

  double get _totalBruto => widget.cartItems.fold<double>(
        0.0,
        (sum, item) => sum + (item.precioUnitario * item.cantidad),
      );

  double get _totalDescuento => widget.cartItems.fold<double>(
        0.0,
        (sum, item) => sum + (item.descuentoUnitario * item.cantidad),
      );

  double get _totalVentasGravadas =>
      widget.cartItems.fold<double>(0.0, (sum, item) => sum + item.subtotal);

  Future<void> _openGoogleMaps() async {
    final uri = Uri.parse(widget.currentAddress.googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _confirmarPedido() async {
    if (widget.cartItems.isEmpty || _submitting) return;

    setState(() => _submitting = true);

    int clientId = widget.customerProfile.idCliente;
    final saveCli = await ApiService.saveCustomerAndCoords(
      profile: widget.customerProfile,
      compactGpsAddress: widget.currentAddress.toCompactDbString(),
    );
    if (saveCli.idCliente > 0) {
      clientId = saveCli.idCliente;
      widget.onClientIdUpdated(clientId);
    }

    final modalidad = _isPickupMode ? 'Retiro en Tienda (Pick Up)' : 'Envío a Domicilio';
    final direccionTexto = _isPickupMode
        ? 'Sucursal Principal - Super Tienda Kenia (Retiro en Tienda)'
        : (widget.currentAddress.referencia.trim().isNotEmpty
            ? '${widget.currentAddress.etiqueta}: ${widget.currentAddress.referencia}'
            : widget.currentAddress.etiqueta);

    final res = await ApiService.registrarPedidoMovil(
      idCliente: clientId,
      tipoComprobante: 'Ticket',
      metodoPago: 'Efectivo',
      items: widget.cartItems,
      modalidadEntrega: modalidad,
      direccionEntrega: direccionTexto,
      clienteNombre: widget.customerProfile.nombre,
      clienteTelefono: widget.customerProfile.telefono,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (res.success) {
      final totalPagado = _totalVentasGravadas;
      final generatedPedido = res.pedido;
      widget.onOrderCompleted();
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 56,
                  color: widget.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Pedido Confirmado',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isPickupMode
                    ? 'Tu pedido para retiro en tienda ha sido registrado. Presenta tu ticket digital en caja al retirar.'
                    : res.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF475569), fontSize: 13.5),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _dialogRow('Ticket No.:', res.numComprobante ?? 'Generado'),
                    const SizedBox(height: 6),
                    _dialogRow('Comprobante:', 'Ticket de Venta'),
                    const SizedBox(height: 6),
                    _dialogRow('Modalidad:', modalidad),
                    const SizedBox(height: 6),
                    _dialogRow(
                      'Método de Pago:',
                      _isPickupMode ? 'Efectivo en tienda' : 'Efectivo contra entrega',
                    ),
                    const SizedBox(height: 6),
                    _dialogRow('Cliente:', widget.customerProfile.nombre),
                    const Divider(height: 16),
                    _dialogRow(
                      'Total Ventas Gravadas:',
                      '\$${totalPagado.toStringAsFixed(2)}',
                      bold: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (generatedPedido != null) ...[
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTicketScreen(
                            venta: generatedPedido,
                            customerProfile: widget.customerProfile,
                            primaryColor: widget.primaryColor,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_rounded, size: 19),
                    label: const Text(
                      'Ver Ticket de Compra',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.primaryColor,
                    side: BorderSide(color: widget.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Volver al Inicio',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _dialogRow(String label, String val, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
        ),
        Flexible(
          child: Text(
            val,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: bold ? 14.5 : 12.5,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.primaryColor;
    final hasAddress = widget.currentAddress.referencia.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Mi Carrito (${widget.cartItems.length})',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          if (widget.cartItems.isNotEmpty)
            TextButton.icon(
              onPressed: () {
                setState(() => widget.cartItems.clear());
                widget.onCartUpdated();
              },
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: Color(0xFFDC2626),
                size: 20,
              ),
              label: const Text(
                'Vaciar',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: widget.cartItems.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: c,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Tu carrito está vacío',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Explora nuestro catálogo y agrega los productos que necesites.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Selector de Modalidad de Entrega (Envío a Domicilio vs Retiro en Tienda / Pick Up)
                const Text(
                  'Modalidad de Entrega',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isPickupMode = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          decoration: BoxDecoration(
                            color: !_isPickupMode ? c.withValues(alpha: 0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: !_isPickupMode ? c : const Color(0xFFE2E8F0),
                              width: !_isPickupMode ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                size: 20,
                                color: !_isPickupMode ? c : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Envío a Domicilio',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: !_isPickupMode ? c : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isPickupMode = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          decoration: BoxDecoration(
                            color: _isPickupMode ? c.withValues(alpha: 0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _isPickupMode ? c : const Color(0xFFE2E8F0),
                              width: _isPickupMode ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.storefront_outlined,
                                size: 20,
                                color: _isPickupMode ? c : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Retiro en Tienda',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: _isPickupMode ? c : const Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Detalle según la modalidad seleccionada
                if (!_isPickupMode)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: c.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded, color: c, size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Entrega en: ${widget.currentAddress.etiqueta}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: widget.onOpenAddressPicker,
                              child: Text(
                                'Cambiar',
                                style: TextStyle(
                                  color: c,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          hasAddress
                              ? widget.currentAddress.referencia
                              : 'Toca en "Cambiar" para indicar tu dirección de entrega',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: _openGoogleMaps,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.map_outlined, size: 15, color: c),
                                const SizedBox(width: 4),
                                Text(
                                  'Ver ubicación en Google Maps',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: c,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: c.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: c.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.store_mall_directory_rounded, color: c, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Retiro en Tienda (Pick Up) - Super Tienda Kenia',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13.5,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Preparamos tu pedido de inmediato. Al confirmar se generará tu Ticket de Compra digital para que retires tus productos en sucursal sin hacer filas.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF475569),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // 2. Lista de Productos en el Carrito
                const Text(
                  'Productos Seleccionados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                ...widget.cartItems.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final item = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 60,
                            height: 60,
                            color: const Color(0xFFF1F5F9),
                            child: item.producto.imagenUrl != null &&
                                    item.producto.imagenUrl!.isNotEmpty
                                ? Image.network(
                                    item.producto.imagenUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        Icon(Icons.inventory_2_outlined, color: c),
                                  )
                                : Icon(Icons.inventory_2_outlined, color: c),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.producto.nombre,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${item.esGranel ? "Granel (${item.unidadLabel})" : "Unidad"} • \$${item.precioUnitario.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${item.subtotal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: c,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  final step = item.esGranel ? 0.5 : 1.0;
                                  if (item.cantidad - step <= 0) {
                                    widget.cartItems.removeAt(idx);
                                  } else {
                                    item.cantidad -= step;
                                  }
                                });
                                widget.onCartUpdated();
                              },
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 22,
                              ),
                            ),
                            Text(
                              item.cantidad % 1 == 0
                                  ? item.cantidad.toInt().toString()
                                  : item.cantidad.toStringAsFixed(2),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  item.cantidad += item.esGranel ? 0.5 : 1.0;
                                });
                                widget.onCartUpdated();
                              },
                              icon: Icon(
                                Icons.add_circle_rounded,
                                color: c,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // 3. Método de Pago (Solo Efectivo activo, los demás bloqueados)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Método de Pago',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: c.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Comprobante: Ticket',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: c,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Efectivo (Habilitado y Seleccionado)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: c.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: c, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.payments_outlined, color: c, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isPickupMode
                                        ? 'Efectivo al retirar en tienda'
                                        : 'Efectivo contra entrega',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    _isPickupMode
                                        ? 'Paga en efectivo en caja presentando tu Ticket de Compra'
                                        : 'Paga en efectivo al recibir tu pedido',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.check_circle_rounded, color: c, size: 22),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Métodos bloqueados
                      _buildLockedPaymentOption(
                        icon: Icons.credit_card_outlined,
                        title: 'Tarjeta de Débito / Crédito',
                      ),
                      const SizedBox(height: 8),
                      _buildLockedPaymentOption(
                        icon: Icons.account_balance_outlined,
                        title: 'Transferencia Bancaria',
                      ),
                      const SizedBox(height: 8),
                      _buildLockedPaymentOption(
                        icon: Icons.handshake_outlined,
                        title: 'Crédito Comercial',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Resumen de Ventas Gravadas (Sin mencionar IVA)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _summaryRow(
                        'Modalidad',
                        _isPickupMode ? 'Retiro en Tienda (Pick Up)' : 'Envío a Domicilio',
                      ),
                      const SizedBox(height: 6),
                      _summaryRow(
                        'Ventas Gravadas',
                        '\$${_totalBruto.toStringAsFixed(2)}',
                      ),
                      if (_totalDescuento > 0) ...[
                        const SizedBox(height: 6),
                        _summaryRow(
                          'Descuento Promocional',
                          '-\$${_totalDescuento.toStringAsFixed(2)}',
                          valueColor: const Color(0xFF16A34A),
                        ),
                      ],
                      const Divider(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total a Pagar',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '\$${_totalVentasGravadas.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: c,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
      bottomNavigationBar: widget.cartItems.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _submitting ? null : _confirmarPedido,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    _submitting
                        ? 'Procesando tu pedido...'
                        : 'Confirmar Pedido (\$${_totalVentasGravadas.toStringAsFixed(2)})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLockedPaymentOption({
    required IconData icon,
    required String title,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 12,
                  color: Color(0xFF64748B),
                ),
                SizedBox(width: 4),
                Text(
                  'Próximamente',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String val, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
        ),
        Text(
          val,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
