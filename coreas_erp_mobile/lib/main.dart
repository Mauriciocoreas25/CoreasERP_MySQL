import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/erp_models.dart';
import 'services/api_service.dart';
import 'screens/login_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_checkout_screen.dart';
import 'screens/modals_and_forms.dart';
import 'screens/categories_screen.dart';
import 'screens/offers_screen.dart';
import 'screens/orders_history_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CoreasErpMobileApp());
}

class CoreasErpMobileApp extends StatefulWidget {
  const CoreasErpMobileApp({super.key});

  @override
  State<CoreasErpMobileApp> createState() => _CoreasErpMobileAppState();
}

class _CoreasErpMobileAppState extends State<CoreasErpMobileApp> {
  bool _usePinkTheme = false;

  Color get _primaryColor =>
      _usePinkTheme ? const Color(0xFFE11D48) : const Color(0xFF15803D);

  void _toggleTheme(bool usePink) {
    setState(() {
      _usePinkTheme = usePink;
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        primary: _primaryColor,
        surface: const Color(0xFFF8FAFC),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    );

    return MaterialApp(
      title: 'Super Tienda Kenia',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTheme.textTheme),
      ),
      home: MainShellScreen(
        primaryColor: _primaryColor,
        usePinkTheme: _usePinkTheme,
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}

class MainShellScreen extends StatefulWidget {
  final Color primaryColor;
  final bool usePinkTheme;
  final ValueChanged<bool> onThemeChanged;

  const MainShellScreen({
    super.key,
    required this.primaryColor,
    required this.usePinkTheme,
    required this.onThemeChanged,
  });

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  bool _isLoggedIn = false;
  bool _checkingSession = true;

  int _currentTab = 0; // 0: Inicio, 1: Categorías, 2: Ofertas, 3: Mis Pedidos, 4: Perfil
  int _productFilterTab = 0; // 0: En Promoción, 1: Más Vendidos, 2: Nuevos
  int? _selectedCategoryId;
  bool _preferPickupMode = false; // false: Envío a Domicilio, true: Retiro en Tienda (Pick Up)

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _isLoading = true;

  List<CategoriaModel> _categorias = [];
  List<ProductoModel> _productos = [];
  List<PromocionModel> _promociones = [];
  List<VentaHistorialModel> _historialPedidos = [];
  final List<CartItemModel> _cart = [];

  SavedAddressModel _currentAddress = SavedAddressModel(
    etiqueta: 'Casa',
    referencia: '',
    latitud: 13.69294,
    longitud: -89.21819,
    esPrincipal: true,
  );

  List<SavedAddressModel> _savedAddresses = [];

  CustomerProfileModel _customerProfile = CustomerProfileModel(
    idCliente: 0,
    tipoPersona: 'Natural',
    nombre: '',
    tipoDocumento: 'DUI',
    numDocumento: '',
    telefono: '',
    email: '',
  );

  BannerConfigModel _bannerConfig = BannerConfigModel();

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initApp() async {
    await _loadLocalPrefs();
    await _loadCatalogData();
  }

  Future<void> _loadLocalPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logged = prefs.getBool('is_logged_in') ?? false;
      _preferPickupMode = prefs.getBool('prefer_pickup_mode') ?? false;
      final addrJson = prefs.getString('current_address');
      if (addrJson != null) {
        _currentAddress = SavedAddressModel.fromJson(jsonDecode(addrJson));
      }
      final savedListJson = prefs.getString('saved_addresses_list');
      if (savedListJson != null) {
        final List list = jsonDecode(savedListJson);
        _savedAddresses = list.map((e) => SavedAddressModel.fromJson(e)).toList();
      }
      final profJson = prefs.getString('customer_profile');
      if (profJson != null) {
        _customerProfile = CustomerProfileModel.fromJson(jsonDecode(profJson));
      }
      final bannerJson = prefs.getString('banner_config');
      if (bannerJson != null) {
        _bannerConfig = BannerConfigModel.fromJson(jsonDecode(bannerJson));
        widget.onThemeChanged(_bannerConfig.usarTonoRosa);
      }

      if (logged &&
          _customerProfile.nombre.trim().isNotEmpty &&
          _customerProfile.idCliente != 2 &&
          _customerProfile.giro != null &&
          _customerProfile.giro!.startsWith('PWD:')) {
        _isLoggedIn = true;
      } else {
        await prefs.setBool('is_logged_in', false);
        _isLoggedIn = false;
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _checkingSession = false);
    }
  }

