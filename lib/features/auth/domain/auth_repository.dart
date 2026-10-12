enum AuthProvider { google }
abstract interface class AuthRepository {
  Future<void> signIn(String email, String password);
  Future<void> register(String name, String email, String password);
  Future<void> resetPassword(String email);
  Future<void> signInWithProvider(AuthProvider provider);
}
class AuthUnavailable implements Exception {
  const AuthUnavailable();
}
