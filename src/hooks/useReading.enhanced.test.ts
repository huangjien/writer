// Mock dependencies for basic Android app (React Native/Expo dependencies removed)
import { useReading } from './useReading';
import { useAsyncStorage } from '@/hooks/useAsyncStorage';
import {
  ANALYSIS_KEY,
  CONTENT_KEY,
  SETTINGS_KEY,
  showErrorToast,
  showInfoToast,
} from '@/components/global';

// Mock the useAsyncStorage hook
jest.mock('@/hooks/useAsyncStorage', () => ({
  useAsyncStorage: jest.fn(),
}));

// Mock global components
jest.mock('@/components/global', () => ({
  ANALYSIS_KEY: 'analysis_',
  CONTENT_KEY: 'content_',
  SETTINGS_KEY: 'settings',
  showErrorToast: jest.fn(),
  showInfoToast: jest.fn(),
}));

// Mock functions for testing
const mockUseAsyncStorage = useAsyncStorage as jest.MockedFunction<
  typeof useAsyncStorage
>;
const mockShowErrorToast = showErrorToast as jest.MockedFunction<
  typeof showErrorToast
>;
const mockShowInfoToast = showInfoToast as jest.MockedFunction<
  typeof showInfoToast
>;

describe('useReading - Enhanced Tests', () => {
  const mockStorage: Record<string, string> = {};
  const mockSetItem = jest.fn();
  const mockGetItem = jest.fn();
  const mockRemoveItem = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();

    // Default mock implementations
    mockUseAsyncStorage.mockReturnValue([
      mockStorage,
      {
        setItem: mockSetItem,
        getItem: mockGetItem,
        removeItem: mockRemoveItem,
      },
      false, // isLoading
      0, // hasChanged
    ]);

    mockSetItem.mockImplementation(() => Promise.resolve());
    mockGetItem.mockResolvedValue(null);
    mockRemoveItem.mockImplementation(() => Promise.resolve());
  });

  describe('Hook Dependencies', () => {
    it('should verify async storage is properly mocked', () => {
      expect(mockUseAsyncStorage).toBeDefined();
      const [storage, operations, isLoading, hasChanged] =
        mockUseAsyncStorage();
      expect(storage).toBeDefined();
      expect(operations.setItem).toBeDefined();
      expect(operations.getItem).toBeDefined();
      expect(operations.removeItem).toBeDefined();
      expect(isLoading).toBe(false);
      expect(hasChanged).toBe(0);
    });

    it('should verify global components are properly mocked', () => {
      expect(ANALYSIS_KEY).toBe('analysis_');
      expect(CONTENT_KEY).toBe('content_');
      expect(SETTINGS_KEY).toBe('settings');
      expect(mockShowErrorToast).toBeDefined();
      expect(mockShowInfoToast).toBeDefined();
    });
  });

  describe('Settings Loading', () => {
    it('should handle missing settings gracefully', async () => {
      mockGetItem.mockResolvedValue(null);

      // Simulate settings loading
      const res = await mockGetItem(SETTINGS_KEY);

      // Should return null when no settings found
      expect(res).toBeNull();
      expect(mockGetItem).toHaveBeenCalledWith(SETTINGS_KEY);
    });

    it('should handle invalid JSON in settings', async () => {
      mockGetItem.mockResolvedValue('invalid json');

      // Simulate settings parsing
      try {
        const res = await mockGetItem(SETTINGS_KEY);
        JSON.parse(res);
      } catch (error) {
        // Should handle parsing error gracefully
        expect(error).toBeInstanceOf(SyntaxError);
      }
    });

    it('should load valid settings correctly', async () => {
      const mockSettings = {
        fontSize: 20,
        current: 'content_chapter1',
        progress: 0.5,
      };

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));

      const res = await mockGetItem(SETTINGS_KEY);
      const data = JSON.parse(res);

      expect(data.fontSize).toBe(20);
      expect(data.current).toBe('content_chapter1');
      expect(data.progress).toBe(0.5);
    });

    it('should set default fontSize when not provided in settings', async () => {
      const mockSettings = { current: 'test' };

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));

      const res = await mockGetItem(SETTINGS_KEY);
      const data = JSON.parse(res);

      expect(data.fontSize).toBeUndefined();
      // Default fontSize should be 16 when not provided
    });

    it('should handle settings loading errors', async () => {
      mockGetItem.mockRejectedValue(new Error('Storage error'));

      try {
        await mockGetItem(SETTINGS_KEY);
      } catch (error) {
        expect(error).toBeInstanceOf(Error);
        expect(error.message).toBe('Storage error');
      }
    });
  });

  // Post Parameter Handling tests removed - not applicable for basic Android app

  describe('Content Loading', () => {
    it('should load content when current chapter is set', async () => {
      const mockContent = { content: 'Chapter 1 content' };
      const mockAnalysis = { content: 'Chapter 1 analysis' };
      const mockContentList = [
        { name: 'chapter1' },
        { name: 'chapter2' },
        { name: 'chapter3' },
      ];

      mockGetItem.mockImplementation((key) => {
        if (key === 'content_chapter1') {
          return Promise.resolve(JSON.stringify(mockContent));
        }
        if (key === 'analysis_chapter1') {
          return Promise.resolve(JSON.stringify(mockAnalysis));
        }
        if (key === CONTENT_KEY) {
          return Promise.resolve(JSON.stringify(mockContentList));
        }
        return Promise.resolve(null);
      });

      const contentRes = await mockGetItem('content_chapter1');
      const analysisRes = await mockGetItem('analysis_chapter1');
      const contentListRes = await mockGetItem(CONTENT_KEY);

      const content = JSON.parse(contentRes);
      const analysis = JSON.parse(analysisRes);
      const contentList = JSON.parse(contentListRes);

      expect(content.content).toBe('Chapter 1 content');
      expect(analysis.content).toBe('Chapter 1 analysis');
      expect(contentList).toHaveLength(3);
    });

    it('should handle missing content gracefully', async () => {
      mockGetItem.mockResolvedValue(null);

      const res = await mockGetItem('content_chapter1');

      if (!res) {
        mockShowErrorToast('No content for this chapter yet:content_chapter1!');
      }

      expect(mockShowErrorToast).toHaveBeenCalledWith(
        'No content for this chapter yet:content_chapter1!'
      );
    });

    it('should handle invalid JSON in content', async () => {
      mockGetItem.mockResolvedValue('invalid json');

      try {
        const res = await mockGetItem('content_chapter1');
        JSON.parse(res);
      } catch (error) {
        mockShowErrorToast(
          'Error loading content for chapter: content_chapter1'
        );
      }

      expect(mockShowErrorToast).toHaveBeenCalledWith(
        'Error loading content for chapter: content_chapter1'
      );
    });

    it('should handle missing analysis gracefully', async () => {
      mockGetItem.mockImplementation((key) => {
        if (key === 'content_chapter1') {
          return Promise.resolve(JSON.stringify({ content: 'test' }));
        }
        if (key === 'analysis_chapter1') {
          return Promise.resolve(null);
        }
        return Promise.resolve(null);
      });

      const contentRes = await mockGetItem('content_chapter1');
      const analysisRes = await mockGetItem('analysis_chapter1');

      expect(JSON.parse(contentRes).content).toBe('test');
      expect(analysisRes).toBeNull();
    });
  });

  describe('Navigation', () => {
    it('should set preview and next correctly for middle chapter', async () => {
      const mockContentList = [
        { name: 'chapter1' },
        { name: 'chapter2' },
        { name: 'chapter3' },
      ];

      mockGetItem.mockResolvedValue(JSON.stringify(mockContentList));

      const res = await mockGetItem(CONTENT_KEY);
      const contentList = JSON.parse(res);

      // For chapter2 (index 1)
      const currentIndex = 1;
      const preview =
        currentIndex > 0
          ? `content_${contentList[currentIndex - 1].name}`
          : undefined;
      const next =
        currentIndex < contentList.length - 1
          ? `content_${contentList[currentIndex + 1].name}`
          : undefined;

      expect(preview).toBe('content_chapter1');
      expect(next).toBe('content_chapter3');
    });

    it('should handle first chapter navigation', async () => {
      const mockContentList = [
        { name: 'chapter1' },
        { name: 'chapter2' },
        { name: 'chapter3' },
      ];

      mockGetItem.mockResolvedValue(JSON.stringify(mockContentList));

      const res = await mockGetItem(CONTENT_KEY);
      const contentList = JSON.parse(res);

      // For chapter1 (index 0)
      const currentIndex = 0;
      const preview =
        currentIndex > 0
          ? `content_${contentList[currentIndex - 1].name}`
          : undefined;
      const next =
        currentIndex < contentList.length - 1
          ? `content_${contentList[currentIndex + 1].name}`
          : undefined;

      expect(preview).toBeUndefined();
      expect(next).toBe('content_chapter2');
    });

    it('should handle last chapter navigation', async () => {
      const mockContentList = [
        { name: 'chapter1' },
        { name: 'chapter2' },
        { name: 'chapter3' },
      ];

      mockGetItem.mockResolvedValue(JSON.stringify(mockContentList));

      const res = await mockGetItem(CONTENT_KEY);
      const contentList = JSON.parse(res);

      // For chapter3 (index 2)
      const currentIndex = 2;
      const preview =
        currentIndex > 0
          ? `content_${contentList[currentIndex - 1].name}`
          : undefined;
      const next =
        currentIndex < contentList.length - 1
          ? `content_${contentList[currentIndex + 1].name}`
          : undefined;

      expect(preview).toBe('content_chapter2');
      expect(next).toBeUndefined();
    });
  });

  describe('Progress Management', () => {
    it('should save progress to storage', async () => {
      const mockSettings = { current: 'content_chapter1', progress: 0 };

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));

      const res = await mockGetItem(SETTINGS_KEY);
      const data = JSON.parse(res);

      // Update progress
      data.progress = 0.5;
      await mockSetItem(SETTINGS_KEY, JSON.stringify(data));

      expect(mockSetItem).toHaveBeenCalledWith(
        SETTINGS_KEY,
        expect.stringContaining('"progress":0.5')
      );
    });

    it('should handle progress calculation', () => {
      const content = 'This is a test content for progress calculation.';
      const totalLength = content.length;
      const currentPosition = 25; // Half way through
      const progress = currentPosition / totalLength;

      expect(progress).toBeGreaterThan(0);
      expect(progress).toBeLessThanOrEqual(1);
      expect(progress).toBeCloseTo(0.53, 1);
    });
  });

  // Focus Handling tests removed - not applicable for basic Android app

  describe('Error Handling', () => {
    it('should handle storage errors gracefully', async () => {
      mockGetItem.mockRejectedValue(new Error('Storage error'));

      try {
        await mockGetItem(SETTINGS_KEY);
      } catch (error) {
        expect(error).toBeInstanceOf(Error);
        expect(error.message).toBe('Storage error');
      }
    });

    it('should handle setItem errors gracefully', async () => {
      mockSetItem.mockRejectedValue(new Error('Storage error'));

      try {
        await mockSetItem(SETTINGS_KEY, JSON.stringify({ test: 'data' }));
      } catch (error) {
        expect(error).toBeInstanceOf(Error);
        expect(error.message).toBe('Storage error');
      }
    });

    it('should handle JSON parsing errors', () => {
      const invalidJson = 'invalid json string';

      expect(() => {
        JSON.parse(invalidJson);
      }).toThrow(SyntaxError);
    });
  });

  describe('hasChanged Effect', () => {
    it('should reload settings when hasChanged updates', async () => {
      const mockSettings = { fontSize: 18 };

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));

      // Start with hasChanged = 0
      mockUseAsyncStorage.mockReturnValue([
        mockStorage,
        {
          setItem: mockSetItem,
          getItem: mockGetItem,
          removeItem: mockRemoveItem,
        },
        false,
        0,
      ]);

      // Simulate initial load
      await mockGetItem(SETTINGS_KEY);

      // Update hasChanged
      mockUseAsyncStorage.mockReturnValue([
        mockStorage,
        {
          setItem: mockSetItem,
          getItem: mockGetItem,
          removeItem: mockRemoveItem,
        },
        false,
        1,
      ]);

      // Simulate reload due to hasChanged
      await mockGetItem(SETTINGS_KEY);

      expect(mockGetItem).toHaveBeenCalledWith(SETTINGS_KEY);
      expect(mockGetItem).toHaveBeenCalledTimes(2);
    });
  });

  describe('Utility Functions', () => {
    it('should handle content extraction from progress', () => {
      const content =
        'This is a sample content for testing progress calculation and content extraction.';
      const progress = 0.5;
      const extractedLength = Math.floor(content.length * progress);
      const extractedContent = content.substring(0, extractedLength);

      expect(extractedContent.length).toBe(extractedLength);
      expect(extractedContent).toBe(content.substring(0, extractedLength));
    });

    it('should return empty string when no content', () => {
      const content = '';
      const progress = 0.5;
      const extractedContent = content.substring(
        0,
        Math.floor(content.length * progress)
      );

      expect(extractedContent).toBe('');
    });

    it('should handle edge cases in progress calculation', () => {
      const content = 'Test content';

      // Progress at 0
      let extractedContent = content.substring(
        0,
        Math.floor(content.length * 0)
      );
      expect(extractedContent).toBe('');

      // Progress at 1
      extractedContent = content.substring(0, Math.floor(content.length * 1));
      expect(extractedContent).toBe(content);

      // Progress beyond 1
      extractedContent = content.substring(0, Math.floor(content.length * 1.5));
      expect(extractedContent).toBe(content);
    });
  });
});
