import 'package:flutter/material.dart';
import 'song_cover.dart';
import '../../../app/app_controller.dart';
import '../../../core/widgets/feedback.dart';
import '../domain/song.dart';
import '../../player/presentation/player_screen.dart';
class SongTile extends StatelessWidget {
  const SongTile({super.key, required this.song, required this.controller, this.playlist});
  final Song song;
  final List<Song>? playlist;
  final AppController controller;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(
    contentPadding: const EdgeInsets.all(12),
    leading: SongCover(path: song.coverUrl),
    title: Text(song.title), subtitle: Text('${song.artist} · ${song.genre}'),
    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PlayerScreen(song: song, controller: controller, playlist: playlist))),
    trailing: IconButton(tooltip: controller.favoriteSaving(song) ? 'Guardando favorito' : 'Cambiar favorito', onPressed: controller.favoriteSaving(song) ? null : () => runAction(context, () => controller.toggleFavorite(song)),
      icon: controller.favoriteSaving(song) ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(controller.isFavorite(song) ? Icons.favorite : Icons.favorite_border, color: const Color(0xFFEC4899))),
  ));
}
