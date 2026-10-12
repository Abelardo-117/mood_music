import 'dart:async';
import '../core/widgets/music_motion.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/domain/auth_repository.dart';
import '../features/auth/presentation/auth_screen.dart';
import 'app_controller.dart';
import 'app_shell.dart';

class MoodMusicApp extends StatefulWidget {
  const MoodMusicApp({super.key, required this.controller, required this.auth});
  final AppController controller;
  final AuthRepository auth;
  @override
  State<MoodMusicApp> createState() => _MoodMusicAppState();
}
class _MoodMusicAppState extends State<MoodMusicApp> {
  bool _intro = true;
  Timer? _timer;
  AppController get controller => widget.controller;
  AuthRepository get auth => widget.auth;
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _intro = false);
    });
  }
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => MaterialApp(
      // Cambiar de cuenta o salir descarta las rutas abiertas de la sesión anterior.
      key: ValueKey('${controller.userId ?? "guest"}:${controller.demoOpen}:${controller.sessionError}'),
      title: 'MoodMusic', debugShowCheckedModeBanner: false,
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark), themeMode: controller.themeMode,
      builder: (context, child) => Stack(children: [
        ExcludeSemantics(excluding: _intro,
          child: IgnorePointer(ignoring: _intro, child: child ?? const SizedBox.shrink())),
        if (_intro) Positioned.fill(child: Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: const SafeArea(child: Center(child: MusicEntrance(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              MusicEmblem(size: 104),
              SizedBox(height: 28),
              Text('MoodMusic', style: TextStyle(fontSize: 34,
                fontWeight: FontWeight.w900, letterSpacing: -1)),
            ]),
          ))))),
      ]),
      home: !controller.sessionReady
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : controller.sessionError
            ? const Scaffold(body: Center(child: Padding(padding: EdgeInsets.all(24),
                child: Text('No se pudo recuperar la sesión. Cierra y vuelve a abrir la aplicación.'))))
            : controller.isSignedIn || controller.demoOpen
              ? AppShell(controller: controller)
              : AuthScreen(controller: controller, repository: auth),
    ),
  );
}
