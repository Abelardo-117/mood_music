import 'dart:io';
import 'package:flutter/material.dart';
class SongCover extends StatelessWidget {
  const SongCover({super.key, this.path, this.size = 52});
  final String? path;
  final double size;
  @override
  Widget build(BuildContext context) {
    final fallback = Container(width: size, height: size, decoration: const BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF7135BC), Color(0xFFBC237B)])),
      child: Icon(Icons.graphic_eq, color: Colors.white, size: size * .45));
    return ClipRRect(borderRadius: BorderRadius.circular(16), child: path == null ? fallback :
      Image.file(File(path!), width: size, height: size, fit: BoxFit.cover,
        cacheWidth: 800, errorBuilder: (_, error, stack) => fallback));
  }
}
