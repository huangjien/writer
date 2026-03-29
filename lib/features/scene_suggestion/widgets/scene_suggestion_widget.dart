import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/models/character.dart';
import 'package:writer/models/scene_suggestion.dart';
import 'package:writer/features/scene_suggestion/widgets/scene_suggestion_card.dart';
import 'package:writer/features/scene_suggestion/services/scene_suggestion_service.dart';

class SceneSuggestionWidget extends ConsumerStatefulWidget {
  final String novelId;
  final String chapterId;
  final String currentScene;
  final List<String> previousScenes;
  final String genre;
  final String tone;
  final List<Character> characters;
  final Function(String) onSuggestionAccepted;

  const SceneSuggestionWidget({
    super.key,
    required this.novelId,
    required this.chapterId,
    required this.currentScene,
    this.previousScenes = const [],
    this.genre = 'general',
    this.tone = 'neutral',
    this.characters = const [],
    required this.onSuggestionAccepted,
  });

  @override
  ConsumerState<SceneSuggestionWidget> createState() =>
      _SceneSuggestionWidgetState();
}

class _SceneSuggestionWidgetState extends ConsumerState<SceneSuggestionWidget> {
  List<SceneSuggestion> _suggestions = [];
  bool _loading = false;
  String? _error;
  int? _selectedSuggestionIndex;

  @override
  void initState() {
    super.initState();
    if (widget.currentScene.isNotEmpty) {
      _generateSuggestions();
    }
  }

  Future<void> _generateSuggestions() async {
    setState(() {
      _loading = true;
      _error = null;
      _suggestions = [];
    });

    try {
      final service = ref.read(sceneSuggestionServiceProvider);

      final request = SceneSuggestionRequest(
        currentScene: widget.currentScene,
        previousScenes: widget.previousScenes,
        genre: widget.genre,
        tone: widget.tone,
        characters: widget.characters,
        sceneContext: 'Chapter ${widget.chapterId}',
      );

      final suggestions = await service.generateSceneSuggestions(request);

      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _loading = false;
        });

        if (_suggestions.isEmpty) {
          setState(() {
            _error = 'No suggestions generated. Please try again.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    }
  }

  void _handleAccept(int index) {
    final suggestion = _suggestions[index];
    widget.onSuggestionAccepted(suggestion.suggestedText);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Suggestion accepted!'),
        duration: Duration(seconds: 2),
      ),
    );

    setState(() {
      _selectedSuggestionIndex = index;
    });
  }

  void _handleReject(int index) {
    setState(() {
      _suggestions.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Suggestion rejected'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleModify(int index) {
    final suggestion = _suggestions[index];
    _showModifyDialog(suggestion);
  }

  void _showModifyDialog(SceneSuggestion suggestion) {
    final controller = TextEditingController(text: suggestion.suggestedText);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modify Suggestion'),
          content: TextField(
            controller: controller,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Edit the suggestion',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  widget.onSuggestionAccepted(controller.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Modified suggestion accepted!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Accept'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Generating scene suggestions...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error generating suggestions',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _generateSuggestions,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_suggestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('No Scene Content', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              'Start writing your scene to get AI-powered suggestions',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '${_suggestions.length} Scene Suggestion${_suggestions.length == 1 ? '' : 's'}',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _generateSuggestions,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _suggestions.length,
            itemBuilder: (context, index) {
              return SceneSuggestionCard(
                suggestion: _suggestions[index],
                index: index,
                isLoading: _selectedSuggestionIndex == index,
                onAccept: () => _handleAccept(index),
                onReject: () => _handleReject(index),
                onModify: () => _handleModify(index),
              );
            },
          ),
        ),
      ],
    );
  }
}
