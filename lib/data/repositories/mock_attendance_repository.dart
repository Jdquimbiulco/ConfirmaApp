import '../../domain/entities/asistencia.dart';
import '../../domain/repositories/attendance_repository.dart';

class MockAttendanceRepository implements AttendanceRepository {
  final List<Asistencia> _asistencias = [];

  @override
  Future<void> registrarAsistencia(Asistencia asistencia) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _asistencias.add(asistencia);
  }

  @override
  Future<List<Asistencia>> getAsistenciasPorEvento(String eventoId) async {
    return _asistencias.where((a) => a.eventoId == eventoId).toList();
  }
}
