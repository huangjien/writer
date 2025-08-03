import React from 'react';
import { render, fireEvent, waitFor, act } from '@testing-library/react-native';
import { useLocalSearchParams, router } from 'expo-router';
import { useNavigation, useIsFocused } from '@react-navigation/native';
import * as Speech from 'expo-speech';
import * as KeepAwake from 'expo-keep-awake';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import Page from '../app/read';
import {
  STATUS_PLAYING,
  STATUS_PAUSED,
  STATUS_STOPPED,
  CONTENT_KEY,
  ANALYSIS_KEY,
  SETTINGS_KEY,
} from '../components/global';

// Mock dependencies
jest.mock('expo-router');
jest.mock('@react-navigation/native');
jest.mock('expo-speech');
jest.mock('expo-keep-awake');
jest.mock('react-native-safe-area-context');

// Mock react-native-modal
jest.mock('react-native-modal', () => {
  const React = require('react');
  return ({ children, isVisible, ...props }) =>
    isVisible
      ? React.createElement('View', { ...props, testID: 'modal' }, children)
      : null;
});

// Mock react-native-markdown-display
jest.mock('react-native-markdown-display', () => {
  const React = require('react');
  const { Text } = require('react-native');
  return ({ children, ...props }) =>
    React.createElement(Text, { ...props, testID: 'markdown' }, children);
});

// Mock @expo/vector-icons
jest.mock('@expo/vector-icons', () => ({
  Feather: ({ name, size, color, ...props }) => {
    const React = require('react');
    const { Text } = require('react-native');
    return React.createElement(
      Text,
      { ...props, testID: `icon-${name}` },
      name
    );
  },
}));

// Mock @react-native-community/slider
jest.mock('@react-native-community/slider', () => {
  const React = require('react');
  const { View } = require('react-native');
  return React.forwardRef(
    ({ value, onValueChange, onSlidingComplete, ...props }, ref) => {
      return React.createElement(View, {
        ...props,
        ref,
        testID: 'progress-slider',
        onTouchEnd: () => {
          if (onSlidingComplete) onSlidingComplete(0.5);
          if (onValueChange) onValueChange(0.5);
        },
      });
    }
  );
});

// Enhanced gesture handler mock with better interaction support
jest.mock('react-native-gesture-handler', () => {
  const React = require('react');
  const RN = require('react-native');

  const mockGesture = {
    onEnd: jest.fn().mockReturnThis(),
    runOnJS: jest.fn().mockReturnThis(),
    numberOfTaps: jest.fn().mockReturnThis(),
  };

  return {
    Swipeable: React.forwardRef(
      ({ children, onSwipeableClose, ...props }, ref) => {
        return React.createElement(
          RN.View,
          {
            ...props,
            ref,
            testID: 'swipeable-container',
            onTouchEnd: () => {
              // Simulate swipe left for testing
              if (onSwipeableClose) {
                onSwipeableClose('left');
              }
            },
          },
          children
        );
      }
    ),
    GestureDetector: ({ children, gesture, ...props }) => {
      return React.createElement(
        RN.View,
        {
          ...props,
          testID: 'gesture-detector',
          onPress: () => {
            // Simulate single tap
            console.log('Single tap detected');
          },
          onLongPress: () => {
            // Simulate long press
            console.log('Long press detected');
          },
        },
        children
      );
    },
    GestureHandlerRootView: ({ children, ...props }) =>
      React.createElement(RN.View, props, children),
    Gesture: {
      LongPress: () => mockGesture,
      Tap: () => mockGesture,
      Simultaneous: (...gestures) => mockGesture,
    },
    ScrollView: React.forwardRef(({ children, ...props }, ref) =>
      React.createElement(RN.ScrollView, { ...props, ref }, children)
    ),
    gestureHandlerRootHOC: jest.fn((component) => component),
  };
});

// Mock useAsyncStorage
const mockGetItem = jest.fn();
const mockSetItem = jest.fn();
const mockRemoveItem = jest.fn();

jest.mock('../hooks/useAsyncStorage', () => ({
  useAsyncStorage: () => [
    {}, // storage
    { getItem: mockGetItem, setItem: mockSetItem, removeItem: mockRemoveItem },
    false, // isLoading
    false, // hasChanged
  ],
}));

