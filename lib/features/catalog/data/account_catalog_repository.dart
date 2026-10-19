import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../domain/catalog_repository.dart';
import '../domain/song.dart';
import 'local_catalog_repository.dart';

/// Each authenticated account owns a separate on-device library.
/// Legacy mood_music_library files are preserved, never assigned implicitly.
class AccountCatalogRepository extends ChangeNotifier implements CatalogRepository {
  AccountCatalogRepository({this.root, this.watchShared});
  final Stream<List<Song>> Function()? watchShared;
  StreamSubscription<List<Song>>? _sharedSubscription;
  List<Song> _shared = const [];
  String? sharedError;
  int _sharedRevision = 0;

  void retryShared() {
    final revision = ++_sharedRevision;
    unawaited(_sharedSubscription?.cancel());
    _sharedSubscription = null;
    _shared = const [];
    sharedError = null;
    if (owner != null && watchShared != null) {
      _sharedSubscription = watchShared!().listen((songs) {
        if (_closed || revision != _sharedRevision) return;
        _shared = List.unmodifiable(songs);
        sharedError = null;
        notifyListeners();
      }, onError: (Object error) {
        if (_closed || revision != _sharedRevision) return;
        _shared = const [];
        sharedError = 'No se pudo cargar la canción compartida.';
        notifyListeners();
      });
    }
    notifyListeners();
  }
  final Directory? root;
  LocalCatalogRepository? local;
  String? owner;
  String? error;
  bool loading = false;
  int _revision = 0;
  bool _closed = false;
  final Map<String, Future<LocalCatalogRepository>> _libraries = {};

  Future<LocalCatalogRepository> _open(String uid) async {
    final base = root ?? Directory('${(await getApplicationDocumentsDirectory()).path}/mood_music_accounts');
    final key = base64Url.encode(utf8.encode(uid)).replaceAll('=', '');
    return LocalCatalogRepository.open(directory: Directory('${base.path}/$key'));
  }

  @override
  List<Song> get songs => List.unmodifiable([..._shared, ...?local?.songs]);

  Future<void> bind(String? uid) async {
    final revision = ++_revision;
    local?.removeListener(notifyListeners);
    // Old instances may still be finishing an import for their original owner.
    local = null;
    owner = uid;
    retryShared();
    error = null;
    loading = uid != null;
    notifyListeners();
    if (uid == null) return;
    try {
      final opened = await _libraries.putIfAbsent(uid, () => _open(uid));
      if (_closed || revision != _revision) return;
      local = opened;
      local!.addListener(notifyListeners);
    } catch (_) {
      _libraries.remove(uid);
      if (!_closed && revision == _revision) {
        error = 'No se pudo abrir tu biblioteca. Intenta de nuevo.';
      }
    } finally {
      if (!_closed && revision == _revision) {
        loading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _closed = true;
    ++_sharedRevision;
    unawaited(_sharedSubscription?.cancel());
    ++_revision;
    local?.removeListener(notifyListeners);
    super.dispose();
  }
}
