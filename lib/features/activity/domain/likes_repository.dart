import '../../catalog/domain/song.dart';

abstract interface class LikesRepository {
  Future<void> setLike(String uid, Song song, bool liked);
  Stream<List<Song>> watchLikes(String uid);
}
