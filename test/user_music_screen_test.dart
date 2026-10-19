import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mood_music/app/app_controller.dart';
import 'package:mood_music/core/storage/preferences_service.dart';
import 'package:mood_music/features/catalog/data/account_catalog_repository.dart';
import 'package:mood_music/features/admin/presentation/local_songs_screen.dart';
import 'package:mood_music/features/upload/presentation/upload_song_screen.dart';

void main() {
  testWidgets('un usuario sin rol admin puede agregar música y salir bloquea el formulario', (tester) async {
    SharedPreferences.setMockInitialValues({});
    late Directory root;
    late AccountCatalogRepository catalog;
    late AppController controller;
    // File I/O must run outside the widget test's simulated async environment.
    await tester.runAsync(() async {
      root = await Directory.systemTemp.createTemp('music_ui_');
      catalog = AccountCatalogRepository(root: root);
      controller = AppController(await PreferencesService.create(), catalog);
      controller.userId = 'ordinary-user';
      await catalog.bind(controller.userId);
    });
    expect(tester.takeException(), isNull);
    addTearDown(() async {
      controller.dispose();
      catalog.dispose();
      await tester.runAsync(() => root.delete(recursive: true));
    });
    expect(controller.isAdmin, isFalse);
    await tester.pumpWidget(MaterialApp(home: LocalSongsScreen(controller: controller)));
    expect(find.text('Agregar canción'), findsOneWidget);
    await tester.tap(find.text('Agregar canción'));
    await tester.pumpAndSettle();
    expect(find.byType(UploadSongScreen), findsOneWidget);
    expect(controller.canManageMusic, isTrue);
    expect(find.byType(Form), findsOneWidget);
    // The save button is below the initial viewport on small screens.
    await tester.scrollUntilVisible(
      find.text('Guardar canción'),
      300,
      scrollable: find.descendant(
        of: find.byType(UploadSongScreen),
        matching: find.byWidgetPredicate((widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down),
      ),
      maxScrolls: 15,
    );
    expect(find.text('Guardar canción'), findsOneWidget);
    final saveButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Guardar canción'));
    expect(saveButton.onPressed, isNotNull);
    controller.userId = null;
    await catalog.bind(null);
    await tester.pump();
    expect(find.text('Guardar canción'), findsNothing);
    expect(find.text('Vuelve a Mi música para abrir la biblioteca de tu cuenta.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());

  });
}
