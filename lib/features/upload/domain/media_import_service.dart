enum MediaSource { audio, video }
class ImportedAudio {
  const ImportedAudio({required this.localPath, required this.mimeType});
  final String localPath, mimeType;
}
abstract interface class MediaImportService {
  Future<ImportedAudio?> selectAudio();
  Future<ImportedAudio?> extractAudioFromVideo();
}
// Pendiente: selector, validación, progreso, cancelación y conversión real.
// Un video sin pista de audio debe producir un error explícito.
