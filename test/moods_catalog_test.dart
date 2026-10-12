import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_music/features/catalog/data/local_catalog_repository.dart';

void main() {
  test('abre catálogo anterior, guarda varios ánimos y permite quitarlos', () async {
    final dir = await Directory.systemTemp.createTemp('mood_test_');
    addTearDown(() => dir.delete(recursive: true));
    await File('${dir.path}/song.mp3').writeAsBytes([1, 2, 3]);
    await File('${dir.path}/catalog.json').writeAsString(jsonEncode([
      {'id': 'old', 'title': 'Antes', 'artist': 'Artista', 'genre': 'Rock', 'audio': 'song.mp3', 'cover': null}
    ]));
    final repo = await LocalCatalogRepository.open(directory: dir);
    addTearDown(repo.dispose);
    expect(repo.songs.single.moods, isEmpty);
    final song = await repo.save(existing: repo.songs.single, title: 'Antes', artist: 'Artista',
      genre: 'Rock', moods: ['Feliz', 'Con energía']);
    final reopened = await LocalCatalogRepository.open(directory: dir);
    addTearDown(reopened.dispose);
    expect(reopened.songs.single.moods, ['Feliz', 'Con energía']);
    expect(reopened.songs.single.id, 'old');
    expect(await File(song.audioUrl!).readAsBytes(), [1, 2, 3]);
    final renamed = await repo.save(existing: song, title: 'Nuevo título', artist: 'Artista', genre: 'Rock');
    expect(renamed.moods, ['Feliz', 'Con energía']);
    await repo.save(existing: renamed, title: 'Nuevo título', artist: 'Artista', genre: 'Rock', moods: []);
    final cleared = await LocalCatalogRepository.open(directory: dir);
    addTearDown(cleared.dispose);
    expect(cleared.songs.single.moods, isEmpty);
  });
}
