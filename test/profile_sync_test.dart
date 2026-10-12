import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_music/app/app_controller.dart';
import 'package:mood_music/core/storage/preferences_service.dart';
import 'package:mood_music/features/catalog/data/demo_catalog_repository.dart';
import 'package:mood_music/features/profile/domain/profile_repository.dart';

class _Profiles implements ProfileRepository {
  final started = Completer<void>();
  final release = Completer<void>();
  final names = <String>[];
  bool fail = false;
  @override
  Future<void> sync({required String uid, required String name, required String email}) async {
    names.add(name);
    if (!started.isCompleted) {
      started.complete();
      await release.future;
    }
    if (fail) throw StateError('offline');
  }
}

void main() {
  test('serializa cambios de nombre y permite reintentar un fallo', () async {
    SharedPreferences.setMockInitialValues({});
    final profiles = _Profiles();
    final controller = AppController(await PreferencesService.create(), DemoCatalogRepository(), profiles: profiles);
    addTearDown(controller.dispose);
    controller.userId = 'user-a';
    controller.email = 'test@example.com';
    controller.name = 'Inicial';
    final first = controller.syncProfile();
    await profiles.started.future;
    controller.name = 'Final';
    final second = controller.syncProfile();
    profiles.release.complete();
    await first;
    await second;
    expect(profiles.names, ['Inicial', 'Final']);
    expect(controller.profileSyncing, isFalse);
    expect(controller.profileError, isNull);
    profiles.fail = true;
    await controller.syncProfile();
    expect(controller.profileError, isNotNull);
    profiles.fail = false;
    await controller.syncProfile();
    expect(controller.profileError, isNull);
  });

  test('un error de una cuenta anterior no aparece tras cerrar sesión', () async {
    SharedPreferences.setMockInitialValues({});
    final profiles = _Profiles()..fail = true;
    final controller = AppController(await PreferencesService.create(), DemoCatalogRepository(), profiles: profiles);
    addTearDown(controller.dispose);
    controller.userId = 'old-user';
    controller.email = 'old@example.com';
    final pending = controller.syncProfile();
    await profiles.started.future;
    controller.userId = null;
    await controller.syncProfile();
    profiles.release.complete();
    await pending;
    expect(controller.profileError, isNull);
    expect(controller.profileSyncing, isFalse);
  });
}
