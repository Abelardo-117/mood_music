import 'package:flutter_test/flutter_test.dart';
import 'package:mood_music/features/activity/domain/listening_meter.dart';

void main() {
  Duration at(int seconds) => Duration(seconds: seconds);
  test('solo cuenta al alcanzar diez segundos, una vez por sesión', () {
    final meter = ListeningMeter();
    expect(meter.update(now: at(0), running: true), isFalse);
    expect(meter.update(now: at(9), running: true), isFalse);
    expect(meter.update(now: at(10), running: true), isTrue);
    expect(meter.update(now: at(20), running: true), isFalse);
  });
  test('pausas y buffering no suman, reanudar conserva lo escuchado', () {
    final meter = ListeningMeter();
    meter.update(now: at(0), running: true);
    meter.update(now: at(4), running: false);
    expect(meter.update(now: at(100), running: false), isFalse);
    expect(meter.elapsed, at(4));
    meter.update(now: at(100), running: true);
    expect(meter.update(now: at(105), running: true), isFalse);
    expect(meter.update(now: at(106), running: true), isTrue);
  });
  test('notificaciones repetidas y saltos de barra no añaden tiempo', () {
    final meter = ListeningMeter();
    meter.update(now: at(0), running: true);
    for (var i = 0; i < 100; i++) {
      // El reloj real no avanza aunque cambie la posición del audio.
      expect(meter.update(now: at(1), running: true), isFalse);
    }
    expect(meter.elapsed, at(1));
  });
  test('cambiar canción o cuenta descarta tiempo incompleto', () {
    final meter = ListeningMeter();
    meter.update(now: at(0), running: true);
    meter.update(now: at(8), running: false);
    meter.reset();
    meter.update(now: at(8), running: true);
    expect(meter.update(now: at(10), running: true), isFalse);
    expect(meter.update(now: at(18), running: true), isTrue);
  });
  test('la frontera de pausa cuenta el tiempo activo justo anterior', () {
    final meter = ListeningMeter();
    meter.update(now: at(0), running: true);
    expect(meter.update(now: at(10), running: false), isTrue);
    expect(meter.update(now: at(70), running: false), isFalse);
    expect(meter.elapsed, at(10));
  });
  test('repetir tras reiniciar permite una nueva escucha, no un duplicado', () {
    final meter = ListeningMeter();
    meter.update(now: at(0), running: true);
    expect(meter.update(now: at(10), running: false), isTrue);
    meter.reset();
    meter.update(now: at(50), running: true);
    expect(meter.update(now: at(60), running: true), isTrue);
    expect(meter.update(now: at(61), running: true), isFalse);
  });
}
