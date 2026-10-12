import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_music/app/app_controller.dart';
import 'package:mood_music/core/storage/preferences_service.dart';
import 'package:mood_music/features/catalog/data/demo_catalog_repository.dart';
import 'package:mood_music/features/catalog/domain/song.dart';
import 'package:mood_music/features/activity/domain/likes_repository.dart';

class FakeLikes implements LikesRepository {
  final calls = <({String uid, String songId, bool liked, Completer<void> done})>[];
  @override
  Future<void> setLike(String uid, Song song, bool liked) {
    final done = Completer<void>();
    calls.add((uid: uid, songId: song.id, liked: liked, done: done));
    return done.future;
  }
  @override
  Stream<List<Song>> watchLikes(String uid) => const Stream.empty();
}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('escribe una vez al dar dos toques mientras confirma', () async {
    final repo = FakeLikes();
    final controller = AppController(await PreferencesService.create(), DemoCatalogRepository(), likes: repo);
    controller.userId = 'cuenta-a';
    final song = controller.catalog.songs.first;
    final pending = controller.toggleFavorite(song);
    await controller.toggleFavorite(song);
    expect(repo.calls.length, 1);
    expect(repo.calls.single.uid, 'cuenta-a');
    expect(controller.favoriteSaving(song), isTrue);
    repo.calls.single.done.complete();
    await pending;
    expect(controller.isFavorite(song), isTrue);
    expect(controller.favoriteSaving(song), isFalse);
    final prefs = await PreferencesService.create();
    expect(prefs.favoritesFor('cuenta-a'), contains(song.id));
    controller.dispose();
  });
  test('un rechazo no borra otro like confirmado ni persiste el rechazado', () async {
    final repo = FakeLikes();
    final controller = AppController(await PreferencesService.create(), DemoCatalogRepository(), likes: repo);
    controller.userId = 'cuenta-a';
    final songs = controller.catalog.songs;
    final first = controller.toggleFavorite(songs[0]);
    final failure = expectLater(first, throwsStateError);
    final second = controller.toggleFavorite(songs[1]);
    repo.calls[1].done.complete();
    await second;
    repo.calls[0].done.completeError(StateError('permission-denied'));
    await failure;
    expect(controller.isFavorite(songs[0]), isFalse);
    expect(controller.isFavorite(songs[1]), isTrue);
    final prefs = await PreferencesService.create();
    expect(prefs.favoritesFor('cuenta-a'), isNot(contains(songs[0].id)));
    expect(prefs.favoritesFor('cuenta-a'), contains(songs[1].id));
    controller.dispose();
  });
  test('una escritura antigua guarda solo en su cuenta original', () async {
    final repo = FakeLikes();
    final controller = AppController(await PreferencesService.create(), DemoCatalogRepository(), likes: repo);
    controller.userId = 'cuenta-a';
    final song = controller.catalog.songs.first;
    final pending = controller.toggleFavorite(song);
    controller.userId = 'cuenta-b';
    repo.calls.single.done.complete();
    await pending;
    final prefs = await PreferencesService.create();
    expect(prefs.favoritesFor('cuenta-b'), isEmpty);
    expect(prefs.favoritesFor('cuenta-a'), contains(song.id));
    controller.dispose();
  });
  test('demostración mantiene favoritos locales sin enviar a Firestore', () async {
    final repo = FakeLikes();
    final controller = AppController(await PreferencesService.create(), DemoCatalogRepository(), likes: repo);
    final song = controller.catalog.songs.first;
    await controller.toggleFavorite(song);
    expect(repo.calls, isEmpty);
    expect(controller.isFavorite(song), isTrue);
    controller.dispose();
  });
}
