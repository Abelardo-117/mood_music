import 'package:cloud_firestore/cloud_firestore.dart';
import '../../catalog/domain/song.dart';
import '../domain/listening_repository.dart';

class FirestoreListeningRepository implements ListeningRepository {
  FirestoreListeningRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;
  CollectionReference<Map<String, dynamic>> _records(String uid) =>
      _db.collection('users').doc(uid).collection('listens');

  @override
  String newId(String uid) => _records(uid).doc().id;

  @override
  Future<void> save(String uid, ListeningRecord record) => _records(uid).doc(record.id).set({
    'songId': record.song.id,
    'title': record.song.title,
    'artist': record.song.artist,
    'genre': record.song.genre,
    'qualifiedSeconds': 10,
    'listenedAt': Timestamp.fromDate(record.listenedAt),
    'syncedAt': FieldValue.serverTimestamp(),
  });

  @override
  Stream<List<ListeningRecord>> watchRecent(String uid) => _records(uid)
      .orderBy('listenedAt', descending: true).limit(100).snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
        final data = doc.data();
        return ListeningRecord(id: doc.id,
          listenedAt: (data['listenedAt'] as Timestamp).toDate(),
          song: Song(id: data['songId'] as String, title: data['title'] as String,
            artist: data['artist'] as String, genre: data['genre'] as String));
      }).toList());
}
