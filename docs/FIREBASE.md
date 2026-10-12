# Integración siguiente
1. Crear proyecto Firebase de desarrollo y registrar el applicationId real de android/app/build.gradle.kts.
2. Instalar Firebase CLI y FlutterFire CLI, ejecutar flutterfire configure para Android.
3. Agregar firebase_core, firebase_auth, cloud_firestore, firebase_storage y cloud_functions mediante flutter pub add.
4. Inicializar Firebase antes de runApp con firebase_options.dart generado.
5. Sustituir PendingAuthRepository; adaptar el contrato para emitir usuario/sesión y un AuthGate que escuche authStateChanges. La demo no es una sesión real.
6. Correo: habilitar Email/Password y configurar recuperación/verificación de correo.
7. Google: habilitar proveedor, registrar huellas SHA de depuración y firma de publicación, configurar google_sign_in conforme a su versión. No copiar APIs antiguas.
8. Facebook: crear aplicación Meta, habilitar proveedor y configurar App ID, secreto en consola, URI OAuth y configuración Android solicitada por el SDK. Revisar estado de desarrollo/público y cuentas de prueba. No introducir secretos en Flutter.
9. Definir vinculación de proveedores para un mismo correo y tratamiento de account-exists-with-different-credential.
10. Asignar administrador desde entorno seguro usando custom claims. Eliminar la vista previa administrativa de ajustes al pasar a producción y proteger las rutas; además, verificar permisos en reglas y servidor.
11. Sustituir catálogo demo por streams de Firestore; aislar favoritos por UID. Las preferencias demo actuales NO deben transferirse automáticamente a una cuenta real.
12. Probar reglas en emulador antes de desplegarlas. Las reglas incluidas deniegan todo deliberadamente, no son las reglas funcionales finales.
13. Revisar plan/facturación de Storage y Functions antes de habilitarlos.

Fuentes:
https://firebase.google.com/docs/flutter/setup
https://firebase.google.com/docs/auth/flutter/federated-auth
https://docs.flutter.dev/app-architecture/guide
