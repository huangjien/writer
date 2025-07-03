/**
 * @jest-environment react-native
 */
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

describe('useAsyncStorage React Native Environment', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockAsyncStorage.getAllKeys.mockResolvedValue([]);
    mockAsyncStorage.multiGet.mockResolvedValue([]);
    mockAsyncStorage.getItem.mockResolvedValue(null);
    mockAsyncStorage.setItem.mockResolvedValue();
    mockAsyncStorage.removeItem.mockResolvedValue();
  });

  it('should work with provider in react-native environment', async () => {
    const wrapper = ({ children }: { children: React.ReactNode }) => (
      <AsyncStorageProvider>{children}</AsyncStorageProvider>
    );

    const { result } = renderHook(() => useAsyncStorage(), { wrapper });

    // Wait for provider to initialize
    await new Promise((resolve) => setTimeout(resolve, 100));

    expect(result.current).not.toBeNull();
    expect(Array.isArray(result.current)).toBe(true);
    expect(result.current).toHaveLength(4);
  });
});
