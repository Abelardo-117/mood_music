import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  PreferencesService._(this._prefs);
  final SharedPreferences _prefs;
  static Future<PreferencesService> create() async =>
      PreferencesService._(await SharedPreferences.getInstance());
  String get theme => _prefs.getString('theme') ?? 'dark';
  String get name => _prefs.getString('demo_name') ?? 'Yahir';
  Set<String> get favorites => favoritesFor('demo');
  String _favoriteKey(String owner) => owner == 'demo' ? 'demo_favorites' : 'favorites_$owner';
  Set<String> favoritesFor(String owner) => (_prefs.getStringList(_favoriteKey(owner)) ?? []).toSet();
  Future<void> saveTheme(String value) async {
    if (!await _prefs.setString('theme', value)) throw StateError('No se pudo guardar el tema.');
  }
  Future<void> saveName(String value) async {
    if (!await _prefs.setString('demo_name', value)) throw StateError('No se pudo guardar el nombre.');
  }
  Future<void> saveFavorites(Set<String> values) => saveFavoritesFor('demo', values);
  Future<void> saveFavoritesFor(String owner, Set<String> values) async {
    if (!await _prefs.setStringList(_favoriteKey(owner), values.toList())) {
      throw StateError('No se pudieron guardar los favoritos.');
    }
  }
}
