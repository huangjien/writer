const int _kRawLlmTimeoutSeconds = int.fromEnvironment(
  'LLM_TIMEOUT_SECONDS',
  defaultValue: 300,
);

const int kLlmTimeoutSeconds = _kRawLlmTimeoutSeconds < 60
    ? 60
    : _kRawLlmTimeoutSeconds;

const Duration kLlmTimeout = Duration(seconds: kLlmTimeoutSeconds);

// TTS & Reader
const int kTtsBaseTimeoutMs = 5000;
const int kTtsCharTimeoutMs = 200;
const int kTtsChunkMaxLen = 500;
const int kTtsMaxAttempts = 5;
const List<Duration> kTtsRetryDelays = [
  Duration(seconds: 1),
  Duration(seconds: 2),
  Duration(seconds: 4),
  Duration(seconds: 8),
  Duration(seconds: 8),
];

// UI & Interaction
const int kPreviewLenShort = 50; // Prompts
const int kPreviewLenLong = 80; // Patterns
const int kSearchDebounceMs = 6000;
const int kSearchMinLen = 2;
const Duration kDoubleTapThreshold = Duration(milliseconds: 300);

// AI Chat Health
const Duration kAiHealthCheckIntervalOk = Duration(minutes: 8);
const Duration kAiHealthCheckIntervalFail = Duration(minutes: 2);

// Chapter Editing
const Duration kEmbeddingDebounce = Duration(seconds: 2);
