import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mood_music/features/player/presentation/playback_seek_bar.dart';

void main() {
  testWidgets('Arrastrar muestra el destino y solo busca al soltar', (tester) async {
    final calls = <Duration>[];
    final completed = Completer<void>();
    var position = const Duration(seconds: 10);
    Widget screen() => MaterialApp(home: Scaffold(body: PlaybackSeekBar(
      position: position, duration: const Duration(minutes: 3),
      readPosition: () => position,
      onSeek: (value) async {
        calls.add(value);
        await completed.future;
        position = value;
      },
    )));
    await tester.pumpWidget(screen());
    final slider = tester.widget<Slider>(find.byType(Slider));
    slider.onChanged!(30000);
    slider.onChanged!(60000);
    slider.onChanged!(90000);
    await tester.pump();
    expect(calls, isEmpty);
    expect(find.text('1:30'), findsOneWidget);
    // An incoming playback update must not pull the thumb away from the finger.
    position = const Duration(seconds: 11);
    await tester.pumpWidget(screen());
    expect(tester.widget<Slider>(find.byType(Slider)).value, 90000);
    tester.widget<Slider>(find.byType(Slider)).onChangeEnd!(90000);
    await tester.pump();
    expect(calls, [const Duration(seconds: 90)]);
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
    completed.complete();
    await tester.pump();
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNotNull);
    expect(tester.widget<Slider>(find.byType(Slider)).value, 90000);
  });

  testWidgets('Un fallo libera la barra para reintentar', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PlaybackSeekBar(
      position: const Duration(seconds: 10),
      duration: const Duration(minutes: 2),
      readPosition: () => const Duration(seconds: 10),
      onSeek: (_) async => throw StateError('seek failed'),
    ))));
    tester.widget<Slider>(find.byType(Slider)).onChangeEnd!(60000);
    await tester.pump();
    expect(find.text('No se pudo cambiar la posición. Intenta nuevamente.'), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNotNull);
    expect(tester.widget<Slider>(find.byType(Slider)).value, 10000);
  });

  testWidgets('Duración desconocida deshabilita la barra', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PlaybackSeekBar(
      position: Duration.zero, duration: Duration.zero,
      readPosition: () => Duration.zero, onSeek: (_) async {},
    ))));
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
  });
}
