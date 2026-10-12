import 'package:flutter/material.dart';
import '../../../app/app_controller.dart';
import '../../activity/domain/listening_repository.dart';
import '../domain/admin_access_repository.dart';

class UserHistoryScreen extends StatefulWidget {
  const UserHistoryScreen({super.key, required this.controller, required this.profile});
  final AppController controller;
  final AdminProfile profile;
  @override
  State<UserHistoryScreen> createState() => _UserHistoryScreenState();
}

class _UserHistoryScreenState extends State<UserHistoryScreen> {
  Stream<List<ListeningRecord>>? _records;
  @override
  void initState() {
    super.initState();
    _load();
    widget.controller.adminAccess.addListener(_accessChanged);
  }
  void _load() {
    _records = widget.controller.isAdmin
      ? widget.controller.history?.watchRecent(widget.profile.uid) : null;
  }
  void _accessChanged() {
    if (mounted) {
      setState(_load);
    }
  }
  @override
  void dispose() {
    widget.controller.adminAccess.removeListener(_accessChanged);
    super.dispose();
  }
  String _date(DateTime value) {
    final d = value.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} · ${two(d.hour)}:${two(d.minute)}';
  }
  List<MapEntry<String, int>> _rank(Map<String, int> values) => values.entries.toList()
    ..sort((a, b) {
      final result = b.value.compareTo(a.value);
      return result != 0 ? result : a.key.compareTo(b.key);
    });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Historial de escucha')),
    body: !widget.controller.isAdmin
      ? const Center(child: Text('Se necesita acceso de administrador.'))
      : _records == null ? const Center(child: Text('El historial no está disponible.'))
      : StreamBuilder<List<ListeningRecord>>(stream: _records, builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(
            mainAxisSize: MainAxisSize.min, children: [
              const Text('No se pudo cargar el historial. Revisa tu conexión e inténtalo nuevamente.'),
              TextButton(onPressed: () => setState(_load), child: const Text('Reintentar')),
            ],
          )));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final records = snapshot.data!;
        final songCounts = <String, int>{};
        final genreCounts = <String, int>{};
        final labels = <String, String>{};
        for (final record in records) {
          final song = record.song;
          songCounts.update(song.id, (n) => n + 1, ifAbsent: () => 1);
          genreCounts.update(song.genre, (n) => n + 1, ifAbsent: () => 1);
          labels.putIfAbsent(song.id, () => '${song.title} · ${song.artist}');
        }
        final topSongs = _rank(songCounts).take(5);
        final topGenres = _rank(genreCounts);
        return ListView(padding: const EdgeInsets.all(24), children: [
          Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFFB52693)])),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.headphones_rounded, color: Colors.white, size: 36),
              const SizedBox(height: 12),
              Text(widget.profile.name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              Text(widget.profile.email, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 16),
              Text('${records.length} escuchas recientes', style: const TextStyle(color: Colors.white, fontSize: 20)),
            ])),
          if (records.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 28),
            child: Text('Todavía no hay escuchas registradas.')),
          if (records.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('Géneros destacados recientes', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: topGenres.map((g) => Chip(
              avatar: const Icon(Icons.music_note, size: 18), label: Text('${g.key}: ${g.value}'),
            )).toList()),
            const SizedBox(height: 24),
            Text('Canciones destacadas recientes', style: Theme.of(context).textTheme.titleLarge),
            ...topSongs.map((entry) => Card(child: ListTile(
              leading: const Icon(Icons.equalizer), title: Text(labels[entry.key]!),
              trailing: Text('${entry.value}', style: Theme.of(context).textTheme.titleLarge),
            ))),
            const SizedBox(height: 24),
            Text('Últimas 100 escuchas', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...records.map((record) => Card(child: ListTile(
              leading: const Icon(Icons.history_rounded),
              title: Text(record.song.title), isThreeLine: true,
              subtitle: Text('${record.song.artist} · ${record.song.genre}\n${_date(record.listenedAt)}'),
            ))),
          ],
        ]);
      }),
  );
}
