import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Decorative motion, not an audio spectrum.
class MusicPulse extends StatefulWidget {
  const MusicPulse({super.key, required this.builder, this.active = true, this.child});
  final Widget Function(BuildContext, double, Widget?) builder;
  final bool active;
  final Widget? child;
  @override
  State<MusicPulse> createState() => _MusicPulseState();
}

class _MusicPulseState extends State<MusicPulse>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _motion = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 2400));
  bool _foreground = true;
  bool _enabled = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    _foreground = state == null || state == AppLifecycleState.resumed;
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _enabled = !MediaQuery.of(context).disableAnimations && TickerMode.valuesOf(context).enabled;
    _sync();
  }
  @override
  void didUpdateWidget(covariant MusicPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _sync();
  }
  void _sync() {
    if (widget.active && _enabled && _foreground) {
      if (!_motion.isAnimating) _motion.repeat();
    } else {
      _motion.stop();
    }
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _motion.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => RepaintBoundary(child: AnimatedBuilder(
    animation: _motion, child: widget.child,
    builder: (context, child) => widget.builder(context, _motion.value, child)));
}

class MusicEntrance extends StatelessWidget {
  const MusicEntrance({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic, child: child,
      builder: (context, value, child) => Opacity(opacity: value,
        child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child)));
  }
}

class MusicEmblem extends StatelessWidget {
  const MusicEmblem({super.key, this.size = 88});
  final double size;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: MusicPulse(
    child: Icon(Icons.graphic_eq_rounded, size: size * .55, color: Colors.white),
    builder: (context, phase, child) {
      final pulse = (math.sin(phase * math.pi * 2) + 1) / 2;
      return Transform.scale(scale: 1 + pulse * .035, child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * .32),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF8B5CF6), Color(0xFFCE3C9D)]),
          boxShadow: [BoxShadow(color: const Color(0xFF9B66FF).withAlpha(45 + (pulse * 30).round()),
            blurRadius: 24 + pulse * 12, spreadRadius: 2)]),
        child: child));
    }));
}

class MusicBars extends StatelessWidget {
  const MusicBars({super.key, required this.active});
  final bool active;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(child: MusicPulse(
    active: active, builder: (context, phase, _) => SizedBox(height: 32,
      child: Row(mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(17, (i) {
          final wave = active ? (math.sin(phase * math.pi * 4 + i * .72) + 1) / 2 : .12;
          return Container(width: 4, height: 5 + wave * 25,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4),
              color: Color.lerp(const Color(0xFF9B66FF), const Color(0xFFEC4899), i / 16)));
        })))));
}
