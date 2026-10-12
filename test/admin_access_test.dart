import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_music/features/admin/domain/admin_access_repository.dart';
import 'package:mood_music/features/admin/presentation/admin_access_controller.dart';
class _Access implements AdminAccessRepository {
  final streams = <String, StreamController<bool>>{};
  @override
  Stream<bool> watchAccess(String uid) => (streams[uid] ??= StreamController<bool>.broadcast(sync: true)).stream;
  @override
  Stream<List<AdminProfile>> watchProfiles() => const Stream.empty();
  Future<void> close() async { for (final stream in streams.values) { await stream.close(); } }
}
void main() {
  test('retira permisos al cambiar de cuenta, revocar y fallar', () async {
    final repository = _Access();
    final access = AdminAccessController(repository);
    access.bind('admin');
    repository.streams['admin']!.add(true);
    expect(access.allowed, isTrue);
    access.bind('normal');
    expect(access.allowed, isFalse);
    repository.streams['admin']!.add(true);
    expect(access.allowed, isFalse);
    repository.streams['normal']!.add(false);
    expect(access.allowed, isFalse);
    access.bind('admin');
    repository.streams['admin']!.add(true);
    repository.streams['admin']!.add(false);
    expect(access.allowed, isFalse);
    repository.streams['admin']!.add(true);
    repository.streams['admin']!.addError(StateError('offline'));
    expect(access.allowed, isFalse);
    expect(access.error, isNotNull);
    access.bind(null);
    expect(access.allowed, isFalse);
    access.dispose();
    await repository.close();
  });
}
