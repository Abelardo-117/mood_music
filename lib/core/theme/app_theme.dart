import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const purple = Color(0xFF8B5CF6);
  static const pink = Color(0xFFEC4899);
  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(seedColor: purple, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
      }),
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF0B0B14) : const Color(0xFFF7F5FC),
      appBarTheme: const AppBarTheme(centerTitle: false),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: dark ? const Color(0xFF452080) : const Color(0xFFE9DFFF),
      ),
    );
  }
}
