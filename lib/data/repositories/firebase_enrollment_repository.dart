import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../domain/repositories/enrollment_repository.dart';
import '../../domain/entities/inscripcion.dart';

class FirebaseEnrollmentRepository implements EnrollmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Inscripcion _fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Inscripcion(
      id: doc.id,
      eventoId: data['eventoId'] ?? '',
      participanteId: data['participanteId'] ?? '',
      fechaInscripcion: data['fechaInscripcion'] != null ? (data['fechaInscripcion'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  @override
  Future<void> inscribirParticipante(String eventoId, String participanteId) async {
    if (await estaInscrito(eventoId, participanteId)) {
      throw Exception('Ya estás inscrito en este evento.');
    }
    
    final eventoDoc = await _firestore.collection('eventos').doc(eventoId).get();
    if (eventoDoc.exists) {
       final cupos = eventoDoc.data()?['cupos'] ?? 0;
       final inscritosSnap = await _firestore.collection('inscripciones').where('eventoId', isEqualTo: eventoId).get();
       if (inscritosSnap.docs.length >= cupos) {
         throw Exception('Cupos agotados para este evento.');
       }
    }

    final id = const Uuid().v4();
    await _firestore.collection('inscripciones').doc(id).set({
      'eventoId': eventoId,
      'participanteId': participanteId,
      'fechaInscripcion': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<Inscripcion>> getInscripcionesPorEvento(String eventoId) async {
    final snap = await _firestore.collection('inscripciones').where('eventoId', isEqualTo: eventoId).get();
    return snap.docs.map(_fromFirestore).toList();
  }

  @override
  Future<List<Inscripcion>> getInscripcionesPorParticipante(String participanteId) async {
    final snap = await _firestore.collection('inscripciones').where('participanteId', isEqualTo: participanteId).get();
    return snap.docs.map(_fromFirestore).toList();
  }

  @override
  Future<bool> estaInscrito(String eventoId, String participanteId) async {
    final snap = await _firestore.collection('inscripciones')
        .where('eventoId', isEqualTo: eventoId)
        .where('participanteId', isEqualTo: participanteId)
        .get();
    return snap.docs.isNotEmpty;
  }
}