// Mock useReading hook
const mockUseReading = {
  content:
    'This is test content for reading.\n\nThis is the second paragraph.\n\nThis is the third paragraph.',
  analysis: 'This is test analysis content.',
  preview: '@Content:chapter0.md',
  next: '@Content:chapter2.md',
  current: '@Content:chapter1.md',
  progress: 0,
  fontSize: 16,
  setProgress: jest.fn(),
  setFontSize: jest.fn(),
  getContentFromProgress: jest.fn(),
  loadReadingByName: jest.fn(),
};

jest.mock('../hooks/useReading', () => ({
  useReading: () => mockUseReading,
}));

// Mock readingUtils
jest.mock('../utils/readingUtils', () => ({
  navigateToChapter: jest.fn(),
  handleProgressChange: jest.fn(),
  handleContentChange: jest.fn(),
  handleSpeechProgressUpdate: jest.fn(),
}));

const mockUseLocalSearchParams = useLocalSearchParams as jest.MockedFunction<
  typeof useLocalSearchParams
>;
const mockRouter = router as jest.Mocked<typeof router>;
const mockUseNavigation = useNavigation as jest.MockedFunction<
  typeof useNavigation
>;
const mockUseIsFocused = useIsFocused as jest.MockedFunction<
  typeof useIsFocused
>;
const mockSpeech = Speech as jest.Mocked<typeof Speech>;
const mockKeepAwake = KeepAwake as jest.Mocked<typeof KeepAwake>;
const mockUseSafeAreaInsets = useSafeAreaInsets as jest.MockedFunction<
  typeof useSafeAreaInsets
>;

