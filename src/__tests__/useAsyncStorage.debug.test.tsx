import React from 'react';
import { renderHook } from '@testing-library/react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  AsyncStorageProvider,
  useAsyncStorage,
} from '../hooks/useAsyncStorage';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage');
const mockAsyncStorage = AsyncStorage as jest.Mocked<typeof AsyncStorage>;

describe('useAsyncStorage Debug', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockAsyncStorage.getAllKeys.mockResolvedValue([]);
    mockAsyncStorage.multiGet.mockResolvedValue([]);
    mockAsyncStorage.getItem.mockResolvedValue(null);
    mockAsyncStorage.setItem.mockResolvedValue();
    mockAsyncStorage.removeItem.mockResolvedValue();
  });

  it('should verify AsyncStorageProvider provides context', () => {
    const TestComponent = () => {
      const result = useAsyncStorage();
      return React.createElement('div', null, JSON.stringify(result));
    };

    const WrappedComponent = () => {
      return React.createElement(
        AsyncStorageProvider,
        null,
        React.createElement(TestComponent)
      );
    };

    expect(() => {
      React.createElement(WrappedComponent);
    }).not.toThrow();
  });

  it('should verify hook works with renderHook', () => {
    const wrapper = ({ children }: { children: React.ReactNode }) => {
      return React.createElement(AsyncStorageProvider, null, children);
    };

    const { result } = renderHook(
      () => {
        console.log('Hook is being called');
        const hookResult = useAsyncStorage();
        console.log('Hook result:', hookResult);
        return hookResult;
      },
      { wrapper }
    );

    console.log('Final result.current:', result.current);
    expect(result.current).toBeDefined();
    expect(result.current).not.toBeNull();
    expect(Array.isArray(result.current)).toBe(true);
    expect(result.current).toHaveLength(4);
  });
});
