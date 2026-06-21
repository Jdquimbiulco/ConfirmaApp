import '../entities/inscripcion.dart';

abstract class EnrollmentRepository {
  Future<void> inscribirParticipante(String eventoId, String participanteId);
  Future<List<Inscripcion>> getInscripcionesPorEvento(String eventoId);
  Future<List<Inscripcion>> getInscripcionesPorParticipante(String participanteId);
  Future<bool> estaInscrito(String eventoId, String participanteId);
}
