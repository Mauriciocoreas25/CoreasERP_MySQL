import 'package:flutter/material.dart';
import '../models/erp_models.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductoModel producto;
  final PromocionModel? promocionActiva;
  final Color primaryColor;
  final void Function(ProductoModel prod, double cant, bool granel, double descUnit) onAddToCart;
  final VoidCallback onOpenCartCheckout;

  const ProductDetailScreen({
    super.key,
    required this.producto,
    this.promocionActiva,
    required this.primaryColor,
    required this.onAddToCart,
    required this.onOpenCartCheckout,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  double _cantidad = 1.0;
  bool _modoGranel = false;

  double get _precioBase =>
      (_modoGranel && widget.producto.esGranel && (widget.producto.precioGranel ?? 0) > 0)
          ? widget.producto.precioGranel!
          : widget.producto.precioVenta;

  double get _descuentoUnitario {
    final promo = widget.promocionActiva;
    if (promo == null || !promo.estado) return 0.0;
    if (promo.tipoDescuento.toLowerCase().contains('porcentaje')) {
      return double.parse((_precioBase * (promo.valor / 100.0)).toStringAsFixed(2));
    }
    return promo.valor < _precioBase ? promo.valor : 0.0;
  }

  double get _precioFinalUnitario => (_precioBase - _descuentoUnitario).clamp(0.01, 999999.0);

  double get _totalLinea => _precioFinalUnitario * _cantidad;

  @override
  Widget build(BuildContext context) {
    final p = widget.producto;
    final hasPromo = _descuentoUnitario > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Text(
          'Ficha Técnica del Producto',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Ver Carrito',
            onPressed: () {
              Navigator.pop(context);
              widget.onOpenCartCheckout();
            },
            icon: Icon(Icons.shopping_cart_outlined, color: widget.primaryColor),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen Principal Hero con Badges
            Stack(
              children: [
                Container(
                  height: 270,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: p.imagenUrl != null && p.imagenUrl!.isNotEmpty
                      ? Image.network(
                          p.imagenUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildFallbackImage(),
                        )
                      : _buildFallbackImage(),
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.72),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.qr_code_2, color: Colors.white, size: 15),
                        const SizedBox(width: 6),
                        Text(
                          'SKU: ${p.codigo}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (hasPromo)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFE11D48), Color(0xFFF43F5E)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE11D48).withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.promocionActiva!.tipoDescuento.toLowerCase().contains('porcentaje')
                            ? '-${widget.promocionActiva!.valor.toStringAsFixed(0)}% PROMO'
                            : '-\$${widget.promocionActiva!.valor.toStringAsFixed(2)} OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Contenedor Principal de Información
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categoría y Disponibilidad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          p.categoriaNombre ?? 'Catálogo General',
                          style: TextStyle(
                            color: widget.primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: p.stock > 0 ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              p.stock > 0 ? Icons.check_circle : Icons.error_outline,
                              size: 14,
                              color: p.stock > 0 ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              p.stock > 0 ? 'Disponible' : 'Agotado temporalmente',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: p.stock > 0 ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nombre del Producto
                  Text(
                    p.nombre,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Bloque de Precio (Ventas Gravadas)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Precio (Ventas Gravadas)',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${_precioFinalUnitario.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: widget.primaryColor,
                                  ),
                                ),
                                if (hasPromo) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${_precioBase.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF94A3B8),
                                      decoration: TextDecoration.lineThrough,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Presentación',
                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              ),
                              Text(
                                _modoGranel ? p.unidadMedida : 'Unidad / Empaque',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Selector de Modalidad (Unidad Completa vs Granel/Fracción) si el producto es a granel
                  if (p.esGranel && (p.precioGranel ?? 0) > 0) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Modalidad de Compra Disponible:',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _modoGranel = false),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: !_modoGranel
                                    ? widget.primaryColor.withValues(alpha: 0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !_modoGranel ? widget.primaryColor : const Color(0xFFCBD5E1),
                                  width: !_modoGranel ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Text('Empaque Cerrado', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  Text('\$${p.precioVenta.toStringAsFixed(2)}', style: TextStyle(color: widget.primaryColor, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _modoGranel = true),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _modoGranel
                                    ? widget.primaryColor.withValues(alpha: 0.1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _modoGranel ? widget.primaryColor : const Color(0xFFCBD5E1),
                                  width: _modoGranel ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text('A Granel (${p.unidadMedida})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                  Text('\$${p.precioGranel!.toStringAsFixed(2)} / ${p.unidadMedida}', style: TextStyle(color: widget.primaryColor, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Selector de Cantidad
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cantidad a solicitar:',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        Row(
                          children: [
                            IconButton.filledTonal(
                              onPressed: () {
                                if (_cantidad > 1) {
                                  setState(() => _cantidad -= 1);
                                }
                              },
                              icon: const Icon(Icons.remove, size: 18),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                _cantidad.toStringAsFixed(_modoGranel ? 1 : 0),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                              ),
                            ),
                            IconButton.filled(
                              style: IconButton.styleFrom(backgroundColor: widget.primaryColor),
                              onPressed: () {
                                setState(() => _cantidad += 1);
                              },
                              icon: const Icon(Icons.add, size: 18, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Ficha Técnica y Especificaciones
                  const Text(
                    'Ficha Técnica y Descripción',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (p.descripcion != null && p.descripcion!.trim().isNotEmpty)
                              ? p.descripcion!
                              : 'Producto disponible para pedido en línea y entrega a domicilio.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF334155),
                            height: 1.5,
                          ),
                        ),
                        const Divider(height: 24),
                        _buildSpecRow('Código', p.codigo),
                        _buildSpecRow('Categoría', p.categoriaNombre ?? 'General'),
                        _buildSpecRow('Presentación', p.unidadMedida),
                        _buildSpecRow(
                          'Modalidad de Venta',
                          p.esGranel
                              ? 'Unidad y Granel (${p.unidadMedida})'
                              : 'Venta por unidad',
                        ),
                        _buildSpecRow('Comprobante', 'Ticket de Venta'),
                        _buildSpecRow('Método de Pago', 'Efectivo contra entrega'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Barra Inferior Fija: Agregar al Carrito + Confirmar Pedido Directo
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: widget.primaryColor, width: 1.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: p.stock <= 0
                      ? null
                      : () {
                          widget.onAddToCart(p, _cantidad, _modoGranel, _descuentoUnitario);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${p.nombre} agregado al carrito'),
                              backgroundColor: widget.primaryColor,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                  icon: Icon(Icons.add_shopping_cart, color: widget.primaryColor, size: 19),
                  label: Text(
                    'Al Carrito',
                    style: TextStyle(color: widget.primaryColor, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  onPressed: p.stock <= 0
                      ? null
                      : () {
                          widget.onAddToCart(p, _cantidad, _modoGranel, _descuentoUnitario);
                          Navigator.pop(context);
                          widget.onOpenCartCheckout();
                        },
                  icon: const Icon(Icons.bolt, size: 20),
                  label: Text(
                    'Confirmar Pedido (\$${_totalLinea.toStringAsFixed(2)})',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Icon(
          Icons.inventory_2_rounded,
          size: 76,
          color: widget.primaryColor.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
