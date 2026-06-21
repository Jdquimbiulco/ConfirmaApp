import '../entities/evento.dart';

abstract class EventRepository {
  Future<List<Evento>> getEventos();
  Future<Evento?> getEventoById(String id);
  Future<void> crearEvento(Evento evento);
  Future<void> editarEvento(Evento evento);
  Future<void> eliminarEvento(String id);
}
