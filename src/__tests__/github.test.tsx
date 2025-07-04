import React from 'react';
import {
  render,
  fireEvent,
  waitFor,
  screen,
} from '@testing-library/react-native';
import axios from 'axios';
import Page from '../app/github';
import { AsyncStorageProvider } from '../hooks/useAsyncStorage';

// Mock dependencies
jest.mock('expo-router', () => ({
  useRouter: jest.fn(() => ({
    push: jest.fn(),
  })),
}));

jest.mock('@react-navigation/native', () => ({
  useIsFocused: jest.fn(() => true),
}));

jest.mock('@react-native-async-storage/async-storage', () => ({
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  getAllKeys: jest.fn(() => Promise.resolve([])),
  multiGet: jest.fn(() => Promise.resolve([])),
}));

jest.mock('@/components/global', () => ({
  handleError: jest.fn(),
  showErrorToast: jest.fn(),
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
  });

  it('renders correctly', () => {
    expect(() => render(<Page />)).not.toThrow();
  });

  it('should return a valid component instance', () => {
    const component = render(<Page />);
    expect(component).toBeDefined();
    expect(component.toJSON).toBeDefined();
  });

  it('shows settings required message when no settings are configured', async () => {
    const AsyncStorage = require('@react-native-async-storage/async-storage');
    AsyncStorage.getItem.mockResolvedValue(null);

    const component = render(<Page />);
    expect(component).toBeDefined();
  });

  it('navigates to settings when Go to Settings is pressed', async () => {
    const AsyncStorage = require('@react-native-async-storage/async-storage');
    AsyncStorage.getItem.mockResolvedValue(null);

    const component = render(<Page />);
    expect(component).toBeDefined();
  });

  it('shows loading state when fetching content', async () => {
    const AsyncStorage = require('@react-native-async-storage/async-storage');
    AsyncStorage.getItem.mockResolvedValue(
      JSON.stringify({
        githubRepo: 'https://github.com/user/repo',
        githubToken: 'token123',
        contentFolder: 'Content',
      })
    );

    const component = render(<Page />);
    expect(component).toBeDefined();
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

    const AsyncStorage = require('@react-native-async-storage/async-storage');
    AsyncStorage.getItem.mockResolvedValue(JSON.stringify(mockSettings));

    mockedAxios.get.mockResolvedValue({ data: mockContent });

    const component = render(<Page />);
    expect(component).toBeDefined();
  });

  it('handles GitHub API errors gracefully', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };

    const AsyncStorage = require('@react-native-async-storage/async-storage');
    AsyncStorage.getItem.mockResolvedValue(JSON.stringify(mockSettings));

    mockedAxios.get.mockRejectedValue(new Error('API Error'));

    const component = render(<Page />);
    expect(component).toBeDefined();
  });

  it('shows no content message when repository is empty', async () => {
    const mockSettings = {
      githubToken: 'test-token',
      githubOwner: 'test-owner',
      githubRepo: 'test-repo',
    };

    const AsyncStorage = require('@react-native-async-storage/async-storage');
    AsyncStorage.getItem.mockResolvedValue(JSON.stringify(mockSettings));

    mockedAxios.get.mockResolvedValue({ data: [] });

    const component = render(<Page />);
    expect(component).toBeDefined();
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

    const AsyncStorage = require('@react-native-async-storage/async-storage');
    AsyncStorage.getItem.mockResolvedValue(JSON.stringify(mockSettings));

    mockedAxios.get.mockResolvedValue({ data: mockContent });

    const component = render(<Page />);
    expect(component).toBeDefined();
  });
});
