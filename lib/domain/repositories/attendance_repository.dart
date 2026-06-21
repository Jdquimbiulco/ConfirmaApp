import '../entities/asistencia.dart';

abstract class AttendanceRepository {
  Future<void> registrarAsistencia(Asistencia asistencia);
  Future<List<Asistencia>> getAsistenciasPorEvento(String eventoId);
}
