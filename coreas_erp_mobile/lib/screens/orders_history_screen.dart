import 'package:flutter/material.dart';
import '../models/erp_models.dart';
import 'order_ticket_screen.dart';

class OrdersHistoryScreen extends StatefulWidget {
  final List<VentaHistorialModel> historialPedidos;
  final CustomerProfileModel customerProfile;
  final Color primaryColor;
  final VoidCallback onGoToCatalog;
  final void Function(ProductoModel prod, double cant, bool granel, double descUnit) onAddToCart;
  final Future<void> Function() onRefresh;

  const OrdersHistoryScreen({
    super.key,
    required this.historialPedidos,
    required this.customerProfile,
    required this.primaryColor,
    required this.onGoToCatalog,
    required this.onAddToCart,
    required this.onRefresh,
  });

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _statusFilterIndex = 0; // 0: Todos, 1: En camino, 2: Entregados, 3: Cancelados

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _computeStepIndex(String estado) {
    final e = estado.trim().toLowerCase();
    if (e.contains('cancel') || e.contains('anula')) return -1;
    if (e.contains('entregad') || e.contains('completad') || e.contains('finalizad')) return 3;
    if (e.contains('camino') || e.contains('ruta') || e.contains('despachad')) return 2;
    if (e.contains('prepar') || e.contains('alist')) return 1;
    return 0; // Confirmado / Pendiente
  }

  bool _isOrderActive(String estado) {
    final e = estado.trim().toLowerCase();
    if (e.contains('cancel') || e.contains('anula')) return false;
    if (e.contains('entregad') || e.contains('completad') || e.contains('finalizad')) return false;
    return true;
  }

  List<VentaHistorialModel> get _filteredOrders {
    var list = widget.historialPedidos;

    if (_statusFilterIndex == 1) {
      // En camino / Activos
      list = list.where((v) => _isOrderActive(v.estado)).toList();
    } else if (_statusFilterIndex == 2) {
      // Entregados / Completados
      list = list.where((v) {
        final e = v.estado.toLowerCase();
        return e.contains('entregad') || e.contains('completad') || e.contains('finalizad');
      }).toList();
    } else if (_statusFilterIndex == 3) {
      // Cancelados / Anulados
      list = list.where((v) {
        final e = v.estado.toLowerCase();
        return e.contains('cancel') || e.contains('anula');
      }).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((v) {
        final ticketMatches = v.numComprobante.toLowerCase().contains(q);
        final itemMatches = v.detalles.any((d) => d.nombre.toLowerCase().contains(q));
        return ticketMatches || itemMatches;
      }).toList();
    }

    return list;
  }

