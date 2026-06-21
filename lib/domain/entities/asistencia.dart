class Asistencia {
  final String id;
  final String eventoId;
  final String participanteId;
  final DateTime fechaHora;
  final bool ubicacionValida;

  Asistencia({
    required this.id,
    required this.eventoId,
    required this.participanteId,
    required this.fechaHora,
    required this.ubicacionValida,
  });
}
