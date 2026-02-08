// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get newChapter => '新章节';

  @override
  String get back => '返回';

  @override
  String get helloWorld => '你好世界！';

  @override
  String get settings => '设置';

  @override
  String get appTitle => '写手';

  @override
  String get about => '关于';

  @override
  String get aboutDescription =>
      '阅读和管理小说，支持云端存储、离线模式和文本转语音播放。使用“文库”浏览、搜索并打开章节；登录以同步进度；在设置中调整主题、排版和动效。';

  @override
  String get aboutIntro =>
      'AuthorConsole 帮助您跨设备规划、编写和阅读小说。它专注于读者的简洁体验和作者的强大功能，提供统一的平台来管理章节、大纲、角色和场景。';

  @override
  String get aboutSecurity =>
      '借助云端存储和严格的访问控制，您的数据将得到保护。经过验证的用户可以同步进度、元数据和模板，同时保持隐私。';

  @override
  String get aboutCoach =>
      '内置的 AI 教练使用雪花法来改进您的故事大纲。它会提出针对性的问题，提供建议，并在准备就绪时提供完善的大纲，应用会自动将其应用到您的文档中。';

  @override
  String get aboutFeatureCreate => '• 创建新小说并组织章节。';

  @override
  String get aboutFeatureTemplates => '• 使用角色和场景模板来快速启动创意。';

  @override
  String get aboutFeatureTracking => '• 跟踪阅读进度并在设备间恢复阅读。';

  @override
  String get aboutFeatureCoach => '• 使用 AI 教练完善大纲并应用改进。';

  @override
  String get aboutFeaturePrompts => '• 管理提示词并尝试 AI 辅助的工作流程。';

  @override
  String get aboutUsage => '用法';

  @override
  String get aboutUsageList =>
      '• 文库：搜索并打开小说\n• 阅读器：浏览章节、切换 TTS\n• 模板：管理角色与场景模板\n• 设置：主题、排版和偏好\n• 登录：启用云同步';

  @override
  String get version => '版本';

  @override
  String get appLanguage => '应用语言';

  @override
  String get english => '英语';

  @override
  String get chinese => '中文';

  @override
  String get supabaseIntegrationInitialized => '云同步已初始化';

  @override
  String get configureEnvironment => '请配置您的环境变量以启用云同步';

  @override
  String signedInAs(String email) {
    return '已登录为 $email';
  }

  @override
  String get guest => '访客';

  @override
  String get notSignedIn => '未登录';

  @override
  String get signIn => '登录';

  @override
  String get continueLabel => '继续';

  @override
  String get reload => '重新加载';

  @override
  String get signInToSync => '登录以在设备间同步进度。';

  @override
  String get currentProgress => '当前进度';

  @override
  String get loadingProgress => '正在加载进度...';

  @override
  String get recentlyRead => '最近阅读';

  @override
  String get noSupabase => '此版本未启用云同步。';

  @override
  String get errorLoadingProgress => '加载进度时出错';

  @override
  String get noProgress => '未找到进度';

  @override
  String get errorLoadingNovels => '加载小说时出错';

  @override
  String get loadingNovels => '正在加载小说…';

  @override
  String get titleLabel => '标题';

  @override
  String get authorLabel => '作者';

  @override
  String get noNovelsFound => '未找到小说。';

  @override
  String get myNovels => '我的小说';

  @override
  String get createNovel => '创建小说';

  @override
  String get create => '创建';

  @override
  String get errorLoadingChapters => '加载章节时出错';

  @override
  String get loadingChapter => '正在加载章节…';

  @override
  String get notStarted => '尚未开始';

  @override
  String get unknownNovel => '未知小说';

  @override
  String get unknownChapter => '未知章节';

  @override
  String get chapter => '章节';

  @override
  String get novel => '小说';

  @override
  String get chapterTitle => '章节标题';

  @override
  String get scrollOffset => '滚动偏移';

  @override
  String get ttsIndex => 'TTS 索引';

  @override
  String get speechRate => '语速';

  @override
  String get volume => '音量';

  @override
  String get defaultTTSVoice => '默认 TTS 语音';

  @override
  String get defaultVoiceUpdated => '默认语音已更新';

  @override
  String get defaultLanguageSet => '默认语言已设置';

  @override
  String get searchByTitle => '按标题搜索…';

  @override
  String get chooseLanguage => '选择语言';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get signInWithGoogle => '使用 Google 登录';

  @override
  String get signInWithApple => '使用 Apple 登录';

  @override
  String get testVoice => '测试语音';

  @override
  String get reloadVoices => '重新加载语音';

  @override
  String get signOut => '退出登录';

  @override
  String get signedOut => '已退出登录';

  @override
  String get appSettings => '应用设置';

  @override
  String get supabaseSettings => '云同步设置';

  @override
  String get supabaseNotEnabled => '云同步未启用';

  @override
  String get supabaseNotEnabledDescription => '此版本未配置云同步。';

  @override
  String get authDisabledInBuild => '未配置云同步。本版本已禁用认证。';

  @override
  String get fetchFromSupabase => '从云端获取';

  @override
  String get fetchFromSupabaseDescription => '从云端获取最新的小说和进度。';

  @override
  String get confirmFetch => '确认获取';

  @override
  String get confirmFetchDescription => '这将覆盖您的本地数据。您确定吗？';

  @override
  String get cancel => '取消';

  @override
  String get fetch => '获取';

  @override
  String get downloadChapters => '下载章节';

  @override
  String get modeSupabase => '模式：云同步';

  @override
  String get modeMockData => '模式：模拟数据';

  @override
  String continueAtChapter(String title) {
    return '继续阅读章节 • $title';
  }

  @override
  String get error => '错误';

  @override
  String get ttsSettings => 'TTS 设置';

  @override
  String get enableTTS => '启用 TTS';

  @override
  String get sentenceSummary => '一句话概要';

  @override
  String get paragraphSummary => '一段话概要';

  @override
  String get pageSummary => '一页纸大纲';

  @override
  String get expandedSummary => '细纲';

  @override
  String get pitch => '音高';

  @override
  String get signInWithBiometrics => '使用生物识别登录';

  @override
  String get enableBiometricLogin => '启用生物识别登录';

  @override
  String get enableBiometricLoginDescription => '使用指纹或面部识别登录。';

  @override
  String get biometricAuthFailed => '生物识别验证失败';

  @override
  String get saveCredentialsForBiometric => '保存凭据用于生物识别登录';

  @override
  String get saveCredentialsForBiometricDescription => '安全存储您的凭据以便更快进行生物识别验证';

  @override
  String get biometricTokensExpired => '生物识别令牌已过期';

  @override
  String get biometricNoTokens => '未找到生物识别令牌';

  @override
  String get biometricTokenError => '生物识别令牌错误';

  @override
  String get biometricTechnicalError => '生物识别技术错误';

  @override
  String get ttsVoice => 'TTS 语音';

  @override
  String get loadingVoices => '正在加载语音...';

  @override
  String get selectVoice => '选择语音';

  @override
  String get ttsLanguage => 'TTS 语言';

  @override
  String get loadingLanguages => '正在加载语言...';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get ttsSpeechRate => '语速';

  @override
  String get ttsSpeechVolume => '音量';

  @override
  String get ttsSpeechPitch => '音高';

  @override
  String get novelsAndProgress => '小说和进度';

  @override
  String get novels => '小说';

  @override
  String get progress => '进度';

  @override
  String novelsAndProgressSummary(int count, String progress) {
    return '小说: $count, 进度: $progress';
  }

  @override
  String get chapters => '章节';

  @override
  String get noChaptersFound => '未找到章节。';

  @override
  String indexLabel(int index) {
    return '第 $index 章';
  }

  @override
  String get enterFloatIndexHint => '输入小数索引以重新定位';

  @override
  String indexOutOfRange(int min, int max) {
    return '索引必须在 $min-$max 之间';
  }

  @override
  String get indexUnchanged => '索引未变化';

  @override
  String get roundingBefore => '总是前插';

  @override
  String get roundingAfter => '总是后插';

  @override
  String get stopTTS => '停止 TTS';

  @override
  String get speak => '朗读';

  @override
  String get supabaseProgressNotSaved => '未配置云同步；进度未保存';

  @override
  String get progressSaved => '进度已保存';

  @override
  String get errorSavingProgress => '保存进度时出错';

  @override
  String get autoplayBlocked => '自动播放被阻止。点击“继续”开始。';

  @override
  String get autoplayBlockedInline => '浏览器阻止了自动播放。点击“继续”开始阅读。';

  @override
  String get reachedLastChapter => '已到最后一章';

  @override
  String ttsError(String msg) {
    return 'TTS 错误：$msg';
  }

  @override
  String get themeMode => '主题模式';

  @override
  String get system => '跟随系统';

  @override
  String get light => '浅色';

  @override
  String get dark => '深色';

  @override
  String get colorTheme => '配色主题';

  @override
  String get themeLight => '浅色';

  @override
  String get themeSepia => '仿古纸';

  @override
  String get themeHighContrast => '高对比';

  @override
  String get themeDefault => '默认';

  @override
  String get themeEmeraldGreen => '祖母绿';

  @override
  String get themeSolarizedTan => 'Solarized Tan';

  @override
  String get themeNord => 'Nord';

  @override
  String get themeNordFrost => 'Nord Frost';

  @override
  String get separateDarkPalette => '使用独立深色配色';

  @override
  String get lightPalette => '浅色配色';

  @override
  String get darkPalette => '深色配色';

  @override
  String get typographyPreset => '阅读排版';

  @override
  String get typographyComfortable => '舒适';

  @override
  String get typographyCompact => '紧凑';

  @override
  String get typographySerifLike => '仿衬线';

  @override
  String get fontPack => '字体方案';

  @override
  String get separateTypographyPresets => '为浅色/深色使用独立排版';

  @override
  String get typographyLight => '浅色排版';

  @override
  String get typographyDark => '深色排版';

  @override
  String get readerBundles => '阅读主题预设';

  @override
  String get tokenUsage => '令牌使用量';

  @override
  String removedNovel(String title) {
    return '已移除 $title';
  }

  @override
  String get discover => '发现';

  @override
  String get profile => '个人资料';

  @override
  String get libraryTitle => '文库';

  @override
  String get undo => '撤销';

  @override
  String get allFilter => '全部';

  @override
  String get readingFilter => '阅读中';

  @override
  String get completedFilter => '已完成';

  @override
  String get downloadedFilter => '已下载';

  @override
  String get searchNovels => '搜索小说...';

  @override
  String get listView => '列表视图';

  @override
  String get gridView => '网格视图';

  @override
  String get userManagement => '用户管理';

  @override
  String get totalThisMonth => '本月总计';

  @override
  String get inputTokens => '输入令牌';

  @override
  String get outputTokens => '输出令牌';

  @override
  String get requests => '请求数';

  @override
  String get viewHistory => '查看历史';

  @override
  String get noUsageThisMonth => '本月暂无使用';

  @override
  String get startUsingAiFeatures => '开始使用 AI 功能以查看令牌消耗';

  @override
  String get errorLoadingUsage => '加载使用量出错';

  @override
  String get refresh => '刷新';

  @override
  String totalRecords(int count) {
    return '总记录数：$count';
  }

  @override
  String get total => '总计';

  @override
  String get noUsageHistory => '暂无使用历史';

  @override
  String get bundleNordCalm => 'Nord Calm';

  @override
  String get bundleSolarizedFocus => 'Solarized Focus';

  @override
  String get bundleHighContrastReadability => '高对比可读性';

  @override
  String get customFontFamily => '自定义字体';

  @override
  String get commonFonts => '常见字体';

  @override
  String get readerFontSize => '阅读字体大小';

  @override
  String get textScale => '文字缩放';

  @override
  String get readerBackgroundDepth => '阅读背景深度';

  @override
  String get depthLow => '浅';

  @override
  String get depthMedium => '中';

  @override
  String get depthHigh => '深';

  @override
  String get select => '选择';

  @override
  String get clear => '清除';

  @override
  String get adminMode => '管理员模式';

  @override
  String get reduceMotion => '减少动效';

  @override
  String get reduceMotionDescription => '为舒适体验尽量减少动画';

  @override
  String get gesturesEnabled => '启用手势';

  @override
  String get gesturesEnabledDescription => '在阅读器中启用滑动和点击手势';

  @override
  String get readerSwipeSensitivity => '阅读器滑动灵敏度';

  @override
  String get readerSwipeSensitivityDescription => '调整用于章节导航的最小滑动速度';

  @override
  String get remove => '移除';

  @override
  String get removedFromLibrary => '已从文库中移除';

  @override
  String get confirmDelete => '确认删除';

  @override
  String confirmDeleteDescription(String title) {
    return '将从云端删除“$title”。是否确认？';
  }

  @override
  String get delete => '删除';

  @override
  String get reachedFirstChapter => '已到第一章';

  @override
  String get previousChapter => '上一章';

  @override
  String get nextChapter => '下一章';

  @override
  String get betaEvaluate => '内测';

  @override
  String get betaEvaluating => '正在发送到内测评审…';

  @override
  String get betaEvaluationReady => '内测评审结果已返回';

  @override
  String get betaEvaluationFailed => '内测评审失败';

  @override
  String get performanceSettings => '性能设置';

  @override
  String get prefetchNextChapter => '预取下一章';

  @override
  String get prefetchNextChapterDescription => '预加载下一章以减少等待。';

  @override
  String get clearOfflineCache => '清除离线缓存';

  @override
  String get offlineCacheCleared => '离线缓存已清除';

  @override
  String get edit => '编辑';

  @override
  String get exitEdit => '退出编辑';

  @override
  String get enterEditMode => '进入编辑模式';

  @override
  String get exitEditMode => '退出编辑模式';

  @override
  String get chapterContent => '章节内容';

  @override
  String get save => '保存';

  @override
  String get createNextChapter => '创建下一章';

  @override
  String get enterChapterTitle => '输入章节标题';

  @override
  String get enterChapterContent => '输入章节内容';

  @override
  String get discardChangesTitle => '放弃更改？';

  @override
  String get discardChangesMessage => '你有未保存的更改。是否要放弃？';

  @override
  String get keepEditing => '继续编辑';

  @override
  String get discardChanges => '放弃更改';

  @override
  String get saveAndExit => '保存并退出';

  @override
  String get descriptionLabel => '描述';

  @override
  String get coverUrlLabel => '封面链接';

  @override
  String get invalidCoverUrl => '请输入有效的 http(s) 链接且不包含空格。';

  @override
  String get navigation => '导航';

  @override
  String get home => '主页';

  @override
  String get chapterIndex => '章节索引';

  @override
  String get summary => '摘要';

  @override
  String get characters => '角色';

  @override
  String get scenes => '场景';

  @override
  String get characterTemplates => '角色模板';

  @override
  String get sceneTemplates => '场景模板';

  @override
  String get updateNovel => '更新小说';

  @override
  String get deleteNovel => '删除小说';

  @override
  String get deleteNovelConfirmation => '这将永久删除该小说。要继续吗？';

  @override
  String get format => '格式化';

  @override
  String get aiServiceUrl => 'AI 服务地址';

  @override
  String get aiServiceUrlDescription => 'AI 功能的后端服务地址';

  @override
  String get aiAssistant => 'AI 助手';

  @override
  String get aiChatHistory => '历史';

  @override
  String get aiChatNewChat => '新对话';

  @override
  String get aiChatNoHistory => '暂无历史记录';

  @override
  String get aiChatHint => '输入您的消息...';

  @override
  String get aiChatEmpty => '询问我关于本章或小说的任何问题';

  @override
  String get aiThinking => 'AI 正在思考...';

  @override
  String get aiChatContextLabel => '上下文';

  @override
  String aiTokenCount(int count) {
    return '$count tokens';
  }

  @override
  String aiContextLoadError(String error) {
    return '加载上下文出错：$error';
  }

  @override
  String aiChatContextTooLongCompressing(int tokens) {
    return '上下文过长（$tokens tokens）。正在压缩...';
  }

  @override
  String aiChatContextCompressionFailedNote(String error) {
    return '[注意：上下文压缩失败：$error]';
  }

  @override
  String aiChatError(String error) {
    return '错误：$error';
  }

  @override
  String aiChatDeepAgentError(String error) {
    return 'Deep Agent 错误：$error';
  }

  @override
  String get aiChatSearchFailed => '搜索失败';

  @override
  String aiChatSearchError(String error) {
    return '搜索错误：$error';
  }

  @override
  String get aiChatRagSearchResultsTitle => 'RAG 搜索结果';

  @override
  String aiChatRagRefinedQuery(String query) {
    return '优化后的查询：\"$query\"';
  }

  @override
  String get aiChatRagNoResults => '未找到结果。';

  @override
  String get aiChatRagUnknownType => '未知';

  @override
  String get aiServiceSignInRequired => '需要登录才能使用 AI 服务';

  @override
  String get aiServiceFeatureNotAvailable => '你的套餐不支持此功能';

  @override
  String aiServiceFailedToConnect(String error) {
    return '连接 AI 服务失败：$error';
  }

  @override
  String get aiServiceNoResponse => 'AI 服务没有返回结果';

  @override
  String get aiDeepAgentDetailsTitle => 'Deep Agent';

  @override
  String aiDeepAgentStop(String reason, Object rounds) {
    return '停止：$reason（轮次：$rounds）';
  }

  @override
  String get aiDeepAgentPlanLabel => '计划：';

  @override
  String get aiDeepAgentToolsLabel => '工具：';

  @override
  String get deepAgentSettingsTitle => 'Deep Agent 设置';

  @override
  String get deepAgentSettingsDescription =>
      '控制 AI Chat 是否优先使用 Deep Agent，以及反思与调试输出。';

  @override
  String get deepAgentPreferTitle => '优先使用 Deep Agent';

  @override
  String get deepAgentPreferSubtitle => '开启后，普通聊天会先调用 /agents/deep-agent。';

  @override
  String get deepAgentFallbackTitle => 'Deep Agent 不可用时回退 QA';

  @override
  String get deepAgentFallbackSubtitle =>
      '当 deep-agent 返回 404/501 时自动调用 /agents/qa。';

  @override
  String get deepAgentReflectionModeTitle => '反思模式';

  @override
  String get deepAgentReflectionModeSubtitle =>
      '控制 deep-agent 是否在回答后进行评估与可选重试。';

  @override
  String get deepAgentReflectionModeOff => '关闭';

  @override
  String get deepAgentReflectionModeOnFailure => '仅失败时';

  @override
  String get deepAgentReflectionModeAlways => '总是';

  @override
  String get deepAgentShowDetailsTitle => '显示执行细节';

  @override
  String get deepAgentShowDetailsSubtitle => '在 /deep 命令结果里附加 plan 与工具调用记录。';

  @override
  String get deepAgentMaxPlanSteps => '规划步数上限';

  @override
  String get deepAgentMaxToolRounds => '工具轮次上限';

  @override
  String get send => '发送';

  @override
  String get resetToDefault => '重置为默认值';

  @override
  String get invalidUrl => '请输入有效的 http(s) 链接且不包含空格。';

  @override
  String get urlTooLong => 'URL 必须少于 2048 个字符。';

  @override
  String get urlContainsSpaces => 'URL 不能包含空格。';

  @override
  String get urlInvalidScheme => 'URL 必须以 http:// 或 https:// 开头。';

  @override
  String get saved => '已保存';

  @override
  String get required => '必填';

  @override
  String get summariesLabel => '概要';

  @override
  String get synopsesLabel => '梗概';

  @override
  String get locationLabel => '地点';

  @override
  String languageLabel(String code) {
    return '语言：$code';
  }

  @override
  String get publicLabel => '公开';

  @override
  String get privateLabel => '私密';

  @override
  String chaptersCount(int count) {
    return '章节：$count';
  }

  @override
  String avgWordsPerChapter(int avg) {
    return '平均每章字数：$avg';
  }

  @override
  String chapterLabel(int idx) {
    return '第$idx章';
  }

  @override
  String chapterWithTitle(int idx, String title) {
    return '第$idx章：$title';
  }

  @override
  String get refreshTooltip => '刷新';

  @override
  String get untitled => '未命名';

  @override
  String get newLabel => '新建';

  @override
  String get deleteSceneTitle => '删除场景';

  @override
  String get deleteCharacterTitle => '删除角色';

  @override
  String get deleteTemplateTitle => '删除模板';

  @override
  String get confirmDeleteGeneric => '确定要删除此项吗？';

  @override
  String get novelMetadata => '小说元数据';

  @override
  String get contributorEmailLabel => '协作者邮箱';

  @override
  String get contributorEmailHint => '输入用户邮箱以添加为协作者';

  @override
  String get addContributor => '添加协作者';

  @override
  String get contributorAdded => '协作者已添加';

  @override
  String get pdf => 'PDF';

  @override
  String get generatingPdf => '正在生成 PDF…';

  @override
  String get pdfFailed => '生成 PDF 失败';

  @override
  String get tableOfContents => '目录';

  @override
  String byAuthor(String name) {
    return '作者：$name';
  }

  @override
  String pageOfTotal(int page, int total) {
    return '第$page/$total页';
  }

  @override
  String get close => '关闭';

  @override
  String get copy => '复制';

  @override
  String get copiedToClipboard => '已复制到剪贴板';

  @override
  String showingCachedPublicData(String msg) {
    return '$msg — 显示缓存/公共数据';
  }

  @override
  String get menu => '菜单';

  @override
  String get metaLabel => '元数据';

  @override
  String get aiServiceUnavailable => 'AI 服务不可用';

  @override
  String get aiConfigurations => 'AI 配置';

  @override
  String get modelLabel => '模型';

  @override
  String get temperatureLabel => '温度';

  @override
  String get saveFailed => '保存失败';

  @override
  String get saveMyVersion => '保存我的版本';

  @override
  String get resetToPublic => '重置为公开';

  @override
  String get resetFailed => '重置失败';

  @override
  String get prompts => '提示';

  @override
  String get patterns => '套路';

  @override
  String get storyLines => '故事线';

  @override
  String get tools => '工具';

  @override
  String get preview => '预览';

  @override
  String get actions => '操作';

  @override
  String get searchLabel => '搜索';

  @override
  String get allLabel => '全部';

  @override
  String get filterByLocked => '按锁定筛选';

  @override
  String get lockedOnly => '仅锁定';

  @override
  String get unlockedOnly => '仅未锁定';

  @override
  String get promptKey => '提示键';

  @override
  String get language => '语言';

  @override
  String get filterByKey => '按键筛选';

  @override
  String get viewPublic => '查看公开';

  @override
  String get groupNone => '不分组';

  @override
  String get groupLanguage => '按语言分组';

  @override
  String get groupKey => '按键分组';

  @override
  String get newPrompt => '新建提示';

  @override
  String get newPattern => '新建模式';

  @override
  String get newStoryLine => '新建故事线';

  @override
  String get editPrompt => '编辑提示';

  @override
  String get editPattern => '编辑模式';

  @override
  String get editStoryLine => '编辑故事线';

  @override
  String deletedWithTitle(String title) {
    return '已删除：$title';
  }

  @override
  String deleteFailedWithTitle(String title) {
    return '删除失败：$title';
  }

  @override
  String deleteErrorWithMessage(String error) {
    return '删除出错：$error';
  }

  @override
  String get makePublic => '设为公开';

  @override
  String get noPrompts => '没有提示';

  @override
  String get noPatterns => '没有模式';

  @override
  String get noStoryLines => '没有故事线';

  @override
  String conversionFailed(String error) {
    return '转换失败：$error';
  }

  @override
  String get failedToAnalyze => '分析失败';

  @override
  String get aiCoachAnalyzing => 'AI 教练正在分析...';

  @override
  String get retry => '重试';

  @override
  String get startAiCoaching => '开始 AI 教练';

  @override
  String get refinementComplete => '完善完成！';

  @override
  String get coachQuestion => '教练提问';

  @override
  String get summaryLooksGood => '做得很好！你的概要很扎实。';

  @override
  String get howToImprove => '我们可以如何改进？';

  @override
  String get suggestionsLabel => '建议：';

  @override
  String get reviewSuggestionsHint => '查看建议或输入回答...';

  @override
  String get aiGenerationComplete => 'AI 生成完成';

  @override
  String get clickRegenerateForNew => '点击重新生成获取新建议';

  @override
  String get regenerate => '重新生成';

  @override
  String get imSatisfied => '我满意了';

  @override
  String get templateLabel => '模板';

  @override
  String get exampleCharacterName => '例如：哈利·波特';

  @override
  String get aiConvert => 'AI 转换';

  @override
  String get toggleAiCoach => '切换 AI 教练';

  @override
  String retrieveFailed(String error) {
    return '获取失败：$error';
  }

  @override
  String get confirm => '确认';

  @override
  String get lastRead => '上次阅读';

  @override
  String get noRecentChapters => '没有最近章节';

  @override
  String get failedToLoadConfig => '配置加载失败';

  @override
  String makePublicPromptConfirm(String promptKey, String language) {
    return '将提示 \"$promptKey\"（$language）设为公开？';
  }

  @override
  String get content => '内容';

  @override
  String get invalidKey => '键无效';

  @override
  String get invalidLanguage => '语言无效';

  @override
  String get invalidInput => '输入无效';

  @override
  String charsCount(int count) {
    return '字符数：$count';
  }

  @override
  String deletePromptConfirm(String promptKey, String language) {
    return '删除提示词 \"$promptKey\"（$language）？';
  }

  @override
  String get profileRetrieved => '已获取个人资料';

  @override
  String get noProfileFound => '未找到个人资料';

  @override
  String get templateName => '模板名称';

  @override
  String get retrieveProfile => '获取个人资料';

  @override
  String get previewLabel => '预览';

  @override
  String get markdownHint => '用 Markdown 输入描述...';

  @override
  String get templateNameExists => '模板名称已存在';

  @override
  String get aiServiceUrlHint => '输入 AI 服务 URL（http/https）';

  @override
  String get urlLabel => '链接';

  @override
  String get systemFont => '系统字体';

  @override
  String get fontInter => 'Inter';

  @override
  String get fontMerriweather => 'Merriweather';

  @override
  String get editPatternTitle => '编辑模式';

  @override
  String get newPatternTitle => '新建模式';

  @override
  String get editStoryLineTitle => '编辑故事线';

  @override
  String get newStoryLineTitle => '新建故事线';

  @override
  String get usageRulesLabel => '使用规则 (JSON)';

  @override
  String get publicPatternLabel => '公开模式';

  @override
  String get publicStoryLineLabel => '公开故事线';

  @override
  String get lockedLabel => '已锁定';

  @override
  String get unlockedLabel => '未锁定';

  @override
  String get aiButton => 'AI';

  @override
  String get invalidJson => '无效的 JSON';

  @override
  String get deleteFailed => '删除失败';

  @override
  String get lockPattern => '锁定模式';

  @override
  String get errorUnauthorized => '未授权';

  @override
  String get errorForbidden => '禁止访问';

  @override
  String get errorSessionExpired => '会话已过期';

  @override
  String get errorValidation => '验证错误';

  @override
  String get errorInvalidInput => '输入无效';

  @override
  String get errorDuplicateTitle => '标题重复';

  @override
  String get errorNotFound => '未找到';

  @override
  String get errorServiceUnavailable => '服务不可用';

  @override
  String get errorAiNotConfigured => 'AI 服务未配置';

  @override
  String get errorSupabaseError => '云服务错误';

  @override
  String get errorRateLimited => '请求过多';

  @override
  String get errorInternal => '服务器内部错误';

  @override
  String get errorBadGateway => '网关错误';

  @override
  String get errorGatewayTimeout => '网关超时';

  @override
  String get loginFailed => '登录失败';

  @override
  String get invalidResponseFromServer => '服务器响应无效';

  @override
  String get signUp => '注册';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get signupFailed => '注册失败';

  @override
  String get accountCreatedCheckEmail => '账户已创建！请检查您的邮箱以验证。';

  @override
  String get backToSignIn => '返回登录';

  @override
  String get createAccount => '创建账户';

  @override
  String get alreadyHaveAccountSignIn => '已有账户？登录';

  @override
  String get requestFailed => '请求失败';

  @override
  String get ifAccountExistsResetLinkSent => '如果账户存在，重置链接已发送到您的邮箱。';

  @override
  String get enterEmailForResetLink => '输入您的邮箱地址以接收密码重置链接。';

  @override
  String get sendResetLink => '发送重置链接';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get sessionInvalidLoginAgain => '会话无效。请重新登录或再次使用重置链接。';

  @override
  String get updateFailed => '更新失败';

  @override
  String get passwordUpdatedSuccessfully => '密码已成功更新！';

  @override
  String get resetPassword => '重置密码';

  @override
  String get newPassword => '新密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get updatePassword => '更新密码';

  @override
  String get noActiveSessionFound => '未找到活动会话。请重新登录。';

  @override
  String get authenticationFailedSignInAgain => '身份验证失败。请重新登录。';

  @override
  String get accessDeniedNoAdminPrivileges => '访问被拒绝。您没有管理员权限。';

  @override
  String failedToLoadUsers(int statusCode, String errorBody) {
    return '加载用户失败：$statusCode - $errorBody';
  }

  @override
  String get smartSearchRequiresSignIn => '智能搜索需要登录';

  @override
  String get smartSearch => '智能搜索';

  @override
  String get failedToPersistTemplate => '保存模板失败';

  @override
  String userIdCreated(String id, String createdAt) {
    return 'ID：$id\n创建时间：$createdAt';
  }

  @override
  String get tryAdjustingSearchCreateNovel => '尝试调整搜索或创建新小说';

  @override
  String get sessionExpired => '会话已过期';

  @override
  String get errorLoadingUsers => '加载用户时出错';

  @override
  String get unknownError => '未知错误';

  @override
  String get goBack => '返回';

  @override
  String get unableToLoadAsset => '无法加载资源：\\\"assetmanifest.bin.json\\\"';

  @override
  String get youDontHavePermission => '您没有权限执行此操作。';

  @override
  String get continueReading => '继续阅读';

  @override
  String get removeFromLibrary => '从文库中移除';

  @override
  String get createFirstNovelSubtitle => '创建您的第一本小说以开始。';

  @override
  String get navigationError => '导航错误';

  @override
  String get pdfStepPreparing => '准备章节';

  @override
  String get pdfStepGenerating => '生成 PDF';

  @override
  String get pdfStepSharing => '分享';

  @override
  String get tipIntention => '提示：每个场景写一个明确的意图。';

  @override
  String get tipVerbs => '提示：强有力的动词让句子更有生命力。';

  @override
  String get tipStuck => '提示：如果卡住了，重写上一段。';

  @override
  String get tipDialogue => '提示：对话比描述更能快速揭示角色。';

  @override
  String get errorNovelNotFound => '未找到小说';

  @override
  String get noSentenceSummary => '暂无一句话概要。';

  @override
  String get noParagraphSummary => '暂无一段话概要。';

  @override
  String get noPageSummary => '暂无一页纸大纲。';

  @override
  String get noExpandedSummary => '暂无细纲。';

  @override
  String get aiSentenceSummaryTooltip => 'AI 一句话概要';

  @override
  String get aiParagraphSummaryTooltip => 'AI 一段话概要';

  @override
  String get aiPageSummaryTooltip => 'AI 一页纸大纲';

  @override
  String get keyboardShortcuts => '键盘快捷键';

  @override
  String get shortcutSpace => '空格：播放/停止';

  @override
  String get shortcutArrows => '← / →：上一章/下一章';

  @override
  String get shortcutRate => 'Ctrl/⌘ + R：语速';

  @override
  String get shortcutVoice => 'Ctrl/⌘ + V：语音';

  @override
  String get shortcutHelp => 'Ctrl/⌘ + /：显示快捷键';

  @override
  String get shortcutEsc => 'Esc：关闭';

  @override
  String get styles => '样式';

  @override
  String get noVoicesAvailable => '无可用语音';

  @override
  String get comingSoon => '即将推出';

  @override
  String get selectNovelFirst => '请先选择小说';

  @override
  String get adminLogs => '管理员日志';

  @override
  String get styleGlassmorphism => '玻璃拟态';

  @override
  String get styleLiquidGlass => '液态玻璃';

  @override
  String get styleNeumorphism => '新拟态';

  @override
  String get styleClaymorphism => '泥陶拟态';

  @override
  String get styleMinimalism => '极简主义';

  @override
  String get styleBrutalism => '野兽派';

  @override
  String get styleSkeuomorphism => '拟物化';

  @override
  String get styleBentoGrid => '便当盒布局';

  @override
  String get styleResponsive => '响应式';

  @override
  String get styleFlatDesign => '扁平设计';

  @override
  String get scrollToBottom => '滚动到底部';

  @override
  String get scrollToTop => '滚动到顶部';

  @override
  String get numberOfLines => '行数';

  @override
  String get lines => '行';

  @override
  String get load => '加载';

  @override
  String get noLogsAvailable => '暂无日志。';

  @override
  String get failedToLoadLogs => '加载日志失败';

  @override
  String wordCount(int count) {
    return '字数：$count';
  }

  @override
  String characterCount(int count) {
    return '字符数：$count';
  }

  @override
  String get startWriting => '开始写作...';

  @override
  String failedToLoadChapter(String error) {
    return '加载章节失败：$error';
  }

  @override
  String get saving => '保存中…';

  @override
  String get wordCountLabel => '字数统计';

  @override
  String get characterCountLabel => '字符统计';

  @override
  String get discard => '放弃';

  @override
  String get saveShortcut => '保存';

  @override
  String get previewShortcut => '预览';

  @override
  String get boldShortcut => '粗体';

  @override
  String get italicShortcut => '斜体';

  @override
  String get underlineShortcut => '下划线';

  @override
  String get headingShortcut => '标题';

  @override
  String get insertLinkShortcut => '插入链接';

  @override
  String get shortcutsHelpShortcut => '快捷键帮助';

  @override
  String get closeShortcut => '关闭';

  @override
  String get designSystemStyleGuide => '设计系统样式指南';

  @override
  String get headlineLarge => '大标题';

  @override
  String get headlineMedium => '中标题';

  @override
  String get titleLarge => '大号标题';

  @override
  String get bodyLarge => '大号正文';

  @override
  String get bodyMedium => '中号正文';

  @override
  String get primaryButton => '主按钮';

  @override
  String get disabled => '已禁用';

  @override
  String checkboxState(bool value) {
    return '复选框状态：$value';
  }

  @override
  String get option1 => '选项 1';

  @override
  String get option2 => '选项 2';

  @override
  String switchState(bool value) {
    return '开关状态：$value';
  }

  @override
  String sliderValue(String value) {
    return '数值：$value';
  }

  @override
  String get enterTextHere => '在此输入文本...';

  @override
  String get selectAnOption => '选择一个选项';

  @override
  String get optionA => '选项 A';

  @override
  String get optionB => '选项 B';

  @override
  String get optionC => '选项 C';

  @override
  String get contrastIssuesDetected => '检测到对比度问题';

  @override
  String foundContrastIssues(int count) {
    return '发现 $count 个可能影响可读性的对比度问题。';
  }

  @override
  String get allGood => '一切正常！';

  @override
  String get allGoodContrast => '所有文本元素均符合 WCAG 2.1 AA 对比度标准。';

  @override
  String get ignore => '忽略';

  @override
  String get applyBestFix => '应用最佳修复';

  @override
  String get moreMenuComingSoon => '更多菜单即将推出';

  @override
  String get styleGuide => '样式指南';

  @override
  String get themeFactoryNotDefined => '主题工厂未定义任何主题，已使用默认主题。';

  @override
  String progressPercentage(int percent) {
    return '$percent%';
  }

  @override
  String get review => '审查';

  @override
  String get wordsLabel => '字数';

  @override
  String get charsLabel => '字符';

  @override
  String get readLabel => '阅读';

  @override
  String get streakLabel => '连续';

  @override
  String get pause => '暂停';

  @override
  String get start => '开始';

  @override
  String get editMode => '编辑模式';

  @override
  String get previewMode => '预览模式';

  @override
  String get quote => '引用';

  @override
  String get inlineCode => '行内代码';

  @override
  String get bulletedList => '无序列表';

  @override
  String get numberedList => '有序列表';

  @override
  String get previewTab => '预览';

  @override
  String get editTab => '编辑';

  @override
  String get noExpandedSummaryAvailable => '暂无细纲。';

  @override
  String get analyze => '分析';

  @override
  String youreOffline(String message) {
    return '您已离线。$message';
  }

  @override
  String get download => '下载';

  @override
  String get moreActions => '更多操作';

  @override
  String get doubleTapToOpen => '双击打开。长按查看操作。';

  @override
  String get more => '更多';

  @override
  String get pressD => '按 D 键';

  @override
  String get pressEnter => '按 Enter 键';

  @override
  String get pressDelete => '按 Delete 键';

  @override
  String get exitPreview => '退出预览';

  @override
  String get saveLabel => '保存';

  @override
  String get exitZenMode => '退出禅模式';

  @override
  String get clearSearch => '清除搜索';

  @override
  String get notSignedInLabel => '未登录';

  @override
  String get stylePreviewGrid => '样式预览网格';

  @override
  String get themeOceanDepths => '海洋深渊';

  @override
  String get themeSunsetBoulevard => '日落大道';

  @override
  String get themeForestCanopy => '森林树冠';

  @override
  String get themeModernMinimalist => '现代极简';

  @override
  String get themeGoldenHour => '金色时刻';

  @override
  String get themeArcticFrost => '北极霜冻';

  @override
  String get themeDesertRose => '沙漠玫瑰';

  @override
  String get themeTechInnovation => '科技创新';

  @override
  String get themeBotanicalGarden => '植物园';

  @override
  String get themeMidnightGalaxy => '午夜星河';

  @override
  String get standardLight => '标准浅色';

  @override
  String get warmPaper => '暖色纸张';

  @override
  String get coolGrey => '冷灰';

  @override
  String get sepiaLabel => '仿古纸';

  @override
  String get standardDark => '标准深色';

  @override
  String get midnight => '午夜';

  @override
  String get darkSepia => '深色仿古';

  @override
  String get deepOcean => '深海';

  @override
  String get youreOfflineLabel => '您已离线';

  @override
  String get changesWillSync => '更改将在您重新上线时同步';

  @override
  String changesWillSyncCount(int count) {
    return '$count 项更改将在您重新上线时同步';
  }

  @override
  String get toggleSidebar => '切换侧边栏';

  @override
  String get quickSearch => '快速搜索';
}
