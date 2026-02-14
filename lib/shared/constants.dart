import 'package:flutter/material.dart';

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

// UI Spacing
const double kSpacingSmall = 4.0;
const double kSpacingMedium = 8.0;
const double kSpacingLarge = 16.0;
const double kSpacingXLarge = 24.0;
const double kSpacingXXLarge = 32.0;

// Border Radius
const double kRadiusSmall = 4.0;
const double kRadiusMedium = 8.0;
const double kRadiusLarge = 12.0;
const double kRadiusXLarge = 16.0;

final BorderRadius kBorderRadiusSmall = const BorderRadius.all(
  Radius.circular(kRadiusSmall),
);
final BorderRadius kBorderRadiusMedium = const BorderRadius.all(
  Radius.circular(kRadiusMedium),
);
final BorderRadius kBorderRadiusLarge = const BorderRadius.all(
  Radius.circular(kRadiusLarge),
);
final BorderRadius kBorderRadiusXLarge = const BorderRadius.all(
  Radius.circular(kRadiusXLarge),
);

// Animation Durations
final Duration kAnimationFast = const Duration(milliseconds: 150);
final Duration kAnimationMedium = const Duration(milliseconds: 300);
final Duration kAnimationSlow = const Duration(milliseconds: 500);

// Size Constraints
const double kButtonHeight = 40.0;
const double kButtonHeightSmall = 32.0;
const double kButtonHeightLarge = 48.0;
const double kIconSize = 24.0;
const double kIconSizeSmall = 16.0;
const double kIconSizeLarge = 32.0;
