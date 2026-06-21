import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../../domain/entities/evento.dart';
import '../viewmodels/login_viewmodel.dart';
import 'scanner_screen.dart';
import 'reporte_asistencia_screen.dart';
import 'event_qr_screen.dart';
import 'crear_evento_screen.dart';
import 'participantes_inscritos_screen.dart';

class DashboardOrganizador extends StatefulWidget {
  const DashboardOrganizador({super.key});

  @override
  State<DashboardOrganizador> createState() => DashboardOrganizadorState();
}

class DashboardOrganizadorState extends State<DashboardOrganizador> {
  List<Evento> _eventos = [];
  Map<String, int> _inscritosPorEvento = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEventos();
  }

  Future<void> reloadEventos() async {
    await _loadEventos();
  }

  Future<void> _loadEventos() async {
    final user = context.read<LoginViewModel>().currentUser;
    if (user == null) return;
    
    try {
      final events = await context.read<EventRepository>().getEventos();
      // Solo mostramos los eventos que le pertenecen a este organizador
      final misEventos = events.where((e) => e.organizadorId == user.id || e.organizadorId.isEmpty).toList();

      final enrollmentRepo = context.read<EnrollmentRepository>();
      Map<String, int> inscritosMap = {};
      for (var e in misEventos) {
        final inscripciones = await enrollmentRepo.getInscripcionesPorEvento(e.id);
        inscritosMap[e.id] = inscripciones.length;
      }

      if (mounted) {
        setState(() {
          _eventos = misEventos;
          _inscritosPorEvento = inscritosMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _eliminar(Evento evento) async {
    final conf = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Evento'),
        content: Text('¿Seguro que deseas eliminar "${evento.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
        ],
      )
    );

    if (conf == true && mounted) {
      await context.read<EventRepository>().eliminarEvento(evento.id);
      _loadEventos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Eventos')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _eventos.length,
            itemBuilder: (context, index) {
              final evento = _eventos[index];
              final isRelaxed = evento.nivelControl == NivelControl.relajado;
              final inscritos = _inscritosPorEvento[evento.id] ?? 0;
              final cuposDisponibles = evento.cupos - inscritos;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(evento.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text('${evento.fecha.toString().substring(0,10)} - ${evento.hora}\n${evento.lugar}\nCupos Disponibles: $cuposDisponibles / ${evento.cupos}'),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (val) async {
                          if (val == 'edit') {
                            final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => CrearEventoScreen(eventoAEditar: evento)));
                            if (res == true) _loadEventos();
                          } else if (val == 'delete') {
                            _eliminar(evento);
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'edit', child: Text('Editar')),
                          const PopupMenuItem(value: 'delete', child: Text('Eliminar', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Chip(
                            label: Text(isRelaxed ? 'Auto-Servicio' : 'Estricto', style: const TextStyle(fontSize: 12)),
                            backgroundColor: isRelaxed ? Colors.green.shade100 : Colors.red.shade100,
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text('Inscritos: $inscritos', style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.blue.shade100,
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ParticipantesInscritosScreen(evento: evento))),
                            icon: const Icon(Icons.people),
                            label: const Text('Inscritos'),
                          ),
                          TextButton.icon(
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReporteAsistenciaScreen(evento: evento))),
                            icon: const Icon(Icons.analytics),
                            label: const Text('Reporte'),
                          ),
                          if (isRelaxed)
                            FilledButton.icon(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventQrScreen(evento: evento))),
                              icon: const Icon(Icons.qr_code_2),
                              label: const Text('QR Evento'),
                            )
                          else
                            FilledButton.icon(
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ScannerScreen(evento: evento))),
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text('Escanear'),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
    );
  }
}
