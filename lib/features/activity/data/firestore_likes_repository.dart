import 'package:cloud_firestore/cloud_firestore.dart';
import '../../catalog/domain/song.dart';
import '../domain/likes_repository.dart';

class FirestoreLikesRepository implements LikesRepository {
  FirestoreLikesRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> _likes(String uid) =>
      _db.collection('users').doc(uid).collection('likes');

  @override
  Future<void> setLike(String uid, Song song, bool liked) {
    final ref = _likes(uid).doc(song.id);
    if (!liked) {
      return ref.delete();
    }
    // Solo metadatos: nunca rutas privadas ni archivos de audio.
    return ref.set({
      'title': song.title, 'artist': song.artist, 'genre': song.genre,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Song>> watchLikes(String uid) => _likes(uid)
      .orderBy('updatedAt', descending: true).limit(100).snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return Song(id: doc.id, title: data['title'] as String,
          artist: data['artist'] as String, genre: data['genre'] as String);
      }).toList());
}
