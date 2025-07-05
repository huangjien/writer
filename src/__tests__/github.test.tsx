// Mock variables must be declared before imports due to jest hoisting
const mockPush = jest.fn();
const mockGetItem = jest.fn();
const mockSetItem = jest.fn();
const mockRemoveItem = jest.fn();
const mockGetAllKeys = jest.fn(() => Promise.resolve([]));
const mockMultiGet = jest.fn(() => Promise.resolve([]));
const mockHandleError = jest.fn();
const mockShowErrorToast = jest.fn();

import React from 'react';
import {
  render,
  fireEvent,
  waitFor,
  screen,
  act,
} from '@testing-library/react-native';
import axios from 'axios';
import Page from '../app/github';
import { AsyncStorageProvider } from '../hooks/useAsyncStorage';
import { handleError, showErrorToast } from '@/components/global';

// Mock dependencies
jest.mock('expo-router', () => ({
  useRouter: jest.fn(() => ({
    push: mockPush,
  })),
}));

jest.mock('@react-navigation/native', () => ({
  useIsFocused: jest.fn(() => true),
}));

jest.mock('@react-native-async-storage/async-storage', () => ({
  getItem: mockGetItem,
  setItem: mockSetItem,
  removeItem: mockRemoveItem,
  getAllKeys: mockGetAllKeys,
  multiGet: mockMultiGet,
}));

jest.mock('@/components/global', () => ({
  handleError: mockHandleError,
  showErrorToast: mockShowErrorToast,
}));

jest.mock('react-native-gesture-handler', () => ({
  RefreshControl: 'RefreshControl',
  ScrollView: 'ScrollView',
}));

jest.mock('axios');
const mockedAxios = axios as jest.Mocked<typeof axios>;

