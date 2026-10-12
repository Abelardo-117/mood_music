import '../../catalog/domain/song.dart';

class ListeningRecord {
  const ListeningRecord({required this.id, required this.song, required this.listenedAt});
  final String id;
  final Song song;
  final DateTime listenedAt;
}

abstract interface class ListeningRepository {
  String newId(String uid);
  Future<void> save(String uid, ListeningRecord record);
  Stream<List<ListeningRecord>> watchRecent(String uid);
}
