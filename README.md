# MoodMusic — esqueleto modular 0.2.0

Base para el proyecto Android existente, no una app terminada ni un clon de Spotify.

## Instalar en C:\mood_music
1. Detener flutter run con q.
2. Hacer una copia de seguridad de lib, test, pubspec.yaml y analysis_options.yaml.
3. Reemplazar lib por la carpeta lib de este ZIP (no colocar una lib dentro de otra).
4. Reemplazar pubspec.yaml y analysis_options.yaml por los de este ZIP.
5. Eliminar test/widget_test.dart del proyecto original (prueba el contador antiguo) y copiar la carpeta test de este ZIP.
6. Copiar docs, firebase y functions si quieres conservar las notas de integración.
7. NO reemplazar ni borrar android. Este paquete no modifica tu SDK, firma ni applicationId.
8. En la terminal del proyecto ejecutar:

    flutter pub get
    dart format lib test
    flutter analyze
    flutter test
    flutter run -d EARW8LMVYD4XW4AU

No se incluye pubspec.lock porque las dependencias deben resolverse con el SDK instalado; guardar el generado en Git.

## Qué funciona
- Navegación: acceso, registro, inicio, búsqueda, favoritos, perfil, ajustes, reproductor y vista previa administrativa.
- Tema oscuro/claro/sistema persistente.
- Nombre demo editable y favoritos locales persistentes.
- Búsqueda y filtros sobre catálogo ficticio.
- Formularios de acceso, controles de visibilidad y validación básica.

## Qué NO está conectado
- Correo, Google, Facebook, recuperación: botones muestran aviso explícito, no crean cuentas.
- No hay sesión Firebase, rol administrativo real, streaming de audio ni seguimiento de actividad.
- El reproductor es visual y sus controles de reproducción están deshabilitados.
- Selector de archivos, extracción de audio desde video, subida, edición y borrado están pendientes.
- Perfil: nombre demo; foto, correo y eliminación de cuenta se implementarán con Firebase.
- No hay playlists, recomendaciones automáticas, descargas, suscripciones o modo offline.

## Arquitectura
lib/app: arranque, composición, estado común y navegación.
lib/core: tema, preferencias locales y widgets compartidos.
lib/features/<función>/presentation: pantallas.
lib/features/<función>/domain: modelos y contratos.
lib/features/<función>/data: implementaciones concretas.

ChangeNotifier y ListenableBuilder para observar estado; dependencias por constructor y repositorios para separar datos.
El estado común contiene solo demo, apariencia, nombre y favoritos; auth/reproductor tendrán controladores propios al integrarse.
Favoritos tiene su vista mediante CatalogScreen(favoritesOnly: true), sin duplicar la lista.

## Validación
En el entorno de creación no hay Flutter/Dart instalado. NO se afirma compilación ni pruebas ejecutadas.
Se incluyeron pruebas para ejecutar en tu computadora y se revisaron las referencias locales de archivos.
Si flutter analyze muestra incompatibilidades, conservar el mensaje exacto para corregirlas.

## Próximas entregas
1. Compilar base y revisar aspecto en teléfono.
2. Firebase y acceso por correo, luego Google y Facebook.
3. Catálogo/Storage y reproducción real.
4. Administrador protegido, selección de audio/video, conversión y publicación.
5. Perfil real, actividad, privacidad, eliminación de cuenta y pruebas de publicación.
