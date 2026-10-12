import 'package:flutter/material.dart';

class PlaybackSeekBar extends StatefulWidget {
  const PlaybackSeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    required this.readPosition,
    this.enabled = true,
  });
  final Duration position;
  final Duration duration;
  final Future<void> Function(Duration) onSeek;
  final Duration Function() readPosition;
  final bool enabled;
  @override
  State<PlaybackSeekBar> createState() => _PlaybackSeekBarState();
}

class _PlaybackSeekBarState extends State<PlaybackSeekBar> {
  double? _preview;
  bool _seeking = false;
  Duration? _settledPosition;
  String _time(Duration value) =>
      '${value.inMinutes}:${(value.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  void didUpdateWidget(covariant PlaybackSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.position != oldWidget.position) _settledPosition = null;
    if (!widget.enabled && !_seeking) _preview = null;
  }

  Future<void> _commit(double value) async {
    if (_seeking || !widget.enabled || widget.duration <= Duration.zero) return;
    final target = value.clamp(0.0, widget.duration.inMilliseconds.toDouble()).round();
    setState(() {
      _preview = target.toDouble();
      _seeking = true;
    });
    try {
      await widget.onSeek(Duration(milliseconds: target));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo cambiar la posición. Intenta nuevamente.')));
      }
    } finally {
      if (mounted) {
        setState(() {
          // Read the player after completion rather than a stale stream snapshot.
          _settledPosition = widget.readPosition();
          _preview = null;
          _seeking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.duration.inMilliseconds.toDouble();
    final max = total > 0 ? total : 1.0;
    final value = (_preview ?? (_settledPosition ?? widget.position).inMilliseconds.toDouble())
        .clamp(0.0, max).toDouble();
    final enabled = widget.enabled && total > 0 && !_seeking;
    return Column(children: [
      Slider(
        value: value,
        max: max,
        label: _time(Duration(milliseconds: value.round())),
        semanticFormatterCallback: (value) => _time(Duration(milliseconds: value.round())),
        onChanged: !enabled ? null : (value) => setState(() => _preview = value),
        onChangeEnd: !enabled ? null : _commit,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(_time(Duration(milliseconds: value.round()))),
        Text(_time(widget.duration)),
      ]),
    ]);
  }
}
