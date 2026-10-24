import 'package:flutter/material.dart';
import '../models/erp_models.dart';

class CategoriesScreen extends StatefulWidget {
  final List<CategoriaModel> categorias;
  final Color primaryColor;
  final int totalCartCount;
  final VoidCallback onOpenCart;
  final ValueChanged<CategoriaModel> onSelectCategory;
  final Future<void> Function() onRefresh;

  const CategoriesScreen({
    super.key,
    required this.categorias,
    required this.primaryColor,
    required this.totalCartCount,
    required this.onOpenCart,
    required this.onSelectCategory,
    required this.onRefresh,
  });

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Paleta de tonos pastel elegantes para las tarjetas de categorías (sin emojis)
  final List<({Color bg, Color border, Color accent})> _pastelPalettes = const [
    (bg: Color(0xFFFEF3C7), border: Color(0xFFFDE68A), accent: Color(0xFFB45309)), // Ámbar / Panadería
    (bg: Color(0xFFE0F2FE), border: Color(0xFFBAE6FD), accent: Color(0xFF0369A1)), // Celeste / Lácteos
    (bg: Color(0xFFFFEDD5), border: Color(0xFFFED7AA), accent: Color(0xFFC2410C)), // Naranja suave / Bebidas
    (bg: Color(0xFFDCFCE7), border: Color(0xFFBBF7D0), accent: Color(0xFF15803D)), // Verde menta / Frutas
    (bg: Color(0xFFFCE7F3), border: Color(0xFFFBCFE8), accent: Color(0xFFBE185D)), // Rosa suave / Cuidado
    (bg: Color(0xFFF3E8FF), border: Color(0xFFE9D5FF), accent: Color(0xFF7E22CE)), // Lavanda / Limpieza
    (bg: Color(0xFFE0E7FF), border: Color(0xFFC7D2FE), accent: Color(0xFF4338CA)), // Índigo / Carnes
    (bg: Color(0xFFCCFBF1), border: Color(0xFF99F6E4), accent: Color(0xFF0F766E)), // Turquesa / Snacks
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CategoriaModel> get _filteredCategories {
    if (_searchQuery.trim().isEmpty) return widget.categorias;
    final q = _searchQuery.toLowerCase().trim();
    return widget.categorias.where((c) {
      final nameMatches = c.nombre.toLowerCase().contains(q);
      final descMatches = (c.descripcion ?? '').toLowerCase().contains(q);
      return nameMatches || descMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: c,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Categorías',
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
                  hintText: 'Buscar productos, marcas y categorías...',
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
            const SizedBox(height: 20),

            // Encabezado de la Sección
            const Text(
              'Explora nuestras categorías',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Selecciona una categoría para ver sus productos disponibles.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 16),

            // Estado Vacío si no hay categorías en la base de datos
            if (widget.categorias.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 54, color: c.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    const Text(
                      'Catálogo en proceso de carga',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Aún no hay categorías registradas en la base de datos. Se mostrarán aquí automáticamente cuando se agreguen.',
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
                      label: const Text('Recargar Catálogo'),
                    ),
                  ],
                ),
              )
            else if (_filteredCategories.isEmpty)
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
                    Text(
                      'No hay resultados para "$_searchQuery"',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Intenta buscar con otro término.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                    ),
                  ],
                ),
              )
            else
              // Grid de 2 Columnas con Tarjetas Pastel y Fotos de Categorías (Sin emojis)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredCategories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (ctx, idx) {
                  final cat = _filteredCategories[idx];
                  final palette = _pastelPalettes[idx % _pastelPalettes.length];

                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => widget.onSelectCategory(cat),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: palette.bg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: palette.border, width: 1.2),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  cat.nombre,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Fotografía de la categoría desde la base de datos o ícono elegante (sin emojis)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.white,
                                  child: (cat.imagenUrl != null && cat.imagenUrl!.isNotEmpty)
                                      ? Image.network(
                                          cat.imagenUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) => Center(
                                            child: Icon(
                                              Icons.category_outlined,
                                              color: palette.accent,
                                              size: 26,
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Icon(
                                            Icons.inventory_2_outlined,
                                            color: palette.accent,
                                            size: 26,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Text(
                                cat.totalProductos > 0
                                    ? '${cat.totalProductos} productos'
                                    : 'Ver productos',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: palette.accent,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 14,
                                color: palette.accent,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 28),

            // Sección: Subcategorías Populares
            if (widget.categorias.isNotEmpty) ...[
              const Text(
                'Subcategorías Populares',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: widget.categorias.take(6).map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        avatar: Icon(Icons.arrow_right_rounded, color: c, size: 20),
                        label: Text(
                          cat.nombre,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        onPressed: () => widget.onSelectCategory(cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
