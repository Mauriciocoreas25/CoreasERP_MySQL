import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/erp_models.dart';
import '../services/api_service.dart';

/// 1. Modal de Escáner de Código de Barras (Cámara + Entrada rápida)
class BarcodeScannerModal extends StatefulWidget {
  final Color primaryColor;
  final List<ProductoModel> catalogProducts;
  final void Function(String barcode) onCodeScanned;

  const BarcodeScannerModal({
    super.key,
    required this.primaryColor,
    required this.catalogProducts,
    required this.onCodeScanned,
  });

  @override
  State<BarcodeScannerModal> createState() => _BarcodeScannerModalState();
}

class _BarcodeScannerModalState extends State<BarcodeScannerModal> {
  final TextEditingController _manualController = TextEditingController();
  final bool _cameraActive = true;
  bool _hasScanned = false;

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  void _triggerCode(String code) {
    if (_hasScanned || code.trim().isEmpty) return;
    _hasScanned = true;
    Navigator.pop(context);
    widget.onCodeScanned(code.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.qr_code_scanner_rounded, color: widget.primaryColor, size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Escáner de Código de Barras',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Text(
              'Apunta la cámara al código de barras del producto o ingresa el SKU manualmente.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),

            // Visor de Cámara MobileScanner
            if (_cameraActive)
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  height: 210,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      MobileScanner(
                        onDetect: (capture) {
                          for (final barcode in capture.barcodes) {
                            final raw = barcode.rawValue;
                            if (raw != null && raw.isNotEmpty) {
                              _triggerCode(raw);
                              break;
                            }
                          }
                        },
                        errorBuilder: (ctx, err) => Container(
                          color: const Color(0xFF0F172A),
                          padding: const EdgeInsets.all(16),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.videocam_off_outlined, color: Colors.white70, size: 36),
                                SizedBox(height: 8),
                                Text(
                                  'Cámara no disponible en este entorno.\nUsa el buscador rápido de código abajo.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Container(
                          width: 220,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualController,
                    decoration: InputDecoration(
                      hintText: 'Ej. 7411000101',
                      labelText: 'Código / SKU del producto',
                      prefixIcon: const Icon(Icons.dialpad, size: 19),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                    onSubmitted: _triggerCode,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _triggerCode(_manualController.text),
                  child: const Text('Buscar', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),

            if (widget.catalogProducts.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'Productos sugeridos (toca para buscar rápido):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.catalogProducts.take(5).map((p) {
                  return ActionChip(
                    avatar: Icon(Icons.qr_code, size: 15, color: widget.primaryColor),
                    label: Text(
                      '${p.codigo} • ${p.nombre.length > 18 ? "${p.nombre.substring(0, 18)}..." : p.nombre}',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => _triggerCode(p.codigo),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 2. Modal de Dirección y Cálculo de Coordenadas GPS Compactas + Google Maps
class GpsAddressModal extends StatefulWidget {
  final Color primaryColor;
  final SavedAddressModel currentAddress;
  final List<SavedAddressModel> savedAddresses;
  final void Function(SavedAddressModel selected, List<SavedAddressModel> updatedList) onAddressSaved;

  const GpsAddressModal({
    super.key,
    required this.primaryColor,
    required this.currentAddress,
    required this.savedAddresses,
    required this.onAddressSaved,
  });

  @override
  State<GpsAddressModal> createState() => _GpsAddressModalState();
}

class _GpsAddressModalState extends State<GpsAddressModal> {
  late double _lat;
  late double _lng;
  late String _etiqueta;
  late TextEditingController _refController;
  bool _isCalculatingGps = false;
  String? _statusMsg;

  @override
  void initState() {
    super.initState();
    _lat = widget.currentAddress.latitud;
    _lng = widget.currentAddress.longitud;
    _etiqueta = widget.currentAddress.etiqueta;
    _refController = TextEditingController(text: widget.currentAddress.referencia);
  }

  @override
  void dispose() {
    _refController.dispose();
    super.dispose();
  }

  Future<void> _calcularGpsDispositivo() async {
    setState(() {
      _isCalculatingGps = true;
      _statusMsg = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isCalculatingGps = false;
          _statusMsg = 'El GPS está desactivado. Usa el botón de Google Maps o elige una zona.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _isCalculatingGps = false;
          _statusMsg = 'Permiso de ubicación no concedido.';
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
        _isCalculatingGps = false;
        _statusMsg = 'Coordenadas GPS exactas calculadas (${_lat.toStringAsFixed(5)}, ${_lng.toStringAsFixed(5)})';
      });
    } catch (e) {
      setState(() {
        _isCalculatingGps = false;
        _statusMsg = 'Coordenadas listas: ${_lat.toStringAsFixed(5)}, ${_lng.toStringAsFixed(5)}';
      });
    }
  }

  Future<void> _abrirEnGoogleMaps() async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$_lat,$_lng');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.pin_drop_rounded, color: widget.primaryColor, size: 24),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Ubicación de Entrega',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Text(
              'Calcula tu ubicación actual o ábrela en Google Maps para una entrega rápida y exacta.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),

            // Tarjeta de Ubicación + Botón GPS + Botón Google Maps
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubicación GPS seleccionada:',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_lat.toStringAsFixed(5)}, ${_lng.toStringAsFixed(5)}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isCalculatingGps ? null : _calcularGpsDispositivo,
                          icon: _isCalculatingGps
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.my_location, size: 17),
                          label: const Text(
                            'Calcular mi GPS',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: widget.primaryColor),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _abrirEnGoogleMaps,
                          icon: Icon(Icons.map_rounded, size: 17, color: widget.primaryColor),
                          label: Text(
                            'Abrir Google Maps',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              color: widget.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_statusMsg != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _statusMsg!,
                      style: TextStyle(fontSize: 12, color: widget.primaryColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),
            const Text(
              'Puntos rápidos de referencia:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('San Salvador (Centro)', style: TextStyle(fontSize: 11.5)),
                  onPressed: () => setState(() {
                    _lat = 13.69294;
                    _lng = -89.21819;
                    _refController.text = 'San Salvador, Centro Histórico';
                  }),
                ),
                ActionChip(
                  label: const Text('San Miguel', style: TextStyle(fontSize: 11.5)),
                  onPressed: () => setState(() {
                    _lat = 13.48333;
                    _lng = -88.18333;
                    _refController.text = 'San Miguel, Av. Roosevelt';
                  }),
                ),
                ActionChip(
                  label: const Text('Santa Tecla', style: TextStyle(fontSize: 11.5)),
                  onPressed: () => setState(() {
                    _lat = 13.67694;
                    _lng = -89.27972;
                    _refController.text = 'Santa Tecla, La Libertad';
                  }),
                ),
              ],
            ),

            const SizedBox(height: 14),
            Row(
              children: ['Casa', 'Trabajo', 'Negocio'].map((etiq) {
                final sel = _etiqueta == etiq;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(etiq),
                    selected: sel,
                    selectedColor: widget.primaryColor.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: sel ? widget.primaryColor : const Color(0xFF475569),
                    ),
                    onSelected: (_) => setState(() => _etiqueta = etiq),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _refController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Referencia corta (ej. Casa #14, portón verde)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  final newAddr = SavedAddressModel(
                    etiqueta: _etiqueta,
                    referencia: _refController.text.trim().isEmpty
                        ? 'Entrega por Coordenadas GPS'
                        : _refController.text.trim(),
                    latitud: _lat,
                    longitud: _lng,
                    esPrincipal: true,
                  );
                  final list = List<SavedAddressModel>.from(widget.savedAddresses);
                  list.removeWhere((a) => a.etiqueta == _etiqueta);
                  list.insert(0, newAddr);
                  widget.onAddressSaved(newAddr, list);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text(
                  'Guardar Coordenadas de Entrega',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3. Formulario de Ayuda y Recolección de Datos del Cliente (Conectado a MySQL /api/clientes)
class CustomerDataFormModal extends StatefulWidget {
  final Color primaryColor;
  final CustomerProfileModel profile;
  final SavedAddressModel currentAddress;
  final void Function(CustomerProfileModel updatedProfile) onSaved;

  const CustomerDataFormModal({
    super.key,
    required this.primaryColor,
    required this.profile,
    required this.currentAddress,
    required this.onSaved,
  });

  @override
  State<CustomerDataFormModal> createState() => _CustomerDataFormModalState();
}

class _CustomerDataFormModalState extends State<CustomerDataFormModal> {
  late TextEditingController _nombreCtrl;
  late TextEditingController _docCtrl;
  late TextEditingController _telCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _nrcCtrl;
  late TextEditingController _giroCtrl;
  late TextEditingController _consultaCtrl;
  late String _tipoPersona;
  late String _tipoDocumento;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.profile.nombre);
    _docCtrl = TextEditingController(text: widget.profile.numDocumento);
    _telCtrl = TextEditingController(text: widget.profile.telefono);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _nrcCtrl = TextEditingController(text: widget.profile.nrc ?? '');
    _giroCtrl = TextEditingController(text: widget.profile.giro ?? '');
    _consultaCtrl = TextEditingController();
    _tipoPersona = widget.profile.tipoPersona;
    _tipoDocumento = widget.profile.tipoDocumento;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _docCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    _nrcCtrl.dispose();
    _giroCtrl.dispose();
    _consultaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarEnNube() async {
    if (_nombreCtrl.text.trim().isEmpty || _telCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu nombre y teléfono.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updated = CustomerProfileModel(
      idCliente: widget.profile.idCliente,
      tipoPersona: _tipoPersona,
      nombre: _nombreCtrl.text.trim(),
      tipoDocumento: _tipoDocumento,
      numDocumento: _docCtrl.text.trim(),
      telefono: _telCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      nrc: _nrcCtrl.text.trim().isEmpty ? null : _nrcCtrl.text.trim(),
      giro: (widget.profile.giro != null && widget.profile.giro!.startsWith('PWD:'))
          ? widget.profile.giro
          : (_giroCtrl.text.trim().isEmpty
              ? (_consultaCtrl.text.trim().isEmpty ? null : _consultaCtrl.text.trim())
              : _giroCtrl.text.trim()),
    );

    final res = await ErpApiService.saveCustomerAndCoords(
      profile: updated,
      compactGpsAddress: widget.currentAddress.toCompactDbString(),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (res.idCliente > 0) {
      updated.idCliente = res.idCliente;
    }
    widget.onSaved(updated);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          res.success
              ? 'Tus datos han sido guardados correctamente.'
              : 'Datos guardados en tu dispositivo.',
        ),
        backgroundColor: widget.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.support_agent_rounded, color: widget.primaryColor, size: 26),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Atención al Cliente y Mis Datos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Text(
              'Actualiza tus datos de contacto o envíanos tu solicitud de ayuda.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nombreCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre Completo *',
                prefixIcon: const Icon(Icons.person_outline, size: 19),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _docCtrl,
                    decoration: InputDecoration(
                      labelText: 'DUI / Documento (Opcional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _telCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Teléfono / WhatsApp *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico (Opcional)',
                prefixIcon: const Icon(Icons.email_outlined, size: 19),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _consultaCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: '¿En qué podemos ayudarte hoy? (Opcional)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _isSaving ? null : _guardarEnNube,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline_rounded),
                label: Text(
                  _isSaving ? 'Guardando...' : 'Guardar mis Datos',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4. Personalizador del Banner de Llamado a la Acción (CTA)
class BannerCustomizerModal extends StatefulWidget {
  final BannerConfigModel currentBanner;
  final Color primaryColor;
  final void Function(BannerConfigModel updated) onSave;

  const BannerCustomizerModal({
    super.key,
    required this.currentBanner,
    required this.primaryColor,
    required this.onSave,
  });

  @override
  State<BannerCustomizerModal> createState() => _BannerCustomizerModalState();
}

class _BannerCustomizerModalState extends State<BannerCustomizerModal> {
  late TextEditingController _tituloCtrl;
  late TextEditingController _subtituloCtrl;
  late TextEditingController _botonCtrl;
  late TextEditingController _badgeCtrl;
  late bool _usarRosa;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.currentBanner.titulo);
    _subtituloCtrl = TextEditingController(text: widget.currentBanner.subtitulo);
    _botonCtrl = TextEditingController(text: widget.currentBanner.textoBoton);
    _badgeCtrl = TextEditingController(text: widget.currentBanner.etiquetaDescuento);
    _usarRosa = widget.currentBanner.usarTonoRosa;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _subtituloCtrl.dispose();
    _botonCtrl.dispose();
    _badgeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personalizar Banner y Paleta de Color',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Usar paleta Rosa PedidosYa (#E11D48)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              subtitle: const Text(
                'Alterna entre Verde Esmeralda CoreasERP y Rosa PedidosYa',
                style: TextStyle(fontSize: 12),
              ),
              value: _usarRosa,
              onChanged: (v) => setState(() => _usarRosa = v),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _badgeCtrl,
              decoration: InputDecoration(
                labelText: 'Etiqueta Superior (ej. HASTA 25% OFF)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _tituloCtrl,
              decoration: InputDecoration(
                labelText: 'Título Principal del Banner',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _subtituloCtrl,
              decoration: InputDecoration(
                labelText: 'Subtítulo / Descripción',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _botonCtrl,
              decoration: InputDecoration(
                labelText: 'Texto del Botón de Acción',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  widget.onSave(
                    BannerConfigModel(
                      titulo: _tituloCtrl.text.trim(),
                      subtitulo: _subtituloCtrl.text.trim(),
                      textoBoton: _botonCtrl.text.trim(),
                      etiquetaDescuento: _badgeCtrl.text.trim(),
                      usarTonoRosa: _usarRosa,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Aplicar Cambios', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
