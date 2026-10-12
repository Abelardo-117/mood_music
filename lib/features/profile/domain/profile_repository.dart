abstract interface class ProfileRepository {
  Future<void> sync({required String uid, required String name, required String email});
}
