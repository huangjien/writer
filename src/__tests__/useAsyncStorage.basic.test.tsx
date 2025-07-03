import React from 'react';
import { renderHook } from '@testing-library/react-native';
import { useAsyncStorage, AsyncStorageProvider } from '@/hooks/useAsyncStorage';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () => ({
  getAllKeys: jest.fn(() => Promise.resolve([])),
  multiGet: jest.fn(() => Promise.resolve([])),
  getItem: jest.fn(() => Promise.resolve(null)),
  setItem: jest.fn(() => Promise.resolve()),
  removeItem: jest.fn(() => Promise.resolve()),
}));

describe('useAsyncStorage Basic Tests', () => {
  const TestWrapper: React.FC<{ children: React.ReactNode }> = ({
    children,
  }) => {
    return React.createElement(AsyncStorageProvider, null, children);
  };

  it('should throw error when used outside provider', () => {
    expect(() => {
      renderHook(() => useAsyncStorage());
    }).toThrow('useAsyncStorage must be used within an AsyncStorageProvider');
  });

  it('should not throw when used within provider', () => {
    expect(() => {
      renderHook(() => useAsyncStorage(), { wrapper: TestWrapper });
    }).not.toThrow();
  });

  it('should return an array with 4 elements when used within provider', () => {
    const { result } = renderHook(() => useAsyncStorage(), {
      wrapper: TestWrapper,
    });

    // Debug: Log the actual value
    console.log('result.current:', result.current);
    console.log('typeof result.current:', typeof result.current);

    // The hook should return a StorageState array
    expect(result.current).not.toBeNull();
    expect(Array.isArray(result.current)).toBe(true);
    expect(result.current).toHaveLength(4);
  });
});