  Future<void> _saveLocalPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', _isLoggedIn);
      await prefs.setBool('prefer_pickup_mode', _preferPickupMode);
      await prefs.setString('current_address', jsonEncode(_currentAddress.toJson()));
      await prefs.setString(
        'saved_addresses_list',
        jsonEncode(_savedAddresses.map((e) => e.toJson()).toList()),
      );
      await prefs.setString(
        'customer_profile',
        jsonEncode(_customerProfile.toJson(_currentAddress.toCompactDbString())),
      );
      await prefs.setString('banner_config', jsonEncode(_bannerConfig.toJson()));
    } catch (_) {}
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    setState(() {
      _isLoggedIn = false;
      _cart.clear();
      _currentTab = 0;
    });
  }

  Future<void> _loadCatalogData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final cats = await ApiService.getCategorias();
    final prods = await ApiService.getProductos();
    final allPromos = await ApiService.getPromocionesActivas();
    final hist = await ApiService.getHistorialPedidos(
      idCliente: _customerProfile.idCliente,
    );

    // Extraer configuración del Banner publicada desde el ERP de Escritorio ([APP_BANNER])
    final List<PromocionModel> realPromos = [];
    for (final p in allPromos) {
      if (p.nombre.startsWith('[APP_BANNER]')) {
        final partes = (p.descripcion ?? '').split('||');
        if (partes.isNotEmpty && partes[0].trim().isNotEmpty) {
          _bannerConfig.titulo = partes[0].trim();
        }
        if (partes.length >= 2 && partes[1].trim().isNotEmpty) {
          _bannerConfig.subtitulo = partes[1].trim();
        }
        if (partes.length >= 3 && partes[2].trim().isNotEmpty) {
          _bannerConfig.etiquetaDescuento = partes[2].trim();
        }
        if (partes.length >= 4) {
          final isRosa = partes[3].trim().toUpperCase() == 'ROSA';
          if (_bannerConfig.usarTonoRosa != isRosa) {
            _bannerConfig.usarTonoRosa = isRosa;
            widget.onThemeChanged(isRosa);
          }
        }
      } else {
        realPromos.add(p);
      }
    }

    if (!mounted) return;
    setState(() {
      _categorias = cats;
      _productos = prods;
      _promociones = realPromos;
      _historialPedidos = hist;
      _isLoading = false;
    });
  }

  PromocionModel? _getPromoForProduct(ProductoModel p) {
    if (_promociones.isEmpty) return null;
    for (final promo in _promociones) {
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
      return double.parse((p.precioVenta * (promo.valor / 100.0)).toStringAsFixed(2));
    }
    return promo.valor < p.precioVenta ? promo.valor : 0.0;
  }

  void _addToCart(ProductoModel prod, double cant, bool granel, double descUnit) {
    setState(() {
      final existingIdx = _cart.indexWhere(
        (c) => c.producto.idProducto == prod.idProducto && c.modoGranel == granel,
      );
      if (existingIdx >= 0) {
        _cart[existingIdx].cantidad += cant;
      } else {
        _cart.add(
          CartItemModel(
            producto: prod,
            cantidad: cant,
            modoGranel: granel,
            descuentoUnitario: descUnit,
          ),
        );
      }
    });
  }

  int get _totalCartCount => _cart.length;

  void _openCartCheckout({bool? forcePickupMode}) {
    if (forcePickupMode != null) {
      setState(() => _preferPickupMode = forcePickupMode);
      _saveLocalPrefs();
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartCheckoutScreen(
          cartItems: _cart,
          currentAddress: _currentAddress,
          customerProfile: _customerProfile,
          primaryColor: widget.primaryColor,
          initialPickupMode: _preferPickupMode,
          onCartUpdated: () => setState(() {}),
          onOrderCompleted: () {
            setState(() => _cart.clear());
            _loadCatalogData();
          },
          onOpenAddressPicker: _openGpsAddressModal,
          onClientIdUpdated: (newId) {
            setState(() => _customerProfile.idCliente = newId);
            _saveLocalPrefs();
          },
        ),
      ),
    );
  }

  void _openProductDetail(ProductoModel p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          producto: p,
          promocionActiva: _getPromoForProduct(p),
          primaryColor: widget.primaryColor,
          onAddToCart: _addToCart,
          onOpenCartCheckout: _openCartCheckout,
        ),
      ),
    );
  }

  void _openBarcodeScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BarcodeScannerModal(
        primaryColor: widget.primaryColor,
        catalogProducts: _productos,
        onCodeScanned: (code) async {
          ProductoModel? found;
          for (final p in _productos) {
            if (p.codigo.toLowerCase() == code.toLowerCase()) {
              found = p;
              break;
            }
          }
          found ??= await ApiService.getProductoByCodigo(code);
          if (!mounted) return;
          if (found != null) {
            _openProductDetail(found);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No se encontró ningún producto con el código "$code".'),
                backgroundColor: const Color(0xFFB91C1C),
              ),
            );
          }
        },
      ),
    );
  }

  void _openGpsAddressModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GpsAddressModal(
        primaryColor: widget.primaryColor,
        currentAddress: _currentAddress,
        savedAddresses: _savedAddresses,
        onAddressSaved: (selected, updatedList) {
          setState(() {
            _currentAddress = selected;
            _savedAddresses = updatedList;
          });
          _saveLocalPrefs();
        },
      ),
    );
  }

  void _openCustomerHelpForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomerDataFormModal(
        primaryColor: widget.primaryColor,
        profile: _customerProfile,
        currentAddress: _currentAddress,
        onSaved: (updated) {
          setState(() => _customerProfile = updated);
          _saveLocalPrefs();
        },
      ),
    );
  }

  List<ProductoModel> get _filteredProducts {
    var list = List<ProductoModel>.from(_productos);

    if (_selectedCategoryId != null && _selectedCategoryId! > 0) {
      list = list.where((p) => p.idCategoria == _selectedCategoryId).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list
          .where(
            (p) =>
                p.nombre.toLowerCase().contains(q) ||
                p.codigo.toLowerCase().contains(q) ||
                (p.descripcion?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    if (_productFilterTab == 0) {
      list.sort((a, b) {
        final pa = _getPromoForProduct(a) != null ? 0 : 1;
        final pb = _getPromoForProduct(b) != null ? 0 : 1;
        return pa.compareTo(pb);
      });
    } else if (_productFilterTab == 1) {
      list.sort((a, b) => b.precioVenta.compareTo(a.precioVenta));
    } else {
      list.sort((a, b) => b.idProducto.compareTo(a.idProducto));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.primaryColor;

    if (_checkingSession) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: c),
        ),
      );
    }

    if (!_isLoggedIn) {
      return ClientLoginScreen(
        primaryColor: c,
        isRoseTheme: widget.usePinkTheme,
        onToggleTheme: () {},
        onLoginSuccess: (profile, gpsAddress) {
          setState(() {
            _customerProfile = profile;
            if (gpsAddress != null && gpsAddress.referencia.trim().isNotEmpty) {
              _currentAddress = gpsAddress;
              _savedAddresses.removeWhere((a) => a.etiqueta == gpsAddress.etiqueta);
              _savedAddresses.insert(0, gpsAddress);
            }
            _isLoggedIn = true;
          });
          _saveLocalPrefs();
          _loadCatalogData();
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 2,
        titleSpacing: 14,
        title: Row(
          children: [
            Container(
              width: 58,
              height: 40,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => Icon(
                    Icons.shopping_bag_rounded,
                    color: c,
                    size: 22,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Super Tienda Kenia',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Hola, ${_customerProfile.nombre}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _openCartCheckout,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shopping_cart_rounded, color: c, size: 20),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$_totalCartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
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

      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildHomeTab(c),
          CategoriesScreen(
            categorias: _categorias,
            primaryColor: c,
            totalCartCount: _totalCartCount,
            onOpenCart: _openCartCheckout,
            onSelectCategory: (cat) {
              setState(() {
                _selectedCategoryId = cat.idCategoria;
                _currentTab = 0;
              });
            },
            onRefresh: _loadCatalogData,
          ),
          OffersScreen(
            productos: _productos,
            categorias: _categorias,
            promociones: _promociones,
            primaryColor: c,
            totalCartCount: _totalCartCount,
            onOpenCart: _openCartCheckout,
            onAddToCart: _addToCart,
            onOpenProductDetail: _openProductDetail,
            onRefresh: _loadCatalogData,
          ),
          OrdersHistoryScreen(
            historialPedidos: _historialPedidos,
            customerProfile: _customerProfile,
            primaryColor: c,
            onGoToCatalog: () => setState(() => _currentTab = 0),
            onAddToCart: _addToCart,
            onRefresh: _loadCatalogData,
          ),
          ProfileScreen(
            customerProfile: _customerProfile,
            currentAddress: _currentAddress,
            historialPedidos: _historialPedidos,
            primaryColor: c,
            onEditProfile: _openCustomerHelpForm,
            onOpenAddressPicker: _openGpsAddressModal,
            onLogout: _logout,
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (idx) {
          setState(() => _currentTab = idx);
          if (idx == 1 || idx == 2 || idx == 3 || idx == 4) {
            _loadCatalogData();
          }
        },
        backgroundColor: Colors.white,
        elevation: 8,
        indicatorColor: c.withValues(alpha: 0.15),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: c),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded, color: c),
            label: 'Categorías',
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer_rounded, color: c),
            label: 'Ofertas',
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded, color: c),
            label: 'Mis Pedidos',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: c),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PESTAÑA 1: INICIO
  // ===========================================================================
  Widget _buildHomeTab(Color c) {
    final hasAddress = _currentAddress.referencia.trim().isNotEmpty;

    return RefreshIndicator(
      color: c,
      onRefresh: _loadCatalogData,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          // 1. BARRA DE BÚSQUEDA + ESCÁNER DE CÓDIGO DE BARRAS A LA PAR
          Row(
            children: [
              Expanded(
                child: Container(
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
                      hintText: 'Buscar productos...',
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
              ),
              const SizedBox(width: 10),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _openBarcodeScanner,
                child: Container(
                  height: 50,
                  width: 52,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: c.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. SELECTOR RÁPIDO: ENVÍO A DOMICILIO VS RETIRO EN TIENDA (PICK UP) + DIRECCIÓN
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: c.withValues(alpha: 0.28)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _preferPickupMode = false);
                          _saveLocalPrefs();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_preferPickupMode ? c : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                size: 16,
                                color: !_preferPickupMode ? Colors.white : const Color(0xFF475569),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Envío a Domicilio',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: !_preferPickupMode ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _preferPickupMode = true);
                          _saveLocalPrefs();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _preferPickupMode ? c : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.storefront_outlined,
                                size: 16,
                                color: _preferPickupMode ? Colors.white : const Color(0xFF475569),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Retiro en Tienda (Pick Up)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _preferPickupMode ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (!_preferPickupMode)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _openGpsAddressModal,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: c.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.location_on_rounded, color: c, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enviar a ${_currentAddress.etiqueta}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12.5,
                                  color: c,
                                ),
                              ),
                              Text(
                                hasAddress
                                    ? _currentAddress.referencia
                                    : 'Toca aquí para elegir tu ubicación en el mapa',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF334155)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.map_outlined, size: 17, color: Color(0xFF64748B)),
                        const SizedBox(width: 2),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                      ],
                    ),
                  )
                else
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: c.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.store_mall_directory_rounded, color: c, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Retiro en Sucursal Super Tienda Kenia',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5,
                                color: c,
                              ),
                            ),
                            const Text(
                              'Retira tu pedido en tienda presentando tu Ticket de Compra digital',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: Color(0xFF334155)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3. ROW / LISTA DE CATEGORÍAS CON NOMBRE Y FOTO DE LA CATEGORÍA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Categorías',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              if (_selectedCategoryId != null)
                TextButton(
                  onPressed: () => setState(() => _selectedCategoryId = null),
                  child: Text('Ver todas', style: TextStyle(color: c, fontWeight: FontWeight.w700)),
                )
              else
                TextButton(
                  onPressed: () => setState(() => _currentTab = 1),
                  child: Text('Explorar todo', style: TextStyle(color: c, fontWeight: FontWeight.w700)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_categorias.isNotEmpty)
            SizedBox(
              height: 108,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categorias.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (ctx, idx) {
                  final cat = _categorias[idx];
                  final isSelected = _selectedCategoryId == cat.idCategoria;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = isSelected ? null : cat.idCategoria;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 86,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected ? c.withValues(alpha: 0.12) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? c : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: (cat.imagenUrl != null && cat.imagenUrl!.isNotEmpty)
                                  ? Image.network(
                                      cat.imagenUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _buildCategoryDefaultAvatar(cat.nombre, c),
                                    )
                                  : _buildCategoryDefaultAvatar(cat.nombre, c),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected ? c : const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 18),

          // 4. BANNER PUBLICITARIO DE LA TIENDA (Administrado desde el ERP de Escritorio)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.usePinkTheme
                    ? [const Color(0xFFBE123C), const Color(0xFFF43F5E)]
                    : [const Color(0xFF14532D), const Color(0xFF16A34A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: c.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -12,
                  bottom: -12,
                  child: Icon(
                    Icons.local_mall_rounded,
                    size: 110,
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFACC15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _bannerConfig.etiquetaDescuento,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _bannerConfig.titulo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _bannerConfig.subtitulo,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: c,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() => _productFilterTab = 0);
                      },
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: Text(
                        _bannerConfig.textoBoton,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5. SECCIÓN DE PRODUCTOS (EN PROMOCIÓN, MÁS VENDIDOS, NUEVOS) SIN EMOJIS
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterPill(0, 'En Promoción', Icons.local_offer_outlined, c),
                const SizedBox(width: 8),
                _buildFilterPill(1, 'Más Vendidos', Icons.trending_up_rounded, c),
                const SizedBox(width: 8),
                _buildFilterPill(2, 'Nuevos Productos', Icons.new_releases_outlined, c),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_filteredProducts.isEmpty)
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Icon(Icons.storefront_outlined, size: 52, color: c.withValues(alpha: 0.5)),
                  const SizedBox(height: 10),
                  Text(
                    _productos.isEmpty
                        ? 'Catálogo en preparación'
                        : 'No encontramos productos con ese filtro',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _productos.isEmpty
                        ? 'Estamos actualizando nuestro inventario de productos para ti. Desliza hacia abajo o toca en Actualizar.'
                        : 'Intenta buscar con otro término o selecciona otra categoría.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: _loadCatalogData,
                    icon: Icon(Icons.refresh_rounded, color: c, size: 18),
                    label: Text(
                      'Actualizar catálogo',
                      style: TextStyle(color: c, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredProducts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (ctx, idx) {
                final p = _filteredProducts[idx];
                return _buildProductCard(p, c);
              },
            ),

          const SizedBox(height: 24),

          // 6. BOTÓN DE AYUDA ABAJO QUE REDIRIGE AL FORMULARIO DE RECOLECCIÓN DE DATOS DEL CLIENTE
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.withValues(alpha: 0.25), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.support_agent_rounded, color: c, size: 28),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Necesitas ayuda con tu pedido?',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Actualiza tus datos de contacto o envíanos tu consulta para atenderte.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                    ),
                    onPressed: _openCustomerHelpForm,
                    icon: const Icon(Icons.assignment_ind_outlined, size: 19),
                    label: const Text(
                      'Atención al Cliente',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(int idx, String label, IconData icon, Color c) {
    final selected = _productFilterTab == idx;
    return GestureDetector(
      onTap: () => setState(() => _productFilterTab = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? c : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? c : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : c,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductoModel p, Color c) {
    final promo = _getPromoForProduct(p);
    final desc = _getDiscountForProduct(p);
    final finalPrice = (p.precioVenta - desc).clamp(0.01, 999999.0);
    final available = p.stock > 0;

    return GestureDetector(
      onTap: () => _openProductDetail(p),
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
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: (p.imagenUrl != null && p.imagenUrl!.isNotEmpty)
                          ? Image.network(
                              p.imagenUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: const Color(0xFFF1F5F9),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  size: 42,
                                  color: c.withValues(alpha: 0.4),
                                ),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFF1F5F9),
                              child: Icon(
                                Icons.inventory_2_outlined,
                                size: 42,
                                color: c.withValues(alpha: 0.4),
                              ),
                            ),
                    ),
                  ),
                  if (promo != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          promo.tipoDescuento.toLowerCase().contains('porcentaje')
                              ? '-${promo.valor.toStringAsFixed(0)}%'
                              : 'PROMO',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  if (p.esGranel)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Granel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF0F172A),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    available ? 'Disponible • ${p.unidadMedida}' : 'Agotado',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: available ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (desc > 0)
                            Text(
                              '\$${p.precioVenta.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            '\$${finalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: c,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: !available
                            ? null
                            : () {
                                _addToCart(p, 1.0, false, desc);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${p.nombre} agregado al carrito'),
                                    backgroundColor: c,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: available ? c : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
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
  }

  Widget _buildCategoryDefaultAvatar(String name, Color c) {
    return Container(
      color: c.withValues(alpha: 0.12),
      child: Center(
        child: Icon(Icons.category_rounded, color: c, size: 24),
      ),
    );
  }
}