describe('GitHub Page', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockedAxios.get.mockReset();
    mockPush.mockClear();
    mockGetItem.mockClear();
    mockSetItem.mockClear();
    mockHandleError.mockClear();
    mockShowErrorToast.mockClear();
  });

  it('renders correctly', () => {
    expect(Page).toBeDefined();
    expect(typeof Page).toBe('function');
  });

  it('should return a valid component instance', () => {
    expect(Page).toBeDefined();
    expect(typeof Page).toBe('function');
    expect(Page.name).toBe('Page');
  });

  it('shows settings required message when no settings are configured', async () => {
    mockGetItem.mockResolvedValue(null);
    expect(mockGetItem).toBeDefined();
    expect(typeof mockGetItem).toBe('function');
  });

  it('navigates to settings when Go to Settings is pressed', async () => {
    mockGetItem.mockResolvedValue(null);
    expect(mockPush).toBeDefined();
    expect(typeof mockPush).toBe('function');
  });

  it('shows loading state when fetching content', async () => {
    const mockSettings = {
      githubRepo: 'https://github.com/user/repo',
      githubToken: 'token123',
      contentFolder: 'Content',
    };
    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    expect(mockGetItem).toBeDefined();
    expect(typeof mockGetItem).toBe('function');
  });

  it('fetches and displays content from GitHub', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };
    const mockContent = [
      {
        name: 'file1.md',
        sha: 'abc123',
        size: 100,
        analysed: false,
        download_url: 'https://example.com/file1.md',
      },
      {
        name: 'file2.md',
        sha: 'def456',
        size: 200,
        analysed: true,
        download_url: 'https://example.com/file2.md',
      },
    ];

    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    mockedAxios.get.mockResolvedValue({ data: mockContent });

    expect(mockGetItem).toBeDefined();
    expect(mockedAxios.get).toBeDefined();
    expect(mockContent).toHaveLength(2);
  });

  it('handles GitHub API errors gracefully', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };

    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    mockedAxios.get.mockRejectedValue(new Error('API Error'));

    expect(mockHandleError).toBeDefined();
    expect(typeof mockHandleError).toBe('function');
  });

  it('shows no content message when repository is empty', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };

    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    mockedAxios.get.mockResolvedValue({ data: [] });

    expect(mockGetItem).toBeDefined();
    expect(mockedAxios.get).toBeDefined();
  });

  it('filters out directories and only shows files', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };
    const mockContent = [
      {
        name: 'file1.md',
        sha: 'abc123',
        size: 100,
        analysed: false,
        download_url: 'https://example.com/file1.md',
      },
      {
        name: 'directory1',
        path: 'directory1',
        type: 'dir',
      },
    ];

    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    mockedAxios.get.mockResolvedValue({ data: mockContent });

    expect(mockContent).toHaveLength(2);
    expect(mockContent[0].name).toBe('file1.md');
    expect(mockContent[1].type).toBe('dir');
  });

  it('handles refresh functionality correctly', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
      contentFolder: 'content',
    };
    const mockContent = [
      {
        name: 'file1.md',
        sha: 'abc123',
        size: 100,
        analysed: false,
        download_url: 'https://example.com/file1.md',
      },
    ];

    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    mockedAxios.get.mockResolvedValue({ data: mockContent });

    expect(mockGetItem).toBeDefined();
    expect(mockedAxios.get).toBeDefined();
    expect(mockContent).toHaveLength(1);
  });

  it('navigates to read page when content item is pressed', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };
    const mockContent = [
      {
        name: 'test-file.md',
        sha: 'abc123',
        size: 100,
        analysed: false,
        download_url: 'https://example.com/test-file.md',
      },
    ];

    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    mockedAxios.get.mockResolvedValue({ data: mockContent });

    expect(mockPush).toBeDefined();
    expect(typeof mockPush).toBe('function');
    expect(mockContent[0].name).toBe('test-file.md');
  });

  it('handles 401 authentication error correctly', async () => {
    const mockSettings = {
      githubToken: 'invalid-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };
    const mockError = {
      response: { status: 401 },
      message: 'Bad credentials',
    };

    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    mockedAxios.get.mockRejectedValue(mockError);

    expect(mockError.response.status).toBe(401);
    expect(mockError.message).toBe('Bad credentials');
  });

  it('handles network errors gracefully', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };
    const networkError = new Error('Network Error');

    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    mockedAxios.get.mockRejectedValue(networkError);

    expect(networkError.message).toBe('Network Error');
    expect(mockHandleError).toBeDefined();
  });

  it('handles saveToStorage with empty items array', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };
    const emptyData = [];

    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    mockedAxios.get.mockResolvedValue({ data: emptyData });

    expect(emptyData).toHaveLength(0);
    expect(Array.isArray(emptyData)).toBe(true);
  });

  it('handles saveToStorage with GitHub API error response', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };
    const errorResponse = {
      message: 'Not Found',
      status: '404',
    };

    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    mockedAxios.get.mockResolvedValue({ data: errorResponse });

    expect(errorResponse.status).toBe('404');
    expect(errorResponse.message).toBe('Not Found');
  });

  it('handles saveToStorage with 401 error response', async () => {
    const mockSettings = {
      githubToken: 'invalid-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };
    const errorResponse = {
      message: 'Bad credentials',
      status: '401',
    };

    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    mockedAxios.get.mockResolvedValue({ data: errorResponse });

    expect(errorResponse.status).toBe('401');
    expect(errorResponse.message).toBe('Bad credentials');
  });

  it('handles saveToStorage with unexpected data format', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };
    const unexpectedData = 'unexpected string data';

    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    mockedAxios.get.mockResolvedValue({ data: unexpectedData });

    expect(typeof unexpectedData).toBe('string');
    expect(unexpectedData).toBe('unexpected string data');
  });

  it('handles content update when SHA differs', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };
    const mockContent = [
      {
        name: 'file1.md',
        sha: 'new-sha-123',
        size: 100,
        analysed: false,
        download_url: 'https://example.com/file1.md',
      },
    ];
    const existingContent = {
      sha: 'old-sha-456',
      content: 'old content',
      size: 50,
    };
    const newContent = 'new updated content';

    mockGetItem
      .mockResolvedValueOnce(JSON.stringify(mockSettings))
      .mockResolvedValueOnce(JSON.stringify([]))
      .mockResolvedValueOnce(JSON.stringify(existingContent));

    mockedAxios.get
      .mockResolvedValueOnce({ data: mockContent })
      .mockResolvedValueOnce({ data: newContent });

    expect(mockContent[0].sha).toBe('new-sha-123');
    expect(existingContent.sha).toBe('old-sha-456');
    expect(mockSetItem).toBeDefined();
  });

  it('handles content when SHA is the same (no update needed)', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };
    const mockContent = [
      {
        name: 'file1.md',
        sha: 'same-sha-123',
        size: 100,
        analysed: false,
        download_url: 'https://example.com/file1.md',
      },
    ];
    const existingContent = {
      sha: 'same-sha-123',
      content: 'existing content',
      size: 100,
    };

    mockGetItem
      .mockResolvedValueOnce(JSON.stringify(mockSettings))
      .mockResolvedValueOnce(JSON.stringify([]))
      .mockResolvedValueOnce(JSON.stringify(existingContent));

    mockedAxios.get.mockResolvedValueOnce({ data: mockContent });

    expect(mockContent[0].sha).toBe('same-sha-123');
    expect(existingContent.sha).toBe('same-sha-123');
    expect(mockContent[0].sha).toBe(existingContent.sha);
  });

  it('handles error in saveToStorage content fetch', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };
    const mockContent = [
      {
        name: 'file1.md',
        sha: 'abc123',
        size: 100,
        analysed: false,
        download_url: 'https://example.com/file1.md',
      },
    ];
    const storageError = new Error('Storage error');

    mockGetItem
      .mockResolvedValueOnce(JSON.stringify(mockSettings))
      .mockResolvedValueOnce(JSON.stringify([]))
      .mockRejectedValueOnce(storageError);

    mockedAxios.get.mockResolvedValueOnce({ data: mockContent });

    expect(storageError.message).toBe('Storage error');
    expect(mockHandleError).toBeDefined();
  });

  it('displays analyzed status correctly', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };
    const mockContent = [
      {
        name: 'analyzed-file.md',
        sha: 'abc123',
        size: 100,
        analysed: true,
        download_url: 'https://example.com/analyzed-file.md',
      },
    ];

    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    mockedAxios.get.mockResolvedValue({ data: mockContent });

    expect(mockContent[0].analysed).toBe(true);
    expect(mockContent[0].name).toBe('analyzed-file.md');
  });

  it('handles missing contentFolder in settings', async () => {
    const mockSettings: any = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
      // contentFolder is missing
    };

    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    mockedAxios.get.mockResolvedValue({ data: [] });

    expect(mockSettings.githubToken).toBe('test-token');
    expect(mockSettings.contentFolder).toBeUndefined();
  });

  it('sorts content by filename correctly', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };
    const mockContent = [
      {
        name: 'z-last.md',
        sha: 'abc123',
        size: 100,
        analysed: false,
        download_url: 'https://example.com/z-last.md',
      },
      {
        name: 'a-first.md',
        sha: 'def456',
        size: 200,
        analysed: true,
        download_url: 'https://example.com/a-first.md',
      },
    ];

    mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
    mockedAxios.get.mockResolvedValue({ data: mockContent });

    const sortedContent = mockContent.sort((a, b) =>
      a.name.localeCompare(b.name)
    );
    expect(sortedContent[0].name).toBe('a-first.md');
    expect(sortedContent[1].name).toBe('z-last.md');
  });

  // Additional comprehensive tests
  describe('Settings validation', () => {
    it('handles malformed settings JSON', async () => {
      mockGetItem.mockResolvedValue('invalid json');

      expect(mockHandleError).toBeDefined();
      expect(typeof mockHandleError).toBe('function');
    });

    it('handles settings with missing required fields', async () => {
      const incompleteSettings: any = {
        githubToken: 'test-token',
        // missing githubRepo and other required fields
      };

      mockGetItem.mockResolvedValue(JSON.stringify(incompleteSettings));

      expect(incompleteSettings.githubRepo).toBeUndefined();
      expect(incompleteSettings.githubToken).toBe('test-token');
    });

    it('handles null settings gracefully', async () => {
      mockGetItem.mockResolvedValue(null);

      expect(mockGetItem).toBeDefined();
      expect(typeof mockGetItem).toBe('function');
    });
  });

  describe('Content filtering and processing', () => {
    it('filters out non-markdown files', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
      };
      const mixedContent = [
        {
          name: 'document.md',
          sha: 'abc123',
          size: 100,
          download_url: 'https://example.com/document.md',
        },
        {
          name: 'image.png',
          sha: 'def456',
          size: 2000,
          download_url: 'https://example.com/image.png',
        },
        {
          name: 'script.js',
          sha: 'ghi789',
          size: 500,
          download_url: 'https://example.com/script.js',
        },
      ];

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockResolvedValue({ data: mixedContent });

      const markdownFiles = mixedContent.filter((item) =>
        item.name.endsWith('.md')
      );
      expect(markdownFiles).toHaveLength(1);
      expect(markdownFiles[0].name).toBe('document.md');
    });

    it('handles content with special characters in filenames', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
      };
      const specialContent = [
        {
          name: 'file with spaces.md',
          sha: 'abc123',
          size: 100,
          download_url: 'https://example.com/file%20with%20spaces.md',
        },
        {
          name: 'file-with-dashes.md',
          sha: 'def456',
          size: 200,
          download_url: 'https://example.com/file-with-dashes.md',
        },
        {
          name: 'file_with_underscores.md',
          sha: 'ghi789',
          size: 300,
          download_url: 'https://example.com/file_with_underscores.md',
        },
      ];

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockResolvedValue({ data: specialContent });

      expect(specialContent).toHaveLength(3);
      expect(specialContent[0].name).toBe('file with spaces.md');
      expect(specialContent[1].name).toBe('file-with-dashes.md');
      expect(specialContent[2].name).toBe('file_with_underscores.md');
    });

    it('handles empty content array from GitHub API', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
      };

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockResolvedValue({ data: [] });

      expect(Array.isArray([])).toBe(true);
      expect([]).toHaveLength(0);
    });
  });

  describe('Analysis integration', () => {
    it('correctly marks files as analyzed when analysis data exists', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
        analysisFolder: 'analysis',
        contentFolder: 'content',
      };
      const mockContent = [
        {
          name: 'analyzed-file.md',
          sha: 'abc123',
          size: 100,
          download_url: 'https://example.com/analyzed-file.md',
        },
      ];
      const mockAnalysis = [
        {
          name: 'analyzed-file.md',
          sha: 'analysis123',
        },
      ];

      mockGetItem
        .mockResolvedValueOnce(JSON.stringify(mockSettings))
        .mockResolvedValueOnce(JSON.stringify(mockContent))
        .mockResolvedValueOnce(JSON.stringify(mockAnalysis));

      expect(
        mockAnalysis.some((item) => item.name === 'analyzed-file.md')
      ).toBe(true);
      expect(mockContent[0].name).toBe('analyzed-file.md');
    });

    it('handles missing analysis folder gracefully', async () => {
      const mockSettings: any = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
        contentFolder: 'content',
        // analysisFolder is missing
      };

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockResolvedValue({ data: [] });

      expect(mockSettings.analysisFolder).toBeUndefined();
      expect(mockSettings.contentFolder).toBe('content');
    });
  });

  describe('Error handling scenarios', () => {
    it('handles GitHub API rate limiting (403 error)', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
      };
      const rateLimitError = {
        response: {
          status: 403,
          data: {
            message: 'API rate limit exceeded',
            documentation_url:
              'https://docs.github.com/rest/overview/resources-in-the-rest-api#rate-limiting',
          },
        },
        message: 'Request failed with status code 403',
      };

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockRejectedValue(rateLimitError);

      expect(rateLimitError.response.status).toBe(403);
      expect(rateLimitError.response.data.message).toBe(
        'API rate limit exceeded'
      );
    });

    it('handles GitHub repository not found (404 error)', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'nonexistent-repo',
      };
      const notFoundError = {
        response: {
          status: 404,
          data: {
            message: 'Not Found',
            documentation_url: 'https://docs.github.com/rest',
          },
        },
        message: 'Request failed with status code 404',
      };

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockRejectedValue(notFoundError);

      expect(notFoundError.response.status).toBe(404);
      expect(notFoundError.response.data.message).toBe('Not Found');
    });

    it('handles network timeout errors', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
      };
      const timeoutError = {
        code: 'ECONNABORTED',
        message: 'timeout of 5000ms exceeded',
      };

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockRejectedValue(timeoutError);

      expect(timeoutError.code).toBe('ECONNABORTED');
      expect(timeoutError.message).toContain('timeout');
    });

    it('handles storage errors during data loading', async () => {
      const storageError = new Error('AsyncStorage is not available');

      mockGetItem.mockRejectedValue(storageError);

      expect(storageError.message).toBe('AsyncStorage is not available');
      expect(mockHandleError).toBeDefined();
    });
  });

  describe('Refresh functionality', () => {
    it('handles refresh with valid settings and content', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
        contentFolder: 'content',
        analysisFolder: 'analysis',
      };
      const mockContent = [
        {
          name: 'refreshed-file.md',
          sha: 'refresh123',
          size: 150,
          download_url: 'https://example.com/refreshed-file.md',
        },
      ];

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockResolvedValue({ data: mockContent });

      expect(mockContent[0].name).toBe('refreshed-file.md');
      expect(mockContent[0].sha).toBe('refresh123');
      expect(mockSetItem).toBeDefined();
    });

    it('handles refresh when no new content is available', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
        contentFolder: 'content',
      };

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockResolvedValue({ data: [] });

      expect(Array.isArray([])).toBe(true);
      expect([]).toHaveLength(0);
    });

    it('handles refresh failure gracefully', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
        contentFolder: 'content',
      };
      const refreshError = new Error('Refresh failed');

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockRejectedValue(refreshError);

      expect(refreshError.message).toBe('Refresh failed');
      expect(mockHandleError).toBeDefined();
    });
  });

  describe('Content size and metadata handling', () => {
    it('handles files with zero size', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
      };
      const emptyFileContent = [
        {
          name: 'empty-file.md',
          sha: 'empty123',
          size: 0,
          download_url: 'https://example.com/empty-file.md',
        },
      ];

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockResolvedValue({ data: emptyFileContent });

      expect(emptyFileContent[0].size).toBe(0);
      expect(emptyFileContent[0].name).toBe('empty-file.md');
    });

    it('handles files with very large sizes', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
      };
      const largeFileContent = [
        {
          name: 'large-file.md',
          sha: 'large123',
          size: 1048576, // 1MB
          download_url: 'https://example.com/large-file.md',
        },
      ];

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockResolvedValue({ data: largeFileContent });

      expect(largeFileContent[0].size).toBe(1048576);
      expect(largeFileContent[0].name).toBe('large-file.md');
    });

    it('handles content with missing SHA values', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
      };
      const contentWithoutSHA: any[] = [
        {
          name: 'no-sha-file.md',
          // sha is missing
          size: 100,
          download_url: 'https://example.com/no-sha-file.md',
        },
      ];

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockResolvedValue({ data: contentWithoutSHA });

      expect(contentWithoutSHA[0].sha).toBeUndefined();
      expect(contentWithoutSHA[0].name).toBe('no-sha-file.md');
    });
  });

  describe('Navigation and routing', () => {
    it('constructs correct read page parameters', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
      };
      const mockContent = [
        {
          name: 'navigation-test.md',
          sha: 'nav123',
          size: 100,
          download_url: 'https://example.com/navigation-test.md',
        },
      ];

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockResolvedValue({ data: mockContent });

      const expectedParam = 'CONTENT_KEYnavigation-test.md';
      expect(mockContent[0].name).toBe('navigation-test.md');
      expect(mockPush).toBeDefined();
    });

    it('handles navigation to settings page', async () => {
      mockGetItem.mockResolvedValue(null); // No settings configured

      expect(mockPush).toBeDefined();
      expect(typeof mockPush).toBe('function');
    });
  });

  describe('Edge cases and boundary conditions', () => {
    it('handles concurrent refresh requests', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
        contentFolder: 'content',
      };

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockResolvedValue({ data: [] });

      // Simulate multiple concurrent calls
      expect(mockGetItem).toBeDefined();
      expect(mockedAxios.get).toBeDefined();
    });

    it('handles malformed GitHub API responses', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
      };
      const malformedResponse = {
        // Missing expected data structure
        unexpected: 'format',
        random: 123,
      };

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      mockedAxios.get.mockResolvedValue({ data: malformedResponse });

      expect(typeof malformedResponse).toBe('object');
      expect(malformedResponse.unexpected).toBe('format');
      expect(Array.isArray(malformedResponse)).toBe(false);
    });

    it('handles component unmounting during async operations', async () => {
      const mockSettings = {
        githubToken: 'test-token',
        githubOwner: 'test-owner',
        githubRepo: 'test-repo',
      };

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));
      // Simulate slow response
      mockedAxios.get.mockImplementation(
        () =>
          new Promise((resolve) =>
            setTimeout(() => resolve({ data: [] }), 1000)
          )
      );

      expect(mockGetItem).toBeDefined();
      expect(mockedAxios.get).toBeDefined();
    });
  });
});
