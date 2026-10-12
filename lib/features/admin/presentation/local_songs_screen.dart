import 'package:flutter/material.dart';
import '../../../app/app_controller.dart';
import '../../../core/widgets/feedback.dart';
import '../../catalog/data/local_catalog_repository.dart';
import '../../catalog/domain/song.dart';
import '../../catalog/presentation/song_cover.dart';
import '../../upload/presentation/upload_song_screen.dart';
class LocalSongsScreen extends StatelessWidget {
  const LocalSongsScreen({super.key, required this.controller});
  final AppController controller;
  Future<void> _delete(BuildContext context, Song song) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Eliminar canción'), content: Text('¿Eliminar “${song.title}” de tu biblioteca?'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar'))]));
    if (confirmed != true || !context.mounted || !controller.isAdmin) return;
    await runAction(context, () async {
      await controller.audio?.stop();
      if (!controller.isAdmin) return;
      await (controller.catalog as LocalCatalogRepository).remove(song);
    });
  }
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: controller, builder: (context, _) => Scaffold(
    appBar: AppBar(title: const Text('Administrar canciones')),
    floatingActionButton: !controller.isAdmin ? null : FloatingActionButton.extended(
      onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => UploadSongScreen(controller: controller))),
      icon: const Icon(Icons.add), label: const Text('Agregar canción')),
    body: !controller.isAdmin ? const Center(child: Text('Se necesita acceso de administrador.')) :
      ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), children: [
        if (controller.catalog.songs.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Agrega tu primer audio con el botón de abajo.')),
        ...controller.catalog.songs.map((song) => Card(child: ListTile(
          leading: SongCover(path: song.coverUrl), title: Text(song.title), subtitle: Text('${song.artist} · ${song.genre}'),
          trailing: PopupMenuButton<String>(onSelected: (action) {
            if (action == 'delete') { _delete(context, song); }
            else { Navigator.push(context, MaterialPageRoute<void>(builder: (_) => UploadSongScreen(controller: controller, song: song))); }
          }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Editar')), PopupMenuItem(value: 'delete', child: Text('Eliminar'))]),
        ))),
      ]),
  ));
}
