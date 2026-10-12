import '../../catalog/domain/song.dart';
List<Song> buildPlaybackQueue(List<Song> catalog, Song selected) {
  final byId = <String, Song>{};
  for (final song in catalog) {
    if (song.audioUrl?.isNotEmpty == true) byId[song.id] = song;
  }
  if (selected.audioUrl?.isNotEmpty == true) byId.putIfAbsent(selected.id, () => selected);
  return List.unmodifiable(byId.values);
}
