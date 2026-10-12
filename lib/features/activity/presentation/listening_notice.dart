import 'package:flutter/material.dart';
import '../../../app/app_controller.dart';

class ListeningNotice extends StatelessWidget {
  const ListeningNotice({super.key, required this.controller});
  final AppController controller;
  @override
  Widget build(BuildContext context) {
    final tracker = controller.listening;
    if (!controller.isSignedIn || tracker == null) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder<String?>(valueListenable: tracker.status,
      builder: (context, message, _) => Column(children: [
        if (message != null) ...[
          const SizedBox(height: 8), Text(message, textAlign: TextAlign.center),
          if (tracker.canRetry) TextButton(onPressed: tracker.retry, child: const Text('Reintentar sincronización')),
        ],
      ]),
    );
  }
}
