enum RolUsuario { organizador, participante }

class Usuario {
  final String id;
  final String nombre;
  final String email;
  final RolUsuario rol;
  final bool biometriaRegistrada;
  final String? fotoBiometriaUrl;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.biometriaRegistrada = false,
    this.fotoBiometriaUrl,
  });
}
