import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_music/core/storage/preferences_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('Favoritos no se comparten entre demo y cuentas diferentes', () async {
    final prefs = await PreferencesService.create();
    await prefs.saveFavorites({'demo-song'});
    await prefs.saveFavoritesFor('account-a', {'neon'});
    expect(prefs.favoritesFor('account-b'), isEmpty);
    expect(prefs.favorites, {'demo-song'});
    final reopened = await PreferencesService.create();
    expect(reopened.favoritesFor('account-a'), {'neon'});
    await reopened.saveFavoritesFor('account-a', {});
    expect(reopened.favoritesFor('account-a'), isEmpty);
    expect(reopened.favorites, {'demo-song'});
  });
}
