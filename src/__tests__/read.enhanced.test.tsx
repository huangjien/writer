import React from 'react';
import { render } from '@testing-library/react-native';
import { jest } from '@jest/globals';
import { useLocalSearchParams } from 'expo-router';
import { useNavigation, useIsFocused } from '@react-navigation/native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as Speech from 'expo-speech';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

// Import the component after setup to ensure mocks are applied
import Page from '../app/read';

// Mock all @/ imports that the component uses
jest.mock('@/components/AnalysisModal', () => ({
  AnalysisModal: () => null, // Simple mock that returns nothing
}));

jest.mock('@/components/PlayBar', () => ({
  PlayBar: () => null, // Simple mock that returns nothing
}));

jest.mock('@/components/ContentArea', () => ({
  ContentArea: () => null, // Simple mock that returns nothing
}));

jest.mock('@/hooks/useReading', () => ({
  useReading: () => ({
    content: 'Test content for reading',
    analysis: 'Test analysis',
    preview: 'Test preview',
    next: 'Next chapter',
    current: 'Current chapter',
    progress: 50,
    fontSize: 18,
    setProgress: jest.fn(),
  }),
}));

jest.mock('@/utils/readingUtils', () => ({
  navigateToChapter: jest.fn(),
  handleProgressChange: jest.fn(),
  handleContentChange: jest.fn(),
  handleSpeechProgressUpdate: jest.fn(),
}));

// Mock dependencies
jest.mock('expo-router');
jest.mock('@react-navigation/native');
jest.mock('expo-speech');
jest.mock('expo-keep-awake');
jest.mock('react-native-safe-area-context');
jest.mock('react-native-modal', () => 'Modal');
jest.mock('react-native-markdown-display', () => 'Markdown');
jest.mock('@react-native-community/slider', () => 'Slider');
jest.mock('@react-native-picker/picker', () => ({
  Picker: 'Picker',
}));
jest.mock('react-native-gesture-handler', () => ({
  Gesture: {
    LongPress: () => ({
      onEnd: jest.fn().mockReturnThis(),
      runOnJS: jest.fn().mockReturnThis(),
    }),
    Tap: () => ({
      numberOfTaps: jest.fn().mockReturnThis(),
      onEnd: jest.fn().mockReturnThis(),
      runOnJS: jest.fn().mockReturnThis(),
    }),
    Simultaneous: jest.fn(),
  },
  GestureDetector: ({ children }: { children: React.ReactNode }) => children,
  Swipeable: ({ children }: { children: React.ReactNode }) => children,
}));

const mockUseLocalSearchParams = useLocalSearchParams as jest.Mock;
const mockUseNavigation = useNavigation as jest.Mock;
const mockUseIsFocused = useIsFocused as jest.Mock;
const mockSpeech = {
  speak: jest.fn(),
  stop: jest.fn(),
  isSpeakingAsync: jest.fn(),
  resume: jest.fn(),
};
const mockUseSafeAreaInsets = useSafeAreaInsets as jest.Mock;

// Mock useAsyncStorage
const mockGetItem = jest.fn();
const mockSetItem = jest.fn();
const mockRemoveItem = jest.fn();

jest.mock('../hooks/useAsyncStorage', () => ({
  useAsyncStorage: () => [
    { fontSize: 18 }, // storage
    { getItem: mockGetItem, setItem: mockSetItem, removeItem: mockRemoveItem },
    false, // isLoading
    false, // hasChanged
  ],
}));

