import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/admin_access_repository.dart';

class FirestoreAdminAccessRepository implements AdminAccessRepository {
  FirestoreAdminAccessRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  @override
  Stream<bool> watchAccess(String uid) => _firestore.collection('admins').doc(uid)
      .snapshots(includeMetadataChanges: true)
      .map((doc) => !doc.metadata.isFromCache && doc.data()?['enabled'] == true);
  @override
  Stream<List<AdminProfile>> watchProfiles() => _firestore.collection('users')
      .orderBy('name').limit(100).snapshots(includeMetadataChanges: true)
      .map((snapshot) => snapshot.metadata.isFromCache ? <AdminProfile>[] : snapshot.docs.map((doc) {
        final data = doc.data();
        return AdminProfile(uid: doc.id, name: data['name'] as String? ?? 'Usuario',
            email: data['email'] as String? ?? '',
            lastAccessAt: data['lastAccessAt'] is Timestamp
              ? (data['lastAccessAt'] as Timestamp).toDate() : null);
      }).toList());
}
