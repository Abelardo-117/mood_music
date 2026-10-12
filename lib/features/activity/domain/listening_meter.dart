/// Acumula tiempo de reproducción con un reloj monótono, no la posición
/// de la canción. Adelantar la barra no suma minutos escuchados.
class ListeningMeter {
  ListeningMeter({this.threshold = const Duration(seconds: 10)});
  final Duration threshold;
  Duration elapsed = Duration.zero;
  Duration? _last;
  bool _running = false;
  bool _counted = false;

  bool update({required Duration now, required bool running}) {
    final previous = _last;
    if (_running && previous != null && now >= previous) {
      elapsed += now - previous;
    }
    _last = now;
    _running = running;
    if (!_counted && elapsed >= threshold) {
      _counted = true;
      return true;
    }
    return false;
  }

  void reset() {
    elapsed = Duration.zero;
    _last = null;
    _running = false;
    _counted = false;
  }
}
