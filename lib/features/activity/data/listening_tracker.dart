import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../catalog/domain/song.dart';
import '../../player/data/music_audio_handler.dart';
import '../domain/listening_meter.dart';
import '../domain/listening_repository.dart';

/// Vive con la app, no con PlayerScreen: funciona también en segundo plano.
class ListeningTracker {
  ListeningTracker(this.audio, this.repository) {
    audio.changes.addListener(_sync);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _sync());
  }
  final MusicAudioHandler audio;
  final ListeningRepository repository;
  final ValueNotifier<String?> status = ValueNotifier(null);
  final Stopwatch _clock = Stopwatch()..start();
  final ListeningMeter _meter = ListeningMeter();
  late final Timer _timer;
  String? _uid;
  Song? _song;
  bool _ended = false;
  bool _disposed = false;
  int _session = 0;
  int _pending = 0;
  final Map<String, ListeningRecord> _failed = {};

  void bind(String? uid) {
    if (_uid == uid) {
      return;
    }
    ++_session;
    _uid = uid;
    _song = null;
    _ended = false;
    _pending = 0;
    _failed.clear();
    _meter.reset();
    status.value = null;
  }

  void _sync() {
    if (_disposed || _uid == null) {
      return;
    }
    final now = _clock.elapsed;
    final current = audio.currentSong;
    final playing = current != null && !audio.loading && audio.error == null
        && audio.player.playing && audio.player.processingState == ProcessingState.ready;
    // Cierra el intervalo anterior antes de cambiar de canción/estado.
    if (_meter.update(now: now, running: false)) {
      _record();
    }
    if (_song?.id != current?.id || (_ended && playing)) {
      _meter.reset();
      _song = current;
      _ended = false;
    }
    if (current != null && audio.player.processingState == ProcessingState.completed) {
      _ended = true;
    }
    if (_meter.update(now: now, running: playing)) {
      _record();
    }
  }

  void _record() {
    final uid = _uid;
    final song = _song;
    if (uid == null || song == null) {
      return;
    }
    final record = ListeningRecord(id: repository.newId(uid), song: song,
      listenedAt: DateTime.now());
    unawaited(_send(uid, record, _session));
  }

  void _refreshStatus() {
    if (_disposed) {
      return;
    }
    status.value = _pending > 0
      ? 'Historial pendiente de sincronización ($_pending).'
      : _failed.isNotEmpty ? 'No se pudo sincronizar parte del historial. Puedes reintentar.' : null;
  }

  Future<void> _send(String uid, ListeningRecord record, int session) async {
    if (_disposed || session != _session || uid != _uid) {
      return;
    }
    _pending++;
    _refreshStatus();
    try {
      // El mismo ID hace que reintentar no duplique la reproducción.
      await repository.save(uid, record);
      if (!_disposed && session == _session) {
        _failed.remove(record.id);
      }
    } catch (error) {
      debugPrint('MoodMusic historial: $error');
      if (!_disposed && session == _session) {
        _failed[record.id] = record;
      }
    } finally {
      if (!_disposed && session == _session) {
        _pending--;
        _refreshStatus();
      }
    }
  }

  bool get canRetry => _failed.isNotEmpty && _pending == 0;
  void retry() {
    final uid = _uid;
    if (uid == null || !canRetry) {
      return;
    }
    final records = _failed.values.toList();
    _failed.clear();
    for (final record in records) {
      unawaited(_send(uid, record, _session));
    }
  }

  void dispose() {
    _disposed = true;
    _timer.cancel();
    audio.changes.removeListener(_sync);
    _clock.stop();
    status.dispose();
  }
}
