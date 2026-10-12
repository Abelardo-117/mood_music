import '../domain/song.dart';
import '../domain/catalog_repository.dart';
class DemoCatalogRepository implements CatalogRepository {
  @override
  List<Song> get songs => const [
    Song(id: 'neon', title: 'Luces de neón', artist: 'Luna Nova', genre: 'Electrónica'),
    Song(id: 'medianoche', title: 'A medianoche', artist: 'Kairo', genre: 'Pop'),
    Song(id: 'ecos', title: 'Ecos del club', artist: 'Veltra', genre: 'Rock'),
    Song(id: 'orbita', title: 'Órbita', artist: 'Luna Nova', genre: 'Electrónica'),
  ];
}
