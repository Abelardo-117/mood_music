import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/admin_access_repository.dart';

class AdminAccessController extends ChangeNotifier {
  AdminAccessController(this.repository);
  final AdminAccessRepository? repository;
  StreamSubscription<bool>? _subscription;
  String? _uid;
  int _revision = 0;
  bool _disposed = false;
  bool allowed = false;
  bool loading = false;
  String? error;

  void bind(String? uid) {
    final revision = ++_revision;
    _uid = uid;
    _subscription?.cancel();
    _subscription = null;
    allowed = false;
    error = null;
    loading = uid != null && repository != null;
    notifyListeners();
    if (!loading) return;
    _subscription = repository!.watchAccess(uid!).listen((value) {
      if (_disposed || revision != _revision) return;
      allowed = value;
      loading = false;
      error = null;
      notifyListeners();
    }, onError: (Object failure) {
      if (_disposed || revision != _revision) return;
      allowed = false;
      loading = false;
      error = 'No se pudieron comprobar los permisos. Revisa tu conexión y las reglas de Firestore.';
      notifyListeners();
    });
  }
  void retry() => bind(_uid);
  @override
  void dispose() {
    _disposed = true;
    _revision++;
    _subscription?.cancel();
    super.dispose();
  }
}
