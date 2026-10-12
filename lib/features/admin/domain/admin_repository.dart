import '../../catalog/domain/song.dart';
abstract interface class AdminRepository {
  Future<void> saveSong(Song song);
  Future<void> deleteSong(String songId);
  Future<void> disableUser(String userId);
}
// Las implementaciones deben comprobar permisos en el servidor.
// Nunca incluir service accounts ni conceder roles desde la app.
