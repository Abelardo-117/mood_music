class AdminProfile {
  const AdminProfile({required this.uid, required this.name, required this.email, this.lastAccessAt});
  final String uid, name, email;
  final DateTime? lastAccessAt;
}
abstract interface class AdminAccessRepository {
  Stream<bool> watchAccess(String uid);
  Stream<List<AdminProfile>> watchProfiles();
}
