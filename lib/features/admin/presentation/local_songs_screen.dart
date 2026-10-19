import 'package:flutter/material.dart';
import '../../../app/app_controller.dart';
import '../../../core/widgets/feedback.dart';
import '../../catalog/data/account_catalog_repository.dart';
import '../../catalog/domain/song.dart';
import '../../catalog/presentation/song_cover.dart';
import '../../upload/presentation/upload_song_screen.dart';
class LocalSongsScreen extends StatelessWidget {
  const LocalSongsScreen({super.key, required this.controller});
  final AppController controller;
  Future<void> _delete(BuildContext context, Song song) async {
    final owner = controller.userId;
    final repo = controller.localCatalog;
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Eliminar canción'), content: Text('¿Eliminar “${song.title}” de tu biblioteca?'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar'))]));
    if (confirmed != true || !context.mounted || !controller.canManageMusic || controller.userId != owner || controller.localCatalog != repo) return;
    await runAction(context, () async {
      await controller.audio?.stop();
      if (!controller.canManageMusic || controller.userId != owner || controller.localCatalog != repo) return;
      await repo!.remove(song);
    });
  }
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: controller, builder: (context, _) => Scaffold(
    appBar: AppBar(title: const Text('Mi música')),
    floatingActionButton: !controller.canManageMusic ? null : FloatingActionButton.extended(
      onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => UploadSongScreen(controller: controller))),
      icon: const Icon(Icons.add), label: const Text('Agregar canción')),
    body: !controller.canManageMusic ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(controller.catalog is AccountCatalogRepository && (controller.catalog as AccountCatalogRepository).loading
          ? 'Abriendo tu biblioteca…' : 'No se pudo abrir tu biblioteca.'),
        if (controller.isSignedIn) TextButton(onPressed: controller.retryLibrary, child: const Text('Reintentar')),
      ])) :
      ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), children: [
        if (controller.localCatalog!.songs.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Agrega tu primer audio con el botón de abajo.')),
        ...controller.localCatalog!.songs.map((song) => Card(child: ListTile(
          leading: SongCover(path: song.coverUrl), title: Text(song.title), subtitle: Text('${song.artist} · ${song.genre}'),
          trailing: PopupMenuButton<String>(onSelected: (action) {
            if (action == 'delete') { _delete(context, song); }
            else { Navigator.push(context, MaterialPageRoute<void>(builder: (_) => UploadSongScreen(controller: controller, song: song))); }
          }, itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Editar')), PopupMenuItem(value: 'delete', child: Text('Eliminar'))]),
        ))),
      ]),
  ));
}
