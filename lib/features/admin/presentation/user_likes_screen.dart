import 'user_history_screen.dart';
import 'package:flutter/material.dart';
import '../../../app/app_controller.dart';
import '../../catalog/domain/song.dart';
import '../domain/admin_access_repository.dart';

class UserLikesScreen extends StatefulWidget {
  const UserLikesScreen({super.key, required this.controller, required this.profile});
  final AppController controller;
  final AdminProfile profile;
  @override
  State<UserLikesScreen> createState() => _UserLikesScreenState();
}
class _UserLikesScreenState extends State<UserLikesScreen> {
  Stream<List<Song>>? _likes;
  @override
  void initState() {
    super.initState();
    _likes = widget.controller.likes?.watchLikes(widget.profile.uid);
    widget.controller.adminAccess.addListener(_accessChanged);
  }
  void _accessChanged() {
    if (!widget.controller.isAdmin) {
      // Desmonta StreamBuilder y cancela la consulta al perder el permiso.
      setState(() => _likes = null);
    } else {
      setState(() => _likes ??= widget.controller.likes?.watchLikes(widget.profile.uid));
    }
  }
  @override
  void dispose() {
    widget.controller.adminAccess.removeListener(_accessChanged);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.profile.name)),
    body: !widget.controller.isAdmin
      ? const Center(child: Text('Se necesita acceso de administrador.'))
      : _likes == null ? const Center(child: Text('Los favoritos no están disponibles.'))
      : StreamBuilder<List<Song>>(stream: _likes, builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(
            mainAxisSize: MainAxisSize.min, children: [
              const Text('No se pudieron cargar los favoritos. Revisa tu conexión e inténtalo nuevamente.'),
              TextButton(onPressed: () => setState(() {
                _likes = widget.controller.likes?.watchLikes(widget.profile.uid);
              }), child: const Text('Reintentar')),
            ],
          )));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final songs = snapshot.data!;
        final counts = <String, int>{};
        for (final song in songs) {
          counts.update(song.genre, (n) => n + 1, ifAbsent: () => 1);
        }
        final genres = counts.entries.toList()..sort((a, b) {
          final result = b.value.compareTo(a.value);
          return result != 0 ? result : a.key.compareTo(b.key);
        });
        return ListView(padding: const EdgeInsets.all(24), children: [
          Text(widget.profile.email),
          const SizedBox(height: 16),
          FilledButton.icon(icon: const Icon(Icons.history_rounded),
            label: const Text('Ver historial de escucha'),
            onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) =>
              UserHistoryScreen(controller: widget.controller, profile: widget.profile)))),
          const SizedBox(height: 20),
          Text('Géneros favoritos', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          if (songs.isEmpty) const Text('Todavía no hay favoritos.'),
          Wrap(spacing: 8, runSpacing: 8, children: genres.map((g) => Chip(
            avatar: const Icon(Icons.music_note, size: 18), label: Text('${g.key}: ${g.value}'),
          )).toList()),
          const SizedBox(height: 24),
          Text('Favoritos recientes (${songs.length}/100)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          ...songs.map((song) => Card(child: ListTile(
            leading: const Icon(Icons.favorite, color: Color(0xFFEC4899)),
            title: Text(song.title), subtitle: Text('${song.artist} · ${song.genre}'),
          ))),
        ]);
      }),
  );
}
