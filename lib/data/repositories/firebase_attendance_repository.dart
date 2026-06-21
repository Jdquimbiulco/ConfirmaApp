import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../../domain/entities/asistencia.dart';

class FirebaseAttendanceRepository implements AttendanceRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Asistencia _fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Asistencia(
      id: doc.id,
      eventoId: data['eventoId'] ?? '',
      participanteId: data['participanteId'] ?? '',
      fechaHora: data['fechaHora'] != null ? (data['fechaHora'] as Timestamp).toDate() : DateTime.now(),
      ubicacionValida: data['ubicacionValida'] ?? false,
    );
  }

  @override
  Future<void> registrarAsistencia(Asistencia asistencia) async {
    final existing = await _firestore.collection('asistencias')
      .where('eventoId', isEqualTo: asistencia.eventoId)
      .where('participanteId', isEqualTo: asistencia.participanteId)
      .get();
      
    if (existing.docs.isNotEmpty) {
      throw Exception('Ya tienes asistencia registrada para este evento.');
    }

    await _firestore.collection('asistencias').doc(asistencia.id).set({
      'eventoId': asistencia.eventoId,
      'participanteId': asistencia.participanteId,
      'fechaHora': FieldValue.serverTimestamp(),
      'ubicacionValida': asistencia.ubicacionValida,
    });
  }

  @override
  Future<List<Asistencia>> getAsistenciasPorEvento(String eventoId) async {
    final snap = await _firestore.collection('asistencias').where('eventoId', isEqualTo: eventoId).get();
    return snap.docs.map(_fromFirestore).toList();
  }
}
