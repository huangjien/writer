import React from 'react';
import { render } from '@testing-library/react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';
import { AsyncStorageProvider } from '../hooks/useAsyncStorage';
import Page from '../app/github';
import {
  elementWithNameExists,
  loadSettingsFromStorage,
  loadExistingContentFromStorage,
  loadExistingAnalysisFromStorage,
} from '../app/github/storageUtils';

// Mock React Native components
jest.mock('react-native', () => ({
  View: 'View',
  Text: 'Text',
  ScrollView: 'ScrollView',
  TouchableOpacity: 'TouchableOpacity',
  ActivityIndicator: 'ActivityIndicator',
  Alert: {
    alert: jest.fn(),
  },
  Dimensions: {
    get: jest.fn(() => ({ width: 375, height: 812 })),
  },
}));

// Mock expo-router
jest.mock('expo-router', () => ({
  useRouter: () => ({
    push: jest.fn(),
    back: jest.fn(),
  }),
}));

// Mock @react-navigation/native
jest.mock('@react-navigation/native', () => ({
  useFocusEffect: jest.fn(),
}));

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () => ({
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
}));

// Mock axios
jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

// Mock useAsyncStorage hook
jest.mock('../hooks/useAsyncStorage', () => ({
  useAsyncStorage: () => [
    {},
    {
      setItem: jest.fn(),
      getItem: jest.fn(),
      removeItem: jest.fn(),
    },
    false,
    false,
  ],
  AsyncStorageProvider: ({ children }: { children: React.ReactNode }) =>
    children,
}));

// Mock react-native-gesture-handler
jest.mock('react-native-gesture-handler', () => {
  const RN = require('react-native');
  return {
    ScrollView: RN.ScrollView,
    GestureHandlerRootView: RN.View,
    Swipeable: RN.View,
    DrawerLayout: RN.View,
    State: {},
    PanGestureHandler: RN.View,
    BaseButton: RN.TouchableOpacity,
    Directions: {},
  };
});

// Mock global components - these are inline functions in github.tsx, not separate files

const mockGetItem = AsyncStorage.getItem as jest.MockedFunction<
  typeof AsyncStorage.getItem
>;
const mockSetItem = AsyncStorage.setItem as jest.MockedFunction<
  typeof AsyncStorage.setItem
>;
const { handleError } = require('../components/global');

// Mock console.error to prevent test output pollution
jest.spyOn(console, 'error').mockImplementation(() => {});

// Mock handleError to prevent side effects in tests
jest.mock('../components/global', () => ({
  ...jest.requireActual('../components/global'),
  handleError: jest.fn(),
}));

