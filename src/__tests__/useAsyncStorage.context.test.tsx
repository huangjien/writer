/**
 * Test to verify React context is working properly
 */
import React from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  AsyncStorageProvider,
  useAsyncStorage,
} from '../hooks/useAsyncStorage';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage');
const mockAsyncStorage = AsyncStorage as jest.Mocked<typeof AsyncStorage>;

describe('useAsyncStorage Context Test', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockAsyncStorage.getAllKeys.mockResolvedValue([]);
    mockAsyncStorage.multiGet.mockResolvedValue([]);
    mockAsyncStorage.getItem.mockResolvedValue(null);
    mockAsyncStorage.setItem.mockResolvedValue();
    mockAsyncStorage.removeItem.mockResolvedValue();
  });

  it('should throw error when used outside provider', () => {
    // Test direct hook call without provider
    expect(() => {
      useAsyncStorage();
    }).toThrow('useAsyncStorage must be used within an AsyncStorageProvider');
  });

  it('should work when used within provider context', async () => {
    let hookResult: any = null;
    let hookError: any = null;

    // Create a test component that uses the hook
    const TestComponent = () => {
      try {
        hookResult = useAsyncStorage();
        return null;
      } catch (error) {
        hookError = error;
        return null;
      }
    };

    // Create provider with test component
    const ProviderWithComponent = () => {
      return React.createElement(
        AsyncStorageProvider,
        null,
        React.createElement(TestComponent)
      );
    };

    // Render the provider (this should work without testing library)
    const element = React.createElement(ProviderWithComponent);

    // The hook should be called during element creation
    // If there's no error, the hook worked within the provider
    expect(hookError).toBeNull();
    expect(hookResult).not.toBeNull();
    expect(Array.isArray(hookResult)).toBe(true);
    expect(hookResult).toHaveLength(4);
  });
});
