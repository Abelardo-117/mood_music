import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class LocalFilePicker {
  static Future<File?> pick({required bool cover, bool video = false}) async {
    final maxMb = cover ? 5 : video ? 300 : 100;
    final picked = await FilePicker.pickFile(type: FileType.custom,
      allowedExtensions: cover ? ['jpg','jpeg','png','webp'] : video ? ['mp4','mov','m4v','3gp','mkv'] : ['mp3','m4a','aac','wav','ogg','flac']);
    if (picked == null) return null;
    final extension = picked.name.split('.').last.toLowerCase();
    final folder = await (await getTemporaryDirectory()).createTemp('mood_import_');
    final target = File('${folder.path}/selected.$extension');
    final sink = target.openWrite();
    var count = 0;
    try {
      await for (final bytes in picked.readAsByteStream()) {
        count += bytes.length;
        if (count > maxMb * 1024 * 1024) throw StateError('El archivo supera el límite de $maxMb MB.');
        sink.add(bytes);
      }
      await sink.flush();
      await sink.close();
      if (count == 0) throw StateError('El archivo está vacío.');
      return target;
    } catch (_) {
      await sink.close();
      if (await folder.exists()) await folder.delete(recursive: true);
      rethrow;
    }
  }
  static Future<void> release(File? file) async {
    if (file == null) return;
    try { if (await file.parent.exists()) await file.parent.delete(recursive: true); }
    on FileSystemException { /* Temporary files may be cleaned by the OS. */ }
  }
}
