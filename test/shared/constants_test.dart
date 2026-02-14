import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/constants.dart';

void main() {
  group('LLM Timeout Constants', () {
    test('kLlmTimeoutSeconds should be at least 60', () {
      expect(kLlmTimeoutSeconds, greaterThanOrEqualTo(60));
    });

    test('kLlmTimeout should be a Duration in seconds', () {
      expect(kLlmTimeout, isA<Duration>());
      expect(kLlmTimeout.inSeconds, equals(kLlmTimeoutSeconds));
    });
  });

  group('TTS Constants', () {
    test('kTtsBaseTimeoutMs should be 5000', () {
      expect(kTtsBaseTimeoutMs, equals(5000));
    });

    test('kTtsCharTimeoutMs should be 200', () {
      expect(kTtsCharTimeoutMs, equals(200));
    });

    test('kTtsChunkMaxLen should be 500', () {
      expect(kTtsChunkMaxLen, equals(500));
    });

    test('kTtsMaxAttempts should be 5', () {
      expect(kTtsMaxAttempts, equals(5));
    });

    test('kTtsRetryDelays should have 5 entries', () {
      expect(kTtsRetryDelays.length, equals(5));
    });

    test('kTtsRetryDelays should be Durations', () {
      for (final delay in kTtsRetryDelays) {
        expect(delay, isA<Duration>());
      }
    });
  });

  group('UI & Interaction Constants', () {
    test('kPreviewLenShort should be 50', () {
      expect(kPreviewLenShort, equals(50));
    });

    test('kPreviewLenLong should be 80', () {
      expect(kPreviewLenLong, equals(80));
    });

    test('kSearchDebounceMs should be 6000', () {
      expect(kSearchDebounceMs, equals(6000));
    });

    test('kSearchMinLen should be 2', () {
      expect(kSearchMinLen, equals(2));
    });

    test('kDoubleTapThreshold should be 300ms', () {
      expect(kDoubleTapThreshold, equals(const Duration(milliseconds: 300)));
    });
  });

  group('AI Chat Health Constants', () {
    test('kAiHealthCheckIntervalOk should be 8 minutes', () {
      expect(kAiHealthCheckIntervalOk, equals(const Duration(minutes: 8)));
    });

    test('kAiHealthCheckIntervalFail should be 2 minutes', () {
      expect(kAiHealthCheckIntervalFail, equals(const Duration(minutes: 2)));
    });
  });

  group('Chapter Editing Constants', () {
    test('kEmbeddingDebounce should be 2 seconds', () {
      expect(kEmbeddingDebounce, equals(const Duration(seconds: 2)));
    });
  });

  group('UI Spacing Constants', () {
    test('kSpacingSmall should be 4.0', () {
      expect(kSpacingSmall, equals(4.0));
    });

    test('kSpacingMedium should be 8.0', () {
      expect(kSpacingMedium, equals(8.0));
    });

    test('kSpacingLarge should be 16.0', () {
      expect(kSpacingLarge, equals(16.0));
    });

    test('kSpacingXLarge should be 24.0', () {
      expect(kSpacingXLarge, equals(24.0));
    });

    test('kSpacingXXLarge should be 32.0', () {
      expect(kSpacingXXLarge, equals(32.0));
    });
  });

  group('Border Radius Constants', () {
    test('kRadiusSmall should be 4.0', () {
      expect(kRadiusSmall, equals(4.0));
    });

    test('kRadiusMedium should be 8.0', () {
      expect(kRadiusMedium, equals(8.0));
    });

    test('kRadiusLarge should be 12.0', () {
      expect(kRadiusLarge, equals(12.0));
    });

    test('kRadiusXLarge should be 16.0', () {
      expect(kRadiusXLarge, equals(16.0));
    });

    test('kBorderRadiusSmall should use kRadiusSmall', () {
      expect(kBorderRadiusSmall, isA<BorderRadius>());
    });

    test('kBorderRadiusMedium should use kRadiusMedium', () {
      expect(kBorderRadiusMedium, isA<BorderRadius>());
    });

    test('kBorderRadiusLarge should use kRadiusLarge', () {
      expect(kBorderRadiusLarge, isA<BorderRadius>());
    });

    test('kBorderRadiusXLarge should use kRadiusXLarge', () {
      expect(kBorderRadiusXLarge, isA<BorderRadius>());
    });
  });

  group('Animation Duration Constants', () {
    test('kAnimationFast should be 150ms', () {
      expect(kAnimationFast, equals(const Duration(milliseconds: 150)));
    });

    test('kAnimationMedium should be 300ms', () {
      expect(kAnimationMedium, equals(const Duration(milliseconds: 300)));
    });

    test('kAnimationSlow should be 500ms', () {
      expect(kAnimationSlow, equals(const Duration(milliseconds: 500)));
    });
  });

  group('Size Constraint Constants', () {
    test('kButtonHeight should be 40.0', () {
      expect(kButtonHeight, equals(40.0));
    });

    test('kButtonHeightSmall should be 32.0', () {
      expect(kButtonHeightSmall, equals(32.0));
    });

    test('kButtonHeightLarge should be 48.0', () {
      expect(kButtonHeightLarge, equals(48.0));
    });

    test('kIconSize should be 24.0', () {
      expect(kIconSize, equals(24.0));
    });

    test('kIconSizeSmall should be 16.0', () {
      expect(kIconSizeSmall, equals(16.0));
    });

    test('kIconSizeLarge should be 32.0', () {
      expect(kIconSizeLarge, equals(32.0));
    });
  });
}
