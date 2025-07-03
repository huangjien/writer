import React from 'react';
import { render } from '@testing-library/react-native';
import { Text } from 'react-native';
import { AsyncStorageProvider } from '../hooks/useAsyncStorage';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage');
const mockAsyncStorage = AsyncStorage as jest.Mocked<typeof AsyncStorage>;

describe('AsyncStorageProvider Basic Test', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockAsyncStorage.getAllKeys.mockResolvedValue([]);
    mockAsyncStorage.multiGet.mockResolvedValue([]);
  });

  it('should render children without crashing', () => {
    const TestChild = () => React.createElement(Text, null, 'Test Child');

    expect(() => {
      render(
        React.createElement(
          AsyncStorageProvider,
          null,
          React.createElement(TestChild)
        )
      );
    }).not.toThrow();
  });

  it('should render with JSX syntax', () => {
    const TestChild = () => <Text>Test Child</Text>;

    expect(() => {
      render(
        <AsyncStorageProvider>
          <TestChild />
        </AsyncStorageProvider>
      );
    }).not.toThrow();
  });
});
