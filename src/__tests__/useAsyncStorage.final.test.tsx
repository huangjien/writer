/**
 * Final test for useAsyncStorage hook - bypassing renderHook issues
 */
import React from 'react';
import { render } from '@testing-library/react-native';
import { Text } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  AsyncStorageProvider,
  useAsyncStorage,
} from '../hooks/useAsyncStorage';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () => ({
  getAllKeys: jest.fn(() => Promise.resolve([])),
  multiGet: jest.fn(() => Promise.resolve([])),
  getItem: jest.fn(() => Promise.resolve(null)),
  setItem: jest.fn(() => Promise.resolve()),
  removeItem: jest.fn(() => Promise.resolve()),
}));

const mockAsyncStorage = AsyncStorage as jest.Mocked<typeof AsyncStorage>;

describe('useAsyncStorage Final Test', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockAsyncStorage.getAllKeys.mockResolvedValue([]);
    mockAsyncStorage.multiGet.mockResolvedValue([]);
    mockAsyncStorage.getItem.mockResolvedValue(null);
    mockAsyncStorage.setItem.mockResolvedValue();
    mockAsyncStorage.removeItem.mockResolvedValue();
  });

  it('should throw error when used outside provider', () => {
    // Test component that tries to use the hook outside provider
    const TestComponent = () => {
      try {
        useAsyncStorage();
        return React.createElement(Text, null, 'Should not reach here');
      } catch (error) {
        return React.createElement(
          Text,
          { testID: 'error-message' },
          (error as Error).message
        );
      }
    };

    const { getByTestId } = render(React.createElement(TestComponent));
    const errorMessage = getByTestId('error-message');
    expect(errorMessage.props.children).toBe(
      'useAsyncStorage must be used within an AsyncStorageProvider'
    );
  });

  it('should work when used within provider', async () => {
    let hookResult: any = null;

    // Test component that uses the hook within provider
    const TestComponent = () => {
      try {
        hookResult = useAsyncStorage();
        return React.createElement(
          Text,
          { testID: 'success' },
          'Hook called successfully'
        );
      } catch (error) {
        return React.createElement(
          Text,
          { testID: 'error' },
          (error as Error).message
        );
      }
    };

    const WrappedComponent = () => {
      return React.createElement(
        AsyncStorageProvider,
        null,
        React.createElement(TestComponent)
      );
    };

    const { getByTestId } = render(React.createElement(WrappedComponent));

    // Wait a bit for async initialization
    await new Promise((resolve) => setTimeout(resolve, 100));

    const successElement = getByTestId('success');
    expect(successElement.props.children).toBe('Hook called successfully');

    // Verify hook result structure
    expect(hookResult).not.toBeNull();
    expect(Array.isArray(hookResult)).toBe(true);
    expect(hookResult).toHaveLength(4);

    const [storage, operations, isLoading, hasChanged] = hookResult;
    expect(typeof storage).toBe('object');
    expect(typeof operations).toBe('object');
    expect(typeof isLoading).toBe('boolean');
    expect(typeof hasChanged).toBe('boolean');

    // Verify operations structure
    expect(typeof operations.getItem).toBe('function');
    expect(typeof operations.setItem).toBe('function');
    expect(typeof operations.removeItem).toBe('function');
  });
});
