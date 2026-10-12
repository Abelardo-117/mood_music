import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_music/app/app_controller.dart';
import 'package:mood_music/core/storage/preferences_service.dart';
import 'package:mood_music/features/catalog/data/demo_catalog_repository.dart';
import 'package:mood_music/features/auth/data/pending_auth_repository.dart';
import 'package:mood_music/features/auth/domain/auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('Tema, nombre y favoritos se recuperan al recrear el controlador', () async {
    final first = AppController(await PreferencesService.create(), DemoCatalogRepository());
    await first.setTheme(ThemeMode.light);
    await first.setName('  Yahir Javier  ');
    await first.toggleFavorite(first.catalog.songs.first);
    final second = AppController(await PreferencesService.create(), DemoCatalogRepository());
    expect(second.themeMode, ThemeMode.light);
    expect(second.name, 'Yahir Javier');
    expect(second.isFavorite(second.catalog.songs.first), isTrue);
    await second.toggleFavorite(second.catalog.songs.first);
    expect(second.isFavorite(second.catalog.songs.first), isFalse);
    first.dispose(); second.dispose();
  });
  test('El repositorio pendiente nunca simula autenticación exitosa', () async {
    final auth = PendingAuthRepository();
    await expectLater(auth.signIn('user@example.com', 'example123'), throwsA(isA<AuthUnavailable>()));
    for (final provider in AuthProvider.values) {
      await expectLater(auth.signInWithProvider(provider), throwsA(isA<AuthUnavailable>()));
    }
  });
}
