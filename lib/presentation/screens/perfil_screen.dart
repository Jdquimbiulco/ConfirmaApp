import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/usuario.dart';
import '../viewmodels/login_viewmodel.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'tomar_selfie_screen.dart';
import 'login_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final user = viewModel.currentUser;

    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50, 
              backgroundImage: user.fotoBiometriaUrl != null ? NetworkImage(user.fotoBiometriaUrl!) : null,
              child: user.fotoBiometriaUrl == null ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 16),
            Text(user.nombre, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(user.email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            if (user.rol == RolUsuario.participante) ...[
              FilledButton.icon(
                onPressed: () => _mostrarQr(context, user),
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Mostrar Mi Código QR (Pase)'),
              ),
              const SizedBox(height: 32),
              ListTile(
                leading: Icon(user.biometriaRegistrada ? Icons.check_circle : Icons.warning, color: user.biometriaRegistrada ? Colors.green : Colors.orange),
                title: const Text('Registro Biométrico (Selfie)'),
                subtitle: Text(user.biometriaRegistrada ? 'Completado' : 'Requerido para asistir a eventos'),
                trailing: user.biometriaRegistrada ? null : FilledButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const TomarSelfieScreen()));
                  },
                  child: const Text('Registrar'),
                ),
              ),
              const Divider(),
            ],

            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await context.read<AuthRepository>().logout();
                if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarQr(BuildContext context, Usuario user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tu Código de Acceso', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: QrImageView(data: user.id, size: 200),
            ),
            const SizedBox(height: 16),
            const Text('Muestra este código al Organizador en eventos Estrictos.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar'))],
      ),
    );
  }
}
