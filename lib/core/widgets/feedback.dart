import 'package:flutter/material.dart';
void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
Future<void> runAction(BuildContext context, Future<void> Function() action) async {
  try { await action(); }
  catch (_) { if (context.mounted) showMessage(context, 'No se pudo guardar. Intenta nuevamente.'); }
}
