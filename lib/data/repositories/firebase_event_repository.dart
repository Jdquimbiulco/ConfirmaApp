import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/entities/evento.dart';

class FirebaseEventRepository implements EventRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Evento _fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Evento(
      id: doc.id,
      organizadorId: data['organizadorId'] ?? '',
      nombre: data['nombre'] ?? '',
      descripcion: data['descripcion'] ?? '',
      hora: data['hora'] ?? '',
      lugar: data['lugar'] ?? '',
      cupos: data['cupos'] ?? 0,
      latitud: data['latitud']?.toDouble() ?? 0.0,
      longitud: data['longitud']?.toDouble() ?? 0.0,
      radioToleranciaMetros: data['radioToleranciaMetros']?.toDouble() ?? 100.0,
      fecha: (data['fecha'] as Timestamp).toDate(),
      nivelControl: data['nivelControl'] == 'estricto' ? NivelControl.estricto : NivelControl.relajado,
    );
  }

  Map<String, dynamic> _toFirestore(Evento e) {
    return {
      'organizadorId': e.organizadorId,
      'nombre': e.nombre,
      'descripcion': e.descripcion,
      'hora': e.hora,
      'lugar': e.lugar,
      'cupos': e.cupos,
      'latitud': e.latitud,
      'longitud': e.longitud,
      'radioToleranciaMetros': e.radioToleranciaMetros,
      'fecha': Timestamp.fromDate(e.fecha),
      'nivelControl': e.nivelControl == NivelControl.estricto ? 'estricto' : 'relajado',
    };
  }

  @override
  Future<List<Evento>> getEventos() async {
    final snap = await _firestore.collection('eventos').get();
    return snap.docs.map(_fromFirestore).toList();
  }

  @override
  Future<Evento?> getEventoById(String id) async {
    final doc = await _firestore.collection('eventos').doc(id).get();
    if (!doc.exists) return null;
    return _fromFirestore(doc);
  }

  @override
  Future<void> crearEvento(Evento evento) async {
    await _firestore.collection('eventos').doc(evento.id).set(_toFirestore(evento));
  }

  @override
  Future<void> editarEvento(Evento evento) async {
    await _firestore.collection('eventos').doc(evento.id).update(_toFirestore(evento));
  }

  @override
  Future<void> eliminarEvento(String id) async {
    await _firestore.collection('eventos').doc(id).delete();
  }
}
