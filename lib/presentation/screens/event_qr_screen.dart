import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../domain/entities/evento.dart';

class EventQrScreen extends StatelessWidget {
  final Evento evento;
  const EventQrScreen({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(evento.nombre)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Escanea este código\npara registrar tu asistencia', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)]),
                child: QrImageView(data: evento.id, version: QrVersions.auto, size: 300.0),
              ),
              const SizedBox(height: 32),
              const Text('Asegúrate de permitir el acceso al GPS y Cámara en tu teléfono.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