  void _openOrderDetail(VentaHistorialModel venta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderTicketScreen(
          venta: venta,
          customerProfile: widget.customerProfile,
          primaryColor: widget.primaryColor,
        ),
      ),
    );
  }

  void _reorderItems(VentaHistorialModel venta) {
    int count = 0;
    for (final d in venta.detalles) {
      final dummyProd = ProductoModel(
        idProducto: d.idProducto,
        idCategoria: 1,
        codigo: d.codigo,
        nombre: d.nombre,
        precioCompra: 0,
        precioVenta: d.precioUnitario,
        stock: 999,
        stockMinimo: 1,
        esGranel: false,
        unidadMedida: d.unidadMedida,
        estado: true,
      );
      widget.onAddToCart(dummyProd, d.cantidad, false, d.descuento);
      count++;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$count productos agregados al carrito de compras.'),
        backgroundColor: widget.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.primaryColor;
    final orders = _filteredOrders;
    final activeOrders = orders.where((v) => _isOrderActive(v.estado)).toList();
    final pastOrders = orders.where((v) => !_isOrderActive(v.estado)).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: c,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Mis Pedidos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar pedidos',
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: c,
        onRefresh: widget.onRefresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
          children: [
            // Barra de Búsqueda
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por número de pedido o producto...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: Icon(Icons.search_rounded, color: c),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(Icons.clear, size: 18),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Filtros de Estado (Pills: Todos, En camino, Entregados, Cancelados)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusFilterPill(0, 'Todos', c),
                  const SizedBox(width: 8),
                  _buildStatusFilterPill(1, 'En camino', c),
                  const SizedBox(width: 8),
                  _buildStatusFilterPill(2, 'Entregados', c),
                  const SizedBox(width: 8),
                  _buildStatusFilterPill(3, 'Cancelados', c),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Estado Vacío si no hay pedidos
            if (widget.historialPedidos.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 54, color: c.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    const Text(
                      'Aún no tienes pedidos registrados',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16.5,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Cuando realices pedidos desde el carrito con entrega a domicilio o retiro en tienda, aparecerán aquí con su seguimiento en tiempo real.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: c,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                      ),
                      onPressed: widget.onGoToCatalog,
                      icon: const Icon(Icons.storefront_outlined, size: 18),
                      label: const Text(
                        'Explorar Catálogo',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              )
            else if (orders.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                    SizedBox(height: 8),
                    Text(
                      'No se encontraron pedidos con ese filtro',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Prueba seleccionando otro filtro de estado.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                    ),
                  ],
                ),
              )
            else ...[
              // Sección de Pedidos Activos ("En camino")
              if (activeOrders.isNotEmpty && (_statusFilterIndex == 0 || _statusFilterIndex == 1)) ...[
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'En camino / Activos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...activeOrders.map((v) => _buildActiveOrderCard(v, c)),
                const SizedBox(height: 16),
              ],

              // Sección de Historial de Pedidos ("Entregados" o Pasados)
              if (pastOrders.isNotEmpty && (_statusFilterIndex == 0 || _statusFilterIndex == 2 || _statusFilterIndex == 3)) ...[
                const Text(
                  'Historial de Pedidos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                ...pastOrders.map((v) => _buildPastOrderCard(v, c)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilterPill(int index, String label, Color primaryColor) {
    final isSelected = _statusFilterIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _statusFilterIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  // Tarjeta de Pedido Activo con Stepper de 4 Pasos (Screenshot 3)
  Widget _buildActiveOrderCard(VentaHistorialModel v, Color primaryColor) {
    final step = _computeStepIndex(v.estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera: Número de pedido y Badge de estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${v.numComprobante}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${v.fechaHora.day.toString().padLeft(2, '0')}/${v.fechaHora.month.toString().padLeft(2, '0')}/${v.fechaHora.year} - ${v.fechaHora.hour.toString().padLeft(2, '0')}:${v.fechaHora.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  v.estado.isNotEmpty ? v.estado : 'En camino',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stepper de 4 Pasos: Confirmado -> Preparado -> En camino -> Entregado (Screenshot 3)
          _buildOrderProgressStepper(step, primaryColor),
          const SizedBox(height: 16),

          // Miniaturas de productos
          if (v.detalles.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: v.detalles.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (ctx, idx) {
                  final d = v.detalles[idx];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${d.cantidad.toStringAsFixed(0)}x ${d.nombre}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 14),

          // Modalidad de Entrega + Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    v.esRetiroEnTienda
                        ? Icons.storefront_outlined
                        : Icons.local_shipping_outlined,
                    size: 16,
                    color: const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    v.modalidadEntrega,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  ),
                ],
              ),
              Text(
                'Total: \$${v.total.toStringAsFixed(3)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Botones de Acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => _openOrderDetail(v),
                  icon: const Icon(Icons.navigation_outlined, size: 16),
                  label: const Text(
                    'Seguir pedido',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onPressed: () => _openOrderDetail(v),
                  child: const Text(
                    'Detalles',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tarjeta de Historial de Pedidos Completados (Screenshot 3)
  Widget _buildPastOrderCard(VentaHistorialModel v, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${v.numComprobante}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${v.fechaHora.day.toString().padLeft(2, '0')}/${v.fechaHora.month.toString().padLeft(2, '0')}/${v.fechaHora.year}',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  v.estado.isNotEmpty ? v.estado : 'Entregado',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Total y Productos resumidos
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${v.detalles.length} artículo(s)',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              Text(
                'Total: \$${v.total.toStringAsFixed(3)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Botones Volver a comprar y Ver factura
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF0F172A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _reorderItems(v),
                  icon: const Icon(Icons.replay_rounded, size: 16),
                  label: const Text(
                    'Volver a comprar',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () => _openOrderDetail(v),
                  child: const Text(
                    'Ver comprobante',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Stepper Visual de 4 Pasos: Confirmado -> Preparado -> En camino -> Entregado
  Widget _buildOrderProgressStepper(int currentStep, Color primaryColor) {
    final steps = ['Confirmado', 'Preparado', 'En camino', 'Entregado'];

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Línea conectora
          final stepIndex = i ~/ 2;
          final isActive = stepIndex < currentStep;
          return Expanded(
            child: Container(
              height: 2.5,
              color: isActive ? primaryColor : const Color(0xFFE2E8F0),
            ),
          );
        } else {
          // Nodo del paso
          final stepIndex = i ~/ 2;
          final isCompleted = stepIndex <= currentStep;
          final isCurrent = stepIndex == currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? primaryColor : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? primaryColor : const Color(0xFFCBD5E1),
                    width: isCurrent ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                      : Text(
                          '${stepIndex + 1}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCompleted ? FontWeight.w800 : FontWeight.w600,
                  color: isCompleted ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}
