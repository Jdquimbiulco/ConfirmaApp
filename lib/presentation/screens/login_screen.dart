import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart';
import '../../domain/entities/usuario.dart';
import '../layouts/main_layout_organizador.dart';
import '../layouts/main_layout_participante.dart';
import 'tomar_selfie_screen.dart';

// ─── Colores ──────────────────────────────────────────────────────────────────
const _kNavy = Color(0xFF0D1B3E);
const _kNavyMd = Color(0xFF1A2F5E);
const _kSilver = Color(0xFFC8CDD8);
const _kGrayMid = Color(0xFF6B7280);
const _kError = Color(0xFFDC2626);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();

  bool _isLogin = true;
  bool _obscurePass = true;
  RolUsuario _rol = RolUsuario.participante;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nombreCtrl.dispose();
    super.dispose();
  }

  void _goByRole(RolUsuario rol) => Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => rol == RolUsuario.organizador
          ? const MainLayoutOrganizador()
          : const MainLayoutParticipante(),
    ),
  );

  void _showError(String msg) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: _kError));

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<LoginViewModel>();
    try {
      if (_isLogin) {
        await vm.login(_emailCtrl.text.trim(), _passCtrl.text.trim());
      } else {
        await vm.register(
          _emailCtrl.text.trim(),
          _passCtrl.text.trim(),
          _nombreCtrl.text.trim(),
          _rol,
        );
        if (_rol == RolUsuario.participante && mounted) {
          final ok = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text('¡Registro Exitoso!'),
              content: const Text(
                'Para eventos de nivel "Estricto" necesitas registrar tu rostro.\n'
                '¿Deseas hacerlo ahora?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Más tarde'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Registrar ahora'),
                ),
              ],
            ),
          );
          if (ok == true && mounted) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TomarSelfieScreen()),
            );
          }
        }
      }
      if (vm.currentUser != null && mounted) _goByRole(vm.currentUser!.rol);
    } catch (_) {
      if (mounted) _showError(vm.errorMessage ?? 'Error desconocido');
    }
  }

  void _loginGoogle() async {
    final vm = context.read<LoginViewModel>();
    await vm.loginWithGoogle();
    if (!mounted) return;
    if (vm.currentUser != null) {
      _goByRole(vm.currentUser!.rol);
    } else if (vm.errorMessage != null) {
      _showError(vm.errorMessage!);
    }
  }

  InputDecoration _deco({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(fontSize: 15, color: _kGrayMid),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    prefixIcon: Icon(icon, color: _kGrayMid, size: 20),
    suffixIcon: suffix,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kSilver, width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kSilver, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kNavy, width: 1.8),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kError, width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kError, width: 1.8),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ────────────────────────────────────────────────
                  const SizedBox(height: 48),
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.60),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.event_available_rounded,
                        size: 48,
                        color: _kNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'ConfirmaApp',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: _kNavy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      _isLogin
                          ? '¡Bienvenido a tu app de eventos!'
                          : 'Crea tu cuenta',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: _kNavy,
                      ),
                    ),
                  ),

                  // ── Campos ────────────────────────────────────────────────
                  const SizedBox(height: 40),

                  if (!_isLogin) ...[
                    TextFormField(
                      controller: _nombreCtrl,
                      textCapitalization: TextCapitalization.words,
                      style: GoogleFonts.inter(fontSize: 15, color: _kNavy),
                      decoration: _deco(
                        hint: 'Nombre completo',
                        icon: Icons.person_outline_rounded,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa tu nombre'
                          : null,
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.inter(fontSize: 15, color: _kNavy),
                    decoration: _deco(
                      hint: 'correo@ejemplo.com',
                      icon: Icons.email_outlined,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Ingresa tu correo';
                      if (!RegExp(
                        r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$',
                      ).hasMatch(v.trim()))
                        return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscurePass,
                    style: GoogleFonts.inter(fontSize: 15, color: _kNavy),
                    decoration: _deco(
                      hint: 'Contraseña',
                      icon: Icons.lock_outline_rounded,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: _kGrayMid,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Ingresa tu contraseña';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),

                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<RolUsuario>(
                      value: _rol,
                      style: GoogleFonts.inter(fontSize: 15, color: _kNavy),
                      decoration: _deco(
                        hint: 'Selecciona tu rol',
                        icon: Icons.badge_outlined,
                      ),
                      items: RolUsuario.values
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r == RolUsuario.organizador
                                    ? 'Organizador'
                                    : 'Participante',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: _kNavy,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _rol = v!),
                    ),
                  ],

                  if (_isLogin) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '¿Olvidaste tu contraseña?',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _kNavyMd,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],

                  // ── Botón primario ─────────────────────────────────────────
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: vm.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kNavy,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: _kNavy.withOpacity(0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: vm.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isLogin
                                      ? Icons.event_available_outlined
                                      : Icons.person_add_outlined,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isLogin ? 'Iniciar Sesión' : 'Registrarse',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  // ── Divider + Google ───────────────────────────────────────
                  if (_isLogin) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: _kSilver, thickness: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'ó',
                            style: GoogleFonts.inter(
                              color: _kGrayMid,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: _kSilver, thickness: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: vm.isLoading ? null : _loginGoogle,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _kNavy,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: _kSilver, width: 1.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/google_logo.png',
                              width: 22,
                              height: 22,
                              errorBuilder: (_, __, ___) => const Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Continuar con Google',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: _kNavy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ── Footer ─────────────────────────────────────────────────
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? '¿No tienes cuenta?  '
                            : '¿Ya tienes cuenta?  ',
                        style: GoogleFonts.inter(
                          color: _kGrayMid,
                          fontSize: 13,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() {
                          _isLogin = !_isLogin;
                          _formKey.currentState?.reset();
                        }),
                        child: Text(
                          _isLogin ? 'Regístrate ahora' : 'Inicia Sesión',
                          style: GoogleFonts.inter(
                            color: _kNavy,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: _kNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
    );
  }
}
