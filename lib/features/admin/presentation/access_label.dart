String accessLabel(DateTime? value) {
  if (value == null) {
    return 'Último acceso: sin registro';
  }
  final date = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return 'Último acceso: ${two(date.day)}/${two(date.month)}/${date.year} '
      '${two(date.hour)}:${two(date.minute)}';
}
