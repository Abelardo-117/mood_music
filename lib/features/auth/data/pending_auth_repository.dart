import '../domain/auth_repository.dart';
// Sustituir por un repositorio Firebase después de configurar los proveedores.
// No guarda contraseñas ni simula una autenticación exitosa.
class PendingAuthRepository implements AuthRepository {
  @override
  Future<void> signIn(String email, String password) async => throw const AuthUnavailable();
  @override
  Future<void> register(String name, String email, String password) async => throw const AuthUnavailable();
  @override
  Future<void> resetPassword(String email) async => throw const AuthUnavailable();
  @override
  Future<void> signInWithProvider(AuthProvider provider) async => throw const AuthUnavailable();
}
