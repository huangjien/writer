// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get newChapter => 'Capítulo nuevo';

  @override
  String get back => 'Atrás';

  @override
  String get helloWorld => '¡Hola mundo!';

  @override
  String get home => 'Inicio';

  @override
  String get settings => 'Configuración';

  @override
  String get appTitle => 'Escritor';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutDescription =>
      'Lea y administe novelas con almacenamiento en la nube, soporte sin conexión y reproducción de texto a voz. Use la Biblioteca para navegar, buscar y abrir capítulos; inicie sesión para sincronizar el progreso; ajuste la configuración de tema, tipografía y movimiento.';

  @override
  String get aboutIntro =>
      'AuthorConsole le ayuda a planificar, escribir y leer novelas en varios dispositivos. Se centra en la simplicidad para los lectores y el poder para los autores, ofreciendo un lugar unificado para administrar capítulos, resúmenes, personajes y escenas.';

  @override
  String get aboutSecurity =>
      'Con almacenamiento en la nube y controles de acceso estrictos, sus datos permanecen protegidos. Los usuarios autenticados pueden sincronizar el progreso, metadatos y plantillas manteniendo la privacidad.';

  @override
  String get aboutCoach =>
      'El entrenador de IA integrado utiliza el método Snowflake para mejorar su resumen de historia. Hace preguntas enfocadas, ofrece sugerencias y, cuando está listo, proporciona un resumen refinado que la aplicación aplica a su documento.';

  @override
  String get aboutFeatureCreate =>
      '• Cree una novela nueva y organice capítulos.';

  @override
  String get aboutFeatureTemplates =>
      '• Use plantillas de personajes y escenas para comenzar ideas.';

  @override
  String get aboutFeatureTracking =>
      '• Rastree el progreso de lectura y continúe en varios dispositivos.';

  @override
  String get aboutFeatureCoach =>
      '• Refine su resumen con el entrenador de IA y aplique mejoras.';

  @override
  String get aboutFeaturePrompts =>
      '• Administre instrucciones y experimente con flujos de trabajo asistidos por IA.';

  @override
  String get aboutUsage => 'Uso';

  @override
  String get aboutUsageList =>
      '• Biblioteca: buscar y abrir novelas\n• Lector: navegar capítulos, alternar TTS\n• Plantillas: administrar plantillas de personajes y escenas\n• Configuración: tema, tipografía y preferencias\n• Iniciar sesión: activar sincronización en la nube';

  @override
  String get version => 'Versión';

  @override
  String get appLanguage => 'Idioma de la aplicación';

  @override
  String get english => 'Inglés';

  @override
  String get chinese => 'Chino';

  @override
  String get supabaseIntegrationInitialized =>
      'Sincronización en la nube inicializada';

  @override
  String get configureEnvironment =>
      'Configure sus variables de entorno para habilitar la sincronización en la nube';

  @override
  String signedInAs(String email) {
    return 'Sesión iniciada como $email';
  }

  @override
  String get guest => 'Invitado';

  @override
  String get notSignedIn => 'No iniciado sesión';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get reload => 'Recargar';

  @override
  String get signInToSync =>
      'Inicie sesión para sincronizar el progreso en varios dispositivos.';

  @override
  String get currentProgress => 'Progreso actual';

  @override
  String get loadingProgress => 'Cargando progreso...';

  @override
  String get recentlyRead => 'Leído recientemente';

  @override
  String get noSupabase =>
      'La sincronización en la nube no está habilitada en esta compilación.';

  @override
  String get errorLoadingProgress => 'Error al cargar el progreso';

  @override
  String get noProgress => 'No se encontró progreso';

  @override
  String get errorLoadingNovels => 'Error al cargar novelas';

  @override
  String get loadingNovels => 'Cargando novelas…';

  @override
  String get titleLabel => 'Título';

  @override
  String get authorLabel => 'Autor';

  @override
  String get noNovelsFound => 'No se encontraron novelas.';

  @override
  String get myNovels => 'Mis novelas';

  @override
  String get createNovel => 'Crear novela';

  @override
  String get create => 'Crear';

  @override
  String get errorLoadingChapters => 'Error al cargar capítulos';

  @override
  String get loadingChapter => 'Cargando capítulo…';

  @override
  String get notStarted => 'No iniciado';

  @override
  String get unknownNovel => 'Novela desconocida';

  @override
  String get unknownChapter => 'Capítulo desconocido';

  @override
  String get chapter => 'Capítulo';

  @override
  String get novel => 'Novela';

  @override
  String get chapterTitle => 'Título del capítulo';

  @override
  String get scrollOffset => 'Desplazamiento de desplazamiento';

  @override
  String get ttsIndex => 'Índice TTS';

  @override
  String get speechRate => 'Velocidad de habla';

  @override
  String get volume => 'Volumen';

  @override
  String get defaultTTSVoice => 'Voz TTS predeterminada';

  @override
  String get defaultVoiceUpdated => 'Voz predeterminada actualizada';

  @override
  String get defaultLanguageSet => 'Idioma predeterminado establecido';

  @override
  String get searchByTitle => 'Buscar por título…';

  @override
  String get chooseLanguage => 'Elegir idioma';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get signInWithApple => 'Iniciar sesión con Apple';

  @override
  String get testVoice => 'Probar voz';

  @override
  String get reloadVoices => 'Recargar voces';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get signedOut => 'Sesión cerrada';

  @override
  String get appSettings => 'Configuración de la aplicación';

  @override
  String get supabaseSettings => 'Configuración de sincronización en la nube';

  @override
  String get supabaseNotEnabled => 'Sincronización en la nube no habilitada';

  @override
  String get supabaseNotEnabledDescription =>
      'La sincronización en la nube no está configurada para esta compilación.';

  @override
  String get authDisabledInBuild =>
      'La sincronización en la nube no está configurada. La autenticación está deshabilitada en esta compilación.';

  @override
  String get fetchFromSupabase => 'Obtener de la nube';

  @override
  String get fetchFromSupabaseDescription =>
      'Obtener las novelas y el progreso más recientes de la nube.';

  @override
  String get confirmFetch => 'Confirmar obtención';

  @override
  String get confirmFetchDescription =>
      'Esto sobrescribirá sus datos locales. ¿Está seguro?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get fetch => 'Obtener';

  @override
  String get downloadChapters => 'Descargar capítulos';

  @override
  String get modeSupabase => 'Modo: Sincronización en la nube';

  @override
  String get modeMockData => 'Modo: Datos simulados';

  @override
  String continueAtChapter(String title) {
    return 'Continuar en el capítulo • $title';
  }

  @override
  String get error => 'Error';

  @override
  String get ttsSettings => 'Configuración TTS';

  @override
  String get enableTTS => 'Habilitar TTS';

  @override
  String get sentenceSummary => 'Resumen de oración';

  @override
  String get paragraphSummary => 'Resumen de párrafo';

  @override
  String get pageSummary => 'Resumen de página';

  @override
  String get expandedSummary => 'Resumen ampliado';

  @override
  String get pitch => 'Tono';

  @override
  String get signInWithBiometrics => 'Iniciar sesión con biométricos';

  @override
  String get enableBiometricLogin => 'Habilitar inicio de sesión biométrico';

  @override
  String get enableBiometricLoginDescription =>
      'Use la huella digital o el reconocimiento facial para iniciar sesión.';

  @override
  String get biometricAuthFailed => 'Autenticación biométrica fallida';

  @override
  String get saveCredentialsForBiometric =>
      'Guardar credenciales para inicio de sesión biométrico';

  @override
  String get saveCredentialsForBiometricDescription =>
      'Almacene de forma segura sus credenciales para una autenticación biométrica más rápida';

  @override
  String get biometricTokensExpired => 'Tokens biométricos caducados';

  @override
  String get biometricNoTokens => 'No se encontraron tokens biométricos';

  @override
  String get biometricTokenError => 'Error de token biométrico';

  @override
  String get biometricTechnicalError => 'Error técnico biométrico';

  @override
  String get ttsVoice => 'Voz TTS';

  @override
  String get loadingVoices => 'Cargando voces...';

  @override
  String get selectVoice => 'Seleccionar una voz';

  @override
  String get ttsLanguage => 'Idioma TTS';

  @override
  String get loadingLanguages => 'Cargando idiomas...';

  @override
  String get selectLanguage => 'Seleccionar un idioma';

  @override
  String get ttsSpeechRate => 'Velocidad de habla';

  @override
  String get ttsSpeechVolume => 'Volumen de habla';

  @override
  String get ttsSpeechPitch => 'Tono de habla';

  @override
  String get novelsAndProgress => 'Novelas y progreso';

  @override
  String get novels => 'Novelas';

  @override
  String get progress => 'Progreso';

  @override
  String novelsAndProgressSummary(int count, String progress) {
    return 'Novelas: $count, Progreso: $progress';
  }

  @override
  String get chapters => 'Capítulos';

  @override
  String get noChaptersFound => 'No se encontraron capítulos.';

  @override
  String indexLabel(int index) {
    return 'Índice $index';
  }

  @override
  String get enterFloatIndexHint => 'Ingrese índice decimal para reposicionar';

  @override
  String indexOutOfRange(int min, int max) {
    return 'El índice debe estar entre $min y $max';
  }

  @override
  String get indexUnchanged => 'Índice sin cambios';

  @override
  String get roundingBefore => 'Siempre antes';

  @override
  String get roundingAfter => 'Siempre después';

  @override
  String get stopTTS => 'Detener TTS';

  @override
  String get speak => 'Hablar';

  @override
  String get supabaseProgressNotSaved =>
      'Sincronización en la nube no configurada; progreso no guardado';

  @override
  String get progressSaved => 'Progreso guardado';

  @override
  String get errorSavingProgress => 'Error al guardar el progreso';

  @override
  String get autoplayBlocked =>
      'Reproducción automática bloqueada. Toque Continuar para comenzar.';

  @override
  String get autoplayBlockedInline =>
      'La reproducción automática está bloqueada por el navegador. Toque Continuar para comenzar a leer.';

  @override
  String get reachedLastChapter => 'Último capítulo alcanzado';

  @override
  String ttsError(String msg) {
    return 'Error TTS: $msg';
  }

  @override
  String get themeMode => 'Modo de tema';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get colorTheme => 'Esquema de color';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSepia => 'Sepia';

  @override
  String get themeHighContrast => 'Contraste';

  @override
  String get themeDefault => 'Predeterminado';

  @override
  String get themeEmeraldGreen => 'Verde esmeralda';

  @override
  String get themeSolarizedTan => 'Solarized Tan';

  @override
  String get themeNord => 'Nord';

  @override
  String get themeNordFrost => 'Nord Frost';

  @override
  String get separateDarkPalette => 'Usar paleta oscura separada';

  @override
  String get lightPalette => 'Paleta clara';

  @override
  String get darkPalette => 'Paleta oscura';

  @override
  String get typographyPreset => 'Preestablecido de tipografía';

  @override
  String get typographyComfortable => 'Cómodo';

  @override
  String get typographyCompact => 'Compacto';

  @override
  String get typographySerifLike => 'Tipo serif';

  @override
  String get fontPack => 'Paquete de fuentes';

  @override
  String get separateTypographyPresets =>
      'Usar tipografía separada para claro/oscuro';

  @override
  String get typographyLight => 'Tipografía clara';

  @override
  String get typographyDark => 'Tipografía oscura';

  @override
  String get readerBundles => 'Paquetes de tema del lector';

  @override
  String get tokenUsage => 'Uso de tokens';

  @override
  String removedNovel(String title) {
    return '$title eliminada';
  }

  @override
  String get discover => 'Descubrir';

  @override
  String get profile => 'Perfil';

  @override
  String get libraryTitle => 'Biblioteca';

  @override
  String get undo => 'Deshacer';

  @override
  String get allFilter => 'Todos';

  @override
  String get readingFilter => 'Leyendo';

  @override
  String get completedFilter => 'Completado';

  @override
  String get downloadedFilter => 'Descargado';

  @override
  String get searchNovels => 'Buscar novelas...';

  @override
  String get listView => 'Vista de lista';

  @override
  String get gridView => 'Vista de cuadrícula';

  @override
  String get userManagement => 'Gestión de usuarios';

  @override
  String get totalThisMonth => 'Total este mes';

  @override
  String get inputTokens => 'Tokens de entrada';

  @override
  String get outputTokens => 'Tokens de salida';

  @override
  String get requests => 'Solicitudes';

  @override
  String get viewHistory => 'Ver historial';

  @override
  String get noUsageThisMonth => 'Sin uso este mes';

  @override
  String get startUsingAiFeatures =>
      'Comience a usar funciones de IA para ver su consumo de tokens';

  @override
  String get errorLoadingUsage => 'Error al cargar el uso';

  @override
  String get refresh => 'Actualizar';

  @override
  String totalRecords(int count) {
    return 'Registros totales: $count';
  }

  @override
  String get total => 'Total';

  @override
  String get noUsageHistory => 'Sin historial de uso';

  @override
  String get bundleNordCalm => 'Nord Calma';

  @override
  String get bundleSolarizedFocus => 'Solarized Enfoque';

  @override
  String get bundleHighContrastReadability => 'Alto contraste legibilidad';

  @override
  String get customFontFamily => 'Familia de fuentes personalizada';

  @override
  String get commonFonts => 'Fuentes comunes';

  @override
  String get readerFontSize => 'Tamaño de fuente del lector';

  @override
  String get textScale => 'Escala de texto';

  @override
  String get readerBackgroundDepth => 'Profundidad de fondo del lector';

  @override
  String get depthLow => 'Bajo';

  @override
  String get depthMedium => 'Medio';

  @override
  String get depthHigh => 'Alto';

  @override
  String get select => 'Seleccionar';

  @override
  String get clear => 'Limpiar';

  @override
  String get adminMode => 'Modo administrador';

  @override
  String get reduceMotion => 'Reducir movimiento';

  @override
  String get reduceMotionDescription =>
      'Minimizar animaciones para comodidad de movimiento';

  @override
  String get gesturesEnabled => 'Habilitar gestos táctiles';

  @override
  String get gesturesEnabledDescription =>
      'Habilitar gestos de deslizamiento y toque en el lector';

  @override
  String get readerSwipeSensitivity =>
      'Sensibilidad de deslizamiento del lector';

  @override
  String get readerSwipeSensitivityDescription =>
      'Ajustar la velocidad mínima de deslizamiento para la navegación de capítulos';

  @override
  String get remove => 'Eliminar';

  @override
  String get removedFromLibrary => 'Eliminado de la biblioteca';

  @override
  String get confirmDelete => 'Confirmar eliminación';

  @override
  String confirmDeleteDescription(String title) {
    return 'Esto eliminará \'$title\' de su biblioteca en la nube. ¿Está seguro?';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get reachedFirstChapter => 'Primer capítulo alcanzado';

  @override
  String get previousChapter => 'Capítulo anterior';

  @override
  String get nextChapter => 'Siguiente capítulo';

  @override
  String get betaEvaluate => 'Beta';

  @override
  String get betaEvaluating => 'Enviando para evaluación beta…';

  @override
  String get betaEvaluationReady => 'Evaluación beta lista';

  @override
  String get betaEvaluationFailed => 'Evaluación beta fallida';

  @override
  String get performanceSettings => 'Configuración de rendimiento';

  @override
  String get prefetchNextChapter => 'Precargar siguiente capítulo';

  @override
  String get prefetchNextChapterDescription =>
      'Carga previa el siguiente capítulo para reducir el tiempo de espera.';

  @override
  String get clearOfflineCache => 'Limpiar caché sin conexión';

  @override
  String get offlineCacheCleared => 'Caché sin conexión limpiada';

  @override
  String get edit => 'Editar';

  @override
  String get exitEdit => 'Salir de editar';

  @override
  String get enterEditMode => 'Entrar en modo de edición';

  @override
  String get exitEditMode => 'Salir del modo de edición';

  @override
  String get chapterContent => 'Contenido del capítulo';

  @override
  String get save => 'Guardar';

  @override
  String get createNextChapter => 'Crear siguiente capítulo';

  @override
  String get enterChapterTitle => 'Ingresar título del capítulo';

  @override
  String get enterChapterContent => 'Ingresar contenido del capítulo';

  @override
  String get discardChangesTitle => '¿Descartar cambios?';

  @override
  String get discardChangesMessage =>
      'Tiene cambios sin guardar. ¿Desea descartarlos?';

  @override
  String get keepEditing => 'Seguir editando';

  @override
  String get discardChanges => 'Descartar cambios';

  @override
  String get saveAndExit => 'Guardar y salir';

  @override
  String get descriptionLabel => 'Descripción';

  @override
  String get coverUrlLabel => 'URL de portada';

  @override
  String get invalidCoverUrl => 'Ingrese una URL http(s) válida sin espacios.';

  @override
  String get navigation => 'Navegación';

  @override
  String get chapterIndex => 'Índice de capítulos';

  @override
  String get summary => 'Resumen';

  @override
  String get characters => 'Personajes';

  @override
  String get scenes => 'Escenas';

  @override
  String get characterTemplates => 'Plantillas de personajes';

  @override
  String get sceneTemplates => 'Plantillas de escenas';

  @override
  String get updateNovel => 'Actualizar novela';

  @override
  String get deleteNovel => 'Eliminar novela';

  @override
  String get deleteNovelConfirmation =>
      'Esto eliminará permanentemente la novela. ¿Continuar?';

  @override
  String get format => 'Formato';

  @override
  String get aiServiceUrl => 'URL del servicio IA';

  @override
  String get aiServiceUrlDescription =>
      'URL del servicio backend para funciones de IA';

  @override
  String get aiAssistant => 'Asistente IA';

  @override
  String get aiChatHistory => 'Historial';

  @override
  String get aiChatNewChat => 'Nuevo chat';

  @override
  String get aiChatNoHistory => 'Sin historial';

  @override
  String get aiChatHint => 'Escriba su mensaje...';

  @override
  String get aiChatEmpty =>
      'Pregúnteme cualquier cosa sobre este capítulo o novela';

  @override
  String get aiThinking => 'IA está pensando...';

  @override
  String get aiChatContextLabel => 'Contexto';

  @override
  String aiTokenCount(int count) {
    return '$count tokens';
  }

  @override
  String aiContextLoadError(String error) {
    return 'Error al cargar el contexto: $error';
  }

  @override
  String aiChatContextTooLongCompressing(int tokens) {
    return 'El contexto es demasiado largo ($tokens tokens). Comprimiendo...';
  }

  @override
  String aiChatContextCompressionFailedNote(String error) {
    return '[Nota: La compresión de contexto falló: $error]';
  }

  @override
  String aiChatError(String error) {
    return 'Error: $error';
  }

  @override
  String aiChatDeepAgentError(String error) {
    return 'Error de Deep Agent: $error';
  }

  @override
  String get aiChatSearchFailed => 'Búsqueda fallida';

  @override
  String aiChatSearchError(String error) {
    return 'Error de búsqueda: $error';
  }

  @override
  String get aiChatRagSearchResultsTitle => 'Resultados de búsqueda RAG';

  @override
  String aiChatRagRefinedQuery(String query) {
    return 'Consulta refinada: \"$query\"';
  }

  @override
  String get aiChatRagNoResults => 'No se encontraron resultados.';

  @override
  String get aiChatRagUnknownType => 'desconocido';

  @override
  String get aiServiceSignInRequired =>
      'Se requiere iniciar sesión para usar el servicio IA';

  @override
  String get aiServiceFeatureNotAvailable =>
      'Función no disponible para su plan';

  @override
  String aiServiceFailedToConnect(String error) {
    return 'Error al conectar con el servicio IA: $error';
  }

  @override
  String get aiServiceNoResponse => 'Sin respuesta del servicio IA';

  @override
  String get aiDeepAgentDetailsTitle => 'Deep Agent';

  @override
  String aiDeepAgentStop(String reason, Object rounds) {
    return 'Parar: $reason (rondas: $rounds)';
  }

  @override
  String get aiDeepAgentPlanLabel => 'Plan:';

  @override
  String get aiDeepAgentToolsLabel => 'Herramientas:';

  @override
  String get deepAgentSettingsTitle => 'Configuración de Deep Agent';

  @override
  String get deepAgentSettingsDescription =>
      'Controle si el chat IA prefiere Deep Agent, además de reflexión y salida de depuración.';

  @override
  String get deepAgentPreferTitle => 'Preferir Deep Agent';

  @override
  String get deepAgentPreferSubtitle =>
      'Cuando está habilitado, el chat normal llama a /agents/deep-agent primero.';

  @override
  String get deepAgentFallbackTitle => 'Alternar a QA si no está disponible';

  @override
  String get deepAgentFallbackSubtitle =>
      'Llama automáticamente a /agents/qa cuando deep-agent devuelve 404/501.';

  @override
  String get deepAgentReflectionModeTitle => 'Modo de reflexión';

  @override
  String get deepAgentReflectionModeSubtitle =>
      'Controla la evaluación posterior a la respuesta y reintento opcional.';

  @override
  String get deepAgentReflectionModeOff => 'Desactivado';

  @override
  String get deepAgentReflectionModeOnFailure => 'En caso de error';

  @override
  String get deepAgentReflectionModeAlways => 'Siempre';

  @override
  String get deepAgentShowDetailsTitle => 'Mostrar detalles de ejecución';

  @override
  String get deepAgentShowDetailsSubtitle =>
      'Incluir registros de plan y llamadas a herramientas en la salida /deep.';

  @override
  String get deepAgentMaxPlanSteps => 'Pasos de plan máximos';

  @override
  String get deepAgentMaxToolRounds => 'Rondas de herramienta máximas';

  @override
  String get send => 'Enviar';

  @override
  String get resetToDefault => 'Restablecer a predeterminado';

  @override
  String get invalidUrl => 'Ingrese una URL http(s) válida sin espacios.';

  @override
  String get urlTooLong => 'La URL debe tener 2048 caracteres o menos.';

  @override
  String get urlContainsSpaces => 'La URL no puede contener espacios.';

  @override
  String get urlInvalidScheme => 'La URL debe comenzar con http:// o https://.';

  @override
  String get saved => 'Guardado';

  @override
  String get required => 'Obligatorio';

  @override
  String get summariesLabel => 'Resúmenes';

  @override
  String get synopsesLabel => 'Sinopsis';

  @override
  String get locationLabel => 'Ubicación';

  @override
  String languageLabel(String code) {
    return 'Idioma: $code';
  }

  @override
  String get publicLabel => 'Público';

  @override
  String get privateLabel => 'Privado';

  @override
  String chaptersCount(int count) {
    return 'Capítulos: $count';
  }

  @override
  String avgWordsPerChapter(int avg) {
    return 'Promedio palabras/capítulo: $avg';
  }

  @override
  String chapterLabel(int idx) {
    return 'Capítulo $idx';
  }

  @override
  String chapterWithTitle(int idx, String title) {
    return 'Capítulo $idx: $title';
  }

  @override
  String get refreshTooltip => 'Actualizar';

  @override
  String get untitled => 'Sin título';

  @override
  String get newLabel => 'Nuevo';

  @override
  String get deleteSceneTitle => 'Eliminar escena';

  @override
  String get deleteCharacterTitle => 'Eliminar personaje';

  @override
  String get deleteTemplateTitle => 'Eliminar plantilla';

  @override
  String get confirmDeleteGeneric =>
      '¿Está seguro de que desea eliminar este elemento?';

  @override
  String get novelMetadata => 'Metadatos de novela';

  @override
  String get contributorEmailLabel => 'Correo electrónico de colaborador';

  @override
  String get contributorEmailHint =>
      'Ingrese correo electrónico de usuario para agregar como colaborador';

  @override
  String get addContributor => 'Agregar colaborador';

  @override
  String get contributorAdded => 'Colaborador agregado';

  @override
  String get pdf => 'PDF';

  @override
  String get generatingPdf => 'Generando PDF…';

  @override
  String get pdfFailed => 'Error al generar PDF';

  @override
  String get tableOfContents => 'Tabla de contenidos';

  @override
  String byAuthor(String name) {
    return 'por $name';
  }

  @override
  String pageOfTotal(int page, int total) {
    return 'Página $page de $total';
  }

  @override
  String get close => 'Cerrar';

  @override
  String get openLink => 'Abrir enlace';

  @override
  String get invalidLink => 'Enlace no válido';

  @override
  String get unableToOpenLink => 'No se puede abrir el enlace';

  @override
  String get copy => 'Copiar';

  @override
  String get copiedToClipboard => 'Copiado al portapapeles';

  @override
  String showingCachedPublicData(String msg) {
    return '$msg — mostrando datos públicos/en caché';
  }

  @override
  String get menu => 'Menú';

  @override
  String get metaLabel => 'Meta';

  @override
  String get aiServiceUnavailable => 'Servicio IA no disponible';

  @override
  String get aiConfigurations => 'Configuraciones IA';

  @override
  String get modelLabel => 'Modelo';

  @override
  String get temperatureLabel => 'Temperatura';

  @override
  String get saveFailed => 'Error al guardar';

  @override
  String get saveMyVersion => 'Guardar mi versión';

  @override
  String get resetToPublic => 'Restablecer a público';

  @override
  String get resetFailed => 'Error al restablecer';

  @override
  String get prompts => 'Instrucciones';

  @override
  String get patterns => 'Patrones';

  @override
  String get storyLines => 'Líneas de historia';

  @override
  String get tools => 'Herramientas';

  @override
  String get preview => 'Vista previa';

  @override
  String get actions => 'Acciones';

  @override
  String get searchLabel => 'Buscar';

  @override
  String get allLabel => 'Todos';

  @override
  String get filterByLocked => 'Filtrar por bloqueado';

  @override
  String get lockedOnly => 'Solo bloqueados';

  @override
  String get unlockedOnly => 'Solo desbloqueados';

  @override
  String get promptKey => 'Clave de instrucción';

  @override
  String get language => 'Idioma';

  @override
  String get filterByKey => 'Filtrar por clave';

  @override
  String get viewPublic => 'Ver público';

  @override
  String get groupNone => 'Ninguno';

  @override
  String get groupLanguage => 'Idioma';

  @override
  String get groupKey => 'Clave';

  @override
  String get newPrompt => 'Nueva instrucción';

  @override
  String get newPattern => 'Nuevo patrón';

  @override
  String get newStoryLine => 'Nueva línea de historia';

  @override
  String get editPrompt => 'Editar instrucción';

  @override
  String get editPattern => 'Editar patrón';

  @override
  String get editStoryLine => 'Editar línea de historia';

  @override
  String deletedWithTitle(String title) {
    return 'Eliminado: $title';
  }

  @override
  String deleteFailedWithTitle(String title) {
    return 'Error al eliminar: $title';
  }

  @override
  String deleteErrorWithMessage(String error) {
    return 'Error al eliminar: $error';
  }

  @override
  String get makePublic => 'Hacer público';

  @override
  String get noPrompts => 'No se encontraron instrucciones';

  @override
  String get noPatterns => 'Sin patrones';

  @override
  String get noStoryLines => 'Sin líneas de historia';

  @override
  String conversionFailed(String error) {
    return 'Conversión fallida: $error';
  }

  @override
  String get failedToAnalyze => 'Error al analizar';

  @override
  String get aiCoachAnalyzing => 'Entrenador IA está analizando...';

  @override
  String get retry => 'Reintentar';

  @override
  String get startAiCoaching => 'Iniciar entrenamiento IA';

  @override
  String get refinementComplete => '¡Refinamiento completo!';

  @override
  String get coachQuestion => 'Pregunta del entrenador';

  @override
  String get summaryLooksGood => '¡Buen trabajo! Su resumen se ve sólido.';

  @override
  String get howToImprove => '¿Cómo podemos mejorar esto?';

  @override
  String get suggestionsLabel => 'Sugerencias:';

  @override
  String get reviewSuggestionsHint =>
      'Revisar sugerencias o escribir respuesta...';

  @override
  String get aiGenerationComplete => 'Generación IA completa';

  @override
  String get clickRegenerateForNew =>
      'Haga clic en Regenerar para nuevas sugerencias';

  @override
  String get regenerate => 'Regenerar';

  @override
  String get imSatisfied => 'Estoy satisfecho';

  @override
  String get templateLabel => 'Plantilla';

  @override
  String get exampleCharacterName => 'ej. Harry Potter';

  @override
  String get aiConvert => 'Conversión IA';

  @override
  String get toggleAiCoach => 'Alternar entrenador IA';

  @override
  String retrieveFailed(String error) {
    return 'Error al recuperar: $error';
  }

  @override
  String get confirm => 'Confirmar';

  @override
  String get lastRead => 'Leído por última vez';

  @override
  String get noRecentChapters => 'Sin capítulos recientes';

  @override
  String get failedToLoadConfig => 'Error al cargar configuración';

  @override
  String makePublicPromptConfirm(String promptKey, String language) {
    return '¿Hacer pública \"$promptKey\" ($language)?';
  }

  @override
  String get content => 'Contenido';

  @override
  String get invalidKey => 'Clave no válida';

  @override
  String get invalidLanguage => 'Idioma no válido';

  @override
  String get invalidInput => 'Entrada no válida';

  @override
  String charsCount(int count) {
    return 'Caracteres: $count';
  }

  @override
  String deletePromptConfirm(String promptKey, String language) {
    return '¿Eliminar instrucción \"$promptKey\" ($language)?';
  }

  @override
  String get profileRetrieved => 'Perfil recuperado';

  @override
  String get noProfileFound => 'No se encontró perfil';

  @override
  String get templateName => 'Nombre de plantilla';

  @override
  String get retrieveProfile => 'Recuperar perfil';

  @override
  String get templateRetrieved => 'Plantilla recuperada';

  @override
  String get noTemplateFound => 'No se encontró plantilla';

  @override
  String get retrieveTemplate => 'Recuperar plantilla';

  @override
  String get previewLabel => 'Vista previa';

  @override
  String get markdownHint => 'Ingrese descripción en Markdown...';

  @override
  String get templateNameExists => 'El nombre de plantilla ya existe';

  @override
  String get aiServiceUrlHint => 'Ingresar URL del servicio IA (http/https)';

  @override
  String get urlLabel => 'URL';

  @override
  String get systemFont => 'Fuente del sistema';

  @override
  String get fontInter => 'Inter';

  @override
  String get fontMerriweather => 'Merriweather';

  @override
  String get editPatternTitle => 'Editar patrón';

  @override
  String get newPatternTitle => 'Nuevo patrón';

  @override
  String get editStoryLineTitle => 'Editar línea de historia';

  @override
  String get newStoryLineTitle => 'Nueva línea de historia';

  @override
  String get usageRulesLabel => 'Reglas de uso (JSON)';

  @override
  String get publicPatternLabel => 'Patrón público';

  @override
  String get publicStoryLineLabel => 'Línea de historia pública';

  @override
  String get lockedLabel => 'Bloqueado';

  @override
  String get unlockedLabel => 'Desbloqueado';

  @override
  String get aiButton => 'IA';

  @override
  String get invalidJson => 'JSON no válido';

  @override
  String get deleteFailed => 'Error al eliminar';

  @override
  String get lockPattern => 'Bloquear patrón';

  @override
  String get errorUnauthorized => 'No autorizado';

  @override
  String get errorForbidden => 'Prohibido';

  @override
  String get errorSessionExpired => 'Sesión caducada';

  @override
  String get errorValidation => 'Error de validación';

  @override
  String get errorInvalidInput => 'Entrada no válida';

  @override
  String get errorDuplicateTitle => 'Título duplicado';

  @override
  String get errorNotFound => 'No encontrado';

  @override
  String get errorServiceUnavailable => 'Servicio no disponible';

  @override
  String get errorAiNotConfigured => 'Servicio IA no configurado';

  @override
  String get errorSupabaseError => 'Error de servicio en la nube';

  @override
  String get errorRateLimited => 'Demasiadas solicitudes';

  @override
  String get errorInternal => 'Error interno del servidor';

  @override
  String get errorBadGateway => 'Bad Gateway';

  @override
  String get errorGatewayTimeout =>
      'Tiempo de espera de puerta de enlace agotado';

  @override
  String get loginFailed => 'Error de inicio de sesión';

  @override
  String get invalidResponseFromServer => 'Respuesta no válida del servidor';

  @override
  String get signUp => 'Registrarse';

  @override
  String get forgotPassword => '¿Olvidó su contraseña?';

  @override
  String get signupFailed => 'Error de registro';

  @override
  String get accountCreatedCheckEmail =>
      '¡Cuenta creada! Por favor, revise su correo electrónico para verificar.';

  @override
  String get backToSignIn => 'Volver a iniciar sesión';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get alreadyHaveAccountSignIn => '¿Ya tiene una cuenta? Iniciar sesión';

  @override
  String get requestFailed => 'Solicitud fallida';

  @override
  String get ifAccountExistsResetLinkSent =>
      'Si existe una cuenta, se ha enviado un enlace de restablecimiento a su correo electrónico.';

  @override
  String get enterEmailForResetLink =>
      'Ingrese su dirección de correo electrónico para recibir un enlace de restablecimiento de contraseña.';

  @override
  String get sendResetLink => 'Enviar enlace de restablecimiento';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get sessionInvalidLoginAgain =>
      'Sesión no válida. Inicie sesión nuevamente o use el enlace de restablecimiento nuevamente.';

  @override
  String get updateFailed => 'Error de actualización';

  @override
  String get passwordUpdatedSuccessfully =>
      '¡Contraseña actualizada exitosamente!';

  @override
  String get resetPassword => 'Restablecer contraseña';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get updatePassword => 'Actualizar contraseña';

  @override
  String get noActiveSessionFound =>
      'No se encontró una sesión activa. Inicie sesión nuevamente.';

  @override
  String get authenticationFailedSignInAgain =>
      'Error de autenticación. Inicie sesión nuevamente.';

  @override
  String get accessDeniedNoAdminPrivileges =>
      'Acceso denegado. No tiene privilegios de administrador.';

  @override
  String failedToLoadUsers(int statusCode, String errorBody) {
    return 'Error al cargar usuarios: $statusCode - $errorBody';
  }

  @override
  String get smartSearchRequiresSignIn =>
      'Inicie sesión para usar la búsqueda inteligente';

  @override
  String get smartSearch => 'Búsqueda inteligente';

  @override
  String get failedToPersistTemplate => 'Error al guardar plantilla';

  @override
  String userIdCreated(String id, String createdAt) {
    return 'Usuario $id creado en $createdAt';
  }

  @override
  String get tryAdjustingSearchCreateNovel =>
      'Intente ajustar su búsqueda o crear una novela nueva';

  @override
  String get sessionExpired => 'Sesión caducada';

  @override
  String get errorLoadingUsers => 'Error al cargar usuarios';

  @override
  String get unknownError => 'Error desconocido';

  @override
  String get goBack => 'Volver';

  @override
  String get unableToLoadAsset => 'No se puede cargar el recurso';

  @override
  String get youDontHavePermission =>
      'No tiene permiso para realizar esta acción.';

  @override
  String get continueReading => 'Continuar leyendo';

  @override
  String get removeFromLibrary => 'Eliminar de la biblioteca';

  @override
  String get createFirstNovelSubtitle => 'Cree su primera novela para comenzar';

  @override
  String get navigationError => 'Error de navegación';

  @override
  String get pdfStepPreparing => 'Preparando capítulos';

  @override
  String get pdfStepGenerating => 'Generando PDF';

  @override
  String get pdfStepSharing => 'Compartiendo';

  @override
  String get tipIntention => 'Consejo: Escriba una intención clara por escena.';

  @override
  String get tipVerbs =>
      'Consejo: Los verbos fuertes hacen que las oraciones se sientan vivas.';

  @override
  String get tipStuck =>
      'Consejo: Si está atascado, reescriba el último párrafo.';

  @override
  String get tipDialogue =>
      'Consejo: El diálogo revela personajes más rápido que la descripción.';

  @override
  String get errorNovelNotFound => 'Novela no encontrada';

  @override
  String get noSentenceSummary => 'No hay resumen de oración disponible.';

  @override
  String get noParagraphSummary => 'No hay resumen de párrafo disponible.';

  @override
  String get noPageSummary => 'No hay resumen de página disponible.';

  @override
  String get noExpandedSummary => 'No hay resumen ampliado disponible.';

  @override
  String get aiSentenceSummaryTooltip => 'Resumen de oración IA';

  @override
  String get aiParagraphSummaryTooltip => 'Resumen de párrafo IA';

  @override
  String get aiPageSummaryTooltip => 'Resumen de página IA';

  @override
  String get keyboardShortcuts => 'Atajos de teclado';

  @override
  String get shortcutSpace => 'Espacio: Reproducir / detener';

  @override
  String get shortcutArrows => '← / →: Anterior / siguiente';

  @override
  String get shortcutRate => 'Ctrl/⌘ + R: Velocidad de habla';

  @override
  String get shortcutVoice => 'Ctrl/⌘ + V: Voz';

  @override
  String get shortcutHelp => 'Ctrl/⌘ + /: Mostrar atajos';

  @override
  String get shortcutEsc => 'Esc: Cerrar';

  @override
  String get styles => 'Estilos';

  @override
  String get noVoicesAvailable => 'No hay voces disponibles';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get selectNovelFirst => 'Seleccione una novela primero';

  @override
  String get adminLogs => 'Registros de administrador';

  @override
  String get viewAndFilterBackendLogs => 'Ver y filtrar registros del backend';

  @override
  String get styleGlassmorphism => 'Glassmorfismo';

  @override
  String get styleLiquidGlass => 'Liquid Glass';

  @override
  String get styleNeumorphism => 'Neumorfismo';

  @override
  String get styleClaymorphism => 'Claymorfismo';

  @override
  String get styleMinimalism => 'Minimalismo';

  @override
  String get styleBrutalism => 'Brutalismo';

  @override
  String get styleSkeuomorphism => 'Eskeuomorfismo';

  @override
  String get styleBentoGrid => 'Cuadrícula Bento';

  @override
  String get styleResponsive => 'Responsivo';

  @override
  String get styleFlatDesign => 'Diseño plano';

  @override
  String get scrollToBottom => 'Desplazarse hacia abajo';

  @override
  String get scrollToTop => 'Desplazarse hacia arriba';

  @override
  String get numberOfLines => 'Número de líneas';

  @override
  String get lines => 'líneas';

  @override
  String get load => 'Cargar';

  @override
  String get noLogsAvailable => 'No hay registros disponibles.';

  @override
  String get failedToLoadLogs => 'Error al cargar registros';

  @override
  String wordCount(int count) {
    return 'Conteo de palabras: $count';
  }

  @override
  String characterCount(int count) {
    return 'Conteo de caracteres: $count';
  }

  @override
  String get startWriting => 'Comenzar a escribir...';

  @override
  String failedToLoadChapter(String error) {
    return 'Error al cargar capítulo: $error';
  }

  @override
  String get saving => 'Guardando…';

  @override
  String get wordCountLabel => 'Conteo de palabras';

  @override
  String get characterCountLabel => 'Conteo de caracteres';

  @override
  String get discard => 'Descartar';

  @override
  String get saveShortcut => 'Guardar';

  @override
  String get previewShortcut => 'Vista previa';

  @override
  String get boldShortcut => 'Negrita';

  @override
  String get italicShortcut => 'Cursiva';

  @override
  String get underlineShortcut => 'Subrayado';

  @override
  String get headingShortcut => 'Encabezado';

  @override
  String get insertLinkShortcut => 'Insertar enlace';

  @override
  String get shortcutsHelpShortcut => 'Ayuda de atajos';

  @override
  String get closeShortcut => 'Cerrar';

  @override
  String get designSystemStyleGuide => 'Guía de estilo del sistema de diseño';

  @override
  String get headlineLarge => 'Titular grande';

  @override
  String get headlineMedium => 'Titular mediano';

  @override
  String get titleLarge => 'Título grande';

  @override
  String get bodyLarge => 'Cuerpo grande';

  @override
  String get bodyMedium => 'Cuerpo mediano';

  @override
  String get primaryButton => 'Botón primario';

  @override
  String get disabled => 'Deshabilitado';

  @override
  String checkboxState(bool value) {
    return 'Estado de casilla: $value';
  }

  @override
  String get option1 => 'Opción 1';

  @override
  String get option2 => 'Opción 2';

  @override
  String switchState(bool value) {
    return 'Estado de interruptor: $value';
  }

  @override
  String sliderValue(String value) {
    return 'Valor: $value';
  }

  @override
  String get enterTextHere => 'Ingrese texto aquí...';

  @override
  String get selectAnOption => 'Seleccione una opción';

  @override
  String get optionA => 'Opción A';

  @override
  String get optionB => 'Opción B';

  @override
  String get optionC => 'Opción C';

  @override
  String get contrastIssuesDetected => 'Problemas de contraste detectados';

  @override
  String foundContrastIssues(int count) {
    return 'Se encontraron $count problema(s) de contraste que pueden afectar la legibilidad.';
  }

  @override
  String get allGood => '¡Todo bien!';

  @override
  String get allGoodContrast =>
      'Todos los elementos de texto cumplen con los estándares de contraste WCAG 2.1 AA.';

  @override
  String get ignore => 'Ignorar';

  @override
  String get applyBestFix => 'Aplicar mejor solución';

  @override
  String get moreMenuComingSoon => 'Más menú próximamente';

  @override
  String get styleGuide => 'Guía de estilo';

  @override
  String get themeFactoryNotDefined =>
      'Theme Factory no definió temas, se usará el tema predeterminado.';

  @override
  String progressPercentage(int percent) {
    return '$percent%';
  }

  @override
  String get review => 'Revisar';

  @override
  String get wordsLabel => 'Palabras';

  @override
  String get charsLabel => 'Caracteres';

  @override
  String get readLabel => 'Leer';

  @override
  String get streakLabel => 'Racha';

  @override
  String get pause => 'Pausa';

  @override
  String get start => 'Iniciar';

  @override
  String get editMode => 'Modo de edición';

  @override
  String get previewMode => 'Modo de vista previa';

  @override
  String get quote => 'Cita';

  @override
  String get inlineCode => 'Código en línea';

  @override
  String get bulletedList => 'Lista con viñetas';

  @override
  String get numberedList => 'Lista numerada';

  @override
  String get previewTab => 'Vista previa';

  @override
  String get editTab => 'Editar';

  @override
  String get noExpandedSummaryAvailable =>
      'No hay resumen ampliado disponible.';

  @override
  String get analyze => 'Analizar';

  @override
  String youreOffline(String message) {
    return 'Está sin conexión. $message';
  }

  @override
  String get download => 'Descargar';

  @override
  String get moreActions => 'Más acciones';

  @override
  String get doubleTapToOpen =>
      'Toque dos veces para abrir. Mantenga presionado para acciones.';

  @override
  String get more => 'Más';

  @override
  String get pressD => 'Presionar D';

  @override
  String get pressEnter => 'Presionar Enter';

  @override
  String get pressDelete => 'Presionar Supr';

  @override
  String get exitPreview => 'Salir de vista previa';

  @override
  String get saveLabel => 'Guardar';

  @override
  String get exitZenMode => 'Salir del modo Zen';

  @override
  String get clearSearch => 'Limpiar búsqueda';

  @override
  String get notSignedInLabel => 'No iniciado sesión';

  @override
  String get stylePreviewGrid => 'Cuadrícula de vista previa de estilo';

  @override
  String get themeOceanDepths => 'Profundidades oceánicas';

  @override
  String get themeSunsetBoulevard => 'Bulevar del atardecer';

  @override
  String get themeForestCanopy => 'Dosel del bosque';

  @override
  String get themeModernMinimalist => 'Minimalista moderno';

  @override
  String get themeGoldenHour => 'Hora dorada';

  @override
  String get themeArcticFrost => 'Escarcha ártica';

  @override
  String get themeDesertRose => 'Rosa del desierto';

  @override
  String get themeTechInnovation => 'Innovación tecnológica';

  @override
  String get themeBotanicalGarden => 'Jardín botánico';

  @override
  String get themeMidnightGalaxy => 'Galaxia de medianoche';

  @override
  String get standardLight => 'Claro estándar';

  @override
  String get warmPaper => 'Papel cálido';

  @override
  String get coolGrey => 'Gris frío';

  @override
  String get sepiaLabel => 'Sepia';

  @override
  String get standardDark => 'Oscuro estándar';

  @override
  String get midnight => 'Medianoche';

  @override
  String get darkSepia => 'Sepia oscuro';

  @override
  String get deepOcean => 'Océano profundo';

  @override
  String get youreOfflineLabel => 'Está sin conexión';

  @override
  String get changesWillSync =>
      'Los cambios se sincronizarán cuando vuelva a estar en línea';

  @override
  String changesWillSyncCount(int count) {
    return '$count cambio(s) se sincronizará(n) cuando vuelva a estar en línea';
  }

  @override
  String get toggleSidebar => 'Alternar barra lateral';

  @override
  String get quickSearch => 'Búsqueda rápida';

  // Admin logs
  @override
  String adminLogsSavedTo(String filePath) =>
      'Registros guardados en: $filePath';

  @override
  String adminLogsFailedToDownload(String error) =>
      'Error al descargar registros: $error';

  @override
  String get adminLogsEntry => 'Entrada de registro';

  @override
  String get adminLogsCopiedToClipboard => 'Copiado al portapapeles';

  @override
  String get adminLogsCopy => 'Copiar';

  @override
  String get adminLogsClose => 'Cerrar';

  @override
  String adminLogsMaxSize(String size) => 'Tamaño máximo: $size';

  @override
  String adminLogsSelected(String size) => 'Seleccionado: $size';
}
