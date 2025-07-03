import React from 'react';
import { render } from '@testing-library/react-native';
import { View, Text } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  AsyncStorageProvider,
  useAsyncStorage,
} from '../hooks/useAsyncStorage';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage');
const mockAsyncStorage = AsyncStorage as jest.Mocked<typeof AsyncStorage>;

describe('useAsyncStorage Simple Test', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockAsyncStorage.getAllKeys.mockResolvedValue([]);
    mockAsyncStorage.multiGet.mockResolvedValue([]);
    mockAsyncStorage.getItem.mockResolvedValue(null);
    mockAsyncStorage.setItem.mockResolvedValue();
    mockAsyncStorage.removeItem.mockResolvedValue();
  });

  it('should provide context value without renderHook', () => {
    let hookResult: any = null;
    let hookError: any = null;

    const TestComponent = () => {
      try {
        hookResult = useAsyncStorage();
        return React.createElement(Text, null, 'Success');
      } catch (error) {
        hookError = error;
        return React.createElement(Text, null, 'Error');
      }
    };

    const App = () => {
      return React.createElement(
        AsyncStorageProvider,
        null,
        React.createElement(TestComponent)
      );
    };

    render(React.createElement(App));

    expect(hookError).toBeNull();
    expect(hookResult).not.toBeNull();
    expect(hookResult).toBeDefined();
    expect(Array.isArray(hookResult)).toBe(true);
    expect(hookResult).toHaveLength(4);
  });

  it('should throw error when used outside provider', () => {
    let hookError: any = null;

    const TestComponent = () => {
      try {
        useAsyncStorage();
        return React.createElement(Text, null, 'Success');
      } catch (error) {
        hookError = error;
        return React.createElement(Text, null, 'Error');
      }
    };

    render(React.createElement(TestComponent));

    expect(hookError).not.toBeNull();
    expect(hookError.message).toBe(
      'useAsyncStorage must be used within an AsyncStorageProvider'
    );
  });
});
