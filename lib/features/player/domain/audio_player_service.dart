// Contrato para la futura integración de reproducción real.
abstract interface class AudioPlayerService {
  Stream<Duration> get position;
  Stream<bool> get playing;
  Future<void> load(String url);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> dispose();
}
