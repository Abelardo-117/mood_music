import 'features/catalog/data/firestore_shared_song_repository.dart';
import 'features/profile/data/firestore_access_repository.dart';
import 'features/activity/data/firestore_listening_repository.dart';
import 'features/activity/data/listening_tracker.dart';
import 'features/activity/data/firestore_likes_repository.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'features/player/data/music_audio_handler.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/mood_music_app.dart';
import 'features/admin/data/firestore_admin_access_repository.dart';
import 'features/profile/data/firestore_profile_repository.dart';
import 'app/app_controller.dart';
import 'core/storage/preferences_service.dart';
import 'features/catalog/data/account_catalog_repository.dart';
import 'features/auth/data/firebase_auth_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final preferences = await PreferencesService.create();
    final auth = FirebaseAuthRepository();
    final catalog = AccountCatalogRepository(watchShared: FirestoreSharedSongRepository().watch);
    final audio = await AudioService.init<MusicAudioHandler>(
      builder: MusicAudioHandler.new,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.yahirjavier.mood_music.playback',
        androidNotificationChannelName: 'Reproducción de MoodMusic',
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: false,
      ),
    );
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    final history = FirestoreListeningRepository();
    final listening = ListeningTracker(audio, history);
    final controller = AppController(preferences, catalog, history: history, listening: listening, likes: FirestoreLikesRepository(), audio: audio, auth: auth, profiles: FirestoreProfileRepository(), access: FirestoreAccessRepository(), adminRepository: FirestoreAdminAccessRepository());
    runApp(MoodMusicApp(controller: controller, auth: auth));
  } catch (error, stack) {
    debugPrint('Error al iniciar MoodMusic: $error\n$stack');
    runApp(const MaterialApp(home: Scaffold(body: Center(child: Padding(
      padding: EdgeInsets.all(24), child: Text('No se pudo iniciar MoodMusic. Revisa la conexión, la configuración y el almacenamiento disponible. Vuelve a abrir la app; no borres sus datos.'))))));
  }
}
