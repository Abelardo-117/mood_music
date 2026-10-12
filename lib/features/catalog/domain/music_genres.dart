const musicGenres = <String>[
  'Rock', 'Rock en español', 'Pop', 'Pop en español', 'Pop en inglés',
  'Cumbia', 'Salsa', 'Bachata', 'Merengue', 'Reguetón', 'Regional mexicano',
  'Banda', 'Norteño', 'Corridos', 'Mariachi', 'Ranchera', 'Bolero',
  'Electrónica', 'Dance', 'House', 'Techno', 'Hip hop / Rap', 'Trap',
  'R&B', 'Reggae', 'Jazz', 'Blues', 'Metal', 'Punk', 'Indie',
  'Clásica', 'Instrumental', 'K-pop', 'Country', 'Disco', 'Funk', 'Otro',
];
List<String> genreOptions(String? existing) => [
  ...musicGenres,
  if (existing != null && existing.trim().isNotEmpty && !musicGenres.contains(existing)) existing,
];
