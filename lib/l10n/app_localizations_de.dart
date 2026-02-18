// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get newChapter => 'Neues Kapitel';

  @override
  String get back => 'Zurück';

  @override
  String get helloWorld => 'Hallo Welt!';

  @override
  String get home => 'Startseite';

  @override
  String get settings => 'Einstellungen';

  @override
  String get appTitle => 'Writer';

  @override
  String get about => 'Über';

  @override
  String get aboutDescription =>
      'Lesen und verwalten Sie Romane mit Cloud-Speicher, Offline-Support und Text-to-Speech-Wiedergabe. Verwenden Sie die Bibliothek zum Durchsuchen, Suchen und Öffnen von Kapiteln; melden Sie sich an, um den Fortschritt zu synchronisieren; passen Sie Einstellungen für Design, Typografie und Bewegung an.';

  @override
  String get aboutIntro =>
      'AuthorConsole hilft Ihnen dabei, Romane über Geräte hinweg zu planen, zu schreiben und zu lesen. Es konzentriert sich auf Einfachheit für Leser und Leistung für Autoren und bietet einen einheitlichen Ort zur Verwaltung von Kapiteln, Zusammenfassungen, Charakteren und Szenen.';

  @override
  String get aboutSecurity =>
      'Mit Cloud-Speicher und strengen Zugriffskontrollen bleiben Ihre Daten geschützt. Authentifizierte Benutzer können Fortschritt, Metadaten und Vorlagen synchronisieren und dabei die Privatsphäre wahren.';

  @override
  String get aboutCoach =>
      'Der integrierte KI-Coach verwendet die Snowflake-Methode, um Ihre Zusammenfassung zu verbessern. Er stellt gezielte Fragen, bietet Vorschläge und gibt, wenn bereit, eine verfeinerte Zusammenfassung, die die App auf Ihr Dokument anwendet.';

  @override
  String get aboutFeatureCreate =>
      '• Erstellen Sie einen neuen Roman und organisieren Sie Kapitel.';

  @override
  String get aboutFeatureTemplates =>
      '• Verwenden Sie Charakter- und Szenenvorlagen, um Ideen zu entwickeln.';

  @override
  String get aboutFeatureTracking =>
      '• Verfolgen Sie den Lesefortschritt und setzen Sie über Geräte fort.';

  @override
  String get aboutFeatureCoach =>
      '• Verfeinern Sie Ihre Zusammenfassung mit dem KI-Coach und wenden Sie Verbesserungen an.';

  @override
  String get aboutFeaturePrompts =>
      '• Verwalten Sie Prompts und experimentieren Sie mit KI-gestützten Workflows.';

  @override
  String get aboutUsage => 'Nutzung';

  @override
  String get aboutUsageList =>
      '• Bibliothek: Romane durchsuchen und öffnen\n• Leser: Kapitel navigieren, TTS umschalten\n• Vorlagen: Charakter- und Szenenvorlagen verwalten\n• Einstellungen: Design, Typografie und Präferenzen\n• Anmelden: Cloud-Synchronisation aktivieren';

  @override
  String get version => 'Version';

  @override
  String get appLanguage => 'App-Sprache';

  @override
  String get english => 'Englisch';

  @override
  String get chinese => 'Chinesisch';

  @override
  String get supabaseIntegrationInitialized =>
      'Cloud-Synchronisation initialisiert';

  @override
  String get configureEnvironment =>
      'Bitte konfigurieren Sie Ihre Umgebungsvariablen, um die Cloud-Synchronisation zu aktivieren';

  @override
  String signedInAs(String email) {
    return 'Angemeldet als $email';
  }

  @override
  String get guest => 'Gast';

  @override
  String get notSignedIn => 'Nicht angemeldet';

  @override
  String get signIn => 'Anmelden';

  @override
  String get continueLabel => 'Weiter';

  @override
  String get reload => 'Neu laden';

  @override
  String get signInToSync =>
      'Melden Sie sich an, um den Fortschritt über Geräte zu synchronisieren.';

  @override
  String get currentProgress => 'Aktueller Fortschritt';

  @override
  String get loadingProgress => 'Fortschritt wird geladen...';

  @override
  String get recentlyRead => 'Zuletzt gelesen';

  @override
  String get noSupabase =>
      'Cloud-Synchronisation ist in diesem Build nicht aktiviert.';

  @override
  String get errorLoadingProgress => 'Fehler beim Laden des Fortschritts';

  @override
  String get noProgress => 'Kein Fortschritt gefunden';

  @override
  String get errorLoadingNovels => 'Fehler beim Laden der Romane';

  @override
  String get loadingNovels => 'Romane werden geladen…';

  @override
  String get titleLabel => 'Titel';

  @override
  String get authorLabel => 'Autor';

  @override
  String get noNovelsFound => 'Keine Romane gefunden.';

  @override
  String get myNovels => 'Meine Romane';

  @override
  String get createNovel => 'Roman erstellen';

  @override
  String get create => 'Erstellen';

  @override
  String get errorLoadingChapters => 'Fehler beim Laden der Kapitel';

  @override
  String get loadingChapter => 'Kapitel wird geladen…';

  @override
  String get notStarted => 'Nicht begonnen';

  @override
  String get unknownNovel => 'Unbekannter Roman';

  @override
  String get unknownChapter => 'Unbekanntes Kapitel';

  @override
  String get chapter => 'Kapitel';

  @override
  String get novel => 'Roman';

  @override
  String get chapterTitle => 'Kapiteltitel';

  @override
  String get scrollOffset => 'Scroll-Offset';

  @override
  String get ttsIndex => 'TTS-Index';

  @override
  String get speechRate => 'Sprechgeschwindigkeit';

  @override
  String get volume => 'Lautstärke';

  @override
  String get defaultTTSVoice => 'Standard-TTS-Stimme';

  @override
  String get defaultVoiceUpdated => 'Standardstimme aktualisiert';

  @override
  String get defaultLanguageSet => 'Standardsprache eingestellt';

  @override
  String get searchByTitle => 'Nach Titel suchen…';

  @override
  String get chooseLanguage => 'Sprache wählen';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get signInWithGoogle => 'Mit Google anmelden';

  @override
  String get signInWithApple => 'Mit Apple anmelden';

  @override
  String get testVoice => 'Stimme testen';

  @override
  String get reloadVoices => 'Stimmen neu laden';

  @override
  String get signOut => 'Abmelden';

  @override
  String get signedOut => 'Abgemeldet';

  @override
  String get appSettings => 'App-Einstellungen';

  @override
  String get supabaseSettings => 'Cloud-Sync-Einstellungen';

  @override
  String get supabaseNotEnabled => 'Cloud-Synchronisation nicht aktiviert';

  @override
  String get supabaseNotEnabledDescription =>
      'Cloud-Synchronisation ist für diesen Build nicht konfiguriert.';

  @override
  String get authDisabledInBuild =>
      'Cloud-Synchronisation ist nicht konfiguriert. Authentifizierung ist in diesem Build deaktiviert.';

  @override
  String get fetchFromSupabase => 'Von Cloud abrufen';

  @override
  String get fetchFromSupabaseDescription =>
      'Neueste Romane und Fortschritte aus der Cloud abrufen.';

  @override
  String get confirmFetch => 'Abruf bestätigen';

  @override
  String get confirmFetchDescription =>
      'Dies wird Ihre lokalen Daten überschreiben. Sind Sie sicher?';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get fetch => 'Abrufen';

  @override
  String get downloadChapters => 'Kapitel herunterladen';

  @override
  String get modeSupabase => 'Modus: Cloud-Synchronisation';

  @override
  String get modeMockData => 'Modus: Mock-Daten';

  @override
  String continueAtChapter(String title) {
    return 'Bei Kapitel fortfahren • $title';
  }

  @override
  String get error => 'Fehler';

  @override
  String get ttsSettings => 'TTS-Einstellungen';

  @override
  String get enableTTS => 'TTS aktivieren';

  @override
  String get sentenceSummary => 'Satz-Zusammenfassung';

  @override
  String get paragraphSummary => 'Absatz-Zusammenfassung';

  @override
  String get pageSummary => 'Seiten-Zusammenfassung';

  @override
  String get expandedSummary => 'Erweiterte Zusammenfassung';

  @override
  String get pitch => 'Tonhöhe';

  @override
  String get signInWithBiometrics => 'Mit Biometrie anmelden';

  @override
  String get enableBiometricLogin => 'Biometrische Anmeldung aktivieren';

  @override
  String get enableBiometricLoginDescription =>
      'Verwenden Sie Fingerabdruck oder Gesichtserkennung zur Anmeldung.';

  @override
  String get biometricAuthFailed =>
      'Biometrische Authentifizierung fehlgeschlagen';

  @override
  String get saveCredentialsForBiometric =>
      'Anmeldedaten für biometrische Anmeldung speichern';

  @override
  String get saveCredentialsForBiometricDescription =>
      'Speichern Sie Ihre Anmeldedaten sicher für schnellere biometrische Authentifizierung';

  @override
  String get biometricTokensExpired => 'Biometrische Tokens abgelaufen';

  @override
  String get biometricNoTokens => 'Keine biometrischen Tokens gefunden';

  @override
  String get biometricTokenError => 'Biometrischer Token-Fehler';

  @override
  String get biometricTechnicalError => 'Biometrischer technischer Fehler';

  @override
  String get ttsVoice => 'TTS-Stimme';

  @override
  String get loadingVoices => 'Stimmen werden geladen...';

  @override
  String get selectVoice => 'Stimme auswählen';

  @override
  String get ttsLanguage => 'TTS-Sprache';

  @override
  String get loadingLanguages => 'Sprachen werden geladen...';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get ttsSpeechRate => 'Sprechgeschwindigkeit';

  @override
  String get ttsSpeechVolume => 'Sprachlautstärke';

  @override
  String get ttsSpeechPitch => 'Sprachtonhöhe';

  @override
  String get novelsAndProgress => 'Romane und Fortschritt';

  @override
  String get novels => 'Romane';

  @override
  String get progress => 'Fortschritt';

  @override
  String novelsAndProgressSummary(int count, String progress) {
    return 'Romane: $count, Fortschritt: $progress';
  }

  @override
  String get chapters => 'Kapitel';

  @override
  String get noChaptersFound => 'Keine Kapitel gefunden.';

  @override
  String indexLabel(int index) {
    return 'Index $index';
  }

  @override
  String get enterFloatIndexHint =>
      'Dezimalindex eingeben zum Neupositionieren';

  @override
  String indexOutOfRange(int min, int max) {
    return 'Index muss zwischen $min und $max liegen';
  }

  @override
  String get indexUnchanged => 'Index unverändert';

  @override
  String get roundingBefore => 'Immer vorher';

  @override
  String get roundingAfter => 'Immer nachher';

  @override
  String get stopTTS => 'TTS stoppen';

  @override
  String get speak => 'Sprechen';

  @override
  String get supabaseProgressNotSaved =>
      'Cloud-Synchronisation nicht konfiguriert; Fortschritt nicht gespeichert';

  @override
  String get progressSaved => 'Fortschritt gespeichert';

  @override
  String get errorSavingProgress => 'Fehler beim Speichern des Fortschritts';

  @override
  String get autoplayBlocked =>
      'Automatische Wiedergabe blockiert. Tippen Sie auf Weiter, um zu starten.';

  @override
  String get autoplayBlockedInline =>
      'Die automatische Wiedergabe wird vom Browser blockiert. Tippen Sie auf Weiter, um zu starten.';

  @override
  String get reachedLastChapter => 'Letztes Kapitel erreicht';

  @override
  String ttsError(String msg) {
    return 'TTS-Fehler: $msg';
  }

  @override
  String get themeMode => 'Designmodus';

  @override
  String get system => 'System';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get colorTheme => 'Farbschema';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get themeHighContrast => 'Kontrast';

  @override
  String get themeDefault => 'Standard';

  @override
  String get themeEmeraldGreen => 'Smaragdgrün';

  @override
  String get themeSolarizedTan => 'Solarized Tan';

  @override
  String get themeNord => 'Nord';

  @override
  String get themeNordFrost => 'Nord Frost';

  @override
  String get separateDarkPalette => 'Getrennte dunkle Palette verwenden';

  @override
  String get lightPalette => 'Helle Palette';

  @override
  String get darkPalette => 'Dunkle Palette';

  @override
  String get typographyPreset => 'Typografie-Preset';

  @override
  String get typographyComfortable => 'Komfortabel';

  @override
  String get typographyCompact => 'Kompakt';

  @override
  String get typographySerifLike => 'Serifenartig';

  @override
  String get fontPack => 'Schriftartenpaket';

  @override
  String get separateTypographyPresets =>
      'Getrennte Typografie für Hell/Dunkel verwenden';

  @override
  String get typographyLight => 'Typografie Hell';

  @override
  String get typographyDark => 'Typografie Dunkel';

  @override
  String get readerBundles => 'Leser-Design-Bundles';

  @override
  String get tokenUsage => 'Token-Nutzung';

  @override
  String removedNovel(String title) {
    return '$title entfernt';
  }

  @override
  String get discover => 'Entdecken';

  @override
  String get profile => 'Profil';

  @override
  String get libraryTitle => 'Bibliothek';

  @override
  String get undo => 'Rückgängig';

  @override
  String get allFilter => 'Alle';

  @override
  String get readingFilter => 'Lesen';

  @override
  String get completedFilter => 'Abgeschlossen';

  @override
  String get downloadedFilter => 'Heruntergeladen';

  @override
  String get searchNovels => 'Romane durchsuchen...';

  @override
  String get listView => 'Listenansicht';

  @override
  String get gridView => 'Rasteransicht';

  @override
  String get userManagement => 'Benutzerverwaltung';

  @override
  String get totalThisMonth => 'Gesamt diesen Monat';

  @override
  String get inputTokens => 'Eingabe-Tokens';

  @override
  String get outputTokens => 'Ausgabe-Tokens';

  @override
  String get requests => 'Anfragen';

  @override
  String get viewHistory => 'Verlauf anzeigen';

  @override
  String get noUsageThisMonth => 'Keine Nutzung diesen Monat';

  @override
  String get startUsingAiFeatures =>
      'Beginnen Sie mit der Verwendung von KI-Funktionen, um Ihren Token-Verbrauch zu sehen';

  @override
  String get errorLoadingUsage => 'Fehler beim Laden der Nutzung';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String totalRecords(int count) {
    return 'Gesamtdatensätze: $count';
  }

  @override
  String get total => 'Gesamt';

  @override
  String get noUsageHistory => 'Keine Nutzungshistorie';

  @override
  String get bundleNordCalm => 'Nord Stille';

  @override
  String get bundleSolarizedFocus => 'Solarized Fokus';

  @override
  String get bundleHighContrastReadability => 'Hoher Kontrast Lesbarkeit';

  @override
  String get customFontFamily => 'Benutzerdefinierte Schriftfamilie';

  @override
  String get commonFonts => 'Häufige Schriftarten';

  @override
  String get readerFontSize => 'Leser-Schriftgröße';

  @override
  String get textScale => 'Textskalierung';

  @override
  String get readerBackgroundDepth => 'Leser-Hintergrundtiefe';

  @override
  String get depthLow => 'Niedrig';

  @override
  String get depthMedium => 'Mittel';

  @override
  String get depthHigh => 'Hoch';

  @override
  String get select => 'Auswählen';

  @override
  String get clear => 'Löschen';

  @override
  String get adminMode => 'Admin-Modus';

  @override
  String get reduceMotion => 'Bewegung reduzieren';

  @override
  String get reduceMotionDescription =>
      'Animationen für Bewegungskomfort minimieren';

  @override
  String get gesturesEnabled => 'Touch-Gesten aktivieren';

  @override
  String get gesturesEnabledDescription =>
      'Wisch- und Tipp-Gesten im Leser aktivieren';

  @override
  String get readerSwipeSensitivity => 'Wischempfindlichkeit im Leser';

  @override
  String get readerSwipeSensitivityDescription =>
      'Minimale Geschwindigkeit für Kapitelnavigation anpassen';

  @override
  String get remove => 'Entfernen';

  @override
  String get removedFromLibrary => 'Aus der Bibliothek entfernt';

  @override
  String get confirmDelete => 'Löschen bestätigen';

  @override
  String confirmDeleteDescription(String title) {
    return 'Dies wird \'$title\' aus Ihrer Cloud-Bibliothek löschen. Sind Sie sicher?';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get reachedFirstChapter => 'Erstes Kapitel erreicht';

  @override
  String get previousChapter => 'Vorheriges Kapitel';

  @override
  String get nextChapter => 'Nächstes Kapitel';

  @override
  String get betaEvaluate => 'Beta';

  @override
  String get betaEvaluating => 'Wird zur Beta-Bewertung gesendet…';

  @override
  String get betaEvaluationReady => 'Beta-Bewertung bereit';

  @override
  String get betaEvaluationFailed => 'Beta-Bewertung fehlgeschlagen';

  @override
  String get performanceSettings => 'Leistungseinstellungen';

  @override
  String get prefetchNextChapter => 'Nächstes Kapitel vorabladen';

  @override
  String get prefetchNextChapterDescription =>
      'Lädt das nächste Kapitel vor, um Wartezeiten zu reduzieren.';

  @override
  String get clearOfflineCache => 'Offline-Cache löschen';

  @override
  String get offlineCacheCleared => 'Offline-Cache gelöscht';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get exitEdit => 'Bearbeitung beenden';

  @override
  String get enterEditMode => 'Bearbeitungsmodus aufrufen';

  @override
  String get exitEditMode => 'Bearbeitungsmodus beenden';

  @override
  String get chapterContent => 'Kapitelinhalt';

  @override
  String get save => 'Speichern';

  @override
  String get createNextChapter => 'Nächstes Kapitel erstellen';

  @override
  String get enterChapterTitle => 'Kapiteltitel eingeben';

  @override
  String get enterChapterContent => 'Kapitelinhalt eingeben';

  @override
  String get discardChangesTitle => 'Änderungen verwerfen?';

  @override
  String get discardChangesMessage =>
      'Sie haben ungespeicherte Änderungen. Möchten Sie diese verwerfen?';

  @override
  String get keepEditing => 'Weiter bearbeiten';

  @override
  String get discardChanges => 'Änderungen verwerfen';

  @override
  String get saveAndExit => 'Speichern & Beenden';

  @override
  String get descriptionLabel => 'Beschreibung';

  @override
  String get coverUrlLabel => 'Cover-URL';

  @override
  String get invalidCoverUrl =>
      'Geben Sie eine gültige http(s)-URL ohne Leerzeichen ein.';

  @override
  String get navigation => 'Navigation';

  @override
  String get chapterIndex => 'Kapitelindex';

  @override
  String get summary => 'Zusammenfassung';

  @override
  String get characters => 'Charaktere';

  @override
  String get scenes => 'Szenen';

  @override
  String get characterTemplates => 'Charaktervorlagen';

  @override
  String get sceneTemplates => 'Szenenvorlagen';

  @override
  String get updateNovel => 'Roman aktualisieren';

  @override
  String get deleteNovel => 'Roman löschen';

  @override
  String get deleteNovelConfirmation =>
      'Dies wird den Roman dauerhaft löschen. Fortfahren?';

  @override
  String get format => 'Format';

  @override
  String get aiServiceUrl => 'KI-Dienst-URL';

  @override
  String get aiServiceUrlDescription => 'Backend-Dienst-URL für KI-Funktionen';

  @override
  String get aiAssistant => 'KI-Assistent';

  @override
  String get aiChatHistory => 'Verlauf';

  @override
  String get aiChatNewChat => 'Neuer Chat';

  @override
  String get aiChatNoHistory => 'Kein Verlauf';

  @override
  String get aiChatHint => 'Nachricht eingeben...';

  @override
  String get aiChatEmpty =>
      'Fragen Sie mich alles über dieses Kapitel oder diesen Roman';

  @override
  String get aiThinking => 'KI denkt nach...';

  @override
  String get aiChatContextLabel => 'Kontext';

  @override
  String aiTokenCount(int count) {
    return '$count Tokens';
  }

  @override
  String aiContextLoadError(String error) {
    return 'Fehler beim Laden des Kontexts: $error';
  }

  @override
  String aiChatContextTooLongCompressing(int tokens) {
    return 'Kontext ist zu lang ($tokens Tokens). Komprimierung läuft...';
  }

  @override
  String aiChatContextCompressionFailedNote(String error) {
    return '[Hinweis: Kontextkomprimierung fehlgeschlagen: $error]';
  }

  @override
  String aiChatError(String error) {
    return 'Fehler: $error';
  }

  @override
  String aiChatDeepAgentError(String error) {
    return 'Deep Agent Fehler: $error';
  }

  @override
  String get aiChatSearchFailed => 'Suche fehlgeschlagen';

  @override
  String aiChatSearchError(String error) {
    return 'Suchfehler: $error';
  }

  @override
  String get aiChatRagSearchResultsTitle => 'RAG-Suchergebnisse';

  @override
  String aiChatRagRefinedQuery(String query) {
    return 'Verfeinerte Abfrage: \"$query\"';
  }

  @override
  String get aiChatRagNoResults => 'Keine Ergebnisse gefunden.';

  @override
  String get aiChatRagUnknownType => 'unbekannt';

  @override
  String get aiServiceSignInRequired =>
      'Anmeldung erforderlich, um KI-Dienst zu nutzen';

  @override
  String get aiServiceFeatureNotAvailable =>
      'Funktion für Ihren Plan nicht verfügbar';

  @override
  String aiServiceFailedToConnect(String error) {
    return 'Verbindung zum KI-Dienst fehlgeschlagen: $error';
  }

  @override
  String get aiServiceNoResponse => 'Keine Antwort vom KI-Dienst';

  @override
  String get aiDeepAgentDetailsTitle => 'Deep Agent';

  @override
  String aiDeepAgentStop(String reason, Object rounds) {
    return 'Stopp: $reason (Runden: $rounds)';
  }

  @override
  String get aiDeepAgentPlanLabel => 'Plan:';

  @override
  String get aiDeepAgentToolsLabel => 'Tools:';

  @override
  String get deepAgentSettingsTitle => 'Deep Agent Einstellungen';

  @override
  String get deepAgentSettingsDescription =>
      'Steuern Sie, ob der KI-Chat Deep Agent bevorzugt, sowie Reflexion und Debug-Ausgabe.';

  @override
  String get deepAgentPreferTitle => 'Deep Agent bevorzugen';

  @override
  String get deepAgentPreferSubtitle =>
      'Wenn aktiviert, ruft der normale Chat zuerst /agents/deep-agent auf.';

  @override
  String get deepAgentFallbackTitle => 'Fallback auf QA wenn nicht verfügbar';

  @override
  String get deepAgentFallbackSubtitle =>
      'Ruft automatisch /agents/qa auf, wenn deep-agent 404/501 zurückgibt.';

  @override
  String get deepAgentReflectionModeTitle => 'Reflexionsmodus';

  @override
  String get deepAgentReflectionModeSubtitle =>
      'Steuert Auswertung nach Antwort und optionale Wiederholung.';

  @override
  String get deepAgentReflectionModeOff => 'Aus';

  @override
  String get deepAgentReflectionModeOnFailure => 'Bei Fehler';

  @override
  String get deepAgentReflectionModeAlways => 'Immer';

  @override
  String get deepAgentShowDetailsTitle => 'Ausführungsdetails anzeigen';

  @override
  String get deepAgentShowDetailsSubtitle =>
      'Plan- und Tool-Call-Logs in /deep-Ausgabe einschließen.';

  @override
  String get deepAgentMaxPlanSteps => 'Maximale Planungsschritte';

  @override
  String get deepAgentMaxToolRounds => 'Maximale Tool-Runden';

  @override
  String get send => 'Senden';

  @override
  String get resetToDefault => 'Auf Standard zurücksetzen';

  @override
  String get invalidUrl =>
      'Geben Sie eine gültige http(s)-URL ohne Leerzeichen ein.';

  @override
  String get urlTooLong => 'URL muss 2048 Zeichen oder weniger sein.';

  @override
  String get urlContainsSpaces => 'URL darf keine Leerzeichen enthalten.';

  @override
  String get urlInvalidScheme => 'URL muss mit http:// oder https:// beginnen.';

  @override
  String get saved => 'Gespeichert';

  @override
  String get required => 'Erforderlich';

  @override
  String get summariesLabel => 'Zusammenfassungen';

  @override
  String get synopsesLabel => 'Synopsen';

  @override
  String get locationLabel => 'Ort';

  @override
  String languageLabel(String code) {
    return 'Sprache: $code';
  }

  @override
  String get publicLabel => 'Öffentlich';

  @override
  String get privateLabel => 'Privat';

  @override
  String chaptersCount(int count) {
    return 'Kapitel: $count';
  }

  @override
  String avgWordsPerChapter(int avg) {
    return 'Durchschnitt Wörter/Kapitel: $avg';
  }

  @override
  String chapterLabel(int idx) {
    return 'Kapitel $idx';
  }

  @override
  String chapterWithTitle(int idx, String title) {
    return 'Kapitel $idx: $title';
  }

  @override
  String get refreshTooltip => 'Aktualisieren';

  @override
  String get untitled => 'Unbenannt';

  @override
  String get newLabel => 'Neu';

  @override
  String get deleteSceneTitle => 'Szene löschen';

  @override
  String get deleteCharacterTitle => 'Charakter löschen';

  @override
  String get deleteTemplateTitle => 'Vorlage löschen';

  @override
  String get confirmDeleteGeneric =>
      'Sind Sie sicher, dass Sie dieses Element löschen möchten?';

  @override
  String get novelMetadata => 'Roman-Metadaten';

  @override
  String get contributorEmailLabel => 'Mitwirkender-E-Mail';

  @override
  String get contributorEmailHint =>
      'Benutzer-E-Mail eingeben, um als Mitwirkender hinzuzufügen';

  @override
  String get addContributor => 'Mitwirkenden hinzufügen';

  @override
  String get contributorAdded => 'Mitwirkender hinzugefügt';

  @override
  String get pdf => 'PDF';

  @override
  String get generatingPdf => 'PDF wird generiert…';

  @override
  String get pdfFailed => 'PDF-Generierung fehlgeschlagen';

  @override
  String get tableOfContents => 'Inhaltsverzeichnis';

  @override
  String byAuthor(String name) {
    return 'von $name';
  }

  @override
  String pageOfTotal(int page, int total) {
    return 'Seite $page von $total';
  }

  @override
  String get close => 'Schließen';

  @override
  String get openLink => 'Link öffnen';

  @override
  String get invalidLink => 'Ungültiger Link';

  @override
  String get unableToOpenLink => 'Link kann nicht geöffnet werden';

  @override
  String get copy => 'Kopieren';

  @override
  String get copiedToClipboard => 'In die Zwischenablage kopiert';

  @override
  String showingCachedPublicData(String msg) {
    return '$msg — zwischengespeicherte/öffentliche Daten werden angezeigt';
  }

  @override
  String get menu => 'Menü';

  @override
  String get metaLabel => 'Meta';

  @override
  String get aiServiceUnavailable => 'KI-Dienst nicht verfügbar';

  @override
  String get aiConfigurations => 'KI-Konfigurationen';

  @override
  String get modelLabel => 'Modell';

  @override
  String get temperatureLabel => 'Temperatur';

  @override
  String get saveFailed => 'Speichern fehlgeschlagen';

  @override
  String get saveMyVersion => 'Meine Version speichern';

  @override
  String get resetToPublic => 'Auf öffentlich zurücksetzen';

  @override
  String get resetFailed => 'Zurücksetzen fehlgeschlagen';

  @override
  String get prompts => 'Prompts';

  @override
  String get patterns => 'Muster';

  @override
  String get storyLines => 'Story-Lines';

  @override
  String get hotTopics => 'Aktuelle Themen';

  @override
  String get hotTopicsSelectPlatform => 'Plattform auswählen';

  @override
  String get hotTopicsAllPlatforms => 'Alle Plattformen';

  @override
  String get hotTopicsPlatformWeibo => 'Weibo';

  @override
  String get hotTopicsPlatformZhihu => 'Zhihu';

  @override
  String get hotTopicsPlatformDouyin => 'Douyin';

  @override
  String get hotTopicsPlatformDescWeibo => 'Chinesisches Microblogging';

  @override
  String get hotTopicsPlatformDescZhihu => 'Q&A-Plattform';

  @override
  String get hotTopicsPlatformDescDouyin => 'Video-Sharing';

  @override
  String get tools => 'Tools';

  @override
  String get preview => 'Vorschau';

  @override
  String get actions => 'Aktionen';

  @override
  String get searchLabel => 'Suchen';

  @override
  String get allLabel => 'Alle';

  @override
  String get filterByLocked => 'Nach Gesperrtem filtern';

  @override
  String get lockedOnly => 'Nur gesperrt';

  @override
  String get unlockedOnly => 'Nur entsperrt';

  @override
  String get promptKey => 'Prompt-Schlüssel';

  @override
  String get language => 'Sprache';

  @override
  String get filterByKey => 'Nach Schlüssel filtern';

  @override
  String get viewPublic => 'Öffentlich anzeigen';

  @override
  String get groupNone => 'Keine';

  @override
  String get groupLanguage => 'Sprache';

  @override
  String get groupKey => 'Schlüssel';

  @override
  String get newPrompt => 'Neuer Prompt';

  @override
  String get newPattern => 'Neues Muster';

  @override
  String get newStoryLine => 'Neue Story-Line';

  @override
  String get editPrompt => 'Prompt bearbeiten';

  @override
  String get editPattern => 'Muster bearbeiten';

  @override
  String get editStoryLine => 'Story-Line bearbeiten';

  @override
  String deletedWithTitle(String title) {
    return 'Gelöscht: $title';
  }

  @override
  String deleteFailedWithTitle(String title) {
    return 'Löschen fehlgeschlagen: $title';
  }

  @override
  String deleteErrorWithMessage(String error) {
    return 'Löschfehler: $error';
  }

  @override
  String get makePublic => 'Öffentlich machen';

  @override
  String get noPrompts => 'Keine Prompts gefunden';

  @override
  String get noPatterns => 'Keine Muster';

  @override
  String get noStoryLines => 'Keine Story-Lines';

  @override
  String conversionFailed(String error) {
    return 'Konvertierung fehlgeschlagen: $error';
  }

  @override
  String get failedToAnalyze => 'Analyse fehlgeschlagen';

  @override
  String get aiCoachAnalyzing => 'KI-Coach analysiert...';

  @override
  String get retry => 'Wiederholen';

  @override
  String get startAiCoaching => 'KI-Coaching starten';

  @override
  String get refinementComplete => 'Verfeinerung abgeschlossen!';

  @override
  String get coachQuestion => 'Frage des Coaches';

  @override
  String get summaryLooksGood =>
      'Gute Arbeit! Ihre Zusammenfassung solide aussieht.';

  @override
  String get howToImprove => 'Wie können wir das verbessern?';

  @override
  String get suggestionsLabel => 'Vorschläge:';

  @override
  String get reviewSuggestionsHint =>
      'Vorschläge überprüfen oder Antwort eingeben...';

  @override
  String get aiGenerationComplete => 'KI-Generierung abgeschlossen';

  @override
  String get clickRegenerateForNew =>
      'Klicken Sie auf Neu generieren für neue Vorschläge';

  @override
  String get regenerate => 'Neu generieren';

  @override
  String get imSatisfied => 'Ich bin zufrieden';

  @override
  String get templateLabel => 'Vorlage';

  @override
  String get exampleCharacterName => 'z.B. Harry Potter';

  @override
  String get aiConvert => 'KI-Konvertierung';

  @override
  String get toggleAiCoach => 'KI-Coach umschalten';

  @override
  String retrieveFailed(String error) {
    return 'Abruf fehlgeschlagen: $error';
  }

  @override
  String get confirm => 'Bestätigen';

  @override
  String get lastRead => 'Zuletzt gelesen';

  @override
  String get noRecentChapters => 'Keine aktuellen Kapitel';

  @override
  String get failedToLoadConfig => 'Konfiguration konnte nicht geladen werden';

  @override
  String makePublicPromptConfirm(String promptKey, String language) {
    return '\"$promptKey\" ($language) öffentlich machen?';
  }

  @override
  String get content => 'Inhalt';

  @override
  String get invalidKey => 'Ungültiger Schlüssel';

  @override
  String get invalidLanguage => 'Ungültige Sprache';

  @override
  String get invalidInput => 'Ungültige Eingabe';

  @override
  String charsCount(int count) {
    return 'Zeichen: $count';
  }

  @override
  String deletePromptConfirm(String promptKey, String language) {
    return 'Prompt \"$promptKey\" ($language) löschen?';
  }

  @override
  String get profileRetrieved => 'Profil abgerufen';

  @override
  String get noProfileFound => 'Kein Profil gefunden';

  @override
  String get templateName => 'Vorlagenname';

  @override
  String get retrieveProfile => 'Profil abrufen';

  @override
  String get previewLabel => 'Vorschau';

  @override
  String get markdownHint => 'Beschreibung in Markdown eingeben...';

  @override
  String get templateNameExists => 'Vorlagenname existiert bereits';

  @override
  String get aiServiceUrlHint => 'KI-Dienst-URL eingeben (http/https)';

  @override
  String get urlLabel => 'URL';

  @override
  String get systemFont => 'Systemschrift';

  @override
  String get fontInter => 'Inter';

  @override
  String get fontMerriweather => 'Merriweather';

  @override
  String get editPatternTitle => 'Muster bearbeiten';

  @override
  String get newPatternTitle => 'Neues Muster';

  @override
  String get editStoryLineTitle => 'Story-Line bearbeiten';

  @override
  String get newStoryLineTitle => 'Neue Story-Line';

  @override
  String get usageRulesLabel => 'Nutzungsregeln (JSON)';

  @override
  String get publicPatternLabel => 'Öffentliches Muster';

  @override
  String get publicStoryLineLabel => 'Öffentliche Story-Line';

  @override
  String get lockedLabel => 'Gesperrt';

  @override
  String get unlockedLabel => 'Entsperrt';

  @override
  String get aiButton => 'KI';

  @override
  String get invalidJson => 'Ungültiges JSON';

  @override
  String get deleteFailed => 'Löschen fehlgeschlagen';

  @override
  String get lockPattern => 'Muster sperren';

  @override
  String get errorUnauthorized => 'Nicht autorisiert';

  @override
  String get errorForbidden => 'Verboten';

  @override
  String get errorSessionExpired => 'Sitzung abgelaufen';

  @override
  String get errorValidation => 'Validierungsfehler';

  @override
  String get errorInvalidInput => 'Ungültige Eingabe';

  @override
  String get errorDuplicateTitle => 'Doppelter Titel';

  @override
  String get errorNotFound => 'Nicht gefunden';

  @override
  String get errorServiceUnavailable => 'Dienst nicht verfügbar';

  @override
  String get errorAiNotConfigured => 'KI-Dienst nicht konfiguriert';

  @override
  String get errorSupabaseError => 'Cloud-Dienstfehler';

  @override
  String get errorRateLimited => 'Zu viele Anfragen';

  @override
  String get errorInternal => 'Interner Serverfehler';

  @override
  String get errorBadGateway => 'Bad Gateway';

  @override
  String get errorGatewayTimeout => 'Gateway-Timeout';

  @override
  String get loginFailed => 'Anmeldung fehlgeschlagen';

  @override
  String get invalidResponseFromServer => 'Ungültige Antwort vom Server';

  @override
  String get signUp => 'Registrieren';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get signupFailed => 'Registrierung fehlgeschlagen';

  @override
  String get accountCreatedCheckEmail =>
      'Konto erstellt! Bitte überprüfen Sie Ihre E-Mail zur Bestätigung.';

  @override
  String get backToSignIn => 'Zurück zur Anmeldung';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get alreadyHaveAccountSignIn =>
      'Haben Sie bereits ein Konto? Anmelden';

  @override
  String get requestFailed => 'Anfrage fehlgeschlagen';

  @override
  String get ifAccountExistsResetLinkSent =>
      'Wenn ein Konto existiert, wurde ein Reset-Link an Ihre E-Mail gesendet.';

  @override
  String get enterEmailForResetLink =>
      'Geben Sie Ihre E-Mail-Adresse ein, um einen Passwort-Reset-Link zu erhalten.';

  @override
  String get sendResetLink => 'Reset-Link senden';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get sessionInvalidLoginAgain =>
      'Sitzung ungültig. Bitte melden Sie sich erneut an oder verwenden Sie den Reset-Link erneut.';

  @override
  String get updateFailed => 'Aktualisierung fehlgeschlagen';

  @override
  String get passwordUpdatedSuccessfully =>
      'Passwort erfolgreich aktualisiert!';

  @override
  String get resetPassword => 'Passwort zurücksetzen';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get updatePassword => 'Passwort aktualisieren';

  @override
  String get noActiveSessionFound =>
      'Keine aktive Sitzung gefunden. Bitte melden Sie sich erneut an.';

  @override
  String get authenticationFailedSignInAgain =>
      'Authentifizierung fehlgeschlagen. Bitte melden Sie sich erneut an.';

  @override
  String get accessDeniedNoAdminPrivileges =>
      'Zugriff verweigert. Sie haben keine Admin-Rechte.';

  @override
  String failedToLoadUsers(int statusCode, String errorBody) {
    return 'Benutzer konnten nicht geladen werden: $statusCode - $errorBody';
  }

  @override
  String get smartSearchRequiresSignIn =>
      'Bitte melden Sie sich an, um die intelligente Suche zu nutzen';

  @override
  String get smartSearch => 'Intelligente Suche';

  @override
  String get failedToPersistTemplate =>
      'Vorlage konnte nicht gespeichert werden';

  @override
  String userIdCreated(String id, String createdAt) {
    return 'Benutzer $id erstellt am $createdAt';
  }

  @override
  String get tryAdjustingSearchCreateNovel =>
      'Versuchen Sie, Ihre Suche anzupassen oder einen neuen Roman zu erstellen';

  @override
  String get sessionExpired => 'Sitzung abgelaufen';

  @override
  String get errorLoadingUsers => 'Fehler beim Laden der Benutzer';

  @override
  String get unknownError => 'Unbekannter Fehler';

  @override
  String get goBack => 'Zurück';

  @override
  String get unableToLoadAsset => 'Ressource konnte nicht geladen werden';

  @override
  String get youDontHavePermission =>
      'Sie haben keine Berechtigung, diese Aktion auszuführen.';

  @override
  String get continueReading => 'Weiterlesen';

  @override
  String get removeFromLibrary => 'Aus der Bibliothek entfernen';

  @override
  String get createFirstNovelSubtitle =>
      'Erstellen Sie Ihren ersten Roman, um zu beginnen';

  @override
  String get navigationError => 'Navigationsfehler';

  @override
  String get pdfStepPreparing => 'Kapitel werden vorbereitet';

  @override
  String get pdfStepGenerating => 'PDF wird generiert';

  @override
  String get pdfStepSharing => 'Wird freigegeben';

  @override
  String get tipIntention =>
      'Tipp: Schreiben Sie eine klare Absicht pro Szene.';

  @override
  String get tipVerbs => 'Tipp: Starke Verben machen Sätze lebendig.';

  @override
  String get tipStuck =>
      'Tipp: Wenn Sie feststecken, schreiben Sie den letzten Absatz neu.';

  @override
  String get tipDialogue =>
      'Tipp: Dialoge enthüllen Charaktere schneller als Beschreibungen.';

  @override
  String get errorNovelNotFound => 'Roman nicht gefunden';

  @override
  String get noSentenceSummary => 'Keine Satz-Zusammenfassung verfügbar.';

  @override
  String get noParagraphSummary => 'Keine Absatz-Zusammenfassung verfügbar.';

  @override
  String get noPageSummary => 'Keine Seiten-Zusammenfassung verfügbar.';

  @override
  String get noExpandedSummary => 'Keine erweiterte Zusammenfassung verfügbar.';

  @override
  String get aiSentenceSummaryTooltip => 'KI-Satz-Zusammenfassung';

  @override
  String get aiParagraphSummaryTooltip => 'KI-Absatz-Zusammenfassung';

  @override
  String get aiPageSummaryTooltip => 'KI-Seiten-Zusammenfassung';

  @override
  String get keyboardShortcuts => 'Tastaturkürzel';

  @override
  String get shortcutSpace => 'Leertaste: Abspielen / Stoppen';

  @override
  String get shortcutArrows => '← / →: Zurück / Weiter';

  @override
  String get shortcutRate => 'Strg/⌘ + R: Sprechgeschwindigkeit';

  @override
  String get shortcutVoice => 'Strg/⌘ + V: Stimme';

  @override
  String get shortcutHelp => 'Strg/⌘ + /: Kürzel anzeigen';

  @override
  String get shortcutEsc => 'Esc: Schließen';

  @override
  String get styles => 'Stile';

  @override
  String get noVoicesAvailable => 'Keine Stimmen verfügbar';

  @override
  String get comingSoon => 'Demnächst';

  @override
  String get selectNovelFirst => 'Wählen Sie zuerst einen Roman';

  @override
  String get adminLogs => 'Admin-Logs';

  @override
  String get viewAndFilterBackendLogs => 'Backend-Logs anzeigen und filtern';

  @override
  String get styleGlassmorphism => 'Glassmorphismus';

  @override
  String get styleLiquidGlass => 'Liquid Glass';

  @override
  String get styleNeumorphism => 'Neumorphismus';

  @override
  String get styleClaymorphism => 'Claymorphismus';

  @override
  String get styleMinimalism => 'Minimalismus';

  @override
  String get styleBrutalism => 'Brutalismus';

  @override
  String get styleSkeuomorphism => 'Skeuomorphismus';

  @override
  String get styleBentoGrid => 'Bento Grid';

  @override
  String get styleResponsive => 'Responsive';

  @override
  String get styleFlatDesign => 'Flat Design';

  @override
  String get scrollToBottom => 'Nach unten scrollen';

  @override
  String get scrollToTop => 'Nach oben scrollen';

  @override
  String get numberOfLines => 'Anzahl der Zeilen';

  @override
  String get lines => 'Zeilen';

  @override
  String get load => 'Laden';

  @override
  String get noLogsAvailable => 'Keine Logs verfügbar.';

  @override
  String get failedToLoadLogs => 'Logs konnten nicht geladen werden';

  @override
  String wordCount(int count) {
    return 'Wortanzahl: $count';
  }

  @override
  String characterCount(int count) {
    return 'Zeichenanzahl: $count';
  }

  @override
  String get startWriting => 'Schreiben beginnen...';

  @override
  String failedToLoadChapter(String error) {
    return 'Kapitel konnte nicht geladen werden: $error';
  }

  @override
  String get saving => 'Speichern…';

  @override
  String get wordCountLabel => 'Wortanzahl';

  @override
  String get characterCountLabel => 'Zeichenanzahl';

  @override
  String get discard => 'Verwerfen';

  @override
  String get saveShortcut => 'Speichern';

  @override
  String get previewShortcut => 'Vorschau';

  @override
  String get boldShortcut => 'Fett';

  @override
  String get italicShortcut => 'Kursiv';

  @override
  String get underlineShortcut => 'Unterstrichen';

  @override
  String get headingShortcut => 'Überschrift';

  @override
  String get insertLinkShortcut => 'Link einfügen';

  @override
  String get shortcutsHelpShortcut => 'Kurzhilfe';

  @override
  String get closeShortcut => 'Schließen';

  @override
  String get designSystemStyleGuide => 'Design-System-Stilguide';

  @override
  String get headlineLarge => 'Große Überschrift';

  @override
  String get headlineMedium => 'Mittlere Überschrift';

  @override
  String get titleLarge => 'Großer Titel';

  @override
  String get bodyLarge => 'Großer Text';

  @override
  String get bodyMedium => 'Mittlerer Text';

  @override
  String get primaryButton => 'Primäre Schaltfläche';

  @override
  String get disabled => 'Deaktiviert';

  @override
  String checkboxState(bool value) {
    return 'Checkbox-Status: $value';
  }

  @override
  String get option1 => 'Option 1';

  @override
  String get option2 => 'Option 2';

  @override
  String switchState(bool value) {
    return 'Schalter-Status: $value';
  }

  @override
  String sliderValue(String value) {
    return 'Wert: $value';
  }

  @override
  String get enterTextHere => 'Text hier eingeben...';

  @override
  String get selectAnOption => 'Option auswählen';

  @override
  String get optionA => 'Option A';

  @override
  String get optionB => 'Option B';

  @override
  String get optionC => 'Option C';

  @override
  String get contrastIssuesDetected => 'Kontrastprobleme erkannt';

  @override
  String foundContrastIssues(int count) {
    return '$count Kontrastproblem(e) gefunden, die die Lesbarkeit beeinträchtigen könnten.';
  }

  @override
  String get allGood => 'Alles gut!';

  @override
  String get allGoodContrast =>
      'Alle Textelemente erfüllen die WCAG 2.1 AA-Kontraststandards.';

  @override
  String get ignore => 'Ignorieren';

  @override
  String get applyBestFix => 'Beste Lösung anwenden';

  @override
  String get moreMenuComingSoon => 'Mehr Menü folgt bald';

  @override
  String get styleGuide => 'Stilguide';

  @override
  String get themeFactoryNotDefined =>
      'Theme Factory hat keine Designs definiert, Standard-Design wird verwendet.';

  @override
  String progressPercentage(int percent) {
    return '$percent%';
  }

  @override
  String get review => 'Überprüfung';

  @override
  String get wordsLabel => 'Wörter';

  @override
  String get charsLabel => 'Zeichen';

  @override
  String get readLabel => 'Gelesen';

  @override
  String get streakLabel => 'Serie';

  @override
  String get pause => 'Pause';

  @override
  String get start => 'Start';

  @override
  String get editMode => 'Bearbeitungsmodus';

  @override
  String get previewMode => 'Vorschaumodus';

  @override
  String get quote => 'Zitat';

  @override
  String get inlineCode => 'Inline-Code';

  @override
  String get bulletedList => 'Aufzählungsliste';

  @override
  String get numberedList => 'Nummerierte Liste';

  @override
  String get previewTab => 'Vorschau';

  @override
  String get editTab => 'Bearbeiten';

  @override
  String get noExpandedSummaryAvailable =>
      'Keine erweiterte Zusammenfassung verfügbar.';

  @override
  String get analyze => 'Analysieren';

  @override
  String youreOffline(String message) {
    return 'Sie sind offline. $message';
  }

  @override
  String get download => 'Herunterladen';

  @override
  String get moreActions => 'Weitere Aktionen';

  @override
  String get doubleTapToOpen =>
      'Doppeltippen zum Öffnen. Gedrückt halten für Aktionen.';

  @override
  String get more => 'Mehr';

  @override
  String get pressD => 'D drücken';

  @override
  String get pressEnter => 'Eingabe drücken';

  @override
  String get pressDelete => 'Entf drücken';

  @override
  String get exitPreview => 'Vorschau beenden';

  @override
  String get saveLabel => 'Speichern';

  @override
  String get exitZenMode => 'Zen-Modus beenden';

  @override
  String get clearSearch => 'Suche löschen';

  @override
  String get notSignedInLabel => 'Nicht angemeldet';

  @override
  String get stylePreviewGrid => 'Stilvorschaugitter';

  @override
  String get themeOceanDepths => 'Ozeantiefen';

  @override
  String get themeSunsetBoulevard => 'Sunset Boulevard';

  @override
  String get themeForestCanopy => 'Waldkronen';

  @override
  String get themeModernMinimalist => 'Modern minimalistisch';

  @override
  String get themeGoldenHour => 'Goldene Stunde';

  @override
  String get themeArcticFrost => 'Arktischer Frost';

  @override
  String get themeDesertRose => 'Wüstenrose';

  @override
  String get themeTechInnovation => 'Technische Innovation';

  @override
  String get themeBotanicalGarden => 'Botanischer Garten';

  @override
  String get themeMidnightGalaxy => 'Mitternachtsgalaxie';

  @override
  String get standardLight => 'Standard Hell';

  @override
  String get warmPaper => 'Warmes Papier';

  @override
  String get coolGrey => 'Kühles Grau';

  @override
  String get sepiaLabel => 'Sepia';

  @override
  String get standardDark => 'Standard Dunkel';

  @override
  String get midnight => 'Mitternacht';

  @override
  String get darkSepia => 'Dunkles Sepia';

  @override
  String get deepOcean => 'Tiefer Ozean';

  @override
  String get youreOfflineLabel => 'Sie sind offline';

  @override
  String get changesWillSync =>
      'Änderungen werden synchronisiert, wenn Sie wieder online sind';

  @override
  String changesWillSyncCount(int count) {
    return '$count Änderung(en) wird/werden synchronisiert, wenn Sie wieder online sind';
  }

  @override
  String get toggleSidebar => 'Seitenleiste umschalten';

  @override
  String get quickSearch => 'Schnellsuche';
}