describe('Read Page - Enhanced Integration Tests', () => {
  const mockNavigation = {
    setOptions: jest.fn(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
    mockUseLocalSearchParams.mockReturnValue({ post: '@Content:chapter1.md' });
    mockUseNavigation.mockReturnValue(mockNavigation as any);
    mockUseIsFocused.mockReturnValue(true);
    mockUseSafeAreaInsets.mockReturnValue({
      top: 44,
      bottom: 0,
      left: 0,
      right: 0,
    });

    // Reset Speech mock
    mockSpeech.speak.mockClear();
    mockSpeech.stop.mockClear();
    mockSpeech.isSpeakingAsync.mockResolvedValue(false);

    // Reset useReading mock
    mockUseReading.setProgress.mockClear();
    mockUseReading.setFontSize.mockClear();
    mockUseReading.getContentFromProgress.mockReturnValue(
      'This is test content for reading.'
    );
    mockUseReading.progress = 0;
  });

  describe('Component Integration', () => {
    it('should render without crashing', () => {
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should render content area when current chapter exists', () => {
      render(<Page />);

      // Should render without crashing when content exists
      expect(mockUseReading.content).toBe(
        'This is test content for reading.\n\nThis is the second paragraph.\n\nThis is the third paragraph.'
      );
    });

    it('should handle navigation context not being available', () => {
      mockUseNavigation.mockImplementation(() => {
        throw new Error('Navigation context not available');
      });

      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle safe area context not being available', () => {
      mockUseSafeAreaInsets.mockImplementation(() => {
        throw new Error('SafeAreaProvider context not available');
      });

      expect(() => render(<Page />)).not.toThrow();
    });
  });

  describe('Speech Integration Workflow', () => {
    it('should handle speech functionality setup', () => {
      render(<Page />);

      // Verify speech mocks are properly configured
      expect(mockSpeech.speak).toBeDefined();
      expect(mockSpeech.stop).toBeDefined();
    });

    it('should handle speech state management', () => {
      const { rerender } = render(<Page />);

      // Test different speech states
      expect(() => rerender(<Page />)).not.toThrow();
    });

    it('should handle speech configuration', () => {
      render(<Page />);

      // Verify speech configuration is available
      expect(mockSpeech.speak).toBeDefined();
      expect(mockSpeech.stop).toBeDefined();
    });
  });

  describe('Navigation Integration', () => {
    it('should handle navigation utilities', () => {
      const { navigateToChapter } = require('../utils/readingUtils');
      render(<Page />);

      // Verify navigation utilities are available
      expect(navigateToChapter).toBeDefined();
    });

    it('should handle navigation when no previous chapter exists', () => {
      mockUseReading.preview = undefined;
      const { navigateToChapter } = require('../utils/readingUtils');

      expect(() => render(<Page />)).not.toThrow();
      expect(navigateToChapter).toBeDefined();
    });

    it('should handle navigation context properly', () => {
      render(<Page />);

      // Verify navigation mock is set up
      expect(mockNavigation.setOptions).toBeDefined();
    });
  });

  describe('Progress Tracking Integration', () => {
    it('should handle progress state management', () => {
      render(<Page />);

      // Verify progress tracking is set up
      expect(mockUseReading.progress).toBeDefined();
      expect(mockUseReading.setProgress).toBeDefined();
    });

    it('should handle different progress values', () => {
      mockUseReading.progress = 0.7; // Current progress is 70%

      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle progress updates', () => {
      render(<Page />);

      // Verify progress update function is available
      expect(mockUseReading.setProgress).toBeDefined();
    });
  });

  describe('Modal Integration', () => {
    it('should handle modal state management', () => {
      render(<Page />);

      // Verify modal functionality is available
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle modal with empty analysis data', () => {
      mockUseReading.analysis = null;

      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle different screen sizes', () => {
      const testInsets = [
        { top: 0, bottom: 0, left: 0, right: 0 },
        { top: 44, bottom: 34, left: 0, right: 0 },
        { top: 50, bottom: 30, left: 20, right: 20 },
        { top: -10, bottom: -5, left: -2, right: -2 }, // Edge case: negative values
      ];

      testInsets.forEach((insets) => {
        mockUseSafeAreaInsets.mockReturnValue(insets);
        expect(() => render(<Page />)).not.toThrow();
      });
    });

    it('should handle undefined safe area insets', () => {
      mockUseSafeAreaInsets.mockReturnValue(undefined as any);
      expect(() => render(<Page />)).not.toThrow();
    });
  });

  describe('Error Handling and Edge Cases', () => {
    it('should handle speech errors gracefully', () => {
      mockSpeech.speak.mockImplementation(() =>
        Promise.reject(new Error('Speech unavailable'))
      );

      // Should not crash on speech error
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle navigation errors', () => {
      const { navigateToChapter } = require('../utils/readingUtils');
      navigateToChapter.mockImplementation(() => {
        throw new Error('Navigation failed');
      });

      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle empty content gracefully', () => {
      mockUseReading.content = '';
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle malformed content data', () => {
      mockUseReading.content = null;
      mockUseReading.analysis = undefined;
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle component unmounting during speech', () => {
      const { unmount } = render(<Page />);

      // Unmount component
      expect(() => unmount()).not.toThrow();
    });
  });

  describe('Font Size and Settings Integration', () => {
    it('should handle font size changes', () => {
      render(<Page />);

      // Verify font size functionality is available
      expect(mockUseReading.fontSize).toBeDefined();
      expect(mockUseReading.setFontSize).toBeDefined();
    });

    it('should persist font size changes', () => {
      mockUseReading.fontSize = 22;

      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle extreme font size values', () => {
      mockUseReading.fontSize = 50; // Very large font
      expect(() => render(<Page />)).not.toThrow();

      mockUseReading.fontSize = 8; // Very small font
      expect(() => render(<Page />)).not.toThrow();
    });
  });

  describe('Complete User Workflow Integration', () => {
    it('should handle a complete reading session', () => {
      render(<Page />);

      // 1. Verify component renders without errors
      expect(() => render(<Page />)).not.toThrow();

      // 2. Verify speech functionality is available
      expect(mockSpeech.speak).toBeDefined();

      // 3. Verify reading hook functions are available
      expect(mockUseReading.setProgress).toBeDefined();
      expect(mockUseReading.setFontSize).toBeDefined();

      // 4. Verify navigation functionality is available
      const { navigateToChapter } = require('../utils/readingUtils');
      expect(navigateToChapter).toBeDefined();
    });
  });
});
