import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_music/features/catalog/data/local_catalog_repository.dart';
void main() {
  test('conserva biblioteca al reabrir, edita y borra copias sin tocar originales', () async {
    final temp = await Directory.systemTemp.createTemp('mood_test_');
    addTearDown(() => temp.delete(recursive: true));
    final original = File('${temp.path}/original.mp3');
    await original.writeAsBytes([1, 2, 3, 4]);
    final folder = Directory('${temp.path}/library');
    final repo = await LocalCatalogRepository.open(directory: folder);
    final song = await repo.save(title: 'Tema', artist: 'Artista', genre: 'Pop', audio: original);
    expect(song.audioUrl, isNot(original.path));
    final index = jsonDecode(await File('${folder.path}/catalog.json').readAsString()) as List;
    final audioName = (index.single as Map)['audio'] as String;
    expect(audioName.contains('/'), isFalse);
    expect(audioName.contains('\\'), isFalse);
    final restored = await LocalCatalogRepository.open(directory: folder);
    expect(restored.songs.single.title, 'Tema');
    final edited = await restored.save(existing: restored.songs.single, title: 'Nuevo título', artist: 'Artista', genre: 'Rock');
    expect(edited.id, song.id);
    expect(edited.audioUrl, song.audioUrl);
    await restored.remove(edited);
    expect(await original.exists(), isTrue);
    expect(await File(song.audioUrl!).exists(), isFalse);
    final empty = await LocalCatalogRepository.open(directory: folder);
    expect(empty.songs, isEmpty);
    repo.dispose(); restored.dispose(); empty.dispose();
  });
  test('rechaza archivos vacíos sin guardar una canción incompleta', () async {
    final temp = await Directory.systemTemp.createTemp('mood_test_');
    addTearDown(() => temp.delete(recursive: true));
    final original = await File('${temp.path}/empty.mp3').create();
    final repo = await LocalCatalogRepository.open(directory: Directory('${temp.path}/library'));
    await expectLater(repo.save(title: 'Tema', artist: 'Artista', genre: 'Pop', audio: original), throwsArgumentError);
    expect(repo.songs, isEmpty);
    expect(await original.exists(), isTrue);
    repo.dispose();
  });
}
