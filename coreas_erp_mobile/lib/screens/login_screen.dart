import 'package:flutter/material.dart';
import '../models/erp_models.dart';
import '../services/api_service.dart';

class ClientLoginScreen extends StatefulWidget {
  final Color primaryColor;
  final bool isRoseTheme;
  final VoidCallback onToggleTheme;
  final void Function(CustomerProfileModel profile, SavedGpsAddress? gpsAddress) onLoginSuccess;

  const ClientLoginScreen({
    super.key,
    required this.primaryColor,
    required this.isRoseTheme,
    required this.onToggleTheme,
    required this.onLoginSuccess,
  });

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  bool _isRegisterMode = false;
  bool _loading = false;
  bool _obscureLoginPassword = true;
  bool _obscureRegPassword = true;
  bool _obscureRegConfirmPassword = true;

  // Controladores Login (Teléfono/Correo + Contraseña)
  final TextEditingController _loginIdentifierCtrl = TextEditingController();
  final TextEditingController _loginPasswordCtrl = TextEditingController();

  // Controladores Registro
  final TextEditingController _regNombreCtrl = TextEditingController();
  final TextEditingController _regTelefonoCtrl = TextEditingController();
  final TextEditingController _regEmailCtrl = TextEditingController();
  final TextEditingController _regPasswordCtrl = TextEditingController();
  final TextEditingController _regConfirmPasswordCtrl = TextEditingController();
  final TextEditingController _regDocCtrl = TextEditingController();
  final TextEditingController _regDireccionCtrl = TextEditingController();