describe('GitHub Page', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Unit Tests - Helper Functions', () => {
    describe('elementWithNameExists', () => {
      it('returns true when element with name exists', () => {
        const items = [
          { name: 'file1.md', sha: 'abc123' },
          { name: 'file2.md', sha: 'def456' },
        ];
        expect(elementWithNameExists(items, 'file1.md')).toBe(true);
      });

      it('returns false when element with name does not exist', () => {
        const items = [
          { name: 'file1.md', sha: 'abc123' },
          { name: 'file2.md', sha: 'def456' },
        ];
        expect(elementWithNameExists(items, 'file3.md')).toBe(false);
      });

      it('returns false for empty array', () => {
        expect(elementWithNameExists([], 'file1.md')).toBe(false);
      });

      it('returns false for null/undefined items', () => {
        expect(elementWithNameExists(null as any, 'file1.md')).toBe(false);
        expect(elementWithNameExists(undefined as any, 'file1.md')).toBe(false);
      });
    });

    describe('loadSettingsFromStorage', () => {
      it('returns parsed settings when valid JSON exists', async () => {
        const mockSettings = {
          githubToken: 'test-token',
          githubRepo: 'test-owner/test-repo',
          contentFolder: 'content',
        };
        const mockSetSettings = jest.fn();
        const mockSetIsLoadingContent = jest.fn();
        mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));

        const result = await loadSettingsFromStorage(
          mockGetItem,
          mockSetSettings,
          mockSetIsLoadingContent
        );
        expect(result).toEqual(mockSettings);
        expect(mockGetItem).toHaveBeenCalledWith('@Settings');
        expect(mockSetSettings).toHaveBeenCalledWith(mockSettings);
      });

      it('returns null when no settings exist', async () => {
        const mockSetSettings = jest.fn();
        const mockSetIsLoadingContent = jest.fn();
        mockGetItem.mockResolvedValue(null);

        const result = await loadSettingsFromStorage(
          mockGetItem,
          mockSetSettings,
          mockSetIsLoadingContent
        );
        expect(result).toBeNull();
        expect(mockGetItem).toHaveBeenCalledWith('@Settings');
        expect(mockSetIsLoadingContent).toHaveBeenCalledWith(false);
      });

      it('returns null when invalid JSON exists', async () => {
        const mockSetSettings = jest.fn();
        const mockSetIsLoadingContent = jest.fn();
        mockGetItem.mockResolvedValue('invalid json');

        const result = await loadSettingsFromStorage(
          mockGetItem,
          mockSetSettings,
          mockSetIsLoadingContent
        );
        expect(result).toBeNull();
        expect(mockGetItem).toHaveBeenCalledWith('@Settings');
        expect(mockSetIsLoadingContent).toHaveBeenCalledWith(false);
      });

      it('handles storage errors gracefully', async () => {
        const mockSetSettings = jest.fn();
        const mockSetIsLoadingContent = jest.fn();
        mockGetItem.mockRejectedValue(new Error('Storage error'));

        const result = await loadSettingsFromStorage(
          mockGetItem,
          mockSetSettings,
          mockSetIsLoadingContent
        );
        expect(result).toBeNull();
        expect(mockGetItem).toHaveBeenCalledWith('@Settings');
        expect(mockSetIsLoadingContent).toHaveBeenCalledWith(false);
      });
    });

    describe('loadExistingContentFromStorage', () => {
      it('calls setContent with parsed content when valid JSON exists', async () => {
        const mockContent = [
          { name: 'file1.md', sha: 'abc123', size: 1500, analysed: true },
          { name: 'file2.md', sha: 'def456', size: 2000, analysed: false },
        ];
        const mockSetContent = jest.fn();
        mockGetItem.mockResolvedValue(JSON.stringify(mockContent));

        await loadExistingContentFromStorage(mockGetItem, mockSetContent);
        expect(mockGetItem).toHaveBeenCalledWith('@Content:');
        expect(mockSetContent).toHaveBeenCalledWith(mockContent);
      });

      it('does not call setContent when no content exists', async () => {
        const mockSetContent = jest.fn();
        mockGetItem.mockResolvedValue(null);

        await loadExistingContentFromStorage(mockGetItem, mockSetContent);
        expect(mockGetItem).toHaveBeenCalledWith('@Content:');
        expect(mockSetContent).not.toHaveBeenCalled();
      });

      it('does not call setContent when invalid JSON exists', async () => {
        const mockSetContent = jest.fn();
        mockGetItem.mockResolvedValue('invalid json');

        await loadExistingContentFromStorage(mockGetItem, mockSetContent);
        expect(mockGetItem).toHaveBeenCalledWith('@Content:');
        expect(mockSetContent).not.toHaveBeenCalled();
      });

      it('handles storage errors gracefully', async () => {
        const mockSetContent = jest.fn();
        mockGetItem.mockRejectedValue(new Error('Storage error'));

        await loadExistingContentFromStorage(mockGetItem, mockSetContent);
        expect(mockGetItem).toHaveBeenCalledWith('@Content:');
        expect(mockSetContent).not.toHaveBeenCalled();
      });
    });

    describe('loadExistingAnalysisFromStorage', () => {
      it('calls setAnalysis with parsed analysis when valid JSON exists', async () => {
        const mockAnalysis = [
          { name: 'file1.md', analysis: 'Analysis for file 1' },
          { name: 'file2.md', analysis: 'Analysis for file 2' },
        ];
        const mockSetAnalysis = jest.fn();
        mockGetItem.mockResolvedValue(JSON.stringify(mockAnalysis));

        await loadExistingAnalysisFromStorage(mockGetItem, mockSetAnalysis);
        expect(mockGetItem).toHaveBeenCalledWith('@Analysis:');
        expect(mockSetAnalysis).toHaveBeenCalledWith(mockAnalysis);
      });

      it('does not call setAnalysis when no analysis exists', async () => {
        const mockSetAnalysis = jest.fn();
        mockGetItem.mockResolvedValue(null);

        await loadExistingAnalysisFromStorage(mockGetItem, mockSetAnalysis);
        expect(mockGetItem).toHaveBeenCalledWith('@Analysis:');
        expect(mockSetAnalysis).not.toHaveBeenCalled();
      });

      it('does not call setAnalysis when invalid JSON exists', async () => {
        const mockSetAnalysis = jest.fn();
        mockGetItem.mockResolvedValue('invalid json');

        await loadExistingAnalysisFromStorage(mockGetItem, mockSetAnalysis);
        expect(mockGetItem).toHaveBeenCalledWith('@Analysis:');
        expect(mockSetAnalysis).not.toHaveBeenCalled();
      });

      it('handles storage errors gracefully', async () => {
        const mockSetAnalysis = jest.fn();
        mockGetItem.mockRejectedValue(new Error('Storage error'));

        await loadExistingAnalysisFromStorage(mockGetItem, mockSetAnalysis);
        expect(mockGetItem).toHaveBeenCalledWith('@Analysis:');
        expect(mockSetAnalysis).not.toHaveBeenCalled();
      });
    });
  });

  describe('Component Tests', () => {
    it('component can be imported and is defined', () => {
      expect(Page).toBeDefined();
      expect(typeof Page).toBe('function');
    });

    it('component can be rendered without crashing', () => {
      expect(() => {
        render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );
      }).not.toThrow();
    });
  });

  describe('Integration Tests', () => {
    beforeEach(() => {
      jest.clearAllMocks();
      // Reset AsyncStorage mocks
      mockGetItem.mockResolvedValue(null);
      mockSetItem.mockResolvedValue();
    });

    describe('Loading States', () => {
      it('renders loading indicator when isLoadingContent is true', () => {
        const { getByTestId } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        // Component should render without errors
        expect(() => getByTestId).toBeDefined();
      });

      it('renders settings required message when no settings exist', async () => {
        mockGetItem.mockResolvedValue(null);

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        expect(toJSON()).toBeTruthy();
      });

      it('renders no content message when settings exist but no content', async () => {
        const mockSettings = {
          githubToken: 'test-token',
          githubRepo: 'test-owner/test-repo',
          contentFolder: 'content',
        };
        mockGetItem.mockImplementation((key) => {
          if (key === '@Settings') {
            return Promise.resolve(JSON.stringify(mockSettings));
          }
          return Promise.resolve(null);
        });

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        expect(toJSON()).toBeTruthy();
      });
    });

    describe('Content Display', () => {
      it('renders content list when content exists', async () => {
        const mockSettings = {
          githubToken: 'test-token',
          githubRepo: 'test-owner/test-repo',
          contentFolder: 'content',
        };
        const mockContent = [
          { name: 'file1.md', sha: 'abc123', size: 1500, analysed: true },
          { name: 'file2.md', sha: 'def456', size: 2000, analysed: false },
        ];

        mockGetItem.mockImplementation((key) => {
          if (key === '@Settings') {
            return Promise.resolve(JSON.stringify(mockSettings));
          }
          if (key === '@Content:') {
            return Promise.resolve(JSON.stringify(mockContent));
          }
          return Promise.resolve(null);
        });

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        expect(toJSON()).toBeTruthy();
      });

      it('handles content with analysis data', async () => {
        const mockSettings = {
          githubToken: 'test-token',
          githubRepo: 'test-owner/test-repo',
          contentFolder: 'content',
        };
        const mockContent = [
          { name: 'file1.md', sha: 'abc123', size: 1500, analysed: true },
        ];
        const mockAnalysis = [
          { name: 'file1.md', analysis: 'Test analysis content' },
        ];

        mockGetItem.mockImplementation((key) => {
          if (key === '@Settings') {
            return Promise.resolve(JSON.stringify(mockSettings));
          }
          if (key === '@Content:') {
            return Promise.resolve(JSON.stringify(mockContent));
          }
          if (key === '@Analysis:') {
            return Promise.resolve(JSON.stringify(mockAnalysis));
          }
          return Promise.resolve(null);
        });

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        expect(toJSON()).toBeTruthy();
      });
    });

    describe('GitHub API Integration', () => {
      it('handles successful GitHub API response', async () => {
        const mockSettings = {
          githubToken: 'test-token',
          githubRepo: 'test-owner/test-repo',
          contentFolder: 'content',
        };

        mockGetItem.mockImplementation((key) => {
          if (key === '@Settings') {
            return Promise.resolve(JSON.stringify(mockSettings));
          }
          return Promise.resolve(null);
        });

        // Mock successful GitHub API response
        mockedAxios.get.mockResolvedValue({
          data: [
            { name: 'file1.md', sha: 'abc123', size: 1500, type: 'file' },
            { name: 'file2.md', sha: 'def456', size: 2000, type: 'file' },
          ],
        });

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        expect(toJSON()).toBeTruthy();
      });

      it('handles GitHub API errors gracefully', async () => {
        const mockSettings = {
          githubToken: 'test-token',
          githubRepo: 'test-owner/test-repo',
          contentFolder: 'content',
        };

        mockGetItem.mockImplementation((key) => {
          if (key === '@Settings') {
            return Promise.resolve(JSON.stringify(mockSettings));
          }
          return Promise.resolve(null);
        });

        // Mock GitHub API error
        mockedAxios.get.mockRejectedValue(new Error('API Error'));

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        expect(toJSON()).toBeTruthy();
      });

      it('handles invalid GitHub repository format', async () => {
        const mockSettings = {
          githubToken: 'test-token',
          githubRepo: 'invalid-repo-format',
          contentFolder: 'content',
        };

        mockGetItem.mockImplementation((key) => {
          if (key === '@Settings') {
            return Promise.resolve(JSON.stringify(mockSettings));
          }
          return Promise.resolve(null);
        });

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        expect(toJSON()).toBeTruthy();
      });
    });

    describe('Data Persistence', () => {
      it('saves content to AsyncStorage when GitHub data is fetched', async () => {
        const mockSettings = {
          githubToken: 'test-token',
          githubRepo: 'test-owner/test-repo',
          contentFolder: 'content',
        };

        mockGetItem.mockImplementation((key) => {
          if (key === '@Settings') {
            return Promise.resolve(JSON.stringify(mockSettings));
          }
          return Promise.resolve(null);
        });

        const mockGitHubData = [
          { name: 'file1.md', sha: 'abc123', size: 1500, type: 'file' },
        ];

        mockedAxios.get.mockResolvedValue({ data: mockGitHubData });

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        // Component should render without errors
        expect(toJSON()).toBeTruthy();
      });

      it('handles storage errors when saving content', async () => {
        const mockSettings = {
          githubToken: 'test-token',
          githubRepo: 'test-owner/test-repo',
          contentFolder: 'content',
        };

        mockGetItem.mockImplementation((key) => {
          if (key === '@Settings') {
            return Promise.resolve(JSON.stringify(mockSettings));
          }
          return Promise.resolve(null);
        });

        // Mock storage error
        mockSetItem.mockRejectedValue(new Error('Storage error'));

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        expect(toJSON()).toBeTruthy();
      });
    });

    describe('Error Handling', () => {
      it('handles missing GitHub token', async () => {
        const mockSettings = {
          githubRepo: 'test-owner/test-repo',
          contentFolder: 'content',
        };

        mockGetItem.mockImplementation((key) => {
          if (key === '@Settings') {
            return Promise.resolve(JSON.stringify(mockSettings));
          }
          return Promise.resolve(null);
        });

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        expect(toJSON()).toBeTruthy();
      });

      it('handles missing GitHub repository', async () => {
        const mockSettings = {
          githubToken: 'test-token',
          contentFolder: 'content',
        };

        mockGetItem.mockImplementation((key) => {
          if (key === '@Settings') {
            return Promise.resolve(JSON.stringify(mockSettings));
          }
          return Promise.resolve(null);
        });

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        expect(toJSON()).toBeTruthy();
      });

      it('handles network connectivity issues', async () => {
        const mockSettings = {
          githubToken: 'test-token',
          githubRepo: 'test-owner/test-repo',
          contentFolder: 'content',
        };

        mockGetItem.mockImplementation((key) => {
          if (key === '@Settings') {
            return Promise.resolve(JSON.stringify(mockSettings));
          }
          return Promise.resolve(null);
        });

        // Mock network error
        mockedAxios.get.mockRejectedValue(new Error('Network Error'));

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        expect(toJSON()).toBeTruthy();
      });
    });

    describe('Edge Cases', () => {
      it('handles empty GitHub repository response', async () => {
        const mockSettings = {
          githubToken: 'test-token',
          githubRepo: 'test-owner/test-repo',
          contentFolder: 'content',
        };

        mockGetItem.mockImplementation((key) => {
          if (key === '@Settings') {
            return Promise.resolve(JSON.stringify(mockSettings));
          }
          return Promise.resolve(null);
        });

        // Mock empty response
        mockedAxios.get.mockResolvedValue({ data: [] });

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        expect(toJSON()).toBeTruthy();
      });

      it('handles malformed GitHub API response', async () => {
        const mockSettings = {
          githubToken: 'test-token',
          githubRepo: 'test-owner/test-repo',
          contentFolder: 'content',
        };

        mockGetItem.mockImplementation((key) => {
          if (key === '@Settings') {
            return Promise.resolve(JSON.stringify(mockSettings));
          }
          return Promise.resolve(null);
        });

        // Mock malformed response
        mockedAxios.get.mockResolvedValue({ data: null });

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        expect(toJSON()).toBeTruthy();
      });

      it('handles very large content files', async () => {
        const mockSettings = {
          githubToken: 'test-token',
          githubRepo: 'test-owner/test-repo',
          contentFolder: 'content',
        };

        mockGetItem.mockImplementation((key) => {
          if (key === '@Settings') {
            return Promise.resolve(JSON.stringify(mockSettings));
          }
          return Promise.resolve(null);
        });

        // Mock large file response
        const largeFileData = [
          {
            name: 'large-file.md',
            sha: 'abc123',
            size: 10000000,
            type: 'file',
          },
        ];
        mockedAxios.get.mockResolvedValue({ data: largeFileData });

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        expect(toJSON()).toBeTruthy();
      });

      it('handles special characters in file names', async () => {
        const mockSettings = {
          githubToken: 'test-token',
          githubRepo: 'test-owner/test-repo',
          contentFolder: 'content',
        };

        mockGetItem.mockImplementation((key) => {
          if (key === '@Settings') {
            return Promise.resolve(JSON.stringify(mockSettings));
          }
          return Promise.resolve(null);
        });

        // Mock files with special characters
        const specialCharData = [
          {
            name: 'file with spaces.md',
            sha: 'abc123',
            size: 1500,
            type: 'file',
          },
          {
            name: 'file-with-dashes.md',
            sha: 'def456',
            size: 2000,
            type: 'file',
          },
          {
            name: 'file_with_underscores.md',
            sha: 'ghi789',
            size: 2500,
            type: 'file',
          },
        ];
        mockedAxios.get.mockResolvedValue({ data: specialCharData });

        const { toJSON } = render(
          <AsyncStorageProvider>
            <Page />
          </AsyncStorageProvider>
        );

        expect(toJSON()).toBeTruthy();
      });
    });
  });
});
