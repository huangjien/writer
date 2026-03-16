// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get newChapter => 'Nuovo capitolo';

  @override
  String get back => 'Indietro';

  @override
  String get helloWorld => 'Ciao mondo!';

  @override
  String get home => 'Home';

  @override
  String get settings => 'Impostazioni';

  @override
  String get appTitle => 'Writer';

  @override
  String get about => 'Informazioni';

  @override
  String get aboutDescription =>
      'Leggi e gestisci romanzi, con archiviazione cloud, supporto offline e riproduzione sintesi vocale. Usa la Libreria per sfogliare, cercare e aprire capitoli; accedi per sincronizzare i progressi; regola le impostazioni per tema, tipografia e animazioni.';

  @override
  String get aboutIntro =>
      'AuthorConsole ti aiuta a pianificare, scrivere e leggere romanzi su più dispositivi. Si concentra sulla semplicità per i lettori e sulla potenza per gli autori, offrendo un luogo unificato per gestire capitoli, riassunti, personaggi e scene.';

  @override
  String get aboutSecurity =>
      'Con l\'archiviazione cloud e controlli di accesso rigorosi, i tuoi dati rimangono protetti. Gli utenti autenticati possono sincronizzare progressi, metadati e modelli mantenendo la privacy.';

  @override
  String get aboutCoach =>
      'L\'AI Coach integrato utilizza il metodo Snowflake per migliorare il riassunto della storia. Fa domande mirate, offre suggerimenti e quando è pronto, fornisce un riassunto raffinato che l\'app applica al tuo documento.';

  @override
  String get aboutFeatureCreate =>
      '• Crea un nuovo romanzo e organizza i capitoli.';

  @override
  String get aboutFeatureTemplates =>
      '• Usa modelli di personaggi e scene per avviare idee.';

  @override
  String get aboutFeatureTracking =>
      '• Tieni traccia dei progressi di lettura e riprendi su più dispositivi.';

  @override
  String get aboutFeatureCoach =>
      '• Affina il tuo riassunto con l\'AI Coach e applica miglioramenti.';

  @override
  String get aboutFeaturePrompts =>
      '• Gestisci i prompt e sperimenta con flussi di lavoro assistiti dall\'AI.';

  @override
  String get aboutUsage => 'Utilizzo';

  @override
  String get aboutUsageList =>
      '• Libreria: cerca e apri romanzi\n• Lettore: naviga tra i capitoli, attiva TTS\n• Modelli: gestisci modelli di personaggi e scene\n• Impostazioni: tema, tipografia e preferenze\n• Accedi: abilita la sincronizzazione cloud';

  @override
  String get version => 'Versione';

  @override
  String get appLanguage => 'Lingua app';

  @override
  String get english => 'Inglese';

  @override
  String get chinese => 'Cinese';

  @override
  String get supabaseIntegrationInitialized =>
      'Sincronizzazione cloud inizializzata';

  @override
  String get configureEnvironment =>
      'Configura le variabili d\'ambiente per abilitare la sincronizzazione cloud';

  @override
  String signedInAs(String email) {
    return 'Accesso effettuato come $email';
  }

  @override
  String get guest => 'Ospite';

  @override
  String get notSignedIn => 'Non accessibile';

  @override
  String get signIn => 'Accedi';

  @override
  String get continueLabel => 'Continua';

  @override
  String get reload => 'Ricarica';

  @override
  String get signInToSync =>
      'Accedi per sincronizzare i progressi tra i dispositivi.';

  @override
  String get currentProgress => 'Progresso attuale';

  @override
  String get loadingProgress => 'Caricamento progressi...';

  @override
  String get recentlyRead => 'Letti di recente';

  @override
  String get noSupabase =>
      'La sincronizzazione cloud non è abilitata in questa build.';

  @override
  String get errorLoadingProgress => 'Errore nel caricamento dei progressi';

  @override
  String get noProgress => 'Nessun progresso trovato';

  @override
  String get errorLoadingNovels => 'Errore nel caricamento dei romanzi';

  @override
  String get loadingNovels => 'Caricamento romanzi…';

  @override
  String get titleLabel => 'Titolo';

  @override
  String get authorLabel => 'Autore';

  @override
  String get noNovelsFound => 'Nessun romanzo trovato.';

  @override
  String get myNovels => 'I miei romanzi';

  @override
  String get createNovel => 'Crea romanzo';

  @override
  String get create => 'Crea';

  @override
  String get errorLoadingChapters => 'Errore nel caricamento dei capitoli';

  @override
  String get loadingChapter => 'Caricamento capitolo…';

  @override
  String get notStarted => 'Non iniziato';

  @override
  String get unknownNovel => 'Romanzo sconosciuto';

  @override
  String get unknownChapter => 'Capitolo sconosciuto';

  @override
  String get chapter => 'Capitolo';

  @override
  String get novel => 'Romanzo';

  @override
  String get chapterTitle => 'Titolo del capitolo';

  @override
  String get scrollOffset => 'Scorrimento offset';

  @override
  String get ttsIndex => 'Indice TTS';

  @override
  String get speechRate => 'Velocità parlata';

  @override
  String get volume => 'Volume';

  @override
  String get defaultTTSVoice => 'Voce TTS predefinita';

  @override
  String get defaultVoiceUpdated => 'Voce predefinita aggiornata';

  @override
  String get defaultLanguageSet => 'Lingua predefinita impostata';

  @override
  String get searchByTitle => 'Cerca per titolo…';

  @override
  String get chooseLanguage => 'Scegli lingua';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signInWithGoogle => 'Accedi con Google';

  @override
  String get signInWithApple => 'Accedi con Apple';

  @override
  String get testVoice => 'Prova voce';

  @override
  String get reloadVoices => 'Ricarica voci';

  @override
  String get signOut => 'Esci';

  @override
  String get signedOut => 'Disconnesso';

  @override
  String get appSettings => 'Impostazioni app';

  @override
  String get supabaseSettings => 'Impostazioni sincronizzazione cloud';

  @override
  String get supabaseNotEnabled => 'Sincronizzazione cloud non abilitata';

  @override
  String get supabaseNotEnabledDescription =>
      'La sincronizzazione cloud non è configurata per questa build.';

  @override
  String get authDisabledInBuild =>
      'Sincronizzazione cloud non configurata. L\'autenticazione è disabilitata in questa build.';

  @override
  String get fetchFromSupabase => 'Recupera dal cloud';

  @override
  String get fetchFromSupabaseDescription =>
      'Recupera gli ultimi romanzi e progressi dal cloud.';

  @override
  String get confirmFetch => 'Conferma recupero';

  @override
  String get confirmFetchDescription =>
      'Questo sovrascriverà i tuoi dati locali. Sei sicuro?';

  @override
  String get cancel => 'Annulla';

  @override
  String get fetch => 'Recupera';

  @override
  String get downloadChapters => 'Scarica capitoli';

  @override
  String get modeSupabase => 'Modalità: sincronizzazione cloud';

  @override
  String get modeMockData => 'Modalità: dati di prova';

  @override
  String continueAtChapter(String title) {
    return 'Continua al capitolo • $title';
  }

  @override
  String get error => 'Errore';

  @override
  String get ttsSettings => 'Impostazioni TTS';

  @override
  String get enableTTS => 'Abilita TTS';

  @override
  String get sentenceSummary => 'Riassunto frase';

  @override
  String get paragraphSummary => 'Riassunto paragrafo';

  @override
  String get pageSummary => 'Riassunto pagina';

  @override
  String get expandedSummary => 'Riassunto esteso';

  @override
  String get pitch => 'Tonalità';

  @override
  String get signInWithBiometrics => 'Accedi con biometria';

  @override
  String get enableBiometricLogin => 'Abilita accesso biometrico';

  @override
  String get enableBiometricLoginDescription =>
      'Usa l\'impronta digitale o il riconoscimento facciale per accedere.';

  @override
  String get biometricAuthFailed => 'Autenticazione biometrica fallita';

  @override
  String get saveCredentialsForBiometric =>
      'Salva credenziali per accesso biometrico';

  @override
  String get saveCredentialsForBiometricDescription =>
      'Archivia in modo sicuro le tue credenziali per un\'autenticazione biometrica più rapida';

  @override
  String get biometricTokensExpired => 'I token biometrici sono scaduti';

  @override
  String get biometricNoTokens => 'Nessun token biometrico trovato';

  @override
  String get biometricTokenError => 'Errore token biometrico';

  @override
  String get biometricTechnicalError => 'Errore tecnico biometrico';

  @override
  String get ttsVoice => 'Voce TTS';

  @override
  String get loadingVoices => 'Caricamento voci...';

  @override
  String get selectVoice => 'Seleziona una voce';

  @override
  String get ttsLanguage => 'Lingua TTS';

  @override
  String get loadingLanguages => 'Caricamento lingue...';

  @override
  String get selectLanguage => 'Seleziona una lingua';

  @override
  String get ttsSpeechRate => 'Velocità parlata';

  @override
  String get ttsSpeechVolume => 'Volume parlato';

  @override
  String get ttsSpeechPitch => 'Tonalità parlata';

  @override
  String get novelsAndProgress => 'Romanzi e progressi';

  @override
  String get novels => 'Romanzi';

  @override
  String get progress => 'Progressi';

  @override
  String novelsAndProgressSummary(int count, String progress) {
    return 'Romanzi: $count, Progressi: $progress';
  }

  @override
  String get chapters => 'Capitoli';

  @override
  String get noChaptersFound => 'Nessun capitolo trovato.';

  @override
  String indexLabel(int index) {
    return 'Indice $index';
  }

  @override
  String get enterFloatIndexHint =>
      'Inserisci indice decimale per riposizionare';

  @override
  String indexOutOfRange(int min, int max) {
    return 'L\'indice deve essere tra $min e $max';
  }

  @override
  String get indexUnchanged => 'Indice invariato';

  @override
  String get roundingBefore => 'Sempr prima';

  @override
  String get roundingAfter => 'Sempre dopo';

  @override
  String get stopTTS => 'Ferma TTS';

  @override
  String get speak => 'Parla';

  @override
  String get supabaseProgressNotSaved =>
      'Sincronizzazione cloud non configurata; progressi non salvati';

  @override
  String get progressSaved => 'Progressi salvati';

  @override
  String get errorSavingProgress => 'Errore nel salvataggio dei progressi';

  @override
  String get autoplayBlocked =>
      'Riproduzione automatica bloccata. Tocca Continua per iniziare.';

  @override
  String get autoplayBlockedInline =>
      'La riproduzione automatica è bloccata dal browser. Tocca Continua per iniziare a leggere.';

  @override
  String get reachedLastChapter => 'Ultimo capitolo raggiunto';

  @override
  String ttsError(String msg) {
    return 'Errore TTS: $msg';
  }

  @override
  String get themeMode => 'Modalità tema';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Chiaro';

  @override
  String get dark => 'Scuro';

  @override
  String get colorTheme => 'Tema colore';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeSepia => 'Seppia';

  @override
  String get themeHighContrast => 'Contrasto';

  @override
  String get themeDefault => 'Predefinito';

  @override
  String get themeEmeraldGreen => 'Smeraldo';

  @override
  String get themeSolarizedTan => 'Solarizzato Beige';

  @override
  String get themeNord => 'Nord';

  @override
  String get themeNordFrost => 'Nord Gelo';

  @override
  String get separateDarkPalette => 'Usa tavolozza scura separata';

  @override
  String get lightPalette => 'Tavolozza chiara';

  @override
  String get darkPalette => 'Tavolozza scura';

  @override
  String get typographyPreset => 'Preset tipografia';

  @override
  String get typographyComfortable => 'Confortevole';

  @override
  String get typographyCompact => 'Compatto';

  @override
  String get typographySerifLike => 'Tipo Serif';

  @override
  String get fontPack => 'Pack font';

  @override
  String get separateTypographyPresets =>
      'Usa tipografia separata per chiaro/scuro';

  @override
  String get typographyLight => 'Tipografia chiara';

  @override
  String get typographyDark => 'Tipografia scura';

  @override
  String get readerBundles => 'Bundle tema lettore';

  @override
  String get tokenUsage => 'Utilizzo token';

  @override
  String removedNovel(String title) {
    return 'Rimosso $title';
  }

  @override
  String get discover => 'Scopri';

  @override
  String get profile => 'Profilo';

  @override
  String get libraryTitle => 'Libreria';

  @override
  String get undo => 'Annulla';

  @override
  String get allFilter => 'Tutti';

  @override
  String get readingFilter => 'In lettura';

  @override
  String get completedFilter => 'Completati';

  @override
  String get downloadedFilter => 'Scaricati';

  @override
  String get searchNovels => 'Cerca romanzi...';

  @override
  String get listView => 'Vista elenco';

  @override
  String get gridView => 'Vista griglia';

  @override
  String get userManagement => 'Gestione utenti';

  @override
  String get totalThisMonth => 'Totale questo mese';

  @override
  String get inputTokens => 'Token in input';

  @override
  String get outputTokens => 'Token in output';

  @override
  String get requests => 'Richieste';

  @override
  String get viewHistory => 'Visualizza cronologia';

  @override
  String get noUsageThisMonth => 'Nessun utilizzo questo mese';

  @override
  String get startUsingAiFeatures =>
      'Inizia a usare le funzionalità AI per vedere il consumo di token';

  @override
  String get errorLoadingUsage => 'Errore nel caricamento dell\'utilizzo';

  @override
  String get refresh => 'Aggiorna';

  @override
  String totalRecords(int count) {
    return 'Record totali: $count';
  }

  @override
  String get total => 'Totale';

  @override
  String get noUsageHistory => 'Nessuna cronologia di utilizzo';

  @override
  String get bundleNordCalm => 'Nord Calmo';

  @override
  String get bundleSolarizedFocus => 'Focus Solarizzato';

  @override
  String get bundleHighContrastReadability => 'Leggibilità alto contrasto';

  @override
  String get customFontFamily => 'Famiglia font personalizzata';

  @override
  String get commonFonts => 'Font comuni';

  @override
  String get readerFontSize => 'Dimensione font lettore';

  @override
  String get textScale => 'Scala testo';

  @override
  String get readerBackgroundDepth => 'Profondità sfondo lettore';

  @override
  String get depthLow => 'Bassa';

  @override
  String get depthMedium => 'Media';

  @override
  String get depthHigh => 'Alta';

  @override
  String get select => 'Seleziona';

  @override
  String get clear => 'Cancella';

  @override
  String get adminMode => 'Modalità admin';

  @override
  String get reduceMotion => 'Riduci movimento';

  @override
  String get reduceMotionDescription =>
      'Minimizza le animazioni per il comfort visivo';

  @override
  String get gesturesEnabled => 'Abilita gesture touch';

  @override
  String get gesturesEnabledDescription =>
      'Abilita scorrimento e tocco nel lettore';

  @override
  String get readerSwipeSensitivity => 'Sensibilità scorrimento lettore';

  @override
  String get readerSwipeSensitivityDescription =>
      'Regola la velocità minima di scorrimento per la navigazione dei capitoli';

  @override
  String get remove => 'Rimuovi';

  @override
  String get removedFromLibrary => 'Rimosso dalla libreria';

  @override
  String get confirmDelete => 'Conferma eliminazione';

  @override
  String confirmDeleteDescription(String title) {
    return 'Questo eliminerà \'$title\' dalla tua libreria cloud. Sei sicuro?';
  }

  @override
  String get delete => 'Elimina';

  @override
  String get reachedFirstChapter => 'Primo capitolo raggiunto';

  @override
  String get previousChapter => 'Capitolo precedente';

  @override
  String get nextChapter => 'Capitolo successivo';

  @override
  String get betaEvaluate => 'Beta';

  @override
  String get betaEvaluating => 'Invio per valutazione beta…';

  @override
  String get betaEvaluationReady => 'Valutazione beta pronta';

  @override
  String get betaEvaluationFailed => 'Valutazione beta fallita';

  @override
  String get performanceSettings => 'Impostazioni prestazioni';

  @override
  String get prefetchNextChapter => 'Precarica prossimo capitolo';

  @override
  String get prefetchNextChapterDescription =>
      'Precarica il prossimo capitolo per ridurre l\'attesa.';

  @override
  String get clearOfflineCache => 'Svuota cache offline';

  @override
  String get offlineCacheCleared => 'Cache offline svuotata';

  @override
  String get edit => 'Modifica';

  @override
  String get exitEdit => 'Esci da modifica';

  @override
  String get enterEditMode => 'Entra in modalità modifica';

  @override
  String get exitEditMode => 'Esci dalla modalità modifica';

  @override
  String get chapterContent => 'Contenuto del capitolo';

  @override
  String get save => 'Salva';

  @override
  String get createNextChapter => 'Crea prossimo capitolo';

  @override
  String get enterChapterTitle => 'Inserisci titolo del capitolo';

  @override
  String get enterChapterContent => 'Inserisci contenuto del capitolo';

  @override
  String get discardChangesTitle => 'Scartare le modifiche?';

  @override
  String get discardChangesMessage =>
      'Hai modifiche non salvate. Vuoi scartarle?';

  @override
  String get keepEditing => 'Continua a modificare';

  @override
  String get discardChanges => 'Scarta modifiche';

  @override
  String get saveAndExit => 'Salva ed esci';

  @override
  String get descriptionLabel => 'Descrizione';

  @override
  String get coverUrlLabel => 'URL copertina';

  @override
  String get invalidCoverUrl => 'Inserisci un URL http(s) valido senza spazi.';

  @override
  String get navigation => 'Navigazione';

  @override
  String get chapterIndex => 'Indice capitoli';

  @override
  String get summary => 'Riassunto';

  @override
  String get characters => 'Personaggi';

  @override
  String get scenes => 'Scene';

  @override
  String get characterTemplates => 'Modelli personaggi';

  @override
  String get sceneTemplates => 'Modelli scene';

  @override
  String get updateNovel => 'Aggiorna romanzo';

  @override
  String get deleteNovel => 'Elimina romanzo';

  @override
  String get deleteNovelConfirmation =>
      'Questo eliminerà definitivamente il romanzo. Continuare?';

  @override
  String get format => 'Formato';

  @override
  String get aiServiceUrl => 'URL servizio AI';

  @override
  String get aiServiceUrlDescription =>
      'URL del servizio backend per funzionalità AI';

  @override
  String get aiAssistant => 'Assistente AI';

  @override
  String get aiChatHistory => 'Cronologia';

  @override
  String get aiChatNewChat => 'Nuova chat';

  @override
  String get aiChatNoHistory => 'Nessuna cronologia';

  @override
  String get aiChatHint => 'Scrivi il tuo messaggio...';

  @override
  String get aiChatEmpty =>
      'Chiedimi qualsiasi cosa su questo capitolo o romanzo';

  @override
  String get aiThinking => 'AI sta pensando...';

  @override
  String get aiChatContextLabel => 'Contesto';

  @override
  String aiTokenCount(int count) {
    return '$count token';
  }

  @override
  String aiContextLoadError(String error) {
    return 'Errore nel caricamento del contesto: $error';
  }

  @override
  String aiChatContextTooLongCompressing(int tokens) {
    return 'Il contesto è troppo lungo ($tokens token). Compressione...';
  }

  @override
  String aiChatContextCompressionFailedNote(String error) {
    return '[Nota: compressione contesto fallita: $error]';
  }

  @override
  String aiChatError(String error) {
    return 'Errore: $error';
  }

  @override
  String aiChatDeepAgentError(String error) {
    return 'Errore Deep Agent: $error';
  }

  @override
  String get aiChatSearchFailed => 'Ricerca fallita';

  @override
  String aiChatSearchError(String error) {
    return 'Errore ricerca: $error';
  }

  @override
  String get aiChatRagSearchResultsTitle => 'Risultati ricerca RAG';

  @override
  String aiChatRagRefinedQuery(String query) {
    return 'Query raffinata: \"$query\"';
  }

  @override
  String get aiChatRagNoResults => 'Nessun risultato trovato.';

  @override
  String get aiChatRagUnknownType => 'sconosciuto';

  @override
  String get aiServiceSignInRequired =>
      'Accesso richiesto per usare il servizio AI';

  @override
  String get aiServiceFeatureNotAvailable =>
      'Funzionalità non disponibile per il tuo piano';

  @override
  String aiServiceFailedToConnect(String error) {
    return 'Impossibile connettersi al servizio AI: $error';
  }

  @override
  String get aiServiceNoResponse => 'Nessuna risposta dal servizio AI';

  @override
  String get aiDeepAgentDetailsTitle => 'Deep Agent';

  @override
  String aiDeepAgentStop(String reason, Object rounds) {
    return 'Stop: $reason (round: $rounds)';
  }

  @override
  String get aiDeepAgentPlanLabel => 'Piano:';

  @override
  String get aiDeepAgentToolsLabel => 'Strumenti:';

  @override
  String get deepAgentSettingsTitle => 'Impostazioni Deep Agent';

  @override
  String get deepAgentSettingsDescription =>
      'Controlla se AI Chat preferisce Deep Agent, più riflessione e output debug.';

  @override
  String get deepAgentPreferTitle => 'Preferisci Deep Agent';

  @override
  String get deepAgentPreferSubtitle =>
      'Se abilitato, le chat normali chiamano prima /agents/deep-agent.';

  @override
  String get deepAgentFallbackTitle => 'Fallback su QA se non disponibile';

  @override
  String get deepAgentFallbackSubtitle =>
      'Chiama automaticamente /agents/qa quando deep-agent restituisce 404/501.';

  @override
  String get deepAgentReflectionModeTitle => 'Modalità riflessione';

  @override
  String get deepAgentReflectionModeSubtitle =>
      'Controlla valutazione post-risposta e ripristino opzionale.';

  @override
  String get deepAgentReflectionModeOff => 'Spento';

  @override
  String get deepAgentReflectionModeOnFailure => 'Su errore';

  @override
  String get deepAgentReflectionModeAlways => 'Sempre';

  @override
  String get deepAgentShowDetailsTitle => 'Mostra dettagli esecuzione';

  @override
  String get deepAgentShowDetailsSubtitle =>
      'Include log di piano e chiamate strumenti nell\'output /deep.';

  @override
  String get deepAgentMaxPlanSteps => 'Max passi piano';

  @override
  String get deepAgentMaxToolRounds => 'Max round strumenti';

  @override
  String get send => 'Invia';

  @override
  String get resetToDefault => 'Ripristina predefiniti';

  @override
  String get invalidUrl => 'Inserisci un URL http(s) valido senza spazi.';

  @override
  String get urlTooLong => 'L\'URL deve essere di 2048 caratteri o meno.';

  @override
  String get urlContainsSpaces => 'L\'URL non può contenere spazi.';

  @override
  String get urlInvalidScheme => 'L\'URL deve iniziare con http:// o https://.';

  @override
  String get saved => 'Salvato';

  @override
  String get required => 'Richiesto';

  @override
  String get summariesLabel => 'Riassunti';

  @override
  String get synopsesLabel => 'Sinossi';

  @override
  String get locationLabel => 'Posizione';

  @override
  String languageLabel(String code) {
    return 'Lingua: $code';
  }

  @override
  String get publicLabel => 'Pubblico';

  @override
  String get privateLabel => 'Privato';

  @override
  String chaptersCount(int count) {
    return 'Capitoli: $count';
  }

  @override
  String avgWordsPerChapter(int avg) {
    return 'Media parole/capitolo: $avg';
  }

  @override
  String chapterLabel(int idx) {
    return 'Capitolo $idx';
  }

  @override
  String chapterWithTitle(int idx, String title) {
    return 'Capitolo $idx: $title';
  }

  @override
  String get refreshTooltip => 'Aggiorna';

  @override
  String get untitled => 'Senza titolo';

  @override
  String get newLabel => 'Nuovo';

  @override
  String get deleteSceneTitle => 'Elimina scena';

  @override
  String get deleteCharacterTitle => 'Elimina personaggio';

  @override
  String get deleteTemplateTitle => 'Elimina modello';

  @override
  String get confirmDeleteGeneric =>
      'Sei sicuro di voler eliminare questo elemento?';

  @override
  String get novelMetadata => 'Metadati romanzo';

  @override
  String get contributorEmailLabel => 'Email collaboratore';

  @override
  String get contributorEmailHint =>
      'Inserisci email utente da aggiungere come collaboratore';

  @override
  String get addContributor => 'Aggiungi collaboratore';

  @override
  String get contributorAdded => 'Collaboratore aggiunto';

  @override
  String get pdf => 'PDF';

  @override
  String get generatingPdf => 'Generazione PDF…';

  @override
  String get pdfFailed => 'Generazione PDF fallita';

  @override
  String get tableOfContents => 'Indice';

  @override
  String byAuthor(String name) {
    return 'di $name';
  }

  @override
  String pageOfTotal(int page, int total) {
    return 'Pagina $page di $total';
  }

  @override
  String get close => 'Chiudi';

  @override
  String get openLink => 'Apri link';

  @override
  String get invalidLink => 'Link non valido';

  @override
  String get unableToOpenLink => 'Impossibile aprire il link';

  @override
  String get copy => 'Copia';

  @override
  String get copiedToClipboard => 'Copiato negli appunti';

  @override
  String showingCachedPublicData(String msg) {
    return '$msg — visualizzazione dati cache/pubblici';
  }

  @override
  String get menu => 'Menu';

  @override
  String get metaLabel => 'Meta';

  @override
  String get aiServiceUnavailable => 'Servizio AI non disponibile';

  @override
  String get aiConfigurations => 'Configurazioni AI';

  @override
  String get modelLabel => 'Modello';

  @override
  String get temperatureLabel => 'Temperatura';

  @override
  String get saveFailed => 'Salvataggio fallito';

  @override
  String get saveMyVersion => 'Salva la mia versione';

  @override
  String get resetToPublic => 'Ripristina pubblico';

  @override
  String get resetFailed => 'Ripristino fallito';

  @override
  String get prompts => 'Prompt';

  @override
  String get patterns => 'Pattern';

  @override
  String get storyLines => 'Story line';

  @override
  String get tools => 'Strumenti';

  @override
  String get preview => 'Anteprima';

  @override
  String get actions => 'Azioni';

  @override
  String get searchLabel => 'Cerca';

  @override
  String get allLabel => 'Tutti';

  @override
  String get filterByLocked => 'Filtra per bloccati';

  @override
  String get lockedOnly => 'Solo bloccati';

  @override
  String get unlockedOnly => 'Solo sbloccati';

  @override
  String get promptKey => 'Chiave prompt';

  @override
  String get language => 'Lingua';

  @override
  String get filterByKey => 'Filtra per chiave';

  @override
  String get viewPublic => 'Visualizza pubblico';

  @override
  String get groupNone => 'Nessuno';

  @override
  String get groupLanguage => 'Lingua';

  @override
  String get groupKey => 'Chiave';

  @override
  String get newPrompt => 'Nuovo prompt';

  @override
  String get newPattern => 'Nuovo pattern';

  @override
  String get newStoryLine => 'Nuova story line';

  @override
  String get editPrompt => 'Modifica prompt';

  @override
  String get editPattern => 'Modifica pattern';

  @override
  String get editStoryLine => 'Modifica story line';

  @override
  String deletedWithTitle(String title) {
    return 'Eliminato: $title';
  }

  @override
  String deleteFailedWithTitle(String title) {
    return 'Eliminazione fallita: $title';
  }

  @override
  String deleteErrorWithMessage(String error) {
    return 'Errore eliminazione: $error';
  }

  @override
  String get makePublic => 'Rendi pubblico';

  @override
  String get noPrompts => 'Nessun prompt trovato';

  @override
  String get noPatterns => 'Nessun pattern';

  @override
  String get noStoryLines => 'Nessuna story line';

  @override
  String conversionFailed(String error) {
    return 'Conversione fallita: $error';
  }

  @override
  String get failedToAnalyze => 'Analisi fallita';

  @override
  String get aiCoachAnalyzing => 'AI Coach sta analizzando...';

  @override
  String get retry => 'Riprova';

  @override
  String get startAiCoaching => 'Avvia coaching AI';

  @override
  String get refinementComplete => 'Raffinamento completato!';

  @override
  String get coachQuestion => 'Domanda del coach';

  @override
  String get summaryLooksGood =>
      'Ottimo lavoro! Il tuo riassunto sembra solido.';

  @override
  String get howToImprove => 'Come possiamo migliorarlo?';

  @override
  String get suggestionsLabel => 'Suggerimenti:';

  @override
  String get reviewSuggestionsHint =>
      'Rivedi i suggerimenti o digita una risposta...';

  @override
  String get aiGenerationComplete => 'Generazione AI completata';

  @override
  String get clickRegenerateForNew => 'Clicca Rigenera per nuovi suggerimenti';

  @override
  String get regenerate => 'Rigenera';

  @override
  String get imSatisfied => 'Sono soddisfatto';

  @override
  String get templateLabel => 'Modello';

  @override
  String get exampleCharacterName => 'es. Harry Potter';

  @override
  String get aiConvert => 'Conversione AI';

  @override
  String get toggleAiCoach => 'Attiva/Disattiva AI Coach';

  @override
  String retrieveFailed(String error) {
    return 'Recupero fallito: $error';
  }

  @override
  String get confirm => 'Conferma';

  @override
  String get lastRead => 'Letto l\'ultima volta';

  @override
  String get noRecentChapters => 'Nessun capitolo recente';

  @override
  String get failedToLoadConfig => 'Caricamento configurazione fallito';

  @override
  String makePublicPromptConfirm(String promptKey, String language) {
    return 'Rendere pubblico \"$promptKey\" ($language)?';
  }

  @override
  String get content => 'Contenuto';

  @override
  String get invalidKey => 'Chiave non valida';

  @override
  String get invalidLanguage => 'Lingua non valida';

  @override
  String get invalidInput => 'Input non valido';

  @override
  String charsCount(int count) {
    return 'Caratteri: $count';
  }

  @override
  String deletePromptConfirm(String promptKey, String language) {
    return 'Eliminare il prompt \"$promptKey\" ($language)?';
  }

  @override
  String get profileRetrieved => 'Profilo recuperato';

  @override
  String get noProfileFound => 'Nessun profilo trovato';

  @override
  String get templateName => 'Nome modello';

  @override
  String get retrieveProfile => 'Recupera profilo';

  @override
  String get templateRetrieved => 'Modello recuperato';

  @override
  String get noTemplateFound => 'Nessun modello trovato';

  @override
  String get retrieveTemplate => 'Recupera modello';

  @override
  String get previewLabel => 'Anteprima';

  @override
  String get markdownHint => 'Inserisci descrizione in Markdown...';

  @override
  String get templateNameExists => 'Il nome modello esiste già';

  @override
  String get aiServiceUrlHint => 'Inserisci URL servizio AI (http/https)';

  @override
  String get urlLabel => 'URL';

  @override
  String get systemFont => 'Font di sistema';

  @override
  String get fontInter => 'Inter';

  @override
  String get fontMerriweather => 'Merriweather';

  @override
  String get editPatternTitle => 'Modifica pattern';

  @override
  String get newPatternTitle => 'Nuovo pattern';

  @override
  String get editStoryLineTitle => 'Modifica story line';

  @override
  String get newStoryLineTitle => 'Nuova story line';

  @override
  String get usageRulesLabel => 'Regole utilizzo (JSON)';

  @override
  String get publicPatternLabel => 'Pattern pubblico';

  @override
  String get publicStoryLineLabel => 'Story line pubblica';

  @override
  String get lockedLabel => 'Bloccato';

  @override
  String get unlockedLabel => 'Sbloccato';

  @override
  String get aiButton => 'AI';

  @override
  String get invalidJson => 'JSON non valido';

  @override
  String get deleteFailed => 'Eliminazione fallita';

  @override
  String get lockPattern => 'Blocca pattern';

  @override
  String get errorUnauthorized => 'Non autorizzato';

  @override
  String get errorForbidden => 'Vietato';

  @override
  String get errorSessionExpired => 'Sessione scaduta';

  @override
  String get errorValidation => 'Errore validazione';

  @override
  String get errorInvalidInput => 'Input non valido';

  @override
  String get errorDuplicateTitle => 'Titolo duplicato';

  @override
  String get errorNotFound => 'Non trovato';

  @override
  String get errorServiceUnavailable => 'Servizio non disponibile';

  @override
  String get errorAiNotConfigured => 'Servizio AI non configurato';

  @override
  String get errorSupabaseError => 'Errore servizio cloud';

  @override
  String get errorRateLimited => 'Troppe richieste';

  @override
  String get errorInternal => 'Errore interno del server';

  @override
  String get errorBadGateway => 'Bad gateway';

  @override
  String get errorGatewayTimeout => 'Timeout gateway';

  @override
  String get loginFailed => 'Accesso fallito';

  @override
  String get invalidResponseFromServer => 'Risposta non valida dal server';

  @override
  String get signUp => 'Registrati';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get signupFailed => 'Registrazione fallita';

  @override
  String get accountCreatedCheckEmail =>
      'Account creato! Controlla la tua email per verificare.';

  @override
  String get backToSignIn => 'Torna ad accedi';

  @override
  String get createAccount => 'Crea account';

  @override
  String get alreadyHaveAccountSignIn => 'Hai già un account? Accedi';

  @override
  String get requestFailed => 'Richiesta fallita';

  @override
  String get ifAccountExistsResetLinkSent =>
      'Se esiste un account, un link di reset è stato inviato alla tua email.';

  @override
  String get enterEmailForResetLink =>
      'Inserisci il tuo indirizzo email per ricevere un link di reset password.';

  @override
  String get sendResetLink => 'Invia link reset';

  @override
  String get passwordsDoNotMatch => 'Le password non corrispondono';

  @override
  String get sessionInvalidLoginAgain =>
      'Sessione non valida. Accedi o usa il link reset di nuovo.';

  @override
  String get updateFailed => 'Aggiornamento fallito';

  @override
  String get passwordUpdatedSuccessfully => 'Password aggiornata con successo!';

  @override
  String get resetPassword => 'Resetta password';

  @override
  String get newPassword => 'Nuova password';

  @override
  String get confirmPassword => 'Conferma password';

  @override
  String get updatePassword => 'Aggiorna password';

  @override
  String get noActiveSessionFound =>
      'Nessuna sessione attiva trovata. Accedi di nuovo.';

  @override
  String get authenticationFailedSignInAgain =>
      'Autenticazione fallita. Accedi di nuovo.';

  @override
  String get accessDeniedNoAdminPrivileges =>
      'Accesso negato. Non hai privilegi admin.';

  @override
  String failedToLoadUsers(int statusCode, String errorBody) {
    return 'Caricamento utenti fallito: $statusCode - $errorBody';
  }

  @override
  String get smartSearchRequiresSignIn => 'Accedi per usare la ricerca smart';

  @override
  String get smartSearch => 'Ricerca smart';

  @override
  String get failedToPersistTemplate => 'Salvataggio modello fallito';

  @override
  String userIdCreated(String id, String createdAt) {
    return 'Utente $id creato il $createdAt';
  }

  @override
  String get tryAdjustingSearchCreateNovel =>
      'Prova a modificare la ricerca o crea un nuovo romanzo';

  @override
  String get sessionExpired => 'Sessione scaduta';

  @override
  String get errorLoadingUsers => 'Errore caricamento utenti';

  @override
  String get unknownError => 'Errore sconosciuto';

  @override
  String get goBack => 'Torna indietro';

  @override
  String get unableToLoadAsset => 'Impossibile caricare risorsa';

  @override
  String get youDontHavePermission =>
      'Non hai i permessi per eseguire questa azione.';

  @override
  String get continueReading => 'Continua a leggere';

  @override
  String get removeFromLibrary => 'Rimuovi dalla libreria';

  @override
  String get createFirstNovelSubtitle =>
      'Crea il tuo primo romanzo per iniziare.';

  @override
  String get navigationError => 'Errore navigazione';

  @override
  String get pdfStepPreparing => 'Preparazione capitoli';

  @override
  String get pdfStepGenerating => 'Generazione PDF';

  @override
  String get pdfStepSharing => 'Condivisione';

  @override
  String get tipIntention =>
      'Suggerimento: Scrivi un\'intenzione chiara per scena.';

  @override
  String get tipVerbs => 'Suggerimento: I verbi forti rendono le frasi vive.';

  @override
  String get tipStuck =>
      'Suggerimento: Se sei bloccato, riscrivi l\'ultimo paragrafo.';

  @override
  String get tipDialogue =>
      'Suggerimento: Il dialogo rivela il personaggio più velocemente della descrizione.';

  @override
  String get errorNovelNotFound => 'Romanzo non trovato';

  @override
  String get noSentenceSummary => 'Nessun riassunto frase disponibile.';

  @override
  String get noParagraphSummary => 'Nessun riassunto paragrafo disponibile.';

  @override
  String get noPageSummary => 'Nessun riassunto pagina disponibile.';

  @override
  String get noExpandedSummary => 'Nessun riassunto esteso disponibile.';

  @override
  String get aiSentenceSummaryTooltip => 'Riassunto frase AI';

  @override
  String get aiParagraphSummaryTooltip => 'Riassunto paragrafo AI';

  @override
  String get aiPageSummaryTooltip => 'Riassunto pagina AI';

  @override
  String get keyboardShortcuts => 'Scorciatoie tastiera';

  @override
  String get shortcutSpace => 'Spazio: Riproduci / ferma';

  @override
  String get shortcutArrows => '← / →: Precedente / successivo';

  @override
  String get shortcutRate => 'Ctrl/⌘ + R: Velocità parlata';

  @override
  String get shortcutVoice => 'Ctrl/⌘ + V: Voce';

  @override
  String get shortcutHelp => 'Ctrl/⌘ + /: Mostra scorciatoie';

  @override
  String get shortcutEsc => 'Esc: Chiudi';

  @override
  String get styles => 'Stili';

  @override
  String get noVoicesAvailable => 'Nessuna voce disponibile';

  @override
  String get comingSoon => 'Prossimamente';

  @override
  String get selectNovelFirst => 'Seleziona prima un romanzo';

  @override
  String get adminLogs => 'Log admin';

  @override
  String get viewAndFilterBackendLogs => 'Visualizza e filtra log backend';

  @override
  String adminLogsSavedTo(String path) {
    return 'Log salvati in $path';
  }

  @override
  String get adminLogsCopy => 'Copia';

  @override
  String adminLogsFailedToDownload(String error) {
    return 'Salvataggio fallito: $error';
  }

  @override
  String get adminLogsEntry => 'Voce di log';

  @override
  String get adminLogsCopiedToClipboard => 'Copiato negli appunti';

  @override
  String get adminLogsClose => 'Chiudi';

  @override
  String get styleGlassmorphism => 'Vetromorfismo';

  @override
  String get styleLiquidGlass => 'Vetro liquido';

  @override
  String get styleNeumorphism => 'Neumorfismo';

  @override
  String get styleClaymorphism => 'Claymorfismo';

  @override
  String get styleMinimalism => 'Minimalismo';

  @override
  String get styleBrutalism => 'Brutalismo';

  @override
  String get styleSkeuomorphism => 'Skeuomorfismo';

  @override
  String get styleBentoGrid => 'Griglia Bento';

  @override
  String get styleResponsive => 'Responsivo';

  @override
  String get styleFlatDesign => 'Design piatto';

  @override
  String get scrollToBottom => 'Scorri in basso';

  @override
  String get scrollToTop => 'Scorri in alto';

  @override
  String get numberOfLines => 'Numero di righe';

  @override
  String get lines => 'righe';

  @override
  String get load => 'Carica';

  @override
  String get noLogsAvailable => 'Nessun log disponibile.';

  @override
  String get failedToLoadLogs => 'Caricamento log fallito';

  @override
  String wordCount(int count) {
    return 'Conteggio parole: $count';
  }

  @override
  String characterCount(int count) {
    return 'Conteggio caratteri: $count';
  }

  @override
  String get startWriting => 'Inizia a scrivere...';

  @override
  String failedToLoadChapter(String error) {
    return 'Caricamento capitolo fallito: $error';
  }

  @override
  String get saving => 'Salvataggio…';

  @override
  String get wordCountLabel => 'Conteggio parole';

  @override
  String get characterCountLabel => 'Conteggio caratteri';

  @override
  String get discard => 'Scarta';

  @override
  String get saveShortcut => 'Salva';

  @override
  String get previewShortcut => 'Anteprima';

  @override
  String get boldShortcut => 'Grassetto';

  @override
  String get italicShortcut => 'Corsivo';

  @override
  String get underlineShortcut => 'Sottolineato';

  @override
  String get headingShortcut => 'Intestazione';

  @override
  String get insertLinkShortcut => 'Inserisci link';

  @override
  String get shortcutsHelpShortcut => 'Aiuto scorciatoie';

  @override
  String get closeShortcut => 'Chiudi';

  @override
  String get designSystemStyleGuide => 'Guida design system';

  @override
  String get headlineLarge => 'Intestazione grande';

  @override
  String get headlineMedium => 'Intestazione media';

  @override
  String get titleLarge => 'Titolo grande';

  @override
  String get bodyLarge => 'Corpo grande';

  @override
  String get bodyMedium => 'Corpo medio';

  @override
  String get primaryButton => 'Pulsante primario';

  @override
  String get disabled => 'Disabilitato';

  @override
  String checkboxState(bool value) {
    return 'Stato checkbox: $value';
  }

  @override
  String get option1 => 'Opzione 1';

  @override
  String get option2 => 'Opzione 2';

  @override
  String switchState(bool value) {
    return 'Stato interruttore: $value';
  }

  @override
  String sliderValue(String value) {
    return 'Valore: $value';
  }

  @override
  String get enterTextHere => 'Inserisci testo qui...';

  @override
  String get selectAnOption => 'Seleziona un\'opzione';

  @override
  String get optionA => 'Opzione A';

  @override
  String get optionB => 'Opzione B';

  @override
  String get optionC => 'Opzione C';

  @override
  String get contrastIssuesDetected => 'Problemi di contrasto rilevati';

  @override
  String foundContrastIssues(int count) {
    return 'Trovati $count problema/i di contrasto che potrebbero affettare la leggibilità.';
  }

  @override
  String get allGood => 'Tutto OK!';

  @override
  String get allGoodContrast =>
      'Tutti gli elementi testo soddisfano gli standard di contrasto WCAG 2.1 AA.';

  @override
  String get ignore => 'Ignora';

  @override
  String get applyBestFix => 'Applica miglior fix';

  @override
  String get moreMenuComingSoon => 'Altro menu prossimamente';

  @override
  String get styleGuide => 'Guida stile';

  @override
  String get themeFactoryNotDefined =>
      'Theme factory non ha definito temi, uso tema predefinito.';

  @override
  String progressPercentage(int percent) {
    return '$percent%';
  }

  @override
  String get review => 'Revisiona';

  @override
  String get wordsLabel => 'Parole';

  @override
  String get charsLabel => 'Caratteri';

  @override
  String get readLabel => 'Leggi';

  @override
  String get streakLabel => 'Serie';

  @override
  String get pause => 'Pausa';

  @override
  String get start => 'Avvia';

  @override
  String get editMode => 'Modalità modifica';

  @override
  String get previewMode => 'Modalità anteprima';

  @override
  String get quote => 'Citazione';

  @override
  String get inlineCode => 'Codice inline';

  @override
  String get bulletedList => 'Elenco puntato';

  @override
  String get numberedList => 'Elenco numerato';

  @override
  String get previewTab => 'Anteprima';

  @override
  String get editTab => 'Modifica';

  @override
  String get noExpandedSummaryAvailable =>
      'Nessun riassunto esteso disponibile.';

  @override
  String get analyze => 'Analizza';

  @override
  String youreOffline(String message) {
    return 'Sei offline. $message';
  }

  @override
  String get download => 'Scarica';

  @override
  String get moreActions => 'Più azioni';

  @override
  String get doubleTapToOpen =>
      'Doppio tocco per aprire. Pressione lunga per azioni.';

  @override
  String get more => 'Altro';

  @override
  String get pressD => 'Premi D';

  @override
  String get pressEnter => 'Premi Invio';

  @override
  String get pressDelete => 'Premi Canc';

  @override
  String get exitPreview => 'Esci dall\'anteprima';

  @override
  String get saveLabel => 'Salva';

  @override
  String get exitZenMode => 'Esci modalità Zen';

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String get notSignedInLabel => 'Non accessibile';

  @override
  String get stylePreviewGrid => 'Griglia anteprima stile';

  @override
  String get themeOceanDepths => 'Profondità oceaniche';

  @override
  String get themeSunsetBoulevard => 'Viale al tramonto';

  @override
  String get themeForestCanopy => 'Chioma foresta';

  @override
  String get themeModernMinimalist => 'Minimalista moderno';

  @override
  String get themeGoldenHour => 'Ora d\'oro';

  @override
  String get themeArcticFrost => 'Gelo artico';

  @override
  String get themeDesertRose => 'Rosa del deserto';

  @override
  String get themeTechInnovation => 'Innovazione tech';

  @override
  String get themeBotanicalGarden => 'Giardino botanico';

  @override
  String get themeMidnightGalaxy => 'Galassia di mezzanotte';

  @override
  String get standardLight => 'Chiaro standard';

  @override
  String get warmPaper => 'Carta calda';

  @override
  String get coolGrey => 'Grigio freddo';

  @override
  String get sepiaLabel => 'Seppia';

  @override
  String get standardDark => 'Scuro standard';

  @override
  String get midnight => 'Mezzanotte';

  @override
  String get darkSepia => 'Seppia scuro';

  @override
  String get deepOcean => 'Oceano profondo';

  @override
  String get youreOfflineLabel => 'Sei offline';

  @override
  String get changesWillSync =>
      'Le modifiche verranno sincronizzate quando tornerai online';

  @override
  String changesWillSyncCount(int count) {
    return '$count modifica/e verranno sincronizzate quando tornerai online';
  }

  @override
  String get toggleSidebar => 'Attiva/Disattiva barra laterale';

  @override
  String get quickSearch => 'Ricerca rapida';

  @override
  String get adminLogsMaxSize => 'Max Size';

  @override
  String get adminLogsAllLevels => 'ALL';

  @override
  String adminLogsFileSizeKB(String size) {
    return '$size KB';
  }

  @override
  String adminLogsFileSizeMB(String size) {
    return '$size MB';
  }
}
