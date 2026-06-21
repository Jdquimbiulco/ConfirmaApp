import 'package:uuid/uuid.dart';
import '../../domain/entities/inscripcion.dart';
import '../../domain/repositories/enrollment_repository.dart';

class MockEnrollmentRepository implements EnrollmentRepository {
  final List<Inscripcion> _inscripciones = [];

  @override
  Future<void> inscribirParticipante(String eventoId, String participanteId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (await estaInscrito(eventoId, participanteId)) {
      throw Exception('Ya estás inscrito en este evento.');
    }
    _inscripciones.add(Inscripcion(
      id: const Uuid().v4(),
      eventoId: eventoId,
      participanteId: participanteId,
      fechaInscripcion: DateTime.now(),
    ));
  }

  @override
  Future<List<Inscripcion>> getInscripcionesPorEvento(String eventoId) async {
    return _inscripciones.where((i) => i.eventoId == eventoId).toList();
  }

  @override
  Future<List<Inscripcion>> getInscripcionesPorParticipante(String participanteId) async {
    return _inscripciones.where((i) => i.participanteId == participanteId).toList();
  }

  @override
  Future<bool> estaInscrito(String eventoId, String participanteId) async {
    return _inscripciones.any((i) => i.eventoId == eventoId && i.participanteId == participanteId);
  }
}