  @override
  void dispose() {
    _loginIdentifierCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _regNombreCtrl.dispose();
    _regTelefonoCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPasswordCtrl.dispose();
    _regConfirmPasswordCtrl.dispose();
    _regDocCtrl.dispose();
    _regDireccionCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final input = _loginIdentifierCtrl.text.trim();
    final password = _loginPasswordCtrl.text;

    if (input.isEmpty) {
      _showMessage('Ingresa tu número de teléfono o correo electrónico.', isError: true);
      return;
    }
    if (password.isEmpty) {
      _showMessage('Por favor ingresa tu contraseña.', isError: true);
      return;
    }

    setState(() => _loading = true);

    final authRes = await ApiService.loginCustomerWithPassword(
      identifier: input,
      password: password,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (authRes.success && authRes.profile != null) {
      widget.onLoginSuccess(authRes.profile!, authRes.gpsAddress);
    } else {
      _showMessage(authRes.message, isError: true);
    }
  }

  Future<void> _handleRegister() async {
    final nombre = _regNombreCtrl.text.trim();
    final telefono = _regTelefonoCtrl.text.trim();
    final email = _regEmailCtrl.text.trim();
    final password = _regPasswordCtrl.text;
    final confirmPassword = _regConfirmPasswordCtrl.text;
    final doc = _regDocCtrl.text.trim();
    final direccionRef = _regDireccionCtrl.text.trim();

    if (nombre.isEmpty || telefono.isEmpty) {
      _showMessage('Por favor ingresa tu nombre completo y teléfono.', isError: true);
      return;
    }
    if (password.length < 6) {
      _showMessage('La contraseña debe tener al menos 6 caracteres.', isError: true);
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Las contraseñas no coinciden. Verifica por favor.', isError: true);
      return;
    }

    setState(() => _loading = true);

    final alreadyExists = await ApiService.customerAlreadyExists(telefono, email);
    if (!mounted) return;

    if (alreadyExists) {
      setState(() => _loading = false);
      _showMessage(
        'Ya existe una cuenta con ese teléfono o correo. Inicia sesión con tu contraseña.',
        isError: true,
      );
      return;
    }

    final newProfile = CustomerProfileModel(
      idCliente: 0,
      nombre: nombre,
      numDocumento: doc,
      telefono: telefono,
      email: email,
      tipoPersona: 'Natural',
      giro: ApiService.hashPassword(password),
    );

    SavedGpsAddress? initialAddress;
    String compactAddress = direccionRef;
    if (direccionRef.isNotEmpty) {
      initialAddress = SavedGpsAddress(
        etiqueta: 'Casa',
        latitud: 13.692940,
        longitud: -89.218191,
        referencia: direccionRef,
        esPrincipal: true,
      );
      compactAddress = initialAddress.toCompactDbString();
    }

    final res = await ApiService.saveCustomerAndCoords(
      profile: newProfile,
      compactGpsAddress: compactAddress,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (res.success) {
      newProfile.idCliente = res.idCliente;
      widget.onLoginSuccess(newProfile, initialAddress);
    } else {
      _showMessage(res.message, isError: true);
    }
  }

  void _showMessage(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? const Color(0xFFDC2626) : widget.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Fondo superior curvo con degradado elegante
          Container(
            height: MediaQuery.of(context).size.height * 0.42,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isRoseTheme
                    ? [const Color(0xFFE11D48), const Color(0xFF9F1239)]
                    : [const Color(0xFF15803D), const Color(0xFF14532D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(42),
                bottomRight: Radius.circular(42),
              ),
            ),
          ),

          // Círculos decorativos sutiles
          Positioned(
            top: -50,
            right: -40,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            top: 90,
            left: -60,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Contenedor del Logo Oficial Super Tienda Kenia
                  Container(
                    width: 265,
                    height: 145,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.16),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.shopping_bag_rounded,
                          size: 48,
                          color: c,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  const Text(
                    '¡Bienvenido a Super Tienda Kenia!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Tu Ahorro Campeón • Pedidos rápidos hasta tu puerta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tarjeta Blanca de Login / Registro
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.07),
                          blurRadius: 28,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Selector de Pestañas (Iniciar Sesión / Crear Cuenta)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isRegisterMode = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    decoration: BoxDecoration(
                                      color: !_isRegisterMode ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(11),
                                      boxShadow: !_isRegisterMode
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.05),
                                                blurRadius: 6,
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Iniciar Sesión',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13.5,
                                          color: !_isRegisterMode ? c : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isRegisterMode = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 11),
                                    decoration: BoxDecoration(
                                      color: _isRegisterMode ? Colors.white : Colors.transparent,
                                      borderRadius: BorderRadius.circular(11),
                                      boxShadow: _isRegisterMode
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.05),
                                                blurRadius: 6,
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Crear Cuenta',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13.5,
                                          color: _isRegisterMode ? c : const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        if (!_isRegisterMode) ...[
                          const Text(
                            'Ingresa con tu cuenta',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Escribe tu teléfono o correo y tu contraseña para continuar.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 18),
                          _buildInputField(
                            controller: _loginIdentifierCtrl,
                            label: 'Teléfono o Correo electrónico',
                            hint: 'Ej. 7777-8888 o correo@ejemplo.com',
                            icon: Icons.phone_android_rounded,
                            primaryColor: c,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: _loginPasswordCtrl,
                            label: 'Contraseña',
                            hint: 'Ingresa tu contraseña',
                            icon: Icons.lock_outline_rounded,
                            primaryColor: c,
                            obscureText: _obscureLoginPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureLoginPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: const Color(0xFF64748B),
                              ),
                              onPressed: () {
                                setState(() => _obscureLoginPassword = !_obscureLoginPassword);
                              },
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: c,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Ingresar a la Tienda',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Regístrate en segundos',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Crea tu cuenta con contraseña segura para realizar tus pedidos.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: _regNombreCtrl,
                            label: 'Nombre completo *',
                            hint: 'Tu nombre y apellido',
                            icon: Icons.person_outline_rounded,
                            primaryColor: c,
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            controller: _regTelefonoCtrl,
                            label: 'Teléfono / WhatsApp *',
                            hint: 'Ej. 7000-0000',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            primaryColor: c,
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            controller: _regEmailCtrl,
                            label: 'Correo electrónico (Opcional)',
                            hint: 'cliente@correo.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            primaryColor: c,
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            controller: _regPasswordCtrl,
                            label: 'Contraseña * (mínimo 6 caracteres)',
                            hint: 'Crea una contraseña segura',
                            icon: Icons.lock_outline_rounded,
                            primaryColor: c,
                            obscureText: _obscureRegPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureRegPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: const Color(0xFF64748B),
                              ),
                              onPressed: () {
                                setState(() => _obscureRegPassword = !_obscureRegPassword);
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            controller: _regConfirmPasswordCtrl,
                            label: 'Confirmar contraseña *',
                            hint: 'Repite tu contraseña',
                            icon: Icons.verified_user_outlined,
                            primaryColor: c,
                            obscureText: _obscureRegConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureRegConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                                color: const Color(0xFF64748B),
                              ),
                              onPressed: () {
                                setState(() => _obscureRegConfirmPassword = !_obscureRegConfirmPassword);
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            controller: _regDocCtrl,
                            label: 'DUI / Documento (Opcional)',
                            hint: '00000000-0',
                            icon: Icons.badge_outlined,
                            primaryColor: c,
                          ),
                          const SizedBox(height: 12),
                          _buildInputField(
                            controller: _regDireccionCtrl,
                            label: 'Dirección o punto de referencia',
                            hint: 'Colonia, calle, número de casa...',
                            icon: Icons.location_on_outlined,
                            primaryColor: c,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: c,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Crear mi Cuenta y Entrar',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color primaryColor,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, color: primaryColor, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
