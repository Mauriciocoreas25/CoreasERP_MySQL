import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/erp_models.dart';

class ProfileScreen extends StatefulWidget {
  final CustomerProfileModel customerProfile;
  final SavedAddressModel currentAddress;
  final List<VentaHistorialModel> historialPedidos;
  final Color primaryColor;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenAddressPicker;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.customerProfile,
    required this.currentAddress,
    required this.historialPedidos,
    required this.primaryColor,
    required this.onEditProfile,
    required this.onOpenAddressPicker,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Puntos ahorro calculados dinámicamente: 1 punto por cada $1 en compras registradas
  int get _puntosAhorro {
    double totalSpent = 0.0;
    for (final v in widget.historialPedidos) {
      final e = v.estado.toLowerCase();
      if (!e.contains('cancel') && !e.contains('anula')) {
        totalSpent += v.total;
      }
    }
    // Mínimo de bienvenida si es nuevo usuario
    final pts = totalSpent.toInt();
    return pts > 0 ? pts : 50;
  }

  void _showInfoDialog(String title, String message, IconData icon) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: widget.primaryColor, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Aceptar',
              style: TextStyle(color: widget.primaryColor, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  void _openHelpSupport() async {
    const phone = '7007-9140';
    final url = Uri.parse('https://wa.me/50370079140?text=Hola,%20necesito%20asistencia%20con%20la%20app%20móvil%20de%20Super%20Tienda%20Kenia');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        _showInfoDialog('Atención al Cliente', 'Contáctanos directamente al teléfono $phone.', Icons.headset_mic_outlined);
      }
    } catch (_) {
      if (!mounted) return;
      _showInfoDialog('Atención al Cliente', 'Contáctanos directamente al teléfono $phone.', Icons.headset_mic_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.primaryColor;
    final profile = widget.customerProfile;
    final displayName = profile.nombre.isNotEmpty ? profile.nombre : 'Cliente Registrado';
    final initialLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: c,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Configuración',
            onPressed: () {
              _showInfoDialog(
                'Configuración del Sistema',
                'Versión 1.1.0 (Build 2026).\nSuper Tienda Kenia - CoreasERP Cloud conectado.',
                Icons.settings_outlined,
              );
            },
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        children: [
          // 1. Tarjeta de Usuario con Avatar y Lápiz de Edición (Screenshot 4)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: c.withValues(alpha: 0.15),
                      child: Text(
                        initialLetter,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: c,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: widget.onEditProfile,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (profile.email.isNotEmpty)
                        Text(
                          profile.email,
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                        ),
                      if (profile.telefono.isNotEmpty)
                        Text(
                          profile.telefono,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: c,
                          side: BorderSide(color: c.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          minimumSize: const Size(0, 32),
                        ),
                        onPressed: widget.onEditProfile,
                        icon: const Icon(Icons.edit_outlined, size: 14),
                        label: const Text(
                          'Editar Perfil',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Tarjeta de Fidelización / Puntos Ahorro (Screenshot 4)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD97706).withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.stars_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Puntos Ahorro: $_puntosAhorro pts',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'NIVEL ORO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gana 1 punto por cada \$1 en tus compras y canjéalos por cupones de descuento.',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFFB45309),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () {
                          _showInfoDialog(
                            'Beneficios de Puntos',
                            'Tus $_puntosAhorro puntos te otorgan beneficios exclusivos:\n- Descuentos en productos seleccionados.\n- Envíos prioritarios a domicilio.\n- Promociones 2x1 exclusivas.',
                            Icons.card_giftcard_rounded,
                          );
                        },
                        child: const Text(
                          'Ver beneficios',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () {
                          _showInfoDialog(
                            'Canjear Puntos',
                            'Puedes canjear tus puntos directamente al momento de confirmar tu pedido en caja o carrito.',
                            Icons.discount_outlined,
                          );
                        },
                        child: const Text(
                          'Canjear puntos',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 3. Lista de Opciones del Perfil (Screenshot 4)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                _buildMenuTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Mis Datos',
                  subtitle: 'Nombre, DUI, teléfono y contacto',
                  onTap: widget.onEditProfile,
                  primaryColor: c,
                ),
                _buildDivider(),
                _buildMenuTile(
                  icon: Icons.location_on_outlined,
                  title: 'Direcciones de Envío',
                  subtitle: widget.currentAddress.referencia.isNotEmpty
                      ? widget.currentAddress.referencia
                      : 'Ubicación GPS para tus pedidos',
                  onTap: widget.onOpenAddressPicker,
                  primaryColor: c,
                ),
                _buildDivider(),
                _buildMenuTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Métodos de Pago',
                  subtitle: 'Efectivo contra entrega y transferencias',
                  onTap: () {
                    _showInfoDialog(
                      'Métodos de Pago',
                      'Super Tienda Kenia acepta:\n- Efectivo contra entrega (al recibir tu pedido o en caja).\n- Pagos con cambio exacto.',
                      Icons.credit_card_outlined,
                    );
                  },
                  primaryColor: c,
                ),
                _buildDivider(),
                _buildMenuTile(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Cupones y Descuentos',
                  subtitle: 'Consulta tus cupones activos',
                  onTap: () {
                    _showInfoDialog(
                      'Cupones Activos',
                      'No tienes cupones vencidos. Mantente atento a las notificaciones para cupones sorpresa de temporada.',
                      Icons.confirmation_number_outlined,
                    );
                  },
                  primaryColor: c,
                ),
                _buildDivider(),
                _buildMenuTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notificaciones',
                  subtitle: 'Avisos de estado de tus pedidos',
                  onTap: () {
                    _showInfoDialog(
                      'Notificaciones',
                      'Las alertas de cambio de estado de pedidos (Confirmado, Preparado, En camino, Entregado) están activas.',
                      Icons.notifications_active_outlined,
                    );
                  },
                  primaryColor: c,
                ),
                _buildDivider(),
                _buildMenuTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Seguridad y Contraseña',
                  subtitle: 'Administra la clave de tu cuenta',
                  onTap: () {
                    _showInfoDialog(
                      'Seguridad de la Cuenta',
                      'Tu contraseña está protegida con cifrado SHA-256 en la nube. Si deseas cambiarla, contacta con soporte o edita tus datos.',
                      Icons.lock_outline_rounded,
                    );
                  },
                  primaryColor: c,
                ),
                _buildDivider(),
                _buildMenuTile(
                  icon: Icons.headset_mic_outlined,
                  title: 'Ayuda y Soporte',
                  subtitle: 'Atención personalizada por WhatsApp',
                  onTap: _openHelpSupport,
                  primaryColor: c,
                ),
                _buildDivider(),
                _buildMenuTile(
                  icon: Icons.description_outlined,
                  title: 'Términos y Políticas',
                  subtitle: 'Condiciones de servicio y privacidad',
                  onTap: () {
                    _showInfoDialog(
                      'Términos y Políticas',
                      'Tus datos personales y de ubicación son utilizados exclusivamente para la entrega y facturación de tus compras en Super Tienda Kenia.',
                      Icons.policy_outlined,
                    );
                  },
                  primaryColor: c,
                ),
                _buildDivider(),
                _buildMenuTile(
                  icon: Icons.logout_rounded,
                  title: 'Cerrar sesión',
                  subtitle: 'Salir de tu cuenta en este dispositivo',
                  isDestructive: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text('¿Cerrar sesión?'),
                        content: const Text('¿Estás seguro de que deseas salir de tu cuenta?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onLogout();
                            },
                            child: const Text('Cerrar sesión'),
                          ),
                        ],
                      ),
                    );
                  },
                  primaryColor: c,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color primaryColor,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? const Color(0xFFDC2626) : const Color(0xFF0F172A);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: isDestructive
                    ? const Color(0xFFFEE2E2)
                    : primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isDestructive ? const Color(0xFFDC2626) : primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 60, color: Color(0xFFF1F5F9));
  }
}
