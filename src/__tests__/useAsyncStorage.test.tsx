import React from 'react';
import { renderHook, act } from '@testing-library/react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  AsyncStorageProvider,
  useAsyncStorage,
} from '../components/useAsyncStorage';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage');
const mockAsyncStorage = AsyncStorage as jest.Mocked<typeof AsyncStorage>;

describe('useAsyncStorage', () => {
  const wrapper = ({ children }: { children: React.ReactNode }) => (
    <AsyncStorageProvider>{children}</AsyncStorageProvider>
  );

  beforeEach(() => {
    jest.clearAllMocks();
    mockAsyncStorage.getItem.mockResolvedValue(null);
    mockAsyncStorage.setItem.mockResolvedValue();
    mockAsyncStorage.removeItem.mockResolvedValue();
  });

  describe('initial state', () => {
    it('should initialize with empty storage and not loading', () => {
      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      const [storage, operations, isLoading, hasChanged] = result.current;

      expect(storage).toEqual({});
      expect(isLoading).toBe(false);
      expect(hasChanged).toBe(false);
      expect(operations).toHaveProperty('getItem');
      expect(operations).toHaveProperty('setItem');
      expect(operations).toHaveProperty('removeItem');
    });
  });

  describe('getItem', () => {
    it('should get item from AsyncStorage and update storage', async () => {
      const testKey = 'testKey';
      const testValue = 'testValue';
      mockAsyncStorage.getItem.mockResolvedValue(testValue);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await act(async () => {
        const value = await result.current[1].getItem(testKey);
        expect(value).toBe(testValue);
      });

      expect(mockAsyncStorage.getItem).toHaveBeenCalledWith(testKey);
      expect(result.current[0][testKey]).toBe(testValue);
    });

    it('should handle null values from AsyncStorage', async () => {
      const testKey = 'nonExistentKey';
      mockAsyncStorage.getItem.mockResolvedValue(null);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await act(async () => {
        const value = await result.current[1].getItem(testKey);
        expect(value).toBeNull();
      });

      expect(result.current[0][testKey]).toBeNull();
    });

    it('should handle AsyncStorage errors', async () => {
      const testKey = 'errorKey';
      const error = new Error('AsyncStorage error');
      mockAsyncStorage.getItem.mockRejectedValue(error);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await act(async () => {
        await expect(result.current[1].getItem(testKey)).rejects.toThrow(
          'AsyncStorage error'
        );
      });
    });
  });

  describe('setItem', () => {
    it('should set item in AsyncStorage and update storage', async () => {
      const testKey = 'testKey';
      const testValue = 'testValue';

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await act(async () => {
        await result.current[1].setItem(testKey, testValue);
      });

      expect(mockAsyncStorage.setItem).toHaveBeenCalledWith(testKey, testValue);
      expect(result.current[0][testKey]).toBe(testValue);
      expect(result.current[3]).toBe(true); // hasChanged should be true
    });

    it('should handle AsyncStorage setItem errors', async () => {
      const testKey = 'errorKey';
      const testValue = 'testValue';
      const error = new Error('AsyncStorage setItem error');
      mockAsyncStorage.setItem.mockRejectedValue(error);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await act(async () => {
        await expect(
          result.current[1].setItem(testKey, testValue)
        ).rejects.toThrow('AsyncStorage setItem error');
      });
    });
  });

  describe('removeItem', () => {
    it('should remove item from AsyncStorage and update storage', async () => {
      const testKey = 'testKey';

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // First set an item
      await act(async () => {
        await result.current[1].setItem(testKey, 'testValue');
      });

      expect(result.current[0][testKey]).toBe('testValue');

      // Then remove it
      await act(async () => {
        await result.current[1].removeItem(testKey);
      });

      expect(mockAsyncStorage.removeItem).toHaveBeenCalledWith(testKey);
      expect(result.current[0][testKey]).toBeUndefined();
      expect(result.current[3]).toBe(true); // hasChanged should be true
    });

    it('should handle AsyncStorage removeItem errors', async () => {
      const testKey = 'errorKey';
      const error = new Error('AsyncStorage removeItem error');
      mockAsyncStorage.removeItem.mockRejectedValue(error);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await act(async () => {
        await expect(result.current[1].removeItem(testKey)).rejects.toThrow(
          'AsyncStorage removeItem error'
        );
      });
    });
  });

  describe('loading state', () => {
    it('should set loading state during async operations', async () => {
      const testKey = 'testKey';
      let resolvePromise: (value: string) => void;
      const promise = new Promise<string>((resolve) => {
        resolvePromise = resolve;
      });

      mockAsyncStorage.getItem.mockReturnValue(promise);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // Start async operation
      act(() => {
        result.current[1].getItem(testKey);
      });

      // Should be loading
      expect(result.current[2]).toBe(true);

      // Resolve the promise
      await act(async () => {
        resolvePromise!('testValue');
        await promise;
      });

      // Should not be loading anymore
      expect(result.current[2]).toBe(false);
    });
  });

  describe('multiple operations', () => {
    it('should handle multiple concurrent operations', async () => {
      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await act(async () => {
        await Promise.all([
          result.current[1].setItem('key1', 'value1'),
          result.current[1].setItem('key2', 'value2'),
          result.current[1].setItem('key3', 'value3'),
        ]);
      });

      expect(result.current[0]).toEqual({
        key1: 'value1',
        key2: 'value2',
        key3: 'value3',
      });
      expect(mockAsyncStorage.setItem).toHaveBeenCalledTimes(3);
    });
  });

  describe('context provider', () => {
    it('should throw error when used outside provider', () => {
      // Suppress console.error for this test
      const originalError = console.error;
      console.error = jest.fn();

      expect(() => {
        renderHook(() => useAsyncStorage());
      }).toThrow('useAsyncStorage must be used within an AsyncStorageProvider');

      console.error = originalError;
    });
  });
});
