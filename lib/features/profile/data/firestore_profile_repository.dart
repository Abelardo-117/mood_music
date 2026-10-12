import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/profile_repository.dart';

class FirestoreProfileRepository implements ProfileRepository {
  FirestoreProfileRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<void> sync({required String uid, required String name, required String email}) async {
    final reference = _firestore.collection('users').doc(uid);
    await _firestore.runTransaction<void>((transaction) async {
      if (_auth.currentUser?.uid != uid) throw StateError('La sesión cambió.');
      final snapshot = await transaction.get(reference);
      if (_auth.currentUser?.uid != uid) throw StateError('La sesión cambió.');
      final data = <String, dynamic>{
        'name': name.trim(),
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (snapshot.exists) {
        transaction.update(reference, data);
      } else {
        transaction.set(reference, {
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }, timeout: const Duration(seconds: 15), maxAttempts: 3);
  }
}
