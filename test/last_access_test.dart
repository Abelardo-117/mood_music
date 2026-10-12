import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_music/app/app_controller.dart';
import 'package:mood_music/core/storage/preferences_service.dart';
import 'package:mood_music/features/auth/data/firebase_auth_repository.dart';
import 'package:mood_music/features/catalog/data/demo_catalog_repository.dart';
import 'package:mood_music/features/profile/domain/access_repository.dart';
import 'package:mood_music/features/profile/domain/profile_repository.dart';

class _Auth implements FirebaseAuthRepository {
  final events = StreamController<firebase.User?>.broadcast(sync: true);
  @override
  Stream<firebase.User?> get sessionChanges => events.stream;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
class _User implements firebase.User {
  _User(this.uid, [this.displayName = 'Nombre']);
  @override
  final String uid;
  @override
  final String? displayName;
  @override
  String get email => '$uid@example.com';
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
class _Profiles implements ProfileRepository {
  Completer<void>? gate;
  @override
  Future<void> sync({required String uid, required String name, required String email}) async {
    await gate?.future;
  }
}
class _Access implements AccessRepository {
  final calls = <String>[];
  bool fail = false;
  @override
  Future<void> record(String uid) async {
    calls.add(uid);
    if (fail) throw StateError('sin conexión');
  }
}
Future<void> settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _Auth auth;
  late _Profiles profiles;
  late _Access access;
  late AppController controller;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    auth = _Auth();
    profiles = _Profiles();
    access = _Access();
    controller = AppController(await PreferencesService.create(), DemoCatalogRepository(),
      auth: auth, profiles: profiles, access: access);
  });
  tearDown(() async {
    controller.dispose();
    await auth.events.close();
  });
  test('registra entrada, no cambios de perfil, y otra entrada tras salir', () async {
    auth.events.add(_User('a'));
    await settle();
    expect(access.calls, ['a']);
    auth.events.add(_User('a', 'Otro nombre'));
    await settle();
    expect(access.calls, ['a']);
    auth.events.add(null);
    auth.events.add(_User('a'));
    await settle();
    expect(access.calls, ['a', 'a']);
  });
  test('permite reintentar un acceso fallido', () async {
    access.fail = true;
    auth.events.add(_User('a'));
    await settle();
    expect(controller.profileError, isNotNull);
    access.fail = false;
    await controller.syncProfile();
    expect(access.calls, ['a', 'a']);
    expect(controller.profileError, isNull);
    await controller.syncProfile();
    expect(access.calls.length, 2);
  });
  test('omite el acceso de una cuenta cuyo perfil terminó después de salir', () async {
    final gate = Completer<void>();
    profiles.gate = gate;
    auth.events.add(_User('a'));
    await settle();
    auth.events.add(_User('b'));
    gate.complete();
    await settle();
    expect(access.calls, ['b']);
  });
}
