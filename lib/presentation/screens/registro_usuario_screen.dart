import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/usuario.dart';

class RegistroUsuarioScreen extends StatefulWidget {
  const RegistroUsuarioScreen({super.key});

  @override
  State<RegistroUsuarioScreen> createState() => _RegistroUsuarioScreenState();
}

class _RegistroUsuarioScreenState extends State<RegistroUsuarioScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  RolUsuario _rolSeleccionado = RolUsuario.participante;
  bool _isLoading = false;

  void _registrar() async {
    setState(() { _isLoading = true; });
    try {
      final repo = context.read<AuthRepository>();
      final nuevoUsuario = Usuario(
        id: const Uuid().v4(),
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        rol: _rolSeleccionado,
      );

      await repo.registrarUsuario(nuevoUsuario, _passwordController.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado con éxito. Ahora puedes iniciar sesión.'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Volver al login
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre Completo', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Correo electrónico', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RolUsuario>(
              value: _rolSeleccionado,
              decoration: const InputDecoration(labelText: 'Rol', border: OutlineInputBorder()),
              items: RolUsuario.values.map((rol) {
                return DropdownMenuItem(
                  value: rol,
                  child: Text(rol.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() { _rolSeleccionado = val; });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: _isLoading ? null : _registrar,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Crear Cuenta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
