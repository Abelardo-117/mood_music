import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_music/features/catalog/data/account_catalog_repository.dart';

void main() {
  test('separa cuentas, conserva cambios y no expone música al salir', () async {
    final root = await Directory.systemTemp.createTemp('accounts_');
    addTearDown(() => root.delete(recursive: true));
    final source = File('${root.path}/original.mp3');
    await source.writeAsBytes([1, 2, 3]);
    final catalog = AccountCatalogRepository(root: root);
    addTearDown(catalog.dispose);
    await catalog.bind('alice');
    final alice = catalog.local!;
    final song = await alice.save(title: 'Mi tema', artist: 'Yo', genre: 'Pop', audio: source);
    final switching = catalog.bind('bob');
    expect(catalog.songs, isEmpty);
    expect(catalog.local, isNull);
    await switching;
    expect(catalog.songs, isEmpty);
    await expectLater(catalog.local!.remove(song), throwsStateError);
    await expectLater(catalog.local!.save(existing: song, title: 'Ajena', artist: 'Yo', genre: 'Pop'), throwsStateError);
    await catalog.local!.save(title: 'De Bob', artist: 'Bob', genre: 'Rock', audio: source);
    await catalog.bind('alice');
    expect(catalog.local, same(alice));
    expect(catalog.songs.single.id, song.id);
    await catalog.local!.save(existing: song, title: 'Editada', artist: 'Yo', genre: 'Pop');
    await catalog.bind(null);
    expect(catalog.songs, isEmpty);
    final reopened = AccountCatalogRepository(root: root);
    addTearDown(reopened.dispose);
    await reopened.bind('alice');
    expect(reopened.songs.single.title, 'Editada');
    await reopened.local!.remove(reopened.songs.single);
    expect(reopened.songs, isEmpty);
    expect(await source.exists(), isTrue);
    await reopened.bind('bob');
    expect(reopened.songs.single.title, 'De Bob');
  });

  test('un cambio rápido de cuenta no restaura una biblioteca anterior', () async {
    final root = await Directory.systemTemp.createTemp('accounts_race_');
    addTearDown(() => root.delete(recursive: true));
    final catalog = AccountCatalogRepository(root: root);
    addTearDown(catalog.dispose);
    final first = catalog.bind('alice');
    final second = catalog.bind('bob');
    await Future.wait([first, second]);
    expect(catalog.owner, 'bob');
    expect(catalog.local, isNotNull);
    final load = catalog.bind('alice');
    await catalog.bind(null);
    await load;
    expect(catalog.local, isNull);
    expect(catalog.songs, isEmpty);
  });
}
