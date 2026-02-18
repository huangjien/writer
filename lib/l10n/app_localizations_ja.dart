// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get newChapter => '新しい章';

  @override
  String get back => '戻る';

  @override
  String get helloWorld => 'こんにちは、世界！';

  @override
  String get home => 'ホーム';

  @override
  String get settings => '設定';

  @override
  String get appTitle => 'Writer';

  @override
  String get about => 'このアプリについて';

  @override
  String get aboutDescription =>
      '小説の読書・管理をクラウド保存、オフライン対応、音声合成再生で行います。ライブラリで小説を検索・開いてください。サインインして進捗を同期し、テーマ、タイポグラフィ、モーションの設定を調整してください。';

  @override
  String get aboutIntro =>
      'AuthorConsoleは、デバイス間で小説の企画・執筆・読書をサポートします。読者にはシンプルに、作者には強力な機能を提供し、章、要約、キャラクター、シーンを一元管理します。';

  @override
  String get aboutSecurity =>
      'クラウド保存と厳格なアクセス制御により、データは保護されます。認証ユーザーは進捗、メタデータ、テンプレートをプライバシーを保ったまま同期できます。';

  @override
  String get aboutCoach =>
      '内蔵AIコーチはスノーフレーク法でストーリーの要約を改善します。的確な質問を投げかけ、提案を提供し、準備ができれば洗練された要約をドキュメントに適用します。';

  @override
  String get aboutFeatureCreate => '• 新しい小説を作成し、章を整理。';

  @override
  String get aboutFeatureTemplates => '• キャラクターとシーンのテンプレートを使用してアイデアを起動。';

  @override
  String get aboutFeatureTracking => '• 読書の進捗を追跡し、デバイス間で再開。';

  @override
  String get aboutFeatureCoach => '• AIコーチで要約を洗練させ、改善を適用。';

  @override
  String get aboutFeaturePrompts => '• プロンプトを管理し、AI支援ワークフローを実験。';

  @override
  String get aboutUsage => '使用方法';

  @override
  String get aboutUsageList =>
      '• ライブラリ: 小説の検索・開く\n• リーダー: 章のナビゲーション、音声合成の切り替え\n• テンプレート: キャラクター・シーンテンプレートの管理\n• 設定: テーマ、タイポグラフィ、環境設定\n• サインイン: クラウド同期を有効化';

  @override
  String get version => 'バージョン';

  @override
  String get appLanguage => 'アプリ言語';

  @override
  String get english => '英語';

  @override
  String get chinese => '中国語';

  @override
  String get supabaseIntegrationInitialized => 'クラウド同期が初期化されました';

  @override
  String get configureEnvironment => 'クラウド同期を有効にするために環境変数を設定してください';

  @override
  String signedInAs(String email) {
    return '$emailとしてサインイン中';
  }

  @override
  String get guest => 'ゲスト';

  @override
  String get notSignedIn => '未サインイン';

  @override
  String get signIn => 'サインイン';

  @override
  String get continueLabel => '続行';

  @override
  String get reload => '再読み込み';

  @override
  String get signInToSync => 'デバイス間で進捗を同期するにはサインインしてください。';

  @override
  String get currentProgress => '現在の進捗';

  @override
  String get loadingProgress => '進捗を読み込み中...';

  @override
  String get recentlyRead => '最近読んだもの';

  @override
  String get noSupabase => 'このビルドではクラウド同期が有効になっていません。';

  @override
  String get errorLoadingProgress => '進捗の読み込みエラー';

  @override
  String get noProgress => '進捗が見つかりません';

  @override
  String get errorLoadingNovels => '小説の読み込みエラー';

  @override
  String get loadingNovels => '小説を読み込み中…';

  @override
  String get titleLabel => 'タイトル';

  @override
  String get authorLabel => '作者';

  @override
  String get noNovelsFound => '小説が見つかりません。';

  @override
  String get myNovels => 'マイ小説';

  @override
  String get createNovel => '小説を作成';

  @override
  String get create => '作成';

  @override
  String get errorLoadingChapters => '章の読み込みエラー';

  @override
  String get loadingChapter => '章を読み込み中…';

  @override
  String get notStarted => '未開始';

  @override
  String get unknownNovel => '不明な小説';

  @override
  String get unknownChapter => '不明な章';

  @override
  String get chapter => '章';

  @override
  String get novel => '小説';

  @override
  String get chapterTitle => '章のタイトル';

  @override
  String get scrollOffset => 'スクロール位置';

  @override
  String get ttsIndex => '音声合成インデックス';

  @override
  String get speechRate => '読み上げ速度';

  @override
  String get volume => '音量';

  @override
  String get defaultTTSVoice => 'デフォルトの音声';

  @override
  String get defaultVoiceUpdated => 'デフォルトの音声を更新しました';

  @override
  String get defaultLanguageSet => 'デフォルト言語を設定しました';

  @override
  String get searchByTitle => 'タイトルで検索…';

  @override
  String get chooseLanguage => '言語を選択';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get signInWithGoogle => 'Googleでサインイン';

  @override
  String get signInWithApple => 'Appleでサインイン';

  @override
  String get testVoice => '音声をテスト';

  @override
  String get reloadVoices => '音声を再読み込み';

  @override
  String get signOut => 'サインアウト';

  @override
  String get signedOut => 'サインアウトしました';

  @override
  String get appSettings => 'アプリ設定';

  @override
  String get supabaseSettings => 'クラウド同期設定';

  @override
  String get supabaseNotEnabled => 'クラウド同期が有効になっていません';

  @override
  String get supabaseNotEnabledDescription => 'このビルドではクラウド同期が設定されていません。';

  @override
  String get authDisabledInBuild => 'クラウド同期が設定されていません。このビルドでは認証が無効です。';

  @override
  String get fetchFromSupabase => 'クラウドから取得';

  @override
  String get fetchFromSupabaseDescription => 'クラウドから最新の小説と進捗を取得します。';

  @override
  String get confirmFetch => '取得を確認';

  @override
  String get confirmFetchDescription => 'これによりローカルデータが上書きされます。よろしいですか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get fetch => '取得';

  @override
  String get downloadChapters => '章をダウンロード';

  @override
  String get modeSupabase => 'モード: クラウド同期';

  @override
  String get modeMockData => 'モード: モックデータ';

  @override
  String continueAtChapter(String title) {
    return '「$title」から続きを';
  }

  @override
  String get error => 'エラー';

  @override
  String get ttsSettings => '音声合成設定';

  @override
  String get enableTTS => '音声合成を有効化';

  @override
  String get sentenceSummary => '文の要約';

  @override
  String get paragraphSummary => '段落の要約';

  @override
  String get pageSummary => 'ページの要約';

  @override
  String get expandedSummary => '詳細な要約';

  @override
  String get pitch => 'ピッチ';

  @override
  String get signInWithBiometrics => '生体認証でサインイン';

  @override
  String get enableBiometricLogin => '生体認証ログインを有効化';

  @override
  String get enableBiometricLoginDescription => '指紋認証または顔認証でサインインします。';

  @override
  String get biometricAuthFailed => '生体認証に失敗しました';

  @override
  String get saveCredentialsForBiometric => '生体認証用に資格情報を保存';

  @override
  String get saveCredentialsForBiometricDescription =>
      '生体認証を素早く行うために資格情報を安全に保存します';

  @override
  String get biometricTokensExpired => '生体認証トークンの有効期限が切れました';

  @override
  String get biometricNoTokens => '生体認証トークンが見つかりません';

  @override
  String get biometricTokenError => '生体認証トークンエラー';

  @override
  String get biometricTechnicalError => '生体認証技術エラー';

  @override
  String get ttsVoice => '音声合成の音声';

  @override
  String get loadingVoices => '音声を読み込み中...';

  @override
  String get selectVoice => '音声を選択';

  @override
  String get ttsLanguage => '音声合成の言語';

  @override
  String get loadingLanguages => '言語を読み込み中...';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get ttsSpeechRate => '読み上げ速度';

  @override
  String get ttsSpeechVolume => '読み上げ音量';

  @override
  String get ttsSpeechPitch => '読み上げピッチ';

  @override
  String get novelsAndProgress => '小説と進捗';

  @override
  String get novels => '小説';

  @override
  String get progress => '進捗';

  @override
  String novelsAndProgressSummary(int count, String progress) {
    return '小説: $count、進捗: $progress';
  }

  @override
  String get chapters => '章';

  @override
  String get noChaptersFound => '章が見つかりません。';

  @override
  String indexLabel(int index) {
    return 'インデックス $index';
  }

  @override
  String get enterFloatIndexHint => '小数点インデックスを入力して再配置';

  @override
  String indexOutOfRange(int min, int max) {
    return 'インデックスは$minから$maxの間である必要があります';
  }

  @override
  String get indexUnchanged => 'インデックスは変更されていません';

  @override
  String get roundingBefore => '常に前';

  @override
  String get roundingAfter => '常に後';

  @override
  String get stopTTS => '音声合成を停止';

  @override
  String get speak => '読み上げ';

  @override
  String get supabaseProgressNotSaved => 'クラウド同期が設定されていません。進捗は保存されません';

  @override
  String get progressSaved => '進捗を保存しました';

  @override
  String get errorSavingProgress => '進捗の保存エラー';

  @override
  String get autoplayBlocked => '自動再生がブロックされました。「続行」をタップして開始してください。';

  @override
  String get autoplayBlockedInline =>
      'ブラウザにより自動再生がブロックされています。「続行」をタップして読書を開始してください。';

  @override
  String get reachedLastChapter => '最後の章に到達しました';

  @override
  String ttsError(String msg) {
    return '音声合成エラー: $msg';
  }

  @override
  String get themeMode => 'テーマモード';

  @override
  String get system => 'システム';

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get colorTheme => 'カラーテーマ';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeSepia => 'セピア';

  @override
  String get themeHighContrast => 'コントラスト';

  @override
  String get themeDefault => 'デフォルト';

  @override
  String get themeEmeraldGreen => 'エメラルド';

  @override
  String get themeSolarizedTan => 'ソラライズベージュ';

  @override
  String get themeNord => 'ノルド';

  @override
  String get themeNordFrost => 'ノルドフロスト';

  @override
  String get separateDarkPalette => 'ダークパレットを分離';

  @override
  String get lightPalette => 'ライトパレット';

  @override
  String get darkPalette => 'ダークパレット';

  @override
  String get typographyPreset => 'タイポグラフィプリセット';

  @override
  String get typographyComfortable => '快適';

  @override
  String get typographyCompact => 'コンパクト';

  @override
  String get typographySerifLike => 'セリフ風';

  @override
  String get fontPack => 'フォントパック';

  @override
  String get separateTypographyPresets => 'ライト/ダークで別々のタイポグラフィを使用';

  @override
  String get typographyLight => 'ライトタイポグラフィ';

  @override
  String get typographyDark => 'ダークタイポグラフィ';

  @override
  String get readerBundles => 'リーダーテーマバンドル';

  @override
  String get tokenUsage => 'トークン使用量';

  @override
  String removedNovel(String title) {
    return '「$title」を削除しました';
  }

  @override
  String get discover => '発見';

  @override
  String get profile => 'プロフィール';

  @override
  String get libraryTitle => 'ライブラリ';

  @override
  String get undo => '元に戻す';

  @override
  String get allFilter => 'すべて';

  @override
  String get readingFilter => '読書中';

  @override
  String get completedFilter => '完了';

  @override
  String get downloadedFilter => 'ダウンロード済み';

  @override
  String get searchNovels => '小説を検索...';

  @override
  String get listView => 'リスト表示';

  @override
  String get gridView => 'グリッド表示';

  @override
  String get userManagement => 'ユーザー管理';

  @override
  String get totalThisMonth => '今月の合計';

  @override
  String get inputTokens => '入力トークン';

  @override
  String get outputTokens => '出力トークン';

  @override
  String get requests => 'リクエスト';

  @override
  String get viewHistory => '履歴を表示';

  @override
  String get noUsageThisMonth => '今月の使用量はありません';

  @override
  String get startUsingAiFeatures => 'AI機能を使い始めてトークン消費量を確認してください';

  @override
  String get errorLoadingUsage => '使用量の読み込みエラー';

  @override
  String get refresh => '更新';

  @override
  String totalRecords(int count) {
    return '総レコード数: $count';
  }

  @override
  String get total => '合計';

  @override
  String get noUsageHistory => '使用履歴なし';

  @override
  String get bundleNordCalm => 'ノルドカーム';

  @override
  String get bundleSolarizedFocus => 'ソラライズフォーカス';

  @override
  String get bundleHighContrastReadability => 'ハイコントラスト読みやすさ';

  @override
  String get customFontFamily => 'カスタムフォントファミリー';

  @override
  String get commonFonts => '共通フォント';

  @override
  String get readerFontSize => 'リーダーフォントサイズ';

  @override
  String get textScale => 'テキストスケール';

  @override
  String get readerBackgroundDepth => 'リーダー背景の深さ';

  @override
  String get depthLow => '低';

  @override
  String get depthMedium => '中';

  @override
  String get depthHigh => '高';

  @override
  String get select => '選択';

  @override
  String get clear => 'クリア';

  @override
  String get adminMode => '管理者モード';

  @override
  String get reduceMotion => '動作を減らす';

  @override
  String get reduceMotionDescription => '視覚的な快適さのためにアニメーションを最小化します';

  @override
  String get gesturesEnabled => 'タッチジェスチャーを有効化';

  @override
  String get gesturesEnabledDescription => 'リーダーでスワイプとタップジェスチャーを有効にします';

  @override
  String get readerSwipeSensitivity => 'リーダースワイプ感度';

  @override
  String get readerSwipeSensitivityDescription => '章ナビゲーションの最小スワイプ速度を調整します';

  @override
  String get remove => '削除';

  @override
  String get removedFromLibrary => 'ライブラリから削除しました';

  @override
  String get confirmDelete => '削除の確認';

  @override
  String confirmDeleteDescription(String title) {
    return 'これによりクラウドライブラリから「$title」が削除されます。よろしいですか？';
  }

  @override
  String get delete => '削除';

  @override
  String get reachedFirstChapter => '最初の章に到達しました';

  @override
  String get previousChapter => '前の章';

  @override
  String get nextChapter => '次の章';

  @override
  String get betaEvaluate => 'ベータ';

  @override
  String get betaEvaluating => 'ベータ評価送信中…';

  @override
  String get betaEvaluationReady => 'ベータ評価の準備完了';

  @override
  String get betaEvaluationFailed => 'ベータ評価に失敗しました';

  @override
  String get performanceSettings => 'パフォーマンス設定';

  @override
  String get prefetchNextChapter => '次の章をプリフェッチ';

  @override
  String get prefetchNextChapterDescription => '待ち時間を減らすために次の章を事前に読み込みます。';

  @override
  String get clearOfflineCache => 'オフラインキャッシュをクリア';

  @override
  String get offlineCacheCleared => 'オフラインキャッシュをクリアしました';

  @override
  String get edit => '編集';

  @override
  String get exitEdit => '編集を終了';

  @override
  String get enterEditMode => '編集モードに入る';

  @override
  String get exitEditMode => '編集モードを終了';

  @override
  String get chapterContent => '章の内容';

  @override
  String get save => '保存';

  @override
  String get createNextChapter => '次の章を作成';

  @override
  String get enterChapterTitle => '章のタイトルを入力';

  @override
  String get enterChapterContent => '章の内容を入力';

  @override
  String get discardChangesTitle => '変更を破棄しますか？';

  @override
  String get discardChangesMessage => '保存されていない変更があります。破棄しますか？';

  @override
  String get keepEditing => '編集を続ける';

  @override
  String get discardChanges => '変更を破棄';

  @override
  String get saveAndExit => '保存して終了';

  @override
  String get descriptionLabel => '説明';

  @override
  String get coverUrlLabel => '表紙URL';

  @override
  String get invalidCoverUrl => 'スペースを含まない有効なhttp(s) URLを入力してください。';

  @override
  String get navigation => 'ナビゲーション';

  @override
  String get chapterIndex => '章の索引';

  @override
  String get summary => '要約';

  @override
  String get characters => 'キャラクター';

  @override
  String get scenes => 'シーン';

  @override
  String get characterTemplates => 'キャラクターテンプレート';

  @override
  String get sceneTemplates => 'シーンテンプレート';

  @override
  String get updateNovel => '小説を更新';

  @override
  String get deleteNovel => '小説を削除';

  @override
  String get deleteNovelConfirmation => 'これにより小説が完全に削除されます。続行しますか？';

  @override
  String get format => '形式';

  @override
  String get aiServiceUrl => 'AIサービスURL';

  @override
  String get aiServiceUrlDescription => 'AI機能用バックエンドサービスURL';

  @override
  String get aiAssistant => 'AIアシスタント';

  @override
  String get aiChatHistory => '履歴';

  @override
  String get aiChatNewChat => '新しいチャット';

  @override
  String get aiChatNoHistory => '履歴なし';

  @override
  String get aiChatHint => 'メッセージを入力...';

  @override
  String get aiChatEmpty => 'この章や小説について何でも聞いてください';

  @override
  String get aiThinking => 'AIが考えています...';

  @override
  String get aiChatContextLabel => 'コンテキスト';

  @override
  String aiTokenCount(int count) {
    return '$countトークン';
  }

  @override
  String aiContextLoadError(String error) {
    return 'コンテキスト読み込みエラー: $error';
  }

  @override
  String aiChatContextTooLongCompressing(int tokens) {
    return 'コンテキストが長すぎます（$tokensトークン）。圧縮中...';
  }

  @override
  String aiChatContextCompressionFailedNote(String error) {
    return '[注: コンテキスト圧縮失敗: $error]';
  }

  @override
  String aiChatError(String error) {
    return 'エラー: $error';
  }

  @override
  String aiChatDeepAgentError(String error) {
    return 'ディープエージェントエラー: $error';
  }

  @override
  String get aiChatSearchFailed => '検索失敗';

  @override
  String aiChatSearchError(String error) {
    return '検索エラー: $error';
  }

  @override
  String get aiChatRagSearchResultsTitle => 'RAG検索結果';

  @override
  String aiChatRagRefinedQuery(String query) {
    return '洗練されたクエリ: 「$query」';
  }

  @override
  String get aiChatRagNoResults => '結果が見つかりませんでした。';

  @override
  String get aiChatRagUnknownType => '不明';

  @override
  String get aiServiceSignInRequired => 'AIサービスを使用するにはサインインが必要です';

  @override
  String get aiServiceFeatureNotAvailable => 'このプランでは機能をご利用いただけません';

  @override
  String aiServiceFailedToConnect(String error) {
    return 'AIサービスへの接続に失敗しました: $error';
  }

  @override
  String get aiServiceNoResponse => 'AIサービスからの応答がありません';

  @override
  String get aiDeepAgentDetailsTitle => 'ディープエージェント';

  @override
  String aiDeepAgentStop(String reason, Object rounds) {
    return '停止: $reason（ラウンド: $rounds）';
  }

  @override
  String get aiDeepAgentPlanLabel => 'プラン:';

  @override
  String get aiDeepAgentToolsLabel => 'ツール:';

  @override
  String get deepAgentSettingsTitle => 'ディープエージェント設定';

  @override
  String get deepAgentSettingsDescription =>
      'AIチャットがディープエージェントを優先するか、リフレクションとデバッグ出力を制御します。';

  @override
  String get deepAgentPreferTitle => 'ディープエージェントを優先';

  @override
  String get deepAgentPreferSubtitle =>
      '有効にすると、通常のチャットが最初に/agents/deep-agentを呼び出します。';

  @override
  String get deepAgentFallbackTitle => '利用不可の場合はQAにフォールバック';

  @override
  String get deepAgentFallbackSubtitle =>
      'deep-agentが404/501を返すときに自動的に/agents/qaを呼び出します。';

  @override
  String get deepAgentReflectionModeTitle => 'リフレクションモード';

  @override
  String get deepAgentReflectionModeSubtitle => '応答後の評価とオプションの再試行を制御します。';

  @override
  String get deepAgentReflectionModeOff => 'オフ';

  @override
  String get deepAgentReflectionModeOnFailure => '失敗時';

  @override
  String get deepAgentReflectionModeAlways => '常に';

  @override
  String get deepAgentShowDetailsTitle => '実行の詳細を表示';

  @override
  String get deepAgentShowDetailsSubtitle => 'プランとツール呼び出しログを/deep出力に含めます。';

  @override
  String get deepAgentMaxPlanSteps => '最大プランステップ数';

  @override
  String get deepAgentMaxToolRounds => '最大ツールラウンド数';

  @override
  String get send => '送信';

  @override
  String get resetToDefault => 'デフォルトにリセット';

  @override
  String get invalidUrl => 'スペースを含まない有効なhttp(s) URLを入力してください。';

  @override
  String get urlTooLong => 'URLは2048文字以下である必要があります。';

  @override
  String get urlContainsSpaces => 'URLにスペースを含めることはできません。';

  @override
  String get urlInvalidScheme => 'URLはhttp://またはhttps://で始まる必要があります。';

  @override
  String get saved => '保存しました';

  @override
  String get required => '必須';

  @override
  String get summariesLabel => '要約';

  @override
  String get synopsesLabel => '概要';

  @override
  String get locationLabel => '場所';

  @override
  String languageLabel(String code) {
    return '言語: $code';
  }

  @override
  String get publicLabel => '公開';

  @override
  String get privateLabel => '非公開';

  @override
  String chaptersCount(int count) {
    return '章数: $count';
  }

  @override
  String avgWordsPerChapter(int avg) {
    return '平均字数/章: $avg';
  }

  @override
  String chapterLabel(int idx) {
    return '第$idx章';
  }

  @override
  String chapterWithTitle(int idx, String title) {
    return '第$idx章: $title';
  }

  @override
  String get refreshTooltip => '更新';

  @override
  String get untitled => '無題';

  @override
  String get newLabel => '新規';

  @override
  String get deleteSceneTitle => 'シーンを削除';

  @override
  String get deleteCharacterTitle => 'キャラクターを削除';

  @override
  String get deleteTemplateTitle => 'テンプレートを削除';

  @override
  String get confirmDeleteGeneric => 'この項目を削除してもよろしいですか？';

  @override
  String get novelMetadata => '小説メタデータ';

  @override
  String get contributorEmailLabel => '協力者メールアドレス';

  @override
  String get contributorEmailHint => '協力者として追加するユーザーメールアドレスを入力';

  @override
  String get addContributor => '協力者を追加';

  @override
  String get contributorAdded => '協力者を追加しました';

  @override
  String get pdf => 'PDF';

  @override
  String get generatingPdf => 'PDF生成中…';

  @override
  String get pdfFailed => 'PDF生成に失敗しました';

  @override
  String get tableOfContents => '目次';

  @override
  String byAuthor(String name) {
    return '作者: $name';
  }

  @override
  String pageOfTotal(int page, int total) {
    return '$totalページ中$pageページ目';
  }

  @override
  String get close => '閉じる';

  @override
  String get openLink => 'リンクを開く';

  @override
  String get invalidLink => '無効なリンク';

  @override
  String get unableToOpenLink => 'リンクを開けません';

  @override
  String get copy => 'コピー';

  @override
  String get copiedToClipboard => 'クリップボードにコピーしました';

  @override
  String showingCachedPublicData(String msg) {
    return '$msg — キャッシュ/公開データを表示中';
  }

  @override
  String get menu => 'メニュー';

  @override
  String get metaLabel => 'メタ';

  @override
  String get aiServiceUnavailable => 'AIサービス利用不可';

  @override
  String get aiConfigurations => 'AI設定';

  @override
  String get modelLabel => 'モデル';

  @override
  String get temperatureLabel => '温度';

  @override
  String get saveFailed => '保存失敗';

  @override
  String get saveMyVersion => 'マイバージョンを保存';

  @override
  String get resetToPublic => '公開にリセット';

  @override
  String get resetFailed => 'リセット失敗';

  @override
  String get prompts => 'プロンプト';

  @override
  String get patterns => 'パターン';

  @override
  String get storyLines => 'ストーリーライン';

  @override
  String get hotTopics => '話題のトレンド';

  @override
  String get hotTopicsSelectPlatform => 'プラットフォームを選択';

  @override
  String get hotTopicsAllPlatforms => 'すべてのプラットフォーム';

  @override
  String get hotTopicsPlatformWeibo => '微博';

  @override
  String get hotTopicsPlatformZhihu => '知乎';

  @override
  String get hotTopicsPlatformDouyin => '抖音';

  @override
  String get hotTopicsPlatformDescWeibo => '中国のミクロブログ';

  @override
  String get hotTopicsPlatformDescZhihu => 'Q&Aプラットフォーム';

  @override
  String get hotTopicsPlatformDescDouyin => '動画共有';

  @override
  String get tools => 'ツール';

  @override
  String get preview => 'プレビュー';

  @override
  String get actions => 'アクション';

  @override
  String get searchLabel => '検索';

  @override
  String get allLabel => 'すべて';

  @override
  String get filterByLocked => 'ロック済みでフィルター';

  @override
  String get lockedOnly => 'ロック済みのみ';

  @override
  String get unlockedOnly => 'ロック解除のみ';

  @override
  String get promptKey => 'プロンプトキー';

  @override
  String get language => '言語';

  @override
  String get filterByKey => 'キーでフィルター';

  @override
  String get viewPublic => '公開を表示';

  @override
  String get groupNone => 'なし';

  @override
  String get groupLanguage => '言語';

  @override
  String get groupKey => 'キー';

  @override
  String get newPrompt => '新しいプロンプト';

  @override
  String get newPattern => '新しいパターン';

  @override
  String get newStoryLine => '新しいストーリーライン';

  @override
  String get editPrompt => 'プロンプトを編集';

  @override
  String get editPattern => 'パターンを編集';

  @override
  String get editStoryLine => 'ストーリーラインを編集';

  @override
  String deletedWithTitle(String title) {
    return '削除済み: $title';
  }

  @override
  String deleteFailedWithTitle(String title) {
    return '削除失敗: $title';
  }

  @override
  String deleteErrorWithMessage(String error) {
    return '削除エラー: $error';
  }

  @override
  String get makePublic => '公開にする';

  @override
  String get noPrompts => 'プロンプトが見つかりません';

  @override
  String get noPatterns => 'パターンがありません';

  @override
  String get noStoryLines => 'ストーリーラインがありません';

  @override
  String conversionFailed(String error) {
    return '変換失敗: $error';
  }

  @override
  String get failedToAnalyze => '分析失敗';

  @override
  String get aiCoachAnalyzing => 'AIコーチが分析しています...';

  @override
  String get retry => '再試行';

  @override
  String get startAiCoaching => 'AIコーチングを開始';

  @override
  String get refinementComplete => '洗練完了！';

  @override
  String get coachQuestion => 'コーチの質問';

  @override
  String get summaryLooksGood => 'よくできました！要約はしっかりしています。';

  @override
  String get howToImprove => 'どう改善できますか？';

  @override
  String get suggestionsLabel => '提案:';

  @override
  String get reviewSuggestionsHint => '提案を確認するか、回答を入力...';

  @override
  String get aiGenerationComplete => 'AI生成完了';

  @override
  String get clickRegenerateForNew => '「再生成」をクリックして新しい提案を取得';

  @override
  String get regenerate => '再生成';

  @override
  String get imSatisfied => '満足しました';

  @override
  String get templateLabel => 'テンプレート';

  @override
  String get exampleCharacterName => '例: ハリー・ポッター';

  @override
  String get aiConvert => 'AI変換';

  @override
  String get toggleAiCoach => 'AIコーチの切り替え';

  @override
  String retrieveFailed(String error) {
    return '取得失敗: $error';
  }

  @override
  String get confirm => '確認';

  @override
  String get lastRead => '最終読書';

  @override
  String get noRecentChapters => '最近の章はありません';

  @override
  String get failedToLoadConfig => '設定の読み込み失敗';

  @override
  String makePublicPromptConfirm(String promptKey, String language) {
    return '「$promptKey」($language)を公開にしますか？';
  }

  @override
  String get content => 'コンテンツ';

  @override
  String get invalidKey => '無効なキー';

  @override
  String get invalidLanguage => '無効な言語';

  @override
  String get invalidInput => '無効な入力';

  @override
  String charsCount(int count) {
    return '文字数: $count';
  }

  @override
  String deletePromptConfirm(String promptKey, String language) {
    return 'プロンプト「$promptKey」($language)を削除しますか？';
  }

  @override
  String get profileRetrieved => 'プロフィールを取得しました';

  @override
  String get noProfileFound => 'プロフィールが見つかりません';

  @override
  String get templateName => 'テンプレート名';

  @override
  String get retrieveProfile => 'プロフィールを取得';

  @override
  String get previewLabel => 'プレビュー';

  @override
  String get markdownHint => 'Markdownで説明を入力...';

  @override
  String get templateNameExists => 'テンプレート名は既に存在します';

  @override
  String get aiServiceUrlHint => 'AIサービスURLを入力（http/https）';

  @override
  String get urlLabel => 'URL';

  @override
  String get systemFont => 'システムフォント';

  @override
  String get fontInter => 'Inter';

  @override
  String get fontMerriweather => 'Merriweather';

  @override
  String get editPatternTitle => 'パターンを編集';

  @override
  String get newPatternTitle => '新しいパターン';

  @override
  String get editStoryLineTitle => 'ストーリーラインを編集';

  @override
  String get newStoryLineTitle => '新しいストーリーライン';

  @override
  String get usageRulesLabel => '使用ルール（JSON）';

  @override
  String get publicPatternLabel => '公開パターン';

  @override
  String get publicStoryLineLabel => '公開ストーリーライン';

  @override
  String get lockedLabel => 'ロック中';

  @override
  String get unlockedLabel => 'ロック解除';

  @override
  String get aiButton => 'AI';

  @override
  String get invalidJson => '無効なJSON';

  @override
  String get deleteFailed => '削除失敗';

  @override
  String get lockPattern => 'パターンをロック';

  @override
  String get errorUnauthorized => '認証されていません';

  @override
  String get errorForbidden => '禁止されています';

  @override
  String get errorSessionExpired => 'セッションの有効期限切れ';

  @override
  String get errorValidation => '検証エラー';

  @override
  String get errorInvalidInput => '無効な入力';

  @override
  String get errorDuplicateTitle => '重複するタイトル';

  @override
  String get errorNotFound => '見つかりません';

  @override
  String get errorServiceUnavailable => 'サービス利用不可';

  @override
  String get errorAiNotConfigured => 'AIサービスが設定されていません';

  @override
  String get errorSupabaseError => 'クラウドサービスエラー';

  @override
  String get errorRateLimited => 'リクエストが多すぎます';

  @override
  String get errorInternal => '内部サーバーエラー';

  @override
  String get errorBadGateway => '不正なゲートウェイ';

  @override
  String get errorGatewayTimeout => 'ゲートウェイタイムアウト';

  @override
  String get loginFailed => 'ログイン失敗';

  @override
  String get invalidResponseFromServer => 'サーバーからの無効な応答';

  @override
  String get signUp => 'サインアップ';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get signupFailed => 'サインアップ失敗';

  @override
  String get accountCreatedCheckEmail => 'アカウントを作成しました！確認のためメールをご確認ください。';

  @override
  String get backToSignIn => 'サインインに戻る';

  @override
  String get createAccount => 'アカウントを作成';

  @override
  String get alreadyHaveAccountSignIn => '既にアカウントをお持ちですか？サインイン';

  @override
  String get requestFailed => 'リクエスト失敗';

  @override
  String get ifAccountExistsResetLinkSent =>
      'アカウントが存在する場合、パスワードリセットリンクがメールに送信されます。';

  @override
  String get enterEmailForResetLink => 'パスワードリセットリンクを受け取るためのメールアドレスを入力してください。';

  @override
  String get sendResetLink => 'リセットリンクを送信';

  @override
  String get passwordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get sessionInvalidLoginAgain =>
      'セッションが無効です。再度ログインするか、リセットリンクを再び使用してください。';

  @override
  String get updateFailed => '更新失敗';

  @override
  String get passwordUpdatedSuccessfully => 'パスワードを正常に更新しました！';

  @override
  String get resetPassword => 'パスワードをリセット';

  @override
  String get newPassword => '新しいパスワード';

  @override
  String get confirmPassword => 'パスワードを確認';

  @override
  String get updatePassword => 'パスワードを更新';

  @override
  String get noActiveSessionFound => 'アクティブなセッションが見つかりません。再度ログインしてください。';

  @override
  String get authenticationFailedSignInAgain => '認証に失敗しました。再度サインインしてください。';

  @override
  String get accessDeniedNoAdminPrivileges => 'アクセス拒否。管理者権限がありません。';

  @override
  String failedToLoadUsers(int statusCode, String errorBody) {
    return 'ユーザー読み込み失敗: $statusCode - $errorBody';
  }

  @override
  String get smartSearchRequiresSignIn => 'スマート検索を使用するにはサインインしてください';

  @override
  String get smartSearch => 'スマート検索';

  @override
  String get failedToPersistTemplate => 'テンプレートの保存失敗';

  @override
  String userIdCreated(String id, String createdAt) {
    return 'ユーザー$idが$createdAtに作成されました';
  }

  @override
  String get tryAdjustingSearchCreateNovel => '検索を調整するか、新しい小説を作成してください';

  @override
  String get sessionExpired => 'セッションの有効期限切れ';

  @override
  String get errorLoadingUsers => 'ユーザー読み込みエラー';

  @override
  String get unknownError => '不明なエラー';

  @override
  String get goBack => '戻る';

  @override
  String get unableToLoadAsset => 'アセットを読み込めません';

  @override
  String get youDontHavePermission => 'この操作を実行する権限がありません。';

  @override
  String get continueReading => '読書を続ける';

  @override
  String get removeFromLibrary => 'ライブラリから削除';

  @override
  String get createFirstNovelSubtitle => '最初の小説を作成して始めましょう。';

  @override
  String get navigationError => 'ナビゲーションエラー';

  @override
  String get pdfStepPreparing => '章を準備中';

  @override
  String get pdfStepGenerating => 'PDF生成中';

  @override
  String get pdfStepSharing => '共有中';

  @override
  String get tipIntention => 'ヒント: 各シーンに明確な意図を1つ書きます。';

  @override
  String get tipVerbs => 'ヒント: 強力な動詞で文を生き生きとさせます。';

  @override
  String get tipStuck => 'ヒント: 行き詰まったら、最後の段落を書き直してください。';

  @override
  String get tipDialogue => 'ヒント: 会話は描写よりも早くキャラクターを表現します。';

  @override
  String get errorNovelNotFound => '小説が見つかりません';

  @override
  String get noSentenceSummary => '文の要約がありません。';

  @override
  String get noParagraphSummary => '段落の要約がありません。';

  @override
  String get noPageSummary => 'ページの要約がありません。';

  @override
  String get noExpandedSummary => '詳細な要約がありません。';

  @override
  String get aiSentenceSummaryTooltip => 'AI文の要約';

  @override
  String get aiParagraphSummaryTooltip => 'AI段落の要約';

  @override
  String get aiPageSummaryTooltip => 'AIページの要約';

  @override
  String get keyboardShortcuts => 'キーボードショートカット';

  @override
  String get shortcutSpace => 'スペース: 再生 / 停止';

  @override
  String get shortcutArrows => '← / →: 前 / 次';

  @override
  String get shortcutRate => 'Ctrl/⌘ + R: 読み上げ速度';

  @override
  String get shortcutVoice => 'Ctrl/⌘ + V: 音声';

  @override
  String get shortcutHelp => 'Ctrl/⌘ + /: ショートカットを表示';

  @override
  String get shortcutEsc => 'Esc: 閉じる';

  @override
  String get styles => 'スタイル';

  @override
  String get noVoicesAvailable => '利用可能な音声がありません';

  @override
  String get comingSoon => '近日公開';

  @override
  String get selectNovelFirst => '最初に小説を選択してください';

  @override
  String get adminLogs => '管理者ログ';

  @override
  String get viewAndFilterBackendLogs => 'バックエンドログを表示・フィルター';

  @override
  String get styleGlassmorphism => 'グラスモーフィズム';

  @override
  String get styleLiquidGlass => 'リキッドグラス';

  @override
  String get styleNeumorphism => 'ニューモーフィズム';

  @override
  String get styleClaymorphism => 'クレイモーフィズム';

  @override
  String get styleMinimalism => 'ミニマリズム';

  @override
  String get styleBrutalism => 'ブルータリズム';

  @override
  String get styleSkeuomorphism => 'スキューモーフィズム';

  @override
  String get styleBentoGrid => 'ベントグリッド';

  @override
  String get styleResponsive => 'レスポンシブ';

  @override
  String get styleFlatDesign => 'フラットデザイン';

  @override
  String get scrollToBottom => '下にスクロール';

  @override
  String get scrollToTop => '上にスクロール';

  @override
  String get numberOfLines => '行数';

  @override
  String get lines => '行';

  @override
  String get load => '読み込み';

  @override
  String get noLogsAvailable => '利用可能なログがありません。';

  @override
  String get failedToLoadLogs => 'ログの読み込み失敗';

  @override
  String wordCount(int count) {
    return '文字数: $count';
  }

  @override
  String characterCount(int count) {
    return '文字数: $count';
  }

  @override
  String get startWriting => '執筆を開始...';

  @override
  String failedToLoadChapter(String error) {
    return '章の読み込み失敗: $error';
  }

  @override
  String get saving => '保存中…';

  @override
  String get wordCountLabel => '文字数';

  @override
  String get characterCountLabel => '文字数';

  @override
  String get discard => '破棄';

  @override
  String get saveShortcut => '保存';

  @override
  String get previewShortcut => 'プレビュー';

  @override
  String get boldShortcut => '太字';

  @override
  String get italicShortcut => '斜体';

  @override
  String get underlineShortcut => '下線';

  @override
  String get headingShortcut => '見出し';

  @override
  String get insertLinkShortcut => 'リンクを挿入';

  @override
  String get shortcutsHelpShortcut => 'ショートカットヘルプ';

  @override
  String get closeShortcut => '閉じる';

  @override
  String get designSystemStyleGuide => 'デザインシステムスタイルガイド';

  @override
  String get headlineLarge => '大見出し';

  @override
  String get headlineMedium => '中見出し';

  @override
  String get titleLarge => '大タイトル';

  @override
  String get bodyLarge => '大本文';

  @override
  String get bodyMedium => '中本文';

  @override
  String get primaryButton => 'プライマリボタン';

  @override
  String get disabled => '無効';

  @override
  String checkboxState(bool value) {
    return 'チェックボックスの状態: $value';
  }

  @override
  String get option1 => 'オプション1';

  @override
  String get option2 => 'オプション2';

  @override
  String switchState(bool value) {
    return 'スイッチの状態: $value';
  }

  @override
  String sliderValue(String value) {
    return '値: $value';
  }

  @override
  String get enterTextHere => 'ここにテキストを入力...';

  @override
  String get selectAnOption => 'オプションを選択';

  @override
  String get optionA => 'オプションA';

  @override
  String get optionB => 'オプションB';

  @override
  String get optionC => 'オプションC';

  @override
  String get contrastIssuesDetected => 'コントラストの問題を検出';

  @override
  String foundContrastIssues(int count) {
    return '可読性に影響する$count個のコントラスト問題が見つかりました。';
  }

  @override
  String get allGood => 'すべて良好！';

  @override
  String get allGoodContrast => 'すべてのテキスト要素がWCAG 2.1 AAコントラスト標準を満たしています。';

  @override
  String get ignore => '無視';

  @override
  String get applyBestFix => '最適な修正を適用';

  @override
  String get moreMenuComingSoon => 'その他のメニューは近日公開';

  @override
  String get styleGuide => 'スタイルガイド';

  @override
  String get themeFactoryNotDefined =>
      'テーマファクトリーがテーマを定義していないため、デフォルトテーマを使用します。';

  @override
  String progressPercentage(int percent) {
    return '$percent%';
  }

  @override
  String get review => 'レビュー';

  @override
  String get wordsLabel => '文字';

  @override
  String get charsLabel => '文字';

  @override
  String get readLabel => '読書';

  @override
  String get streakLabel => '連続記録';

  @override
  String get pause => '一時停止';

  @override
  String get start => '開始';

  @override
  String get editMode => '編集モード';

  @override
  String get previewMode => 'プレビューモード';

  @override
  String get quote => '引用';

  @override
  String get inlineCode => 'インラインコード';

  @override
  String get bulletedList => '箇条書きリスト';

  @override
  String get numberedList => '番号付きリスト';

  @override
  String get previewTab => 'プレビュー';

  @override
  String get editTab => '編集';

  @override
  String get noExpandedSummaryAvailable => '詳細な要約がありません。';

  @override
  String get analyze => '分析';

  @override
  String youreOffline(String message) {
    return 'オフラインです。$message';
  }

  @override
  String get download => 'ダウンロード';

  @override
  String get moreActions => 'その他のアクション';

  @override
  String get doubleTapToOpen => 'ダブルタップで開きます。長押しでアクションを表示。';

  @override
  String get more => 'その他';

  @override
  String get pressD => 'Dを押す';

  @override
  String get pressEnter => 'Enterを押す';

  @override
  String get pressDelete => 'Deleteを押す';

  @override
  String get exitPreview => 'プレビューを終了';

  @override
  String get saveLabel => '保存';

  @override
  String get exitZenMode => '禅モードを終了';

  @override
  String get clearSearch => '検索をクリア';

  @override
  String get notSignedInLabel => '未サインイン';

  @override
  String get stylePreviewGrid => 'スタイルプレビューグリッド';

  @override
  String get themeOceanDepths => 'オーシャンの深さ';

  @override
  String get themeSunsetBoulevard => 'サンセット大通り';

  @override
  String get themeForestCanopy => '森の樹冠';

  @override
  String get themeModernMinimalist => 'モダンミニマリスト';

  @override
  String get themeGoldenHour => 'ゴールデンアワー';

  @override
  String get themeArcticFrost => '北極の霜';

  @override
  String get themeDesertRose => '砂漠のバラ';

  @override
  String get themeTechInnovation => 'テクノロジーイノベーション';

  @override
  String get themeBotanicalGarden => '植物園';

  @override
  String get themeMidnightGalaxy => '真夜中の銀河';

  @override
  String get standardLight => '標準ライト';

  @override
  String get warmPaper => 'ウォームペーパー';

  @override
  String get coolGrey => 'クールグレー';

  @override
  String get sepiaLabel => 'セピア';

  @override
  String get standardDark => '標準ダーク';

  @override
  String get midnight => '真夜中';

  @override
  String get darkSepia => 'ダークセピア';

  @override
  String get deepOcean => '深い海';

  @override
  String get youreOfflineLabel => 'オフラインです';

  @override
  String get changesWillSync => 'オンラインに戻ったときに変更が同期されます';

  @override
  String changesWillSyncCount(int count) {
    return 'オンラインに戻ったときに$count件の変更が同期されます';
  }

  @override
  String get toggleSidebar => 'サイドバーを切り替え';

  @override
  String get quickSearch => 'クイック検索';
}
