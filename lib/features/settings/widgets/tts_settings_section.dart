import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:writer/state/tts_settings.dart';
import 'package:writer/shared/widgets/neumorphic_dropdown.dart';
import 'package:writer/shared/widgets/neumorphic_slider.dart';

class TtsSettingsSection extends ConsumerWidget {
  const TtsSettingsSection({
    super.key,
    required this.voiceItems,
    required this.uniqueVoices,
    required this.voiceKey,
    required this.loadingVoices,
    required this.loadingLocales,
    required this.effectiveSelectedKey,
    required this.filteredLocales,
    required this.effectiveSelectedLocale,
  });

  final List<Map<String, dynamic>> voiceItems;
  final Map<String, Map<String, dynamic>> uniqueVoices;
  final String Function(Map<String, dynamic>) voiceKey;
  final bool loadingVoices;
  final bool loadingLocales;
  final String? effectiveSelectedKey;
  final List<String> filteredLocales;
  final String? effectiveSelectedLocale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(ttsSettingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ttsSettings, style: Theme.of(context).textTheme.titleLarge),
        ListTile(
          title: Text(l10n.ttsVoice),
          subtitle: loadingVoices
              ? Text(l10n.loadingVoices)
              : voiceItems.isEmpty
              ? Text(l10n.noVoicesAvailable)
              : NeumorphicDropdown<String>(
                  isExpanded: true,
                  value: effectiveSelectedKey,
                  hint: Text(l10n.selectVoice),
                  onChanged: (name) {
                    if (name == null) return;
                    final voice =
                        uniqueVoices[name] ??
                        voiceItems.firstWhere((v) => voiceKey(v) == name);
                    ref
                        .read(ttsSettingsProvider.notifier)
                        .setVoice(
                          name: voice['name'] as String,
                          locale: voice['locale'] as String,
                        );
                  },
                  items: voiceItems.map((voice) {
                    return DropdownMenuItem(
                      value: voiceKey(voice),
                      child: Text(
                        voice['name'] as String,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
        ),
        ListTile(
          title: Text(l10n.ttsLanguage),
          subtitle: loadingLocales
              ? Text(l10n.loadingLanguages)
              : NeumorphicDropdown<String>(
                  isExpanded: true,
                  value: effectiveSelectedLocale,
                  hint: Text(l10n.selectLanguage),
                  onChanged: (locale) {
                    if (locale != null) {
                      ref.read(ttsSettingsProvider.notifier).setLocale(locale);
                    }
                  },
                  items: filteredLocales.map((locale) {
                    return DropdownMenuItem(value: locale, child: Text(locale));
                  }).toList(),
                ),
        ),
        ListTile(
          title: Text(l10n.ttsSpeechRate),
          subtitle: NeumorphicSlider(
            value: settings.rate,
            onChanged: (value) {
              ref.read(ttsSettingsProvider.notifier).setRate(value);
            },
            min: 0.0,
            max: 1.0,
          ),
        ),
        ListTile(
          title: Text(l10n.ttsSpeechVolume),
          subtitle: NeumorphicSlider(
            value: settings.volume,
            onChanged: (value) {
              ref.read(ttsSettingsProvider.notifier).setVolume(value);
            },
            min: 0.0,
            max: 1.0,
          ),
        ),
      ],
    );
  }
}
