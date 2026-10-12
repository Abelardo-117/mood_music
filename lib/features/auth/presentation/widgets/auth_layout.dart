import '../../../../core/widgets/music_motion.dart';
import 'package:flutter/material.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.title, required this.subtitle,
    required this.child, this.canGoBack = false});
  final String title, subtitle;
  final Widget child;
  final bool canGoBack;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(body: DecoratedBox(
      decoration: BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: dark ? const [Color(0xFF241438), Color(0xFF0B0B14), Color(0xFF171025)]
          : const [Color(0xFFEDE5FF), Color(0xFFFAF8FF), Color(0xFFFCEAF5)],
      )),
      child: SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(24, 16, 24, 30), child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [if (canGoBack) const BackButton(), Expanded(child: Center(child: FittedBox(fit: BoxFit.scaleDown, child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: 'Mood', style: TextStyle(color: dark ? Colors.white : const Color(0xFF201332))),
                  const TextSpan(text: 'Music', style: TextStyle(color: Color(0xFF9B66FF))),
                ]),
                style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -1.2),
              )))),
              if (canGoBack) const SizedBox(width: 48)]),
            const SizedBox(height: 18),
            const Center(child: MusicEmblem(size: 76)),
            const SizedBox(height: 18),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 26),
            Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(
              color: dark ? const Color(0xFF191522) : Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: dark ? const Color(0xFF352945) : const Color(0xFFE8DFF3))), child: MusicEntrance(child: child)),
          ],
        )),
      ))),
    ));
  }
}
