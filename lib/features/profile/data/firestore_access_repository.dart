import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/access_repository.dart';

class FirestoreAccessRepository implements AccessRepository {
  FirestoreAccessRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;

  @override
  Future<void> record(String uid) => _firestore.collection('users').doc(uid).update({
    'lastAccessAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });
}
