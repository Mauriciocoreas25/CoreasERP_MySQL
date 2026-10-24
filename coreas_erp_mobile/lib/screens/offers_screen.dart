import 'package:flutter/material.dart';
import '../models/erp_models.dart';

class OffersScreen extends StatefulWidget {
  final List<ProductoModel> productos;
  final List<CategoriaModel> categorias;
  final List<PromocionModel> promociones;
  final Color primaryColor;
  final int totalCartCount;
  final VoidCallback onOpenCart;
  final void Function(ProductoModel prod, double cant, bool granel, double descUnit) onAddToCart;
  final ValueChanged<ProductoModel> onOpenProductDetail;
  final Future<void> Function() onRefresh;

  const OffersScreen({
    super.key,
    required this.productos,
    required this.categorias,
    required this.promociones,
    required this.primaryColor,
    required this.totalCartCount,
    required this.onOpenCart,
    required this.onAddToCart,
    required this.onOpenProductDetail,
    required this.onRefresh,
  });

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedCategoryId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  PromocionModel? _getPromoForProduct(ProductoModel p) {
    if (widget.promociones.isEmpty) return null;
    for (final promo in widget.promociones) {
      if (promo.idProducto == null || promo.idProducto == p.idProducto) {
        return promo;
      }
    }
    return null;
  }

  double _getDiscountForProduct(ProductoModel p) {
    final promo = _getPromoForProduct(p);
    if (promo == null) return 0.0;
    if (promo.tipoDescuento.toLowerCase().contains('porcentaje')) {
      return double.parse((p.precioVenta * (promo.valor / 100.0)).toStringAsFixed(3));
    }
    return promo.valor < p.precioVenta ? promo.valor : 0.0;
  }

  String _getDiscountBadge(ProductoModel p) {
    final promo = _getPromoForProduct(p);
    if (promo == null) return 'OFERTA';
    if (promo.tipoDescuento.toLowerCase().contains('porcentaje')) {
      return '${promo.valor.toInt()}% OFF';
    }
    if (promo.tipoDescuento.toLowerCase().contains('2x1')) {
      return '2x1';
    }
    return 'AHORRO';
  }

  List<ProductoModel> get _offerProducts {
    // Productos que tienen promoción activa o catálogo de ofertas
    final list = widget.productos.where((p) {
      final hasPromo = _getPromoForProduct(p) != null;
      if (!hasPromo && widget.promociones.isNotEmpty) return false;

      if (_selectedCategoryId != null && p.idCategoria != _selectedCategoryId) {
        return false;
      }

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final nameMatches = p.nombre.toLowerCase().contains(q);
        final codeMatches = p.codigo.toLowerCase().contains(q);
        return nameMatches || codeMatches;
      }

      return true;
    }).toList();

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.primaryColor;
    final offers = _offerProducts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: c,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Ofertas Especiales %',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: widget.onRefresh,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: widget.onOpenCart,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  if (widget.totalCartCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          '${widget.totalCartCount}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
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
                  hintText: 'Buscar en ofertas...',
                  hintStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
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

            // Filtros horizontales de Categorías (Pills)
            if (widget.categorias.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryPill(
                      label: 'Todas',
                      isSelected: _selectedCategoryId == null,
                      onTap: () => setState(() => _selectedCategoryId = null),
                      primaryColor: c,
                    ),
                    ...widget.categorias.map((cat) {
                      final isSelected = _selectedCategoryId == cat.idCategoria;
                      return _buildCategoryPill(
                        label: cat.nombre,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedCategoryId = isSelected ? null : cat.idCategoria;
                          });
                        },
                        primaryColor: c,
                      );
                    }),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Banner Hero: "Ofertas del Día" con Degradado Verde Oscuro / Esmeralda
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F5132), Color(0xFF198754)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F5132).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Hasta 40% DCTO',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ofertas del Día',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Aprovecha descuentos exclusivos por tiempo limitado',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0F5132),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedCategoryId = null;
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                          child: const Text(
                            'Ver Todo',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.percent_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Grid de 2 Columnas de Productos en Oferta
            if (widget.productos.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.local_offer_outlined, size: 52, color: c.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    const Text(
                      'No hay ofertas activas en este momento',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Cuando el administrador registre descuentos o promociones en el catálogo, aparecerán listadas aquí con precios especiales.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c,
                        side: BorderSide(color: c),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: widget.onRefresh,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Actualizar Ofertas'),
                    ),
                  ],
                ),
              )
            else if (offers.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 8),
                    const Text(
                      'No se encontraron ofertas con ese filtro',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Selecciona otra categoría o borra la búsqueda.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: offers.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (ctx, idx) {
                  final p = offers[idx];
                  final descUnit = _getDiscountForProduct(p);
                  final badgeLabel = _getDiscountBadge(p);
                  final finalPrice = (p.precioVenta - descUnit).clamp(0.0, 99999.0);

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => widget.onOpenProductDetail(p),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Imagen del Producto con Badge de Descuento
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                                child: Container(
                                  height: 125,
                                  width: double.infinity,
                                  color: const Color(0xFFF8FAFC),
                                  child: (p.imagenUrl != null && p.imagenUrl!.isNotEmpty)
                                      ? Image.network(
                                          p.imagenUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Center(
                                            child: Icon(
                                              Icons.shopping_bag_outlined,
                                              size: 40,
                                              color: c.withValues(alpha: 0.4),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Icon(
                                            Icons.shopping_bag_outlined,
                                            size: 40,
                                            color: c.withValues(alpha: 0.4),
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    badgeLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Información del Producto
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.nombre,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: Color(0xFF0F172A),
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  p.unidadMedida,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Precios (Tachado y Precio Oferta) + Botón Circular +
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (descUnit > 0)
                                          Text(
                                            '\$${p.precioVenta.toStringAsFixed(3)}',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF94A3B8),
                                              decoration: TextDecoration.lineThrough,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        Text(
                                          '\$${finalPrice.toStringAsFixed(3)}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: descUnit > 0
                                                ? const Color(0xFFDC2626)
                                                : c,
                                          ),
                                        ),
                                      ],
                                    ),
                                    InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      onTap: () {
                                        widget.onAddToCart(p, 1.0, false, descUnit);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('${p.nombre} agregado al carrito.'),
                                            duration: const Duration(seconds: 1),
                                            backgroundColor: c,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: c,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: c.withValues(alpha: 0.35),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.add_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
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
      ),
    );
  }
}
