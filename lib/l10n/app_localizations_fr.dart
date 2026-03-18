// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get newChapter => 'Nouveau chapitre';

  @override
  String get back => 'Retour';

  @override
  String get helloWorld => 'Bonjour le monde!';

  @override
  String get home => 'Accueil';

  @override
  String get settings => 'Paramètres';

  @override
  String get appTitle => 'Writer';

  @override
  String get about => 'À propos';

  @override
  String get aboutDescription =>
      'Lisez et gérez des romans avec un stockage cloud, un support hors ligne et une lecture audio. Utilisez la Bibliothèque pour parcourir, rechercher et ouvrir des chapitres; connectez-vous pour synchroniser la progression; ajustez les paramètres pour le thème, la typographie et le mouvement.';

  @override
  String get aboutIntro =>
      'AuthorConsole vous aide à planifier, écrire et lire des romans sur plusieurs appareils. Il se concentre sur la simplicité pour les lecteurs et la puissance pour les auteurs, offrant un endroit unifié pour gérer les chapitres, les résumés, les personnages et les scènes.';

  @override
  String get aboutSecurity =>
      'Avec un stockage cloud et des contrôles d\'accès stricts, vos données restent protégées. Les utilisateurs authentifiés peuvent synchroniser la progression, les métadonnées et les modèles tout en préservant la confidentialité.';

  @override
  String get aboutCoach =>
      'Le Coach IA intégré utilise la méthode Snowflake pour améliorer votre résumé d\'histoire. Il pose des questions ciblées, offre des suggestions et, lorsque prêt, fournit un résumé affiné que l\'appli applique à votre document.';

  @override
  String get aboutFeatureCreate =>
      '• Créez un nouveau roman et organisez des chapitres.';

  @override
  String get aboutFeatureTemplates =>
      '• Utilisez des modèles de personnages et de scènes pour démarrer des idées.';

  @override
  String get aboutFeatureTracking =>
      '• Suivez la progression de la lecture et reprenez sur plusieurs appareils.';

  @override
  String get aboutFeatureCoach =>
      '• Affinez votre résumé avec le Coach IA et appliquez des améliorations.';

  @override
  String get aboutFeaturePrompts =>
      '• Gérez les invites et expérimentez avec des flux de travail assistés par IA.';

  @override
  String get aboutUsage => 'Utilisation';

  @override
  String get aboutUsageList =>
      '• Bibliothèque: rechercher et ouvrir des romans\n• Lecteur: naviguer entre les chapitres, activer la lecture audio\n• Modèles: gérer les modèles de personnages et de scènes\n• Paramètres: thème, typographie et préférences\n• Connexion: activer la synchronisation cloud';

  @override
  String get version => 'Version';

  @override
  String get appLanguage => 'Langue de l\'appli';

  @override
  String get english => 'Anglais';

  @override
  String get chinese => 'Chinois';

  @override
  String get supabaseIntegrationInitialized =>
      'Synchronisation cloud initialisée';

  @override
  String get configureEnvironment =>
      'Veuillez configurer vos variables d\'environnement pour activer la synchronisation cloud';

  @override
  String signedInAs(String email) {
    return 'Connecté en tant que $email';
  }

  @override
  String get guest => 'Invité';

  @override
  String get notSignedIn => 'Non connecté';

  @override
  String get signIn => 'Se connecter';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get reload => 'Recharger';

  @override
  String get signInToSync =>
      'Connectez-vous pour synchroniser la progression sur plusieurs appareils.';

  @override
  String get currentProgress => 'Progression actuelle';

  @override
  String get loadingProgress => 'Chargement de la progression...';

  @override
  String get recentlyRead => 'Lu récemment';

  @override
  String get noSupabase =>
      'La synchronisation cloud n\'est pas activée dans cette version.';

  @override
  String get errorLoadingProgress =>
      'Erreur lors du chargement de la progression';

  @override
  String get noProgress => 'Aucune progression trouvée';

  @override
  String get errorLoadingNovels => 'Erreur lors du chargement des romans';

  @override
  String get loadingNovels => 'Chargement des romans…';

  @override
  String get titleLabel => 'Titre';

  @override
  String get authorLabel => 'Auteur';

  @override
  String get noNovelsFound => 'Aucun roman trouvé.';

  @override
  String get myNovels => 'Mes romans';

  @override
  String get createNovel => 'Créer un roman';

  @override
  String get create => 'Créer';

  @override
  String get errorLoadingChapters => 'Erreur lors du chargement des chapitres';

  @override
  String get loadingChapter => 'Chargement du chapitre…';

  @override
  String get notStarted => 'Non démarré';

  @override
  String get unknownNovel => 'Roman inconnu';

  @override
  String get unknownChapter => 'Chapitre inconnu';

  @override
  String get chapter => 'Chapitre';

  @override
  String get novel => 'Roman';

  @override
  String get chapterTitle => 'Titre du chapitre';

  @override
  String get scrollOffset => 'Décalage de défilement';

  @override
  String get ttsIndex => 'Index TTS';

  @override
  String get speechRate => 'Vitesse de parole';

  @override
  String get volume => 'Volume';

  @override
  String get defaultTTSVoice => 'Voix TTS par défaut';

  @override
  String get defaultVoiceUpdated => 'Voix par défaut mise à jour';

  @override
  String get defaultLanguageSet => 'Langue par défaut définie';

  @override
  String get searchByTitle => 'Rechercher par titre…';

  @override
  String get chooseLanguage => 'Choisir la langue';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get signInWithApple => 'Se connecter avec Apple';

  @override
  String get testVoice => 'Tester la voix';

  @override
  String get reloadVoices => 'Recharger les voix';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get signedOut => 'Déconnecté';

  @override
  String get appSettings => 'Paramètres de l\'appli';

  @override
  String get supabaseSettings => 'Paramètres de synchronisation cloud';

  @override
  String get supabaseNotEnabled => 'Synchronisation cloud non activée';

  @override
  String get supabaseNotEnabledDescription =>
      'La synchronisation cloud n\'est pas configurée pour cette version.';

  @override
  String get authDisabledInBuild =>
      'La synchronisation cloud n\'est pas configurée. L\'authentification est désactivée dans cette version.';

  @override
  String get fetchFromSupabase => 'Récupérer depuis le cloud';

  @override
  String get fetchFromSupabaseDescription =>
      'Récupérer les derniers romans et la progression depuis le cloud.';

  @override
  String get confirmFetch => 'Confirmer la récupération';

  @override
  String get confirmFetchDescription =>
      'Cela écrasera vos données locales. Êtes-vous sûr?';

  @override
  String get cancel => 'Annuler';

  @override
  String get fetch => 'Récupérer';

  @override
  String get downloadChapters => 'Télécharger les chapitres';

  @override
  String get modeSupabase => 'Mode: Synchronisation cloud';

  @override
  String get modeMockData => 'Mode: Données factices';

  @override
  String continueAtChapter(String title) {
    return 'Continuer au chapitre • $title';
  }

  @override
  String get error => 'Erreur';

  @override
  String get ttsSettings => 'Paramètres TTS';

  @override
  String get enableTTS => 'Activer TTS';

  @override
  String get sentenceSummary => 'Résumé de phrase';

  @override
  String get paragraphSummary => 'Résumé de paragraphe';

  @override
  String get pageSummary => 'Résumé de page';

  @override
  String get expandedSummary => 'Résumé étendu';

  @override
  String get pitch => 'Ton';

  @override
  String get signInWithBiometrics => 'Se connecter avec la biométrie';

  @override
  String get enableBiometricLogin => 'Activer la connexion biométrique';

  @override
  String get enableBiometricLoginDescription =>
      'Utilisez l\'empreinte digitale ou la reconnaissance faciale pour vous connecter.';

  @override
  String get biometricAuthFailed => 'Authentification biométrique échouée';

  @override
  String get saveCredentialsForBiometric =>
      'Enregistrer les identifiants pour la connexion biométrique';

  @override
  String get saveCredentialsForBiometricDescription =>
      'Stockez vos identifiants en toute sécurité pour une authentification biométrique plus rapide';

  @override
  String get biometricTokensExpired => 'Les jetons biométriques ont expiré';

  @override
  String get biometricNoTokens => 'Aucun jeton biométrique trouvé';

  @override
  String get biometricTokenError => 'Erreur de jeton biométrique';

  @override
  String get biometricTechnicalError => 'Erreur technique biométrique';

  @override
  String get ttsVoice => 'Voix TTS';

  @override
  String get loadingVoices => 'Chargement des voix...';

  @override
  String get selectVoice => 'Sélectionner une voix';

  @override
  String get ttsLanguage => 'Langue TTS';

  @override
  String get loadingLanguages => 'Chargement des langues...';

  @override
  String get selectLanguage => 'Sélectionner une langue';

  @override
  String get ttsSpeechRate => 'Vitesse de parole';

  @override
  String get ttsSpeechVolume => 'Volume de parole';

  @override
  String get ttsSpeechPitch => 'Ton de parole';

  @override
  String get novelsAndProgress => 'Romans et progression';

  @override
  String get novels => 'Romans';

  @override
  String get progress => 'Progression';

  @override
  String novelsAndProgressSummary(int count, String progress) {
    return 'Romans: $count, Progression: $progress';
  }

  @override
  String get chapters => 'Chapitres';

  @override
  String get noChaptersFound => 'Aucun chapitre trouvé.';

  @override
  String indexLabel(int index) {
    return 'Index $index';
  }

  @override
  String get enterFloatIndexHint =>
      'Entrer un index décimal pour repositionner';

  @override
  String indexOutOfRange(int min, int max) {
    return 'L\'index doit être entre $min et $max';
  }

  @override
  String get indexUnchanged => 'Index inchangé';

  @override
  String get roundingBefore => 'Toujours avant';

  @override
  String get roundingAfter => 'Toujours après';

  @override
  String get stopTTS => 'Arrêter TTS';

  @override
  String get speak => 'Parler';

  @override
  String get supabaseProgressNotSaved =>
      'Synchronisation cloud non configurée; progression non sauvegardée';

  @override
  String get progressSaved => 'Progression sauvegardée';

  @override
  String get errorSavingProgress =>
      'Erreur lors de la sauvegarde de la progression';

  @override
  String get autoplayBlocked =>
      'Lecture automatique bloquée. Appuyez sur Continuer pour démarrer.';

  @override
  String get autoplayBlockedInline =>
      'La lecture automatique est bloquée par le navigateur. Appuyez sur Continuer pour commencer la lecture.';

  @override
  String get reachedLastChapter => 'Dernier chapitre atteint';

  @override
  String ttsError(String msg) {
    return 'Erreur TTS: $msg';
  }

  @override
  String get themeMode => 'Mode de thème';

  @override
  String get system => 'Système';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get colorTheme => 'Thème de couleurs';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeSepia => 'Sépia';

  @override
  String get themeHighContrast => 'Contraste';

  @override
  String get themeDefault => 'Par défaut';

  @override
  String get themeEmeraldGreen => 'Émeraude';

  @override
  String get themeSolarizedTan => 'Solarized Tan';

  @override
  String get themeNord => 'Nord';

  @override
  String get themeNordFrost => 'Nord Frost';

  @override
  String get separateDarkPalette => 'Utiliser une palette sombre séparée';

  @override
  String get lightPalette => 'Palette claire';

  @override
  String get darkPalette => 'Palette sombre';

  @override
  String get typographyPreset => 'Préréglage de typographie';

  @override
  String get typographyComfortable => 'Confortable';

  @override
  String get typographyCompact => 'Compact';

  @override
  String get typographySerifLike => 'Style serif';

  @override
  String get fontPack => 'Pack de polices';

  @override
  String get separateTypographyPresets =>
      'Utiliser une typographie séparée pour clair/sombre';

  @override
  String get typographyLight => 'Typographie claire';

  @override
  String get typographyDark => 'Typographie sombre';

  @override
  String get readerBundles => 'Packs de thèmes du lecteur';

  @override
  String get tokenUsage => 'Utilisation des jetons';

  @override
  String removedNovel(String title) {
    return '$title supprimé';
  }

  @override
  String get discover => 'Découvrir';

  @override
  String get profile => 'Profil';

  @override
  String get libraryTitle => 'Bibliothèque';

  @override
  String get undo => 'Annuler';

  @override
  String get allFilter => 'Tous';

  @override
  String get readingFilter => 'En lecture';

  @override
  String get completedFilter => 'Terminé';

  @override
  String get downloadedFilter => 'Téléchargé';

  @override
  String get searchNovels => 'Rechercher des romans...';

  @override
  String get listView => 'Vue liste';

  @override
  String get gridView => 'Vue grille';

  @override
  String get userManagement => 'Gestion des utilisateurs';

  @override
  String get totalThisMonth => 'Total ce mois';

  @override
  String get inputTokens => 'Jetons d\'entrée';

  @override
  String get outputTokens => 'Jetons de sortie';

  @override
  String get requests => 'Requêtes';

  @override
  String get viewHistory => 'Voir l\'historique';

  @override
  String get noUsageThisMonth => 'Aucune utilisation ce mois';

  @override
  String get startUsingAiFeatures =>
      'Commencez à utiliser les fonctionnalités IA pour voir votre consommation de jetons';

  @override
  String get errorLoadingUsage => 'Erreur lors du chargement de l\'utilisation';

  @override
  String get refresh => 'Actualiser';

  @override
  String totalRecords(int count) {
    return 'Total des enregistrements: $count';
  }

  @override
  String get total => 'Total';

  @override
  String get noUsageHistory => 'Aucun historique d\'utilisation';

  @override
  String get bundleNordCalm => 'Nord Calme';

  @override
  String get bundleSolarizedFocus => 'Solarized Focus';

  @override
  String get bundleHighContrastReadability => 'Haute lisibilité du contraste';

  @override
  String get customFontFamily => 'Famille de polices personnalisée';

  @override
  String get commonFonts => 'Polices courantes';

  @override
  String get readerFontSize => 'Taille de police du lecteur';

  @override
  String get textScale => 'Échelle de texte';

  @override
  String get readerBackgroundDepth => 'Profondeur d\'arrière-plan du lecteur';

  @override
  String get depthLow => 'Faible';

  @override
  String get depthMedium => 'Moyen';

  @override
  String get depthHigh => 'Élevé';

  @override
  String get select => 'Sélectionner';

  @override
  String get clear => 'Effacer';

  @override
  String get adminMode => 'Mode administrateur';

  @override
  String get reduceMotion => 'Réduire le mouvement';

  @override
  String get reduceMotionDescription =>
      'Minimiser les animations pour le confort de mouvement';

  @override
  String get gesturesEnabled => 'Activer les gestes tactiles';

  @override
  String get gesturesEnabledDescription =>
      'Activer les gestes de balayage et de tapotement dans le lecteur';

  @override
  String get readerSwipeSensitivity => 'Sensibilité de balayage du lecteur';

  @override
  String get readerSwipeSensitivityDescription =>
      'Ajuster la vitesse minimale de balayage pour la navigation des chapitres';

  @override
  String get remove => 'Supprimer';

  @override
  String get removedFromLibrary => 'Supprimé de la bibliothèque';

  @override
  String get confirmDelete => 'Confirmer la suppression';

  @override
  String confirmDeleteDescription(String title) {
    return 'Cela supprimera \'$title\' de votre bibliothèque cloud. Êtes-vous sûr?';
  }

  @override
  String get delete => 'Supprimer';

  @override
  String get reachedFirstChapter => 'Premier chapitre atteint';

  @override
  String get previousChapter => 'Chapitre précédent';

  @override
  String get nextChapter => 'Chapitre suivant';

  @override
  String get betaEvaluate => 'Bêta';

  @override
  String get betaEvaluating => 'Envoi pour évaluation bêta…';

  @override
  String get betaEvaluationReady => 'Évaluation bêta prête';

  @override
  String get betaEvaluationFailed => 'Évaluation bêta échouée';

  @override
  String get performanceSettings => 'Paramètres de performance';

  @override
  String get prefetchNextChapter => 'Précharger le chapitre suivant';

  @override
  String get prefetchNextChapterDescription =>
      'Précharge le chapitre suivant pour réduire l\'attente.';

  @override
  String get clearOfflineCache => 'Vider le cache hors ligne';

  @override
  String get offlineCacheCleared => 'Cache hors ligne vidé';

  @override
  String get edit => 'Modifier';

  @override
  String get exitEdit => 'Quitter la modification';

  @override
  String get enterEditMode => 'Entrer en mode modification';

  @override
  String get exitEditMode => 'Quitter le mode modification';

  @override
  String get chapterContent => 'Contenu du chapitre';

  @override
  String get save => 'Enregistrer';

  @override
  String get createNextChapter => 'Créer le chapitre suivant';

  @override
  String get enterChapterTitle => 'Entrer le titre du chapitre';

  @override
  String get enterChapterContent => 'Entrer le contenu du chapitre';

  @override
  String get discardChangesTitle => 'Annuler les modifications?';

  @override
  String get discardChangesMessage =>
      'Vous avez des modifications non sauvegardées. Voulez-vous les annuler?';

  @override
  String get keepEditing => 'Continuer la modification';

  @override
  String get discardChanges => 'Annuler les modifications';

  @override
  String get saveAndExit => 'Enregistrer et quitter';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get coverUrlLabel => 'URL de couverture';

  @override
  String get invalidCoverUrl => 'Entrez une URL http(s) valide sans espaces.';

  @override
  String get navigation => 'Navigation';

  @override
  String get chapterIndex => 'Index des chapitres';

  @override
  String get summary => 'Résumé';

  @override
  String get characters => 'Personnages';

  @override
  String get scenes => 'Scènes';

  @override
  String get characterTemplates => 'Modèles de personnages';

  @override
  String get sceneTemplates => 'Modèles de scènes';

  @override
  String get updateNovel => 'Mettre à jour le roman';

  @override
  String get deleteNovel => 'Supprimer le roman';

  @override
  String get deleteNovelConfirmation =>
      'Cela supprimera définitivement le roman. Continuer?';

  @override
  String get format => 'Format';

  @override
  String get aiServiceUrl => 'URL du service IA';

  @override
  String get aiServiceUrlDescription =>
      'URL du service backend pour les fonctionnalités IA';

  @override
  String get aiAssistant => 'Assistant IA';

  @override
  String get aiChatHistory => 'Historique';

  @override
  String get aiChatNewChat => 'Nouvelle discussion';

  @override
  String get aiChatNoHistory => 'Aucun historique';

  @override
  String get aiChatHint => 'Tapez votre message...';

  @override
  String get aiChatEmpty =>
      'Demandez-moi n\'importe quoi sur ce chapitre ou ce roman';

  @override
  String get aiThinking => 'L\'IA réfléchit...';

  @override
  String get aiChatContextLabel => 'Contexte';

  @override
  String aiTokenCount(int count) {
    return '$count jetons';
  }

  @override
  String aiContextLoadError(String error) {
    return 'Erreur lors du chargement du contexte: $error';
  }

  @override
  String aiChatContextTooLongCompressing(int tokens) {
    return 'Le contexte est trop long ($tokens jetons). Compression...';
  }

  @override
  String aiChatContextCompressionFailedNote(String error) {
    return '[Note: La compression du contexte a échoué: $error]';
  }

  @override
  String aiChatError(String error) {
    return 'Erreur: $error';
  }

  @override
  String aiChatDeepAgentError(String error) {
    return 'Erreur Deep Agent: $error';
  }

  @override
  String get aiChatSearchFailed => 'Recherche échouée';

  @override
  String aiChatSearchError(String error) {
    return 'Erreur de recherche: $error';
  }

  @override
  String get aiChatRagSearchResultsTitle => 'Résultats de recherche RAG';

  @override
  String aiChatRagRefinedQuery(String query) {
    return 'Requête raffinée: \"$query\"';
  }

  @override
  String get aiChatRagNoResults => 'Aucun résultat trouvé.';

  @override
  String get aiChatRagUnknownType => 'inconnu';

  @override
  String get aiServiceSignInRequired =>
      'Connexion requise pour utiliser le service IA';

  @override
  String get aiServiceFeatureNotAvailable =>
      'Fonctionnalité non disponible pour votre plan';

  @override
  String aiServiceFailedToConnect(String error) {
    return 'Échec de la connexion au service IA: $error';
  }

  @override
  String get aiServiceNoResponse => 'Aucune réponse du service IA';

  @override
  String get aiDeepAgentDetailsTitle => 'Deep Agent';

  @override
  String aiDeepAgentStop(String reason, Object rounds) {
    return 'Arrêt: $reason (tours: $rounds)';
  }

  @override
  String get aiDeepAgentPlanLabel => 'Plan:';

  @override
  String get aiDeepAgentToolsLabel => 'Outils:';

  @override
  String get deepAgentSettingsTitle => 'Paramètres Deep Agent';

  @override
  String get deepAgentSettingsDescription =>
      'Contrôler si le Chat IA préfère Deep Agent, ainsi que la réflexion et la sortie de débogage.';

  @override
  String get deepAgentPreferTitle => 'Préférer Deep Agent';

  @override
  String get deepAgentPreferSubtitle =>
      'Lorsqu\'activé, le chat normal appelle d\'abord /agents/deep-agent.';

  @override
  String get deepAgentFallbackTitle => 'Replier sur QA si indisponible';

  @override
  String get deepAgentFallbackSubtitle =>
      'Appelle automatiquement /agents/qa quand deep-agent renvoie 404/501.';

  @override
  String get deepAgentReflectionModeTitle => 'Mode de réflexion';

  @override
  String get deepAgentReflectionModeSubtitle =>
      'Contrôle l\'évaluation post-réponse et la réévaluation facultative.';

  @override
  String get deepAgentReflectionModeOff => 'Désactivé';

  @override
  String get deepAgentReflectionModeOnFailure => 'En cas d\'échec';

  @override
  String get deepAgentReflectionModeAlways => 'Toujours';

  @override
  String get deepAgentShowDetailsTitle => 'Afficher les détails d\'exécution';

  @override
  String get deepAgentShowDetailsSubtitle =>
      'Inclure les journaux de plan et d\'appels d\'outils dans la sortie /deep.';

  @override
  String get deepAgentMaxPlanSteps => 'Étapes de plan max';

  @override
  String get deepAgentMaxToolRounds => 'Tours d\'outils max';

  @override
  String get send => 'Envoyer';

  @override
  String get resetToDefault => 'Réinitialiser par défaut';

  @override
  String get invalidUrl => 'Entrez une URL http(s) valide sans espaces.';

  @override
  String get urlTooLong => 'L\'URL doit avoir 2048 caractères ou moins.';

  @override
  String get urlContainsSpaces => 'L\'URL ne peut pas contenir d\'espaces.';

  @override
  String get urlInvalidScheme =>
      'L\'URL doit commencer par http:// ou https://.';

  @override
  String get saved => 'Enregistré';

  @override
  String get required => 'Obligatoire';

  @override
  String get summariesLabel => 'Résumés';

  @override
  String get synopsesLabel => 'Synopses';

  @override
  String get locationLabel => 'Emplacement';

  @override
  String languageLabel(String code) {
    return 'Langue: $code';
  }

  @override
  String get publicLabel => 'Public';

  @override
  String get privateLabel => 'Privé';

  @override
  String chaptersCount(int count) {
    return 'Chapitres: $count';
  }

  @override
  String avgWordsPerChapter(int avg) {
    return 'Moyenne mots/chapitre: $avg';
  }

  @override
  String chapterLabel(int idx) {
    return 'Chapitre $idx';
  }

  @override
  String chapterWithTitle(int idx, String title) {
    return 'Chapitre $idx: $title';
  }

  @override
  String get refreshTooltip => 'Actualiser';

  @override
  String get untitled => 'Sans titre';

  @override
  String get newLabel => 'Nouveau';

  @override
  String get deleteSceneTitle => 'Supprimer la scène';

  @override
  String get deleteCharacterTitle => 'Supprimer le personnage';

  @override
  String get deleteTemplateTitle => 'Supprimer le modèle';

  @override
  String get confirmDeleteGeneric =>
      'Êtes-vous sûr de vouloir supprimer cet élément?';

  @override
  String get novelMetadata => 'Métadonnées du roman';

  @override
  String get contributorEmailLabel => 'E-mail du contributeur';

  @override
  String get contributorEmailHint =>
      'Entrez l\'e-mail utilisateur pour ajouter comme contributeur';

  @override
  String get addContributor => 'Ajouter un contributeur';

  @override
  String get contributorAdded => 'Contributeur ajouté';

  @override
  String get pdf => 'PDF';

  @override
  String get generatingPdf => 'Génération du PDF…';

  @override
  String get pdfFailed => 'Échec de la génération du PDF';

  @override
  String get tableOfContents => 'Table des matières';

  @override
  String byAuthor(String name) {
    return 'par $name';
  }

  @override
  String pageOfTotal(int page, int total) {
    return 'Page $page de $total';
  }

  @override
  String get close => 'Fermer';

  @override
  String get openLink => 'Ouvrir le lien';

  @override
  String get invalidLink => 'Lien invalide';

  @override
  String get unableToOpenLink => 'Impossible d\'ouvrir le lien';

  @override
  String get copy => 'Copier';

  @override
  String get copiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String showingCachedPublicData(String msg) {
    return '$msg — affichage des données publiques/en cache';
  }

  @override
  String get menu => 'Menu';

  @override
  String get metaLabel => 'Méta';

  @override
  String get aiServiceUnavailable => 'Service IA indisponible';

  @override
  String get aiConfigurations => 'Configurations IA';

  @override
  String get modelLabel => 'Modèle';

  @override
  String get temperatureLabel => 'Température';

  @override
  String get saveFailed => 'Échec de la sauvegarde';

  @override
  String get saveMyVersion => 'Enregistrer ma version';

  @override
  String get resetToPublic => 'Réinitialiser à public';

  @override
  String get resetFailed => 'Échec de la réinitialisation';

  @override
  String get prompts => 'Prompts';

  @override
  String get patterns => 'Motifs';

  @override
  String get storyLines => 'Lignes d\'histoire';

  @override
  String get tools => 'Outils';

  @override
  String get preview => 'Aperçu';

  @override
  String get actions => 'Actions';

  @override
  String get searchLabel => 'Rechercher';

  @override
  String get allLabel => 'Tous';

  @override
  String get filterByLocked => 'Filtrer par verrouillé';

  @override
  String get lockedOnly => 'Verrouillés seulement';

  @override
  String get unlockedOnly => 'Déverrouillés seulement';

  @override
  String get promptKey => 'Clé de prompt';

  @override
  String get language => 'Langue';

  @override
  String get filterByKey => 'Filtrer par clé';

  @override
  String get viewPublic => 'Voir public';

  @override
  String get groupNone => 'Aucun';

  @override
  String get groupLanguage => 'Langue';

  @override
  String get groupKey => 'Clé';

  @override
  String get newPrompt => 'Nouveau prompt';

  @override
  String get newPattern => 'Nouveau motif';

  @override
  String get newStoryLine => 'Nouvelle ligne d\'histoire';

  @override
  String get editPrompt => 'Modifier le prompt';

  @override
  String get editPattern => 'Modifier le motif';

  @override
  String get editStoryLine => 'Modifier la ligne d\'histoire';

  @override
  String deletedWithTitle(String title) {
    return 'Supprimé: $title';
  }

  @override
  String deleteFailedWithTitle(String title) {
    return 'Échec de la suppression: $title';
  }

  @override
  String deleteErrorWithMessage(String error) {
    return 'Erreur de suppression: $error';
  }

  @override
  String get makePublic => 'Rendre public';

  @override
  String get noPrompts => 'Aucun prompt trouvé';

  @override
  String get noPatterns => 'Aucun motif';

  @override
  String get noStoryLines => 'Aucune ligne d\'histoire';

  @override
  String conversionFailed(String error) {
    return 'Échec de la conversion: $error';
  }

  @override
  String get failedToAnalyze => 'Échec de l\'analyse';

  @override
  String get aiCoachAnalyzing => 'Le Coach IA analyse...';

  @override
  String get retry => 'Réessayer';

  @override
  String get startAiCoaching => 'Démarrer le coaching IA';

  @override
  String get refinementComplete => 'Raffinement terminé!';

  @override
  String get coachQuestion => 'Question du coach';

  @override
  String get summaryLooksGood =>
      'Excellent travail! Votre résumé semble solide.';

  @override
  String get howToImprove => 'Comment pouvons-nous améliorer cela?';

  @override
  String get suggestionsLabel => 'Suggestions:';

  @override
  String get reviewSuggestionsHint =>
      'Réviser les suggestions ou taper la réponse...';

  @override
  String get aiGenerationComplete => 'Génération IA terminée';

  @override
  String get clickRegenerateForNew =>
      'Cliquez sur Régénérer pour de nouvelles suggestions';

  @override
  String get regenerate => 'Régénérer';

  @override
  String get imSatisfied => 'Je suis satisfait';

  @override
  String get templateLabel => 'Modèle';

  @override
  String get exampleCharacterName => 'ex. Harry Potter';

  @override
  String get aiConvert => 'Conversion IA';

  @override
  String get toggleAiCoach => 'Basculer le Coach IA';

  @override
  String retrieveFailed(String error) {
    return 'Échec de la récupération: $error';
  }

  @override
  String get confirm => 'Confirmer';

  @override
  String get lastRead => 'Lu pour la dernière fois';

  @override
  String get noRecentChapters => 'Aucun chapitre récent';

  @override
  String get failedToLoadConfig => 'Échec du chargement de la configuration';

  @override
  String makePublicPromptConfirm(String promptKey, String language) {
    return 'Rendre public \"$promptKey\" ($language)?';
  }

  @override
  String get content => 'Contenu';

  @override
  String get invalidKey => 'Clé invalide';

  @override
  String get invalidLanguage => 'Langue invalide';

  @override
  String get invalidInput => 'Entrée invalide';

  @override
  String charsCount(int count) {
    return 'Caractères: $count';
  }

  @override
  String deletePromptConfirm(String promptKey, String language) {
    return 'Supprimer le prompt \"$promptKey\" ($language)?';
  }

  @override
  String get profileRetrieved => 'Profil récupéré';

  @override
  String get noProfileFound => 'Aucun profil trouvé';

  @override
  String get templateName => 'Nom du modèle';

  @override
  String get retrieveProfile => 'Récupérer le profil';

  @override
  String get templateRetrieved => 'Modèle récupéré';

  @override
  String get noTemplateFound => 'Aucun modèle trouvé';

  @override
  String get retrieveTemplate => 'Récupérer le modèle';

  @override
  String get previewLabel => 'Aperçu';

  @override
  String get markdownHint => 'Entrer la description en Markdown...';

  @override
  String get templateNameExists => 'Le nom du modèle existe déjà';

  @override
  String get aiServiceUrlHint => 'Entrer l\'URL du service IA (http/https)';

  @override
  String get urlLabel => 'URL';

  @override
  String get systemFont => 'Police système';

  @override
  String get fontInter => 'Inter';

  @override
  String get fontMerriweather => 'Merriweather';

  @override
  String get editPatternTitle => 'Modifier le motif';

  @override
  String get newPatternTitle => 'Nouveau motif';

  @override
  String get editStoryLineTitle => 'Modifier la ligne d\'histoire';

  @override
  String get newStoryLineTitle => 'Nouvelle ligne d\'histoire';

  @override
  String get usageRulesLabel => 'Règles d\'utilisation (JSON)';

  @override
  String get publicPatternLabel => 'Motif public';

  @override
  String get publicStoryLineLabel => 'Ligne d\'histoire publique';

  @override
  String get lockedLabel => 'Verrouillé';

  @override
  String get unlockedLabel => 'Déverrouillé';

  @override
  String get aiButton => 'IA';

  @override
  String get invalidJson => 'JSON invalide';

  @override
  String get deleteFailed => 'Échec de la suppression';

  @override
  String get lockPattern => 'Verrouiller le motif';

  @override
  String get errorUnauthorized => 'Non autorisé';

  @override
  String get errorForbidden => 'Interdit';

  @override
  String get errorSessionExpired => 'Session expirée';

  @override
  String get errorValidation => 'Erreur de validation';

  @override
  String get errorInvalidInput => 'Entrée invalide';

  @override
  String get errorDuplicateTitle => 'Titre en double';

  @override
  String get errorNotFound => 'Non trouvé';

  @override
  String get errorServiceUnavailable => 'Service indisponible';

  @override
  String get errorAiNotConfigured => 'Service IA non configuré';

  @override
  String get errorSupabaseError => 'Erreur de service cloud';

  @override
  String get errorRateLimited => 'Trop de requêtes';

  @override
  String get errorInternal => 'Erreur interne du serveur';

  @override
  String get errorBadGateway => 'Mauvaise passerelle';

  @override
  String get errorGatewayTimeout => 'Délai d\'attente de la passerelle dépassé';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String get invalidResponseFromServer => 'Réponse invalide du serveur';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get signupFailed => 'Échec de l\'inscription';

  @override
  String get accountCreatedCheckEmail =>
      'Compte créé! Veuillez vérifier votre e-mail pour confirmer.';

  @override
  String get backToSignIn => 'Retour à la connexion';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get alreadyHaveAccountSignIn =>
      'Vous avez déjà un compte? Se connecter';

  @override
  String get requestFailed => 'Requête échouée';

  @override
  String get ifAccountExistsResetLinkSent =>
      'Si un compte existe, un lien de réinitialisation a été envoyé à votre e-mail.';

  @override
  String get enterEmailForResetLink =>
      'Entrez votre adresse e-mail pour recevoir un lien de réinitialisation du mot de passe.';

  @override
  String get sendResetLink => 'Envoyer le lien de réinitialisation';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get sessionInvalidLoginAgain =>
      'Session invalide. Veuillez vous reconnecter ou utiliser le lien de réinitialisation à nouveau.';

  @override
  String get updateFailed => 'Échec de la mise à jour';

  @override
  String get passwordUpdatedSuccessfully =>
      'Mot de passe mis à jour avec succès!';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get updatePassword => 'Mettre à jour le mot de passe';

  @override
  String get noActiveSessionFound =>
      'Aucune session active trouvée. Veuillez vous reconnecter.';

  @override
  String get authenticationFailedSignInAgain =>
      'Authentification échouée. Veuillez vous reconnecter.';

  @override
  String get accessDeniedNoAdminPrivileges =>
      'Accès refusé. Vous n\'avez pas de privilèges d\'administrateur.';

  @override
  String failedToLoadUsers(int statusCode, String errorBody) {
    return 'Échec du chargement des utilisateurs: $statusCode - $errorBody';
  }

  @override
  String get smartSearchRequiresSignIn =>
      'Veuillez vous connecter pour utiliser la recherche intelligente';

  @override
  String get smartSearch => 'Recherche intelligente';

  @override
  String get failedToPersistTemplate => 'Échec de la sauvegarde du modèle';

  @override
  String userIdCreated(String id, String createdAt) {
    return 'Utilisateur $id créé à $createdAt';
  }

  @override
  String get tryAdjustingSearchCreateNovel =>
      'Essayez d\'ajuster votre recherche ou créer un nouveau roman';

  @override
  String get sessionExpired => 'Session expirée';

  @override
  String get errorLoadingUsers => 'Erreur lors du chargement des utilisateurs';

  @override
  String get unknownError => 'Erreur inconnue';

  @override
  String get goBack => 'Retour';

  @override
  String get unableToLoadAsset => 'Impossible de charger la ressource';

  @override
  String get youDontHavePermission =>
      'Vous n\'avez pas la permission d\'effectuer cette action.';

  @override
  String get continueReading => 'Continuer la lecture';

  @override
  String get removeFromLibrary => 'Supprimer de la bibliothèque';

  @override
  String get createFirstNovelSubtitle =>
      'Créez votre premier roman pour commencer';

  @override
  String get navigationError => 'Erreur de navigation';

  @override
  String get pdfStepPreparing => 'Préparation des chapitres';

  @override
  String get pdfStepGenerating => 'Génération du PDF';

  @override
  String get pdfStepSharing => 'Partage';

  @override
  String get tipIntention => 'Astuce: Écrivez une intention claire par scène.';

  @override
  String get tipVerbs =>
      'Astuce: Les verbes forts rendent les phrases vivantes.';

  @override
  String get tipStuck => 'Astuce: Si bloqué, réécrivez le dernier paragraphe.';

  @override
  String get tipDialogue =>
      'Astuce: Le dialogue révèle les personnages plus vite que la description.';

  @override
  String get errorNovelNotFound => 'Roman non trouvé';

  @override
  String get noSentenceSummary => 'Aucun résumé de phrase disponible.';

  @override
  String get noParagraphSummary => 'Aucun résumé de paragraphe disponible.';

  @override
  String get noPageSummary => 'Aucun résumé de page disponible.';

  @override
  String get noExpandedSummary => 'Aucun résumé étendu disponible.';

  @override
  String get aiSentenceSummaryTooltip => 'Résumé de phrase IA';

  @override
  String get aiParagraphSummaryTooltip => 'Résumé de paragraphe IA';

  @override
  String get aiPageSummaryTooltip => 'Résumé de page IA';

  @override
  String get keyboardShortcuts => 'Raccourcis clavier';

  @override
  String get shortcutSpace => 'Espace: Lecture / arrêt';

  @override
  String get shortcutArrows => '← / →: Précédent / suivant';

  @override
  String get shortcutRate => 'Ctrl/⌘ + R: Vitesse de parole';

  @override
  String get shortcutVoice => 'Ctrl/⌘ + V: Voix';

  @override
  String get shortcutHelp => 'Ctrl/⌘ + /: Afficher les raccourcis';

  @override
  String get shortcutEsc => 'Échap: Fermer';

  @override
  String get styles => 'Styles';

  @override
  String get noVoicesAvailable => 'Aucune voix disponible';

  @override
  String get comingSoon => 'À venir';

  @override
  String get selectNovelFirst => 'Sélectionnez d\'abord un roman';

  @override
  String get adminLogs => 'Journaux d\'admin';

  @override
  String get viewAndFilterBackendLogs => 'Voir et filtrer les journaux backend';

  @override
  String adminLogsSavedTo(String path) {
    return 'Journaux enregistrés dans $path';
  }

  @override
  String get adminLogsCopy => 'Copier';

  @override
  String adminLogsFailedToDownload(String error) {
    return 'Échec de l\'enregistrement: $error';
  }

  @override
  String get adminLogsEntry => 'Entrée de journal';

  @override
  String get adminLogsCopiedToClipboard => 'Copié dans le presse-papiers';

  @override
  String get adminLogsClose => 'Fermer';

  @override
  String get styleGlassmorphism => 'Glassmorphisme';

  @override
  String get styleLiquidGlass => 'Liquid Glass';

  @override
  String get styleNeumorphism => 'Neumorphisme';

  @override
  String get styleClaymorphism => 'Claymorphisme';

  @override
  String get styleMinimalism => 'Minimalisme';

  @override
  String get styleBrutalism => 'Brutalisme';

  @override
  String get styleSkeuomorphism => 'Skeuomorphisme';

  @override
  String get styleBentoGrid => 'Grille Bento';

  @override
  String get styleResponsive => 'Responsive';

  @override
  String get styleFlatDesign => 'Design plat';

  @override
  String get scrollToBottom => 'Faire défiler vers le bas';

  @override
  String get scrollToTop => 'Faire défiler vers le haut';

  @override
  String get numberOfLines => 'Nombre de lignes';

  @override
  String get lines => 'lignes';

  @override
  String get load => 'Charger';

  @override
  String get noLogsAvailable => 'Aucun journal disponible.';

  @override
  String get failedToLoadLogs => 'Échec du chargement des journaux';

  @override
  String wordCount(int count) {
    return 'Nombre de mots: $count';
  }

  @override
  String characterCount(int count) {
    return 'Nombre de caractères: $count';
  }

  @override
  String get startWriting => 'Commencer à écrire...';

  @override
  String failedToLoadChapter(String error) {
    return 'Échec du chargement du chapitre: $error';
  }

  @override
  String get saving => 'Enregistrement…';

  @override
  String get wordCountLabel => 'Nombre de mots';

  @override
  String get characterCountLabel => 'Nombre de caractères';

  @override
  String get discard => 'Annuler';

  @override
  String get saveShortcut => 'Enregistrer';

  @override
  String get previewShortcut => 'Aperçu';

  @override
  String get boldShortcut => 'Gras';

  @override
  String get italicShortcut => 'Italique';

  @override
  String get underlineShortcut => 'Souligné';

  @override
  String get headingShortcut => 'Titre';

  @override
  String get insertLinkShortcut => 'Insérer un lien';

  @override
  String get shortcutsHelpShortcut => 'Aide des raccourcis';

  @override
  String get closeShortcut => 'Fermer';

  @override
  String get designSystemStyleGuide => 'Guide de style du système de design';

  @override
  String get headlineLarge => 'Grand titre';

  @override
  String get headlineMedium => 'Titre moyen';

  @override
  String get titleLarge => 'Grand titre';

  @override
  String get bodyLarge => 'Grand corps';

  @override
  String get bodyMedium => 'Corps moyen';

  @override
  String get primaryButton => 'Bouton primaire';

  @override
  String get disabled => 'Désactivé';

  @override
  String checkboxState(bool value) {
    return 'État de la case à cocher: $value';
  }

  @override
  String get option1 => 'Option 1';

  @override
  String get option2 => 'Option 2';

  @override
  String switchState(bool value) {
    return 'État de l\'interrupteur: $value';
  }

  @override
  String sliderValue(String value) {
    return 'Valeur: $value';
  }

  @override
  String get enterTextHere => 'Entrez du texte ici...';

  @override
  String get selectAnOption => 'Sélectionnez une option';

  @override
  String get optionA => 'Option A';

  @override
  String get optionB => 'Option B';

  @override
  String get optionC => 'Option C';

  @override
  String get contrastIssuesDetected => 'Problèmes de contraste détectés';

  @override
  String foundContrastIssues(int count) {
    return '$count problème(s) de contraste trouvé(s) qui peuvent affecter la lisibilité.';
  }

  @override
  String get allGood => 'Tout est bon!';

  @override
  String get allGoodContrast =>
      'Tous les éléments textuels répondent aux normes de contraste WCAG 2.1 AA.';

  @override
  String get ignore => 'Ignorer';

  @override
  String get applyBestFix => 'Appliquer la meilleure correction';

  @override
  String get moreMenuComingSoon => 'Plus de menu à venir';

  @override
  String get styleGuide => 'Guide de style';

  @override
  String get themeFactoryNotDefined =>
      'Theme Factory n\'a défini aucun thème, utilisation du thème par défaut.';

  @override
  String progressPercentage(int percent) {
    return '$percent%';
  }

  @override
  String get review => 'Réviser';

  @override
  String get wordsLabel => 'Mots';

  @override
  String get charsLabel => 'Caractères';

  @override
  String get readLabel => 'Lire';

  @override
  String get streakLabel => 'Série';

  @override
  String get pause => 'Pause';

  @override
  String get start => 'Démarrer';

  @override
  String get editMode => 'Mode modification';

  @override
  String get previewMode => 'Mode aperçu';

  @override
  String get quote => 'Citation';

  @override
  String get inlineCode => 'Code en ligne';

  @override
  String get bulletedList => 'Liste à puces';

  @override
  String get numberedList => 'Liste numérotée';

  @override
  String get previewTab => 'Aperçu';

  @override
  String get editTab => 'Modifier';

  @override
  String get noExpandedSummaryAvailable => 'Aucun résumé étendu disponible.';

  @override
  String get analyze => 'Analyser';

  @override
  String youreOffline(String message) {
    return 'Vous êtes hors ligne. $message';
  }

  @override
  String get download => 'Télécharger';

  @override
  String get moreActions => 'Plus d\'actions';

  @override
  String get doubleTapToOpen =>
      'Double-tapez pour ouvrir. Appui long pour les actions.';

  @override
  String get more => 'Plus';

  @override
  String get pressD => 'Appuyez sur D';

  @override
  String get pressEnter => 'Appuyez sur Entrée';

  @override
  String get pressDelete => 'Appuyez sur Suppr';

  @override
  String get exitPreview => 'Quitter l\'aperçu';

  @override
  String get saveLabel => 'Enregistrer';

  @override
  String get exitZenMode => 'Quitter le mode Zen';

  @override
  String get clearSearch => 'Effacer la recherche';

  @override
  String get notSignedInLabel => 'Non connecté';

  @override
  String get stylePreviewGrid => 'Grille d\'aperçu de style';

  @override
  String get themeOceanDepths => 'Profondeurs océaniques';

  @override
  String get themeSunsetBoulevard => 'Boulevard du coucher de soleil';

  @override
  String get themeForestCanopy => 'Canopée forestière';

  @override
  String get themeModernMinimalist => 'Minimaliste moderne';

  @override
  String get themeGoldenHour => 'Heure dorée';

  @override
  String get themeArcticFrost => 'Givre arctique';

  @override
  String get themeDesertRose => 'Rose du désert';

  @override
  String get themeTechInnovation => 'Innovation technologique';

  @override
  String get themeBotanicalGarden => 'Jardin botanique';

  @override
  String get themeMidnightGalaxy => 'Galaxie de minuit';

  @override
  String get standardLight => 'Lumière standard';

  @override
  String get warmPaper => 'Papier chaud';

  @override
  String get coolGrey => 'Gris froid';

  @override
  String get sepiaLabel => 'Sépia';

  @override
  String get standardDark => 'Sombre standard';

  @override
  String get midnight => 'Minuit';

  @override
  String get darkSepia => 'Sépia sombre';

  @override
  String get deepOcean => 'Océan profond';

  @override
  String get youreOfflineLabel => 'Vous êtes hors ligne';

  @override
  String get changesWillSync =>
      'Les modifications seront synchronisées lorsque vous serez de nouveau en ligne';

  @override
  String changesWillSyncCount(int count) {
    return '$count modification(s) sera/seront synchronisée(s) lorsque vous serez de nouveau en ligne';
  }

  @override
  String get toggleSidebar => 'Basculer la barre latérale';

  @override
  String get quickSearch => 'Recherche rapide';

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

  @override
  String get size10KB => '10 KB';

  @override
  String get size50KB => '50 KB';

  @override
  String get size100KB => '100 KB';

  @override
  String get size500KB => '500 KB';

  @override
  String get size1MB => '1 MB';

  @override
  String get charCount => 'Character count';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get languageChineseTraditional => '繁體';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageJapanese => '日本語';
}
