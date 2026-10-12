import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
class Brand extends StatelessWidget {
  const Brand({super.key});
  @override
  Widget build(BuildContext context) => const Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(Icons.graphic_eq, color: AppTheme.purple), SizedBox(width: 8),
    Text('Mood', style: TextStyle(fontWeight: FontWeight.w900)),
    Text('Music', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.purple)),
  ]);
}
