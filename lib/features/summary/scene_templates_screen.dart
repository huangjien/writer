import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SceneTemplatesScreen extends ConsumerWidget {
  const SceneTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scene Templates'),
        actions: [
          Tooltip(
            message: 'Create',
            child: IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No scene templates found.'),
      ),
    );
  }
}
