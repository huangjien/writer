import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  String? _version;
  bool _versionLoaded = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadVersion() async {
    try {
      final content = await DefaultAssetBundle.of(
        context,
      ).loadString('package.json', cache: false);
      final data = jsonDecode(content) as Map<String, dynamic>;
      setState(() {
        _version = data['version'] as String?;
        _versionLoaded = true;
      });
    } catch (_) {
      setState(() {
        _version = null;
        _versionLoaded = true;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_versionLoaded) {
      _loadVersion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: kIsWeb
                    ? Image.network(
                        '/icons/Icon-192.png',
                        height: 120,
                        errorBuilder: (context, error, stack) =>
                            const Icon(Icons.menu_book, size: 120),
                      )
                    : Image.asset(
                        'web/icons/Icon-192.png',
                        height: 120,
                        errorBuilder: (context, error, stack) =>
                            const Icon(Icons.menu_book, size: 120),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.appTitle,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(l10n.aboutDescription),
              const SizedBox(height: 12),
              const Text(
                'AuthorConsole helps you plan, write, and read novels across devices. '
                'It focuses on simplicity for readers and power for authors, offering a unified place '
                'to manage chapters, summaries, characters, and scenes.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'With Supabase-backed storage and strict Row Level Security, your data remains protected. '
                'Authenticated users can sync progress, metadata, and templates while maintaining privacy.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'The built‑in AI Coach uses the Snowflake method to improve your story summary. '
                'It asks focused questions, offers suggestions, and when ready, provides a refined summary '
                'that the app applies to your document.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.aboutUsage,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(l10n.aboutUsageList),
              const SizedBox(height: 8),
              const Text('• Create a new novel and organize chapters.'),
              const SizedBox(height: 4),
              const Text(
                '• Use character and scene templates to bootstrap ideas.',
              ),
              const SizedBox(height: 4),
              const Text('• Track reading progress and resume across devices.'),
              const SizedBox(height: 4),
              const Text(
                '• Refine your summary with the AI Coach and apply improvements.',
              ),
              const SizedBox(height: 4),
              const Text(
                '• Manage prompts and experiment with AI-assisted workflows.',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: 6),
                  Text('${l10n.version}: ${_version ?? '--'}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
