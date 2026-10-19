import 'dart:io';

Uri mediaUri(String source) {
  final uri = Uri.tryParse(source);
  if (uri != null && uri.scheme == 'https' && uri.host.isNotEmpty) return uri;
  return File(source).uri;
}
