import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../viewmodels/login_viewmodel.dart';

class DashboardParticipante extends StatelessWidget {
  const DashboardParticipante({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final user = viewModel.currentUser;

    if (user == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Entrada Digital')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hola, ${user.nombre}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Usa este código en eventos estrictos:', textAlign: TextAlign.center),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
                ),
                child: QrImageView(data: user.id, version: QrVersions.auto, size: 250.0),
              ),
              const SizedBox(height: 16),
              const Text('ID de Usuario', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
