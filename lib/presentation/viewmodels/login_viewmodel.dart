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
  /// TODO: La implementación real se realiza en la rama de Google Sign-In.
  /// Requiere: firebase_auth GoogleAuthProvider + google_sign_in package.
  Future<bool> loginWithGoogle() async {
  Future<bool> loginWithGoogle({String? rol}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Implementar integración con Google Sign-In
      // Ejemplo:
      //   final googleUser = await GoogleSignIn().signIn();
      //   final googleAuth = await googleUser!.authentication;
      //   final credential = GoogleAuthProvider.credential(
      //     accessToken: googleAuth.accessToken,
      //     idToken: googleAuth.idToken,
      //   );
      //   _currentUser = await authRepository.loginWithGoogle(credential);
      throw UnimplementedError('Google Sign-In aún no implementado.');
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      _currentUser = await authRepository.loginWithGoogle(rol: rol);
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      // Re-lanzar excepciones especiales para que la UI las maneje
      if (e.toString().contains('NeedsRoleSelectionException')) rethrow;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
