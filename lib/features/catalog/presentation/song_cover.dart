import 'dart:io';
import 'package:flutter/material.dart';

class SongCover extends StatelessWidget {
  const SongCover({super.key, this.path, this.size = 52});
  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size, height: size,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF7135BC), Color(0xFFBC237B)])),
      child: Icon(Icons.graphic_eq, color: Colors.white, size: size * .45));
    final source = path;
    Widget cover = fallback;
    if (source != null && source.isNotEmpty) {
      final uri = Uri.tryParse(source);
      if (uri != null && uri.scheme == 'https' && uri.host.isNotEmpty) {
        cover = Image.network(source, key: ValueKey(source),
          width: size, height: size, fit: BoxFit.cover, cacheWidth: 800,
          frameBuilder: (_, child, frame, wasSynchronouslyLoaded) =>
              wasSynchronouslyLoaded || frame != null ? child : fallback,
          errorBuilder: (_, error, stack) => fallback);
      } else {
        cover = Image.file(File(source), key: ValueKey(source),
          width: size, height: size, fit: BoxFit.cover, cacheWidth: 800,
          errorBuilder: (_, error, stack) => fallback);
      }
    }
    return ClipRRect(borderRadius: BorderRadius.circular(16), child: cover);
  }
}
