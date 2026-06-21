import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../../domain/entities/evento.dart';
import '../../domain/entities/inscripcion.dart';

class ParticipantesInscritosScreen extends StatefulWidget {
  final Evento evento;
  const ParticipantesInscritosScreen({super.key, required this.evento});

  @override
  State<ParticipantesInscritosScreen> createState() => _ParticipantesInscritosScreenState();
}

class _ParticipantesInscritosScreenState extends State<ParticipantesInscritosScreen> {
  List<Inscripcion> _inscripciones = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = context.read<EnrollmentRepository>();
    final insc = await repo.getInscripcionesPorEvento(widget.evento.id);
    if (mounted) {
      setState(() {
        _inscripciones = insc;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Participantes Inscritos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.shade50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Inscritos:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${_inscripciones.length} / ${widget.evento.cupos}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                    ],
                  ),
                ),
                Expanded(
                  child: _inscripciones.isEmpty
                      ? const Center(child: Text('Aún no hay inscritos.'))
                      : ListView.builder(
                          itemCount: _inscripciones.length,
                          itemBuilder: (context, index) {
                            final i = _inscripciones[index];
                            return ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.person)),
                              title: Text('Usuario ID: ${i.participanteId.substring(0, 8)}...'),
                              subtitle: Text('Fecha Inscripción: ${i.fechaInscripcion.toString().substring(0, 16)}'),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
