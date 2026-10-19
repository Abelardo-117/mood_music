import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/song.dart';
import '../domain/shared_song.dart';

class FirestoreSharedSongRepository {
  FirestoreSharedSongRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  Stream<List<Song>> watch() => _db.doc('shared_songs/demo_01').snapshots().map((snapshot) {
    final song = readSharedSong(snapshot.data());
    return song == null ? <Song>[] : [song];
  });
}
