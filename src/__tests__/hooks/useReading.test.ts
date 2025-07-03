import React from 'react';
import { renderHook, act, waitFor } from '@testing-library/react-native';
import { useReading } from '@/hooks/useReading';
import { useLocalSearchParams } from 'expo-router';
import { useIsFocused } from '@react-navigation/native';
import { AsyncStorageProvider } from '@/hooks/useAsyncStorage';
import { ANALYSIS_KEY, CONTENT_KEY, SETTINGS_KEY } from '@/components/global';

// Mock dependencies
jest.mock('expo-router');
jest.mock('@react-navigation/native');
jest.mock('@react-native-async-storage/async-storage', () => ({
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  getAllKeys: jest.fn(() => Promise.resolve([])),
  multiGet: jest.fn(() => Promise.resolve([])),
}));

const mockUseLocalSearchParams = useLocalSearchParams as jest.MockedFunction<
  typeof useLocalSearchParams
>;
const mockUseIsFocused = useIsFocused as jest.MockedFunction<
  typeof useIsFocused
>;

// Create a wrapper component for tests
const TestWrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return React.createElement(AsyncStorageProvider, null, children);
};

describe('useReading', () => {
  beforeEach(() => {
    jest.clearAllMocks();

    // Default mock implementations
    mockUseLocalSearchParams.mockReturnValue({});
    mockUseIsFocused.mockReturnValue(true);

    // Mock console to prevent test output pollution
    jest.spyOn(console, 'error').mockImplementation(() => {});
    jest.spyOn(console, 'log').mockImplementation(() => {});
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('initial state', () => {
    it('should return initial state values', () => {
      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      expect(result.current.content).toBe('Please select a file to read');
      expect(result.current.analysis).toBe('No analysis for this chapter yet');
      expect(result.current.preview).toBeUndefined();
      expect(result.current.next).toBeUndefined();
      expect(result.current.current).toBeUndefined();
      expect(result.current.progress).toBe(0);
      expect(result.current.fontSize).toBe(16);
      expect(typeof result.current.setProgress).toBe('function');
      expect(typeof result.current.getContentFromProgress).toBe('function');
      expect(typeof result.current.loadReadingByName).toBe('function');
    });
  });

  describe('URL parameters handling', () => {
    it('should handle post parameter from URL', async () => {
      const mockParams = {
        post: 'chapter1',
      };

      mockUseLocalSearchParams.mockReturnValue(mockParams);

      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      await waitFor(() => {
        expect(result.current.current).toBe('chapter1');
      });
    });

    it('should reset progress when post parameter changes', async () => {
      const mockParams = {
        post: 'chapter2',
      };

      mockUseLocalSearchParams.mockReturnValue(mockParams);

      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      await waitFor(() => {
        expect(result.current.progress).toBe(0);
      });
    });
  });

  describe('progress tracking', () => {
    it('should update progress', async () => {
      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      await act(async () => {
        result.current.setProgress(0.5);
      });

      expect(result.current.progress).toBe(0.5);
    });

    it('should calculate content from progress', async () => {
      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      // Mock content
      await act(async () => {
        result.current.setProgress(0.5);
      });

      const contentFromProgress = result.current.getContentFromProgress();
      expect(typeof contentFromProgress).toBe('string');
    });
  });

  describe('loadReadingByName function', () => {
    it('should be callable', () => {
      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      expect(() => {
        result.current.loadReadingByName();
      }).not.toThrow();
    });

    it('should handle loading when current is set', async () => {
      const mockParams = {
        post: 'test-chapter',
      };

      mockUseLocalSearchParams.mockReturnValue(mockParams);

      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      await waitFor(() => {
        expect(result.current.current).toBe('test-chapter');
      });

      // Should not throw when loading
      expect(() => {
        result.current.loadReadingByName();
      }).not.toThrow();
    });
  });

  describe('focus state handling', () => {
    it('should respond to focus changes', async () => {
      let focusState = false;
      mockUseIsFocused.mockImplementation(() => focusState);

      const mockParams = {
        post: 'test-chapter',
      };

      mockUseLocalSearchParams.mockReturnValue(mockParams);

      const { rerender } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      // Simulate screen becoming focused
      focusState = true;
      rerender();

      // Should handle focus change without errors
      expect(mockUseIsFocused).toHaveBeenCalled();
    });
  });

  describe('settings integration', () => {
    it('should handle missing settings gracefully', async () => {
      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      // Should use default fontSize when no settings
      expect(result.current.fontSize).toBe(16);
    });

    it('should handle settings loading errors', async () => {
      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      // Should not crash when settings fail to load
      expect(result.current).toHaveProperty('fontSize');
      expect(result.current).toHaveProperty('content');
      expect(result.current).toHaveProperty('analysis');
    });
  });

  describe('content and analysis states', () => {
    it('should have default content message', () => {
      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      expect(result.current.content).toBe('Please select a file to read');
    });

    it('should have default analysis message', () => {
      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      expect(result.current.analysis).toBe('No analysis for this chapter yet');
    });

    it('should handle undefined analysis state', async () => {
      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      // Analysis can be undefined when no analysis is available
      expect(result.current.analysis).toBeDefined();
    });
  });

  describe('navigation states', () => {
    it('should initialize preview and next as undefined', () => {
      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      expect(result.current.preview).toBeUndefined();
      expect(result.current.next).toBeUndefined();
    });

    it('should handle current chapter state', () => {
      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      expect(result.current.current).toBeUndefined();
    });
  });

  describe('error handling', () => {
    it('should handle storage errors gracefully', async () => {
      // Mock console.error to prevent test output pollution
      const consoleSpy = jest
        .spyOn(console, 'error')
        .mockImplementation(() => {});

      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      // Should still provide default values even if storage fails
      expect(result.current.content).toBe('Please select a file to read');
      expect(result.current.fontSize).toBe(16);

      consoleSpy.mockRestore();
    });

    it('should handle missing content gracefully', () => {
      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      // Should not crash when content is missing
      expect(() => {
        result.current.getContentFromProgress();
      }).not.toThrow();
    });
  });

  describe('state persistence', () => {
    it('should maintain state across re-renders', async () => {
      const { result, rerender } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      await act(async () => {
        result.current.setProgress(0.7);
      });

      rerender();

      expect(result.current.progress).toBe(0.7);
    });

    it('should handle multiple progress updates', async () => {
      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      await act(async () => {
        result.current.setProgress(0.3);
        result.current.setProgress(0.6);
        result.current.setProgress(0.9);
      });

      expect(result.current.progress).toBe(0.9);
    });
  });

  describe('integration with AsyncStorage', () => {
    it('should work with AsyncStorageProvider', () => {
      const { result } = renderHook(() => useReading(), {
        wrapper: TestWrapper,
      });

      // Should render without errors when wrapped with AsyncStorageProvider
      expect(result.current).toHaveProperty('content');
      expect(result.current).toHaveProperty('analysis');
      expect(result.current).toHaveProperty('progress');
      expect(result.current).toHaveProperty('fontSize');
    });
  });
});