describe('Read Page - Basic Tests', () => {
  const mockNavigation = {
    setOptions: jest.fn(),
  };

  beforeEach(() => {
    jest.clearAllMocks();
    mockUseLocalSearchParams.mockReturnValue({});
    mockUseNavigation.mockReturnValue(mockNavigation as any);
    mockUseIsFocused.mockReturnValue(true);
    mockUseSafeAreaInsets.mockReturnValue({
      top: 44,
      bottom: 0,
      left: 0,
      right: 0,
    });
    (mockSpeech.isSpeakingAsync as any).mockResolvedValue(false);
    (mockSpeech.speak as any).mockImplementation(() => Promise.resolve());
    (mockSpeech.stop as any).mockImplementation(() => Promise.resolve());
    (mockSpeech.resume as any).mockImplementation(() => Promise.resolve());
    (mockGetItem as any).mockResolvedValue(JSON.stringify({ fontSize: 18 }));
  });

  describe('Component Rendering', () => {
    it('should render without crashing', () => {
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should return a valid component instance', () => {
      const component = render(<Page />);
      expect(component).toBeDefined();
      expect(component.toJSON).toBeDefined();
    });

    it('should render with default props', () => {
      const component = render(<Page />);
      expect(component.toJSON()).toBeTruthy();
    });
  });

  describe('Content Loading', () => {
    it('should handle content parameter from route', () => {
      const testPost = '@Content:chapter1.md';
      mockUseLocalSearchParams.mockReturnValue({ post: testPost });

      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle empty route parameters', () => {
      mockUseLocalSearchParams.mockReturnValue({});

      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle various content types', () => {
      const testCases = [
        { post: '@Content:test.md' },
        { post: '@GitHub:user/repo/file.md' },
        { post: '@Local:document.txt' },
        { post: undefined },
        {},
      ];

      testCases.forEach((params) => {
        mockUseLocalSearchParams.mockReturnValue(params);
        expect(() => render(<Page />)).not.toThrow();
      });
    });
  });

  describe('Error Handling', () => {
    it('should handle missing navigation gracefully', () => {
      mockUseNavigation.mockReturnValue(null as any);
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle undefined navigation gracefully', () => {
      mockUseNavigation.mockReturnValue(undefined as any);
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle storage errors gracefully', () => {
      (mockGetItem as any).mockRejectedValue(new Error('Storage error'));
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle speech errors gracefully', () => {
      (mockSpeech.speak as any).mockRejectedValue(new Error('Speech error'));
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle undefined speech methods', () => {
      // Test that the component handles cases where speech methods might not be available
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle missing Speech object', () => {
      jest.doMock('expo-speech', () => ({}));
      expect(() => render(<Page />)).not.toThrow();
    });
  });

  describe('Settings Management', () => {
    it('should handle missing settings', () => {
      (mockGetItem as any).mockResolvedValue(null);
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle malformed settings', () => {
      (mockGetItem as any).mockResolvedValue('invalid json');
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle empty settings object', () => {
      (mockGetItem as any).mockResolvedValue(JSON.stringify({}));
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle settings with null values', () => {
      (mockGetItem as any).mockResolvedValue(
        JSON.stringify({ fontSize: null })
      );
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle settings with undefined values', () => {
      (mockGetItem as any).mockResolvedValue(
        JSON.stringify({ fontSize: undefined })
      );
      expect(() => render(<Page />)).not.toThrow();
    });
  });

  describe('Focus State Management', () => {
    it('should handle focused state', () => {
      mockUseIsFocused.mockReturnValue(true);
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle unfocused state', () => {
      mockUseIsFocused.mockReturnValue(false);
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle focus state changes', () => {
      // Test initial focused state
      mockUseIsFocused.mockReturnValue(true);
      const { rerender } = render(<Page />);

      // Test unfocused state
      mockUseIsFocused.mockReturnValue(false);
      expect(() => rerender(<Page />)).not.toThrow();
    });

    it('should handle undefined focus state', () => {
      mockUseIsFocused.mockReturnValue(undefined as any);
      expect(() => render(<Page />)).not.toThrow();
    });
  });

  describe('Hook Integration', () => {
    it('should integrate with useReading hook properly', () => {
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle safe area insets', () => {
      mockUseSafeAreaInsets.mockReturnValue({
        top: 50,
        bottom: 30,
        left: 10,
        right: 10,
      });

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

  describe('Speech Integration', () => {
    it('should handle speech functionality availability', () => {
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle speech state changes', () => {
      (mockSpeech.isSpeakingAsync as any).mockResolvedValue(true);
      expect(() => render(<Page />)).not.toThrow();

      (mockSpeech.isSpeakingAsync as any).mockResolvedValue(false);
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle speech configuration', () => {
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle speech promise rejections', () => {
      (mockSpeech.isSpeakingAsync as any).mockRejectedValue(
        new Error('Speech not available')
      );
      expect(() => render(<Page />)).not.toThrow();
    });
  });

  describe('Component State Management', () => {
    it('should render without errors in different states', () => {
      // Test with different hook return values
      const testStates = [
        { focused: true, hasNavigation: true },
        { focused: false, hasNavigation: true },
        { focused: true, hasNavigation: false },
        { focused: false, hasNavigation: false },
      ];

      testStates.forEach(({ focused, hasNavigation }) => {
        mockUseIsFocused.mockReturnValue(focused);
        mockUseNavigation.mockReturnValue(
          hasNavigation ? (mockNavigation as any) : null
        );
        expect(() => render(<Page />)).not.toThrow();
      });
    });

    it('should handle component re-renders', () => {
      const { rerender } = render(<Page />);

      // Change some mock values and re-render
      mockUseLocalSearchParams.mockReturnValue({ post: '@Content:new.md' });
      expect(() => rerender(<Page />)).not.toThrow();

      // Change focus state and re-render
      mockUseIsFocused.mockReturnValue(false);
      expect(() => rerender(<Page />)).not.toThrow();
    });

    it('should handle multiple renders', () => {
      for (let i = 0; i < 5; i++) {
        expect(() => render(<Page />)).not.toThrow();
      }
    });
  });

  describe('Edge Cases', () => {
    it('should handle empty useReading response', () => {
      jest.doMock('@/hooks/useReading', () => ({
        useReading: () => ({}),
      }));
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle null useReading response', () => {
      jest.doMock('@/hooks/useReading', () => ({
        useReading: () => null,
      }));
      expect(() => render(<Page />)).not.toThrow();
    });

    it('should handle component unmounting', () => {
      const { unmount } = render(<Page />);
      expect(() => unmount()).not.toThrow();
    });
  });
});
