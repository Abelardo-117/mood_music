import 'package:flutter_test/flutter_test.dart';
import 'package:mood_music/features/catalog/domain/song.dart';
import 'package:mood_music/features/catalog/domain/music_genres.dart';
import 'package:mood_music/features/player/domain/playback_queue.dart';
void main() {
  test('la cola conserva el orden, incluye la seleccionada y excluye demos sin audio', () {
    const a = Song(id: 'a', title: 'A', artist: 'X', genre: 'Rock', audioUrl: '/a.mp3');
    const b = Song(id: 'b', title: 'B', artist: 'X', genre: 'Cumbia', audioUrl: '/b.mp3');
    const c = Song(id: 'c', title: 'C', artist: 'X', genre: 'Pop', audioUrl: '/c.mp3');
    const demo = Song(id: 'demo', title: 'Demo', artist: 'X', genre: 'Rock');
    final queue = buildPlaybackQueue([a, demo, b, c, a], b);
    expect(queue.map((song) => song.id), ['a', 'b', 'c']);
    expect(queue.indexWhere((song) => song.id == b.id), 1);
    expect(buildPlaybackQueue([a], c).last.id, 'c');
  });
  test('editar conserva géneros anteriores y no duplica opciones', () {
    expect(genreOptions('Cumbia').where((g) => g == 'Cumbia').length, 1);
    expect(genreOptions('Mi género anterior'), contains('Mi género anterior'));
    expect(genreOptions(null), containsAll(['Rock', 'Cumbia', 'Pop en inglés']));
  });
}
