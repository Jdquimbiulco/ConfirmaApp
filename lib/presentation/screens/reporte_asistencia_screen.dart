import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/asistencia.dart';
import '../../domain/entities/inscripcion.dart';

class ReporteAsistenciaScreen extends StatefulWidget {
  final Evento evento;
  const ReporteAsistenciaScreen({super.key, required this.evento});

  @override
  State<ReporteAsistenciaScreen> createState() => _ReporteAsistenciaScreenState();
}

class _ReporteAsistenciaScreenState extends State<ReporteAsistenciaScreen> {
  List<Asistencia> _asistencias = [];
  List<Inscripcion> _inscripciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    final attRepo = context.read<AttendanceRepository>();
    final enrRepo = context.read<EnrollmentRepository>();
    
    final att = await attRepo.getAsistenciasPorEvento(widget.evento.id);
    final enr = await enrRepo.getInscripcionesPorEvento(widget.evento.id);
    
    if (mounted) {
      setState(() {
        _asistencias = att;
        _inscripciones = enr;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Reporte: ${widget.evento.nombre}'),
          bottom: const TabBar(tabs: [Tab(text: 'General'), Tab(text: 'Individual')]),
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              children: [
                _buildReporteGeneral(),
                _buildReporteIndividual(),
              ],
            ),
      ),
    );
  }

  Widget _buildReporteGeneral() {
    int inscritos = _inscripciones.length;
    int asistentes = _asistencias.length;
    int ausentes = inscritos - asistentes;
    if (ausentes < 0) ausentes = 0;
    double porcentaje = inscritos > 0 ? (asistentes / inscritos) * 100 : 0;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Estadísticas en Tiempo Real', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('${porcentaje.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const Text('Porcentaje de Asistencia'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(title: const Text('Total Inscritos'), trailing: Text('$inscritos', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          ListTile(title: const Text('Asistentes (Presentes)'), trailing: Text('$asistentes', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green))),
          ListTile(title: const Text('Ausentes'), trailing: Text('$ausentes', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildReporteIndividual() {
    if (_asistencias.isEmpty) return const Center(child: Text('Aún no hay asistencias registradas.'));
    
    return ListView.builder(
      itemCount: _asistencias.length,
      itemBuilder: (context, index) {
        final asis = _asistencias[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: asis.ubicacionValida ? Colors.green : Colors.orange,
            child: Icon(asis.ubicacionValida ? Icons.check : Icons.warning, color: Colors.white),
          ),
          title: Text('Participante ID: ${asis.participanteId.substring(0,8)}...'),
          subtitle: Text('Hora Ingreso: ${asis.fechaHora.toString().substring(11, 16)}\nEstado: ${asis.ubicacionValida ? 'Validado' : 'Fuera Rango GPS'}'),
          trailing: const Icon(Icons.face, color: Colors.blue),
        );
      },
    );
  }
}
