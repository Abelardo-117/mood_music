const musicMoods = <String>[
  'Feliz', 'Triste', 'Relajado', 'Con energía', 'Concentrado',
];

List<String> readMoods(Object? value) => value is List
    ? List<String>.unmodifiable(value.whereType<String>().where(musicMoods.contains).toSet())
    : const <String>[];
