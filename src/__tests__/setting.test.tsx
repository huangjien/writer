import React from 'react';
import { render, fireEvent, waitFor, act } from '@testing-library/react-native';
import { useIsFocused } from '@react-navigation/native';
import * as Speech from 'expo-speech';
import Page from '../app/setting';
import { SETTINGS_KEY } from '../components/global';

// Mock dependencies
jest.mock('@react-navigation/native');
jest.mock('expo-speech');
jest.mock('react-native-gesture-handler', () => ({
  ScrollView: ({ children }: { children: React.ReactNode }) => children,
}));
jest.mock(
  '@react-native-segmented-control/segmented-control',
  () => 'SegmentedControl'
);
jest.mock('react-hook-form', () => ({
  useForm: () => ({
    control: {},
    handleSubmit: (fn: Function) => fn,
    setValue: jest.fn(),
    getValues: jest.fn().mockReturnValue(['@Content:chapter1.md']),
    formState: { errors: {} },
  }),
  Controller: ({ render, name }: { render: Function; name: string }) => {
    const field = {
      onChange: jest.fn(),
      onBlur: jest.fn(),
      value:
        name === 'githubRepo'
          ? 'https://github.com/user/repo'
          : name === 'githubToken'
            ? 'token123'
            : name === 'contentFolder'
              ? 'Content'
              : name === 'analysisFolder'
                ? 'Analysis'
                : name === 'fontSize'
                  ? 16
                  : name === 'backgroundImage'
                    ? 'wood.jpg'
                    : name === 'current'
                      ? '@Content:chapter1.md'
                      : name === 'progress'
                        ? 0.5
                        : '',
    };
    return render({ field });
  },
}));

const mockUseIsFocused = useIsFocused as jest.MockedFunction<
  typeof useIsFocused
>;
const mockSpeech = Speech as jest.Mocked<typeof Speech>;

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

// Mock global functions
jest.mock('../components/global', () => ({
  CONTENT_KEY: '@Content:',
  SETTINGS_KEY: '@Settings',
  showInfoToast: jest.fn(),
  showErrorToast: jest.fn(),
}));

describe('Settings Page', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockUseIsFocused.mockReturnValue(true);
    mockSpeech.getAvailableVoicesAsync.mockResolvedValue([]);
  });

  describe('Mock Setup', () => {
    it('should have mocked dependencies', () => {
      expect(mockGetItem).toBeDefined();
      expect(mockSetItem).toBeDefined();
      expect(mockRemoveItem).toBeDefined();
    });

    it('should have mocked useIsFocused', () => {
      expect(mockUseIsFocused).toBeDefined();
    });

    it('should have mocked Speech', () => {
      expect(mockSpeech.getAvailableVoicesAsync).toBeDefined();
    });
  });
});
