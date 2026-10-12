class Song {
  const Song({required this.id, required this.title, required this.artist,
    required this.genre, this.moods = const [], this.audioUrl, this.coverUrl});
  final List<String> moods;
  final String id, title, artist, genre;
  final String? audioUrl, coverUrl;
}
