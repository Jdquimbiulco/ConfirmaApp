import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/asistencia.dart';
import '../viewmodels/login_viewmodel.dart';
import '../services/certificado_service.dart';

class HistorialEventosScreen extends StatefulWidget {
  const HistorialEventosScreen({super.key});

  @override
  State<HistorialEventosScreen> createState() => _HistorialEventosScreenState();
}

class _HistorialEventosScreenState extends State<HistorialEventosScreen> {
  List<Asistencia> _asistencias = [];
  Map<String, Evento> _eventosMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = context.read<LoginViewModel>().currentUser;
    if (user == null) return;

    final attRepo = context.read<AttendanceRepository>();
    final evRepo = context.read<EventRepository>();

    // Mock only has getAsistenciasPorEvento, so we need getAsistenciasPorParticipante
    // Let's assume we implement it or we fetch all events and filter.
    // To be safe, we will fetch all events and for each, fetch attendance and filter by user.
    // This is because mock might not have it yet.
    
    final todosLosEventos = await evRepo.getEventos();
    List<Asistencia> misAsis = [];
    
    for (var ev in todosLosEventos) {
      final asisEv = await attRepo.getAsistenciasPorEvento(ev.id);
      final myAsis = asisEv.where((a) => a.participanteId == user.id).toList();
      misAsis.addAll(myAsis);
      _eventosMap[ev.id] = ev;
    }

    if (mounted) {
      setState(() {
        _asistencias = misAsis;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial y Certificados')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _asistencias.isEmpty
              ? const Center(child: Text('Aún no has asistido a ningún evento.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _asistencias.length,
                  itemBuilder: (context, index) {
                    final a = _asistencias[index];
                    final e = _eventosMap[a.eventoId];
                    if (e == null) return const SizedBox();

                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.verified, color: Colors.green, size: 40),
                        title: Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Asististe el: ${a.fechaHora.toString().substring(0, 10)}\nLugar: ${e.lugar}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          onPressed: () async {
                            final user = context.read<LoginViewModel>().currentUser!;
                            await CertificadoService.generarYMostrarCertificado(user, e.nombre);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
