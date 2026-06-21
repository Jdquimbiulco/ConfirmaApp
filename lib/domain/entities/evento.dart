enum NivelControl { estricto, relajado }

class Evento {
  final String id;
  final String organizadorId;
  final String nombre;
  final String descripcion;
  String hora;
  String lugar;
  int cupos;
  double latitud;
  double longitud;
  double radioToleranciaMetros;
  DateTime fecha;
  NivelControl nivelControl;

  Evento({
    required this.id,
    required this.organizadorId,
    required this.nombre,
    required this.descripcion,
    required this.hora,
    required this.lugar,
    required this.cupos,
    required this.latitud,
    required this.longitud,
    required this.radioToleranciaMetros,
    required this.fecha,
    required this.nivelControl,
  });
}
