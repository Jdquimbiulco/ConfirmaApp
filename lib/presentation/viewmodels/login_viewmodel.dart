import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/usuario.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository authRepository;

  LoginViewModel({required this.authRepository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Usuario? _currentUser;
  Usuario? get currentUser => _currentUser;

  Future<void> checkSession() async {
    _currentUser = await authRepository.getCurrentUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await authRepository.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true; // Éxito
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false; // Error
    }
  }

  Future<bool> register(String email, String password, String nombre, RolUsuario rol) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newUser = Usuario(
        id: '', // Firebase asignará el ID real
        nombre: nombre,
        email: email,
        rol: rol,
        biometriaRegistrada: false,
      );
      
      await authRepository.registrarUsuario(newUser, password);
      // Iniciar sesión automáticamente después de registrar
      _currentUser = await authRepository.login(email, password);
      
      _isLoading = false;
      notifyListeners();
      return true; // Éxito
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false; // Error
    }
  }

  /// Inicio de sesión con Google.
  /// Si el usuario es nuevo, el repositorio lanza NeedsRoleSelectionException
  /// y la UI debe capturarla para pedir la selección de rol.
  Future<bool> loginWithGoogle({String? rol}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await authRepository.loginWithGoogle(rol: rol);
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } on Exception catch (e) {
      _isLoading = false;
      notifyListeners();
      // Re-lanzar para que la UI muestre el diálogo de selección de rol
      if (e.toString().contains('NeedsRoleSelectionException')) rethrow;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
