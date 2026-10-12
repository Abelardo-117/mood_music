import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_music/app/app_controller.dart';
import 'package:mood_music/core/storage/preferences_service.dart';
import 'package:mood_music/features/catalog/domain/catalog_repository.dart';
import 'package:mood_music/features/catalog/domain/song.dart';
import 'package:mood_music/features/catalog/presentation/catalog_screen.dart';

class _Catalog implements CatalogRepository {
  @override
  List<Song> get songs => const [
    Song(id: 'a', title: 'Canción alegre', artist: 'Uno', genre: 'Pop', moods: ['Feliz']),
    Song(id: 'b', title: 'Canción tranquila', artist: 'Dos', genre: 'Rock', moods: ['Relajado']),
    Song(id: 'c', title: 'Canción anterior', artist: 'Tres', genre: 'Rock'),
  ];
}
void main() {
  testWidgets('Inicio filtra por ánimo sin buscador; Buscar conserva búsqueda', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final controller = AppController(await PreferencesService.create(), _Catalog());
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: CatalogScreen(controller: controller))));
    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Feliz'));
    await tester.pump();
    expect(find.text('Canción alegre'), findsOneWidget);
    expect(find.text('Canción tranquila'), findsNothing);
    expect(find.text('Canción anterior'), findsNothing);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Todas'));
    await tester.pump();
    expect(find.text('Canción anterior'), findsOneWidget);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: CatalogScreen(
      key: const ValueKey('buscar'), controller: controller, searchPage: true))));
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'tranquila');
    await tester.pump();
    expect(find.text('Canción tranquila'), findsOneWidget);
    expect(find.text('Canción alegre'), findsNothing);
  });
}
