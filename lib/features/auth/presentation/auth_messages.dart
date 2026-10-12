import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import '../domain/auth_repository.dart';
String authMessage(Object error) {
  if (error is AuthUnavailable) return 'Este método de acceso no está disponible en este dispositivo.';
  if (error is FirebaseAuthException) {
    return switch (error.code) {
        'google-canceled' => 'No se completó el acceso con Google. Puedes volver a intentarlo.',
        'google-clientConfigurationError' || 'google-providerConfigurationError' || 'google-missing-id-token' => 'No se pudo iniciar sesión con Google. Intenta más tarde.',
        'google-interrupted' => 'Se interrumpió el acceso con Google. Intenta nuevamente.',
        'google-uiUnavailable' => 'No se pudo abrir Google. Vuelve a intentarlo con la app visible.',
        'google-platform-unsupported' => 'Este método de acceso no está disponible en este dispositivo.',
        'account-exists-with-different-credential' => 'Ya hay una cuenta con otro método de acceso. Entra con el método que utilizaste al registrarte.',
        'invalid-email' => 'Revisa el formato del correo.',
        'weak-password' => 'La contraseña no cumple los requisitos de seguridad.',
        'email-already-in-use' => 'Este correo ya está registrado. Inicia sesión o recupera tu contraseña.',
        'invalid-credential' || 'wrong-password' || 'user-not-found' => 'El correo o la contraseña no son correctos.',
        'user-disabled' => 'Esta cuenta está deshabilitada.',
        'too-many-requests' => 'Hubo demasiados intentos. Espera un momento.',
        'network-request-failed' => 'Revisa tu conexión a internet.',
        'operation-not-allowed' => 'Este método de acceso no está disponible por el momento.',
        _ => 'No se pudo completar la operación. Intenta nuevamente.',
    };
  }
  return 'No se pudo completar la operación. Intenta nuevamente.';
}
String? validateEmail(String? value) {
  return value == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())
    ? 'Escribe un correo válido' : null;
}
