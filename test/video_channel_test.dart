import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:moodmusic_local_media/moodmusic_local_media.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('moodmusic/local_media');
  tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));
  test('envía la ruta de video y recupera el audio extraído', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'extractAudio');
      expect(call.arguments, {'path': '/cache/input.mp4'});
      return '/cache/audio.m4a';
    });
    expect(await MoodMusicLocalMedia.extractAudio('/cache/input.mp4'), '/cache/audio.m4a');
  });
  test('propaga el rechazo de videos sin pista de audio', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'extract', message: 'Este video no contiene una pista de sonido.');
    });
    await expectLater(MoodMusicLocalMedia.extractAudio('/cache/silent.mp4'), throwsA(isA<PlatformException>()));
  });
}
