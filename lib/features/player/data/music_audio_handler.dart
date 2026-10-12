import 'dart:async';
import 'dart:io';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../../catalog/domain/song.dart';
import '../domain/playback_queue.dart';

/// Un solo reproductor por aplicación. Las pantallas no lo destruyen.
class MusicAudioHandler extends BaseAudioHandler {
  MusicAudioHandler() {
    player.playbackEventStream
        .listen((_) => _publish(), onError: (Object e) => _fail(e));
    player.playerStateStream.listen((_) => _publish());
    player.currentIndexStream.listen((_) {
      _publishItem();
      _publish();
    });
    player.durationStream.listen((_) => _publishItem());
    player.errorStream.listen(_fail);
  }
  final AudioPlayer player = AudioPlayer();
  final ValueNotifier<int> changes = ValueNotifier(0);
  List<Song> _songs = const [];
  Future<void> _operations = Future<void>.value();
  int _generation = 0;
  bool _active = false;
  bool loading = false;
  String? error;
  List<Song> get songs => _songs;
  int get index => player.currentIndex ?? 0;
  Song? get currentSong => !_active || _songs.isEmpty
      ? null
      : _songs[index.clamp(0, _songs.length - 1).toInt()];
  bool get hasPrevious => _active && index > 0;
  bool get hasNext => _active && index + 1 < _songs.length;
  bool get isPlaying =>
      player.playing && player.processingState != ProcessingState.completed;
  void _changed() => changes.value++;
  MediaItem _item(Song s, {Duration? duration}) => MediaItem(
        id: s.id,
        title: s.title,
        artist: s.artist,
        genre: s.genre,
        artUri: s.coverUrl == null ? null : File(s.coverUrl!).uri,
        duration: duration,
      );
  void _publishItem() {
    final s = currentSong;
    mediaItem.add(s == null ? null : _item(s, duration: player.duration));
    _changed();
  }

  void _publish() {
    playbackState.add(PlaybackState(
      controls: [
        if (hasPrevious) MediaControl.skipToPrevious,
        isPlaying ? MediaControl.pause : MediaControl.play,
        if (hasNext) MediaControl.skipToNext,
        MediaControl.stop,
      ],
      systemActions: const {MediaAction.seek},
      processingState: !_active
          ? AudioProcessingState.idle
          : error != null
              ? AudioProcessingState.error
              : loading
                  ? AudioProcessingState.loading
                  : switch (player.processingState) {
                      ProcessingState.idle => AudioProcessingState.idle,
                      ProcessingState.loading => AudioProcessingState.loading,
                      ProcessingState.buffering =>
                        AudioProcessingState.buffering,
                      ProcessingState.ready => AudioProcessingState.ready,
                      ProcessingState.completed =>
                        AudioProcessingState.completed,
                    },
      playing: _active && isPlaying && error == null,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: _active ? index : null,
      errorCode: error == null ? null : 1,
      errorMessage: error,
    ));
    _changed();
  }

  void _fail(Object e) {
    if (!_active) return;
    debugPrint('MoodMusic audio: $e');
    error = 'No se pudo reproducir este archivo. Intenta abrir otra canción.';
    loading = false;
    unawaited(player.pause().catchError((Object _) {}));
    _publish();
  }

  Future<void> _enqueue(Future<void> Function(int generation) action) {
    final generation = _generation;
    final next = _operations.then((_) async {
      if (generation != _generation) return;
      try {
        await action(generation);
      } catch (e) {
        if (generation == _generation) _fail(e);
      }
    });
    _operations = next;
    return next;
  }

  Future<void> open(List<Song> catalog, Song selected) {
    if (currentSong?.id == selected.id && error == null) {
      return Future<void>.value();
    }
    return _enqueue((generation) async {
      await player.stop();
      if (generation != _generation) return;
      _songs = buildPlaybackQueue(catalog, selected);
      _active = _songs.isNotEmpty;
      if (!_active) return;
      error = null;
      loading = true;
      queue.add(_songs.map((s) => _item(s)).toList());
      _publish();
      final selectedIndex = _songs.indexWhere((s) => s.id == selected.id);
      await player.setAudioSources(
        _songs.map((s) => AudioSource.uri(File(s.audioUrl!).uri)).toList(),
        initialIndex: selectedIndex < 0 ? 0 : selectedIndex,
      );
      if (generation != _generation) return;
      loading = false;
      _publishItem();
      _publish();
      _start(generation);
    });
  }

  void _start(int generation) {
    if (generation != _generation || !_active) return;
    // play() completes at pause/end; do not block the command queue on it.
    unawaited(player.play().catchError((Object e) {
      if (generation == _generation) _fail(e);
    }));
  }

  @override
  Future<void> play() => _enqueue((generation) async {
        if (!_active || error != null) return;
        if (player.processingState == ProcessingState.completed) {
          await player.seek(Duration.zero);
        }
        _start(generation);
      });
  @override
  Future<void> pause() => _enqueue((_) async {
        await player.pause();
      });
  @override
  Future<void> seek(Duration position) => _enqueue((_) async {
        if (_active) await player.seek(position);
      });
  @override
  Future<void> skipToQueueItem(int index) => _enqueue((generation) async {
        if (!_active || index < 0 || index >= _songs.length) return;
        error = null;
        await player.seek(Duration.zero, index: index);
        _start(generation);
      });
  @override
  Future<void> skipToNext() => skipToQueueItem(index + 1);
  @override
  Future<void> skipToPrevious() => skipToQueueItem(index - 1);
  @override
  Future<void> stop() {
    ++_generation; // Cancel queued loads/plays from the previous session.
    _active = false;
    loading = false;
    error = null;
    _songs = const [];
    queue.add(const []);
    mediaItem.add(null);
    _publish();
    // Stop immediately as well, so an in-flight load can be interrupted.
    final cancel = player.stop().catchError((Object _) {});
    return _enqueue((_) async {
      await cancel;
      await player.stop();
      _publish();
    });
  }
}
