import 'package:flutter_test/flutter_test.dart';
import 'package:writer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

void main() {
  test('Basic en strings', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(l10n.settings, 'Settings');
    expect(l10n.appTitle, 'Writer');
    expect(l10n.supabaseSettings, 'Supabase Settings');
    expect(l10n.supabaseNotEnabled, 'Supabase not enabled');
    expect(l10n.fetchFromSupabase, 'Fetch from Supabase');
    expect(l10n.confirmFetch, 'Confirm Fetch');
    expect(
      l10n.confirmFetchDescription,
      'This will overwrite your local data. Are you sure?',
    );
    expect(l10n.cancel, 'Cancel');
    expect(l10n.fetch, 'Fetch');
    expect(l10n.ttsSettings, 'TTS Settings');
    expect(l10n.ttsSpeechRate, 'Speech Rate');
    expect(l10n.ttsSpeechVolume, 'Speech Volume');
    expect(l10n.themeMode, 'Theme Mode');
    expect(l10n.system, 'System');
    expect(l10n.light, 'Light');
    expect(l10n.dark, 'Dark');
    expect(l10n.select, 'Select');
    expect(l10n.clear, 'Clear');
    expect(l10n.sceneTemplates, 'Scene Templates');
    expect(l10n.templateName, 'Template Name');
    expect(l10n.templateLabel, 'Template');
    expect(l10n.aiConvert, 'AI Convert');
  });

  test('Placeholders en', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(
      l10n.signedInAs('user@example.com'),
      'Signed in as user@example.com',
    );
    expect(
      l10n.continueAtChapter('Chapter 5'),
      'Continue at chapter • Chapter 5',
    );
    expect(l10n.novelsAndProgressSummary(3, '75%'), 'Novels: 3, Progress: 75%');
    expect(l10n.indexLabel(7), 'Index 7');
    expect(l10n.ttsError('Network error'), 'TTS error: Network error');
    expect(
      l10n.confirmDeleteDescription('My Novel'),
      "This will delete 'My Novel' from Supabase. Are you sure?",
    );
  });
}
