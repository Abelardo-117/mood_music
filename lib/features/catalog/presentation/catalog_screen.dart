import 'package:flutter/material.dart';
import '../../../app/app_controller.dart';
import '../domain/music_moods.dart';
import '../domain/song.dart';
import '../../player/presentation/player_screen.dart';
import 'song_tile.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, required this.controller, this.searchPage = false, this.favoritesOnly = false});
  final AppController controller;
  final bool searchPage, favoritesOnly;
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}
class _CatalogScreenState extends State<CatalogScreen> {
  String query = '', genre = 'Todo';
  String? mood;
  bool get isHome => !widget.searchPage && !widget.favoritesOnly;
  static const moodIcons = [Icons.sentiment_satisfied_alt, Icons.water_drop_outlined,
    Icons.spa_outlined, Icons.bolt, Icons.headphones_outlined];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.controller,
    builder: (context, _) {
      final catalog = widget.controller.catalog.songs;
      final songs = catalog.where((s) =>
        (!widget.favoritesOnly || widget.controller.isFavorite(s)) &&
        (!isHome || mood == null || s.moods.contains(mood)) &&
        (!widget.searchPage || ((genre == 'Todo' || s.genre == genre) &&
          '${s.title} ${s.artist} ${s.genre}'.toLowerCase().contains(query.toLowerCase())))).toList();
      final playable = songs.where((s) => s.audioUrl?.isNotEmpty == true).toList();
      return ListView(padding: const EdgeInsets.all(22), children: [
        Text(widget.favoritesOnly ? 'Tus favoritos' : widget.searchPage ? 'Encuentra tu ritmo' : 'Hola, ${widget.controller.name}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        if (widget.searchPage) ...[
          TextField(onChanged: (v) => setState(() => query = v.trim()),
            decoration: const InputDecoration(hintText: 'Canción, artista o género', prefixIcon: Icon(Icons.search))),
          const SizedBox(height: 14),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children:
            {'Todo', ...catalog.map((s) => s.genre)}.map((g) => Padding(padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(label: Text(g), selected: genre == g,
                onSelected: (_) => setState(() => genre = g)))).toList())),
          const SizedBox(height: 20),
        ],
        if (isHome) ...[
          Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(colors: [Color(0xFF6925CC), Color(0xFFAF1689)])),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.graphic_eq_rounded, size: 48, color: Colors.white),
              SizedBox(height: 16),
              Text('¿Cómo te sientes hoy?', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Elige tu ánimo. Encuentra tu ritmo.', style: TextStyle(color: Colors.white)),
            ])),
          const SizedBox(height: 20),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ChoiceChip(label: const Text('Todas'), selected: mood == null,
              onSelected: (_) => setState(() => mood = null)),
            for (var i = 0; i < musicMoods.length; i++)
              ChoiceChip(avatar: Icon(moodIcons[i], size: 20),
                label: Text(musicMoods[i]), selected: mood == musicMoods[i],
                onSelected: (selected) => setState(() => mood = selected ? musicMoods[i] : null)),
          ]),
          const SizedBox(height: 24),
          Text(mood == null ? 'Tu biblioteca' : 'Música · $mood', style: Theme.of(context).textTheme.titleLarge),
          Text('${songs.length} ${songs.length == 1 ? 'canción' : 'canciones'}'),
          if (playable.isNotEmpty && widget.controller.audio != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: () => _play(context, playable),
              icon: const Icon(Icons.play_arrow_rounded), label: const Text('Reproducir lista')),
          ],
          const SizedBox(height: 12),
        ],
        if (songs.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 24), child: Text(
          isHome && mood != null
            ? widget.controller.isAdmin
              ? 'Aún no hay canciones para este ánimo. Asígnalo al agregar o editar una canción en Administrar canciones.'
              : 'Aún no hay canciones para este ánimo. Prueba otro o selecciona Todas.'
            : 'No hay canciones que coincidan.')),
        ...songs.map((s) => SongTile(song: s, controller: widget.controller, playlist: playable)),
      ]);
    },
  );

  void _play(BuildContext context, List<Song> songs) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) =>
      PlayerScreen(song: songs.first, controller: widget.controller, playlist: songs)));
  }
}
