import 'access_label.dart';
import 'user_likes_screen.dart';
import 'package:flutter/material.dart';
import 'local_songs_screen.dart';
import '../../../app/app_controller.dart';
import '../domain/admin_access_repository.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key, required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller.adminAccess,
    builder: (context, _) {
      if (!controller.isAdmin) {
        return Scaffold(appBar: AppBar(title: const Text('Administración')),
          body: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(
            mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.lock_outline, size: 48), const SizedBox(height: 16),
              Text(controller.adminAccess.error ?? 'No tienes acceso de administrador confirmado. Comprueba tu conexión o vuelve a iniciar sesión.', textAlign: TextAlign.center),
              TextButton(onPressed: controller.adminAccess.retry, child: const Text('Reintentar')),
            ]))));
      }
      return _AdminProfiles(repository: controller.adminAccess.repository!, controller: controller);
    },
  );
}

class _AdminProfiles extends StatefulWidget {
  const _AdminProfiles({required this.repository, required this.controller});
  final AppController controller;
  final AdminAccessRepository repository;
  @override
  State<_AdminProfiles> createState() => _AdminProfilesState();
}
class _AdminProfilesState extends State<_AdminProfiles> {
  late Stream<List<AdminProfile>> _profiles = widget.repository.watchProfiles();
  String _query = '';
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Panel de administrador')),
    body: ListView(padding: const EdgeInsets.all(24), children: [
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFFB52693)])),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.graphic_eq, color: Colors.white, size: 36), SizedBox(height: 12),
          Text('MoodMusic Studio', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 8), Text('Tu comunidad, en un solo lugar.', style: TextStyle(color: Colors.white)),
        ])),
      const SizedBox(height: 24),
      Card(child: ListTile(leading: const Icon(Icons.library_music), title: const Text('Administrar canciones'), subtitle: const Text('Agregar, editar y eliminar canciones'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => LocalSongsScreen(controller: widget.controller))))),
      const SizedBox(height: 24),
      Text('Usuarios', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 16),
      TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Buscar en esta lista'),
        onChanged: (value) => setState(() => _query = value.trim().toLowerCase())),
      const SizedBox(height: 16),
      StreamBuilder<List<AdminProfile>>(stream: _profiles, builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(children: [const Text('No se pudieron cargar los perfiles. Revisa tu conexión y los permisos.'),
            TextButton(onPressed: () => setState(() { _profiles = widget.repository.watchProfiles(); }), child: const Text('Reintentar'))]);
        }
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final profiles = snapshot.data ?? [];
        if (profiles.isEmpty) return const Text('No hay usuarios para mostrar.');
        final filtered = profiles.where((p) => p.name.toLowerCase().contains(_query) || p.email.toLowerCase().contains(_query)).toList();
        if (filtered.isEmpty) return const Text('No hay coincidencias en esta lista.');
        return Column(children: filtered.map((p) => Card(child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text(p.name), isThreeLine: true,
          subtitle: Text('${p.email}\n${accessLabel(p.lastAccessAt)}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) =>
            UserLikesScreen(controller: widget.controller, profile: p))),
        ))).toList());
      }),
    ]),
  );
}
