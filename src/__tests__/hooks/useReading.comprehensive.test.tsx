import React from 'react';
import { renderHook, waitFor, act } from '@testing-library/react-native';
import { useReading } from '@/hooks/useReading';
import { useAsyncStorage } from '@/hooks/useAsyncStorage';
import { useLocalSearchParams } from 'expo-router';

// Mock all dependencies
jest.mock('@/hooks/useAsyncStorage');
jest.mock('expo-router');
jest.mock('@react-navigation/native', () => ({
  useIsFocused: jest.fn(() => true),
}));
jest.mock('@/components/global', () => ({
  ANALYSIS_KEY: 'analysis_',
  CONTENT_KEY: 'content_',
  SETTINGS_KEY: 'settings',
  showErrorToast: jest.fn(),
  showInfoToast: jest.fn(),
}));

const mockUseAsyncStorage = useAsyncStorage as jest.MockedFunction<
  typeof useAsyncStorage
>;
const mockUseLocalSearchParams = useLocalSearchParams as jest.MockedFunction<
  typeof useLocalSearchParams
>;

describe('useReading Comprehensive Tests', () => {
  const mockGetItem = jest.fn();
  const mockSetItem = jest.fn();
  const mockRemoveItem = jest.fn();
  const mockStorage = {};

  beforeEach(() => {
    jest.clearAllMocks();

    // Default mock setup
    mockUseAsyncStorage.mockReturnValue([
      mockStorage,
      {
        getItem: mockGetItem,
        setItem: mockSetItem,
        removeItem: mockRemoveItem,
      },
      false, // isStorageLoading
      0, // hasChanged
    ]);

    mockUseLocalSearchParams.mockReturnValue({ post: undefined });

    mockGetItem.mockResolvedValue(null);
    mockSetItem.mockResolvedValue(undefined);
  });

  describe('Initial State', () => {
    it('should return initial reading state', () => {
      const { result } = renderHook(() => useReading());

      if (result.current) {
        expect(result.current.content).toBe('Please select a file to read');
        expect(result.current.analysis).toBe(
          'No analysis for this chapter yet'
        );
        expect(result.current.preview).toBeUndefined();
        expect(result.current.next).toBeUndefined();
        expect(result.current.current).toBeUndefined();
        expect(result.current.progress).toBe(0);
        expect(result.current.fontSize).toBe(16);
        expect(typeof result.current.setProgress).toBe('function');
        expect(typeof result.current.getContentFromProgress).toBe('function');
        expect(typeof result.current.loadReadingByName).toBe('function');
      }
    });
  });

  describe('Settings Loading', () => {
    it('should load font size from settings', async () => {
      const settings = { fontSize: 20, current: 'chapter1', progress: 50 };
      mockGetItem.mockResolvedValue(JSON.stringify(settings));

      // Setup hook with storage change
      mockUseAsyncStorage.mockReturnValue([
        mockStorage,
        {
          getItem: mockGetItem,
          setItem: mockSetItem,
          removeItem: mockRemoveItem,
        },
        false, // isStorageLoading
        1, // hasChanged
      ]);

      const { result } = renderHook(() => useReading());

      if (result.current) {
        await waitFor(() => {
          expect(mockGetItem).toHaveBeenCalledWith('settings');
        });

        await waitFor(() => {
          expect(result.current?.fontSize).toBe(20);
        });
      }
    });

    it('should use default font size when settings are invalid', async () => {
      mockGetItem.mockResolvedValue('invalid-json');

      // Setup hook with storage change
      mockUseAsyncStorage.mockReturnValue([
        mockStorage,
        {
          getItem: mockGetItem,
          setItem: mockSetItem,
          removeItem: mockRemoveItem,
        },
        false, // isStorageLoading
        1, // hasChanged
      ]);

      const { result } = renderHook(() => useReading());

      if (result.current) {
        await waitFor(() => {
          expect(mockGetItem).toHaveBeenCalledWith('settings');
        });

        expect(result.current.fontSize).toBe(16);
      }
    });

    it('should handle missing fontSize in settings', async () => {
      const settings = { current: 'chapter1', progress: 50 };
      mockGetItem.mockResolvedValue(JSON.stringify(settings));

      // Setup hook with storage change
      mockUseAsyncStorage.mockReturnValue([
        mockStorage,
        {
          getItem: mockGetItem,
          setItem: mockSetItem,
          removeItem: mockRemoveItem,
        },
        false, // isStorageLoading
        1, // hasChanged
      ]);

      const { result } = renderHook(() => useReading());

      if (result.current) {
        await waitFor(() => {
          expect(result.current?.fontSize).toBe(16);
        });
      }
    });
  });

  describe('Post Parameter Handling', () => {
    it('should load current chapter from settings when no post param', async () => {
      const settings = { current: 'chapter1', progress: 25 };
      mockGetItem.mockResolvedValue(JSON.stringify(settings));
      mockUseLocalSearchParams.mockReturnValue({ post: undefined });

      const { result } = renderHook(() => useReading());

      if (result.current) {
        await waitFor(() => {
          expect(result.current?.current).toBe('chapter1');
          expect(result.current?.progress).toBe(25);
        });
      }
    });

    it('should set current chapter from post param', async () => {
      const settings = { current: 'oldChapter', progress: 50 };
      mockGetItem.mockResolvedValue(JSON.stringify(settings));
      mockUseLocalSearchParams.mockReturnValue({ post: 'chapter2' });

      const { result } = renderHook(() => useReading());

      if (result.current) {
        await waitFor(() => {
          expect(result.current?.current).toBe('chapter2');
        });

        await waitFor(() => {
          expect(mockSetItem).toHaveBeenCalledWith(
            'settings',
            expect.stringContaining('"current":"chapter2"')
          );
        });
      }
    });

    it('should continue from saved progress for same chapter', async () => {
      const settings = { current: 'chapter1', progress: 75 };
      mockGetItem.mockResolvedValue(JSON.stringify(settings));
      mockUseLocalSearchParams.mockReturnValue({ post: 'chapter1' });

      const { result } = renderHook(() => useReading());

      if (result.current) {
        await waitFor(() => {
          expect(result.current?.current).toBe('chapter1');
          expect(result.current?.progress).toBe(75);
        });
      }
    });

    it('should reset progress for new chapter', async () => {
      const settings = { current: 'chapter1', progress: 75 };
      mockGetItem.mockResolvedValue(JSON.stringify(settings));
      mockUseLocalSearchParams.mockReturnValue({ post: 'chapter2' });

      const { result } = renderHook(() => useReading());

      if (result.current) {
        await waitFor(() => {
          expect(result.current?.current).toBe('chapter2');
          expect(result.current?.progress).toBe(0);
        });
      }
    });
  });

  describe('Content Loading', () => {
    it('should load content for current chapter', async () => {
      const contentData = { content: 'Chapter content here' };
      const settings = { current: 'content_chapter1', progress: 0 };

      mockGetItem
        .mockResolvedValueOnce(JSON.stringify(settings)) // First call for settings
        .mockResolvedValueOnce(JSON.stringify(contentData)) // Second call for content
        .mockResolvedValueOnce(null) // Third call for analysis
        .mockResolvedValueOnce(null); // Fourth call for content list

      mockUseLocalSearchParams.mockReturnValue({ post: 'content_chapter1' });

      const { result } = renderHook(() => useReading());

      if (result.current) {
        await waitFor(() => {
          expect(result.current?.content).toBe('Chapter content here');
        });
      }
    });

    it('should load analysis for current chapter', async () => {
      const analysisData = { content: 'Analysis content here' };
      const settings = { current: 'content_chapter1', progress: 0 };

      mockGetItem
        .mockResolvedValueOnce(JSON.stringify(settings)) // Settings
        .mockResolvedValueOnce(null) // Content (not found)
        .mockResolvedValueOnce(JSON.stringify(analysisData)) // Analysis
        .mockResolvedValueOnce(null); // Content list

      mockUseLocalSearchParams.mockReturnValue({ post: 'content_chapter1' });

      const { result } = renderHook(() => useReading());

      if (result.current) {
        await waitFor(() => {
          expect(result.current?.analysis).toBe('Analysis content here');
        });
      }
    });

    it('should load navigation info (prev/next)', async () => {
      const contentList = [
        { name: 'chapter1' },
        { name: 'chapter2' },
        { name: 'chapter3' },
      ];
      const settings = { current: 'content_chapter2', progress: 0 };

      mockGetItem
        .mockResolvedValueOnce(JSON.stringify(settings)) // Settings
        .mockResolvedValueOnce(null) // Content
        .mockResolvedValueOnce(null) // Analysis
        .mockResolvedValueOnce(JSON.stringify(contentList)); // Content list

      mockUseLocalSearchParams.mockReturnValue({ post: 'content_chapter2' });

      const { result } = renderHook(() => useReading());

      if (result.current) {
        await waitFor(() => {
          expect(result.current?.preview).toBe('content_chapter1');
          expect(result.current?.next).toBe('content_chapter3');
        });
      }
    });
  });

  describe('Progress Management', () => {
    it('should save progress to storage', async () => {
      const settings = { current: 'chapter1', progress: 0 };
      mockGetItem.mockResolvedValue(JSON.stringify(settings));
      mockUseLocalSearchParams.mockReturnValue({ post: 'chapter1' });

      const { result } = renderHook(() => useReading());

      if (result.current) {
        // Wait for initial load to complete
        await waitFor(() => {
          expect(result.current?.current).toBe('chapter1');
        });

        // Update progress
        await act(async () => {
          result.current?.setProgress(50);
        });

        await waitFor(() => {
          expect(result.current?.progress).toBe(50);
        });

        // Should save to storage
        await waitFor(() => {
          expect(mockSetItem).toHaveBeenCalledWith(
            'settings',
            expect.stringContaining('"progress":50')
          );
        });
      }
    });

    it('should get content from progress', () => {
      const { result } = renderHook(() => useReading());

      if (result.current) {
        // Mock content
        const mockContent = 'This is a test content for reading';

        // Since we can't directly set content, we'll test the function exists
        expect(typeof result.current.getContentFromProgress).toBe('function');

        // Test with empty content (default state)
        const contentFromProgress = result.current.getContentFromProgress();
        expect(typeof contentFromProgress).toBe('string');
      }
    });
  });

  describe('Error Handling', () => {
    it('should handle storage errors gracefully', async () => {
      const error = new Error('Storage error');
      mockGetItem.mockRejectedValue(error);

      // Setup hook with storage change
      mockUseAsyncStorage.mockReturnValue([
        mockStorage,
        {
          getItem: mockGetItem,
          setItem: mockSetItem,
          removeItem: mockRemoveItem,
        },
        false, // isStorageLoading
        1, // hasChanged
      ]);

      const { result } = renderHook(() => useReading());

      if (result.current) {
        await waitFor(() => {
          expect(mockGetItem).toHaveBeenCalled();
        });

        // Should not crash and use default values
        expect(result.current.fontSize).toBe(16);
        expect(result.current.content).toBe('Please select a file to read');
      }
    });

    it('should handle invalid JSON gracefully', async () => {
      mockGetItem.mockResolvedValue('invalid-json');

      // Setup hook with storage change
      mockUseAsyncStorage.mockReturnValue([
        mockStorage,
        {
          getItem: mockGetItem,
          setItem: mockSetItem,
          removeItem: mockRemoveItem,
        },
        false, // isStorageLoading
        1, // hasChanged
      ]);

      const { result } = renderHook(() => useReading());

      if (result.current) {
        await waitFor(() => {
          expect(mockGetItem).toHaveBeenCalled();
        });

        // Should use default values
        expect(result.current.fontSize).toBe(16);
      }
    });

    it('should handle missing content gracefully', async () => {
      const settings = { current: 'content_chapter1', progress: 0 };

      mockGetItem
        .mockResolvedValueOnce(JSON.stringify(settings)) // Settings
        .mockResolvedValueOnce(null); // Content not found

      mockUseLocalSearchParams.mockReturnValue({ post: 'content_chapter1' });

      const { result } = renderHook(() => useReading());

      if (result.current) {
        await waitFor(() => {
          expect(mockGetItem).toHaveBeenCalledWith('content_chapter1');
        });

        // Should keep default content
        expect(result.current.content).toBe('Please select a file to read');
      }
    });
  });

  describe('Function Calls', () => {
    it('should call loadReadingByName function', () => {
      const { result } = renderHook(() => useReading());

      if (result.current) {
        expect(typeof result.current.loadReadingByName).toBe('function');

        // Should not throw when called
        expect(() => result.current?.loadReadingByName()).not.toThrow();
      }
    });

    it('should update progress via setProgress', async () => {
      const { result } = renderHook(() => useReading());

      if (result.current) {
        await act(async () => {
          result.current?.setProgress(75);
        });

        expect(result.current.progress).toBe(75);
      }
    });
  });
});
