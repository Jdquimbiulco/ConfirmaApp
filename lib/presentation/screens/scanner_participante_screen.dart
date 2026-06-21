import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/entities/asistencia.dart';
import '../viewmodels/login_viewmodel.dart';
import 'face_validation_screen.dart';

class ScannerParticipanteScreen extends StatefulWidget {
  const ScannerParticipanteScreen({super.key});

  @override
  State<ScannerParticipanteScreen> createState() => _ScannerParticipanteScreenState();
}

class _ScannerParticipanteScreenState extends State<ScannerParticipanteScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  Future<void> _handleScan(String? eventoId) async {
    if (eventoId == null || _isProcessing) return;
    setState(() { _isProcessing = true; });

    try {
      final user = context.read<LoginViewModel>().currentUser;
      if (user == null) throw Exception('Usuario no autenticado');
      if (!user.biometriaRegistrada) throw Exception('Debes registrar tu biometría facial en tu Perfil primero.');

      final eventRepo = context.read<EventRepository>();
      final evento = await eventRepo.getEventoById(eventoId);
      if (evento == null) throw Exception('Código QR no corresponde a un evento válido');

      // 1. Validar GPS
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Servicios de ubicación deshabilitados');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) throw Exception('Permisos de ubicación denegados');
      }

      Position position = await Geolocator.getCurrentPosition();
      double distanceInMeters = Geolocator.distanceBetween(
        evento.latitud, evento.longitud, position.latitude, position.longitude
      );
      bool ubicacionValida = distanceInMeters <= evento.radioToleranciaMetros;

      if (!mounted) return;

      // 2. FaceValidation (Selfie)
      cameraController.stop();
      final faceValid = await Navigator.push(context, MaterialPageRoute(builder: (_) => const FaceValidationScreen(useFrontCamera: true)));
      
      if (faceValid != true) {
        cameraController.start();
        throw Exception('Validación facial cancelada o fallida');
      }
      cameraController.start();

      if (!mounted) return;
      final repo = context.read<AttendanceRepository>();
      final asistencia = Asistencia(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        eventoId: evento.id,
        participanteId: user.id,
        fechaHora: DateTime.now(),
        ubicacionValida: ubicacionValida,
      );

      await repo.registrarAsistencia(asistencia);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ubicacionValida ? '✅ Asistencia Registrada con Éxito' : '⚠️ Asistencia guardada, pero ubicación fuera de rango.'),
        backgroundColor: ubicacionValida ? Colors.green : Colors.orange, duration: const Duration(seconds: 4),
      ));
      await Future.delayed(const Duration(seconds: 3));

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'), backgroundColor: Colors.red));
      await Future.delayed(const Duration(seconds: 2));
    } finally {
      if (mounted) setState(() { _isProcessing = false; });
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Asistencia')),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
                _handleScan(barcode.rawValue);
              }
            },
          ),
          Center(
            child: Container(
              width: 250, height: 250,
              decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent, width: 4), borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const Positioned(
            bottom: 40, left: 0, right: 0,
            child: Text('Apunta al código QR del Evento', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, shadows: [Shadow(blurRadius: 10, color: Colors.black)])),
          ),
          if (_isProcessing)
            Container(color: Colors.black87, child: const Center(child: CircularProgressIndicator(color: Colors.white))),
        ],
      ),
    );
  }
}
