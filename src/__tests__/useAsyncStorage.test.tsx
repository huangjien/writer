import React from 'react';
import {
  renderHook,
  act,
  waitFor,
  render,
} from '@testing-library/react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  AsyncStorageProvider,
  useAsyncStorage,
} from '../hooks/useAsyncStorage';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage');
const mockAsyncStorage = AsyncStorage as jest.Mocked<typeof AsyncStorage>;

describe('useAsyncStorage', () => {
  const wrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    // Create a mock storage that resolves immediately for testing
    const mockStorage = {
      getAllKeys: jest.fn().mockResolvedValue([]),
      multiGet: jest.fn().mockResolvedValue([]),
      getItem: jest.fn().mockResolvedValue(null),
      setItem: jest.fn().mockResolvedValue(undefined),
      removeItem: jest.fn().mockResolvedValue(undefined),
    };

    return React.createElement(AsyncStorageProvider, {
      asyncStorage: mockStorage,
      children,
    });
  };

  beforeEach(() => {
    jest.clearAllMocks();
    mockAsyncStorage.getAllKeys.mockResolvedValue([]);
    mockAsyncStorage.multiGet.mockResolvedValue([]);
    mockAsyncStorage.getItem.mockResolvedValue(null);
    mockAsyncStorage.setItem.mockResolvedValue();
    mockAsyncStorage.removeItem.mockResolvedValue();
  });

  describe('initial state', () => {
    it('should initialize with loading state and load initial data', async () => {
      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // Initially should be loading
      expect(result.current[2]).toBe(true);
      expect(result.current[3]).toBe(0); // hasChanged counter starts at 0
      expect(result.current[1]).toHaveProperty('getItem');
      expect(result.current[1]).toHaveProperty('setItem');
      expect(result.current[1]).toHaveProperty('removeItem');

      // Wait for initial loading to complete
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      expect(mockAsyncStorage.getAllKeys).toHaveBeenCalled();
      expect(mockAsyncStorage.multiGet).toHaveBeenCalled();
      expect(result.current[0]).toEqual({});
    });

    it('should load existing data on initialization', async () => {
      const existingData: [string, string | null][] = [
        ['key1', 'value1'],
        ['key2', 'value2'],
      ];
      mockAsyncStorage.getAllKeys.mockResolvedValue(['key1', 'key2']);
      mockAsyncStorage.multiGet.mockResolvedValue(existingData);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      expect(result.current[0]).toEqual({
        key1: 'value1',
        key2: 'value2',
      });
    });

    it('should handle initialization errors gracefully', async () => {
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();
      mockAsyncStorage.getAllKeys.mockRejectedValue(new Error('Storage error'));

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'Error loading initial storage:',
        expect.any(Error)
      );
      expect(result.current[0]).toEqual({});

      consoleErrorSpy.mockRestore();
    });
  });

  describe('getItem', () => {
    it('should get item from AsyncStorage and update storage', async () => {
      const testKey = 'testKey';
      const testValue = 'testValue';
      mockAsyncStorage.getItem.mockResolvedValue(testValue);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // Wait for initial loading
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      let returnedValue: string;
      await act(async () => {
        returnedValue = await result.current[1].getItem(testKey);
      });

      expect(returnedValue).toBe(testValue);
      expect(mockAsyncStorage.getItem).toHaveBeenCalledWith(testKey);
      expect(result.current[0][testKey]).toBe(testValue);
    });

    it('should handle null values from AsyncStorage', async () => {
      const testKey = 'nonExistentKey';
      mockAsyncStorage.getItem.mockResolvedValue(null);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // Wait for initial loading
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      let returnedValue: string;
      await act(async () => {
        returnedValue = await result.current[1].getItem(testKey);
      });

      expect(returnedValue).toBeNull();
      expect(result.current[0][testKey]).toBeNull();
    });

    it('should handle AsyncStorage errors gracefully', async () => {
      const testKey = 'errorKey';
      const error = new Error('AsyncStorage error');
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();
      mockAsyncStorage.getItem.mockRejectedValue(error);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // Wait for initial loading
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      let returnedValue: string;
      await act(async () => {
        returnedValue = await result.current[1].getItem(testKey);
      });

      expect(returnedValue).toBeNull();
      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'Error getting item:',
        error
      );

      consoleErrorSpy.mockRestore();
    });
  });

  describe('setItem', () => {
    it('should set item in AsyncStorage and update storage', async () => {
      const testKey = 'testKey';
      const testValue = 'testValue';
      mockAsyncStorage.setItem.mockResolvedValue(undefined);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // Wait for initial loading
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      const initialHasChanged = result.current[3];

      await act(async () => {
        await result.current[1].setItem(testKey, testValue);
      });

      expect(mockAsyncStorage.setItem).toHaveBeenCalledWith(testKey, testValue);
      expect(result.current[0][testKey]).toBe(testValue);
      expect(result.current[3]).toBe(initialHasChanged + 1); // hasChanged should increment
    });

    it('should handle AsyncStorage setItem errors gracefully', async () => {
      const testKey = 'errorKey';
      const testValue = 'errorValue';
      const error = new Error('AsyncStorage setItem error');
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();
      mockAsyncStorage.setItem.mockRejectedValue(error);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // Wait for initial loading
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      await act(async () => {
        await result.current[1].setItem(testKey, testValue);
      });

      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'Error setting item:',
        error
      );
      expect(result.current[0][testKey]).toBeUndefined(); // Should not be set on error

      consoleErrorSpy.mockRestore();
    });
  });

  describe('removeItem', () => {
    it('should remove item from AsyncStorage and update storage', async () => {
      const testKey = 'testKey';
      const testValue = 'testValue';
      mockAsyncStorage.setItem.mockResolvedValue(undefined);
      mockAsyncStorage.removeItem.mockResolvedValue(undefined);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // Wait for initial loading
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      // First set an item
      await act(async () => {
        await result.current[1].setItem(testKey, testValue);
      });

      expect(result.current[0][testKey]).toBe(testValue);
      const hasChangedAfterSet = result.current[3];

      // Then remove it
      await act(async () => {
        await result.current[1].removeItem(testKey);
      });

      expect(mockAsyncStorage.removeItem).toHaveBeenCalledWith(testKey);
      expect(result.current[0][testKey]).toBeUndefined();
      expect(result.current[3]).toBe(hasChangedAfterSet + 1); // hasChanged should increment again
    });

    it('should handle AsyncStorage removeItem errors gracefully', async () => {
      const testKey = 'errorKey';
      const error = new Error('AsyncStorage removeItem error');
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();
      mockAsyncStorage.removeItem.mockRejectedValue(error);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // Wait for initial loading
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      await act(async () => {
        await result.current[1].removeItem(testKey);
      });

      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'Error removing item:',
        error
      );

      consoleErrorSpy.mockRestore();
    });
  });

  describe('loading state', () => {
    it('should set loading to true during async operations', async () => {
      const testKey = 'testKey';
      const testValue = 'testValue';

      // Mock a delayed response for setItem
      mockAsyncStorage.setItem.mockImplementation(
        () => new Promise((resolve) => setTimeout(resolve, 100))
      );

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // Wait for initial loading to complete
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      // Start async operation
      act(() => {
        result.current[1].setItem(testKey, testValue);
      });

      // Should be loading during operation
      expect(result.current[2]).toBe(true);

      // Wait for operation to complete
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      expect(result.current[0][testKey]).toBe(testValue);
    });

    it('should handle loading state for getItem operations', async () => {
      const testKey = 'testKey';
      const testValue = 'testValue';

      // Mock a delayed response for getItem
      mockAsyncStorage.getItem.mockImplementation(
        () => new Promise((resolve) => setTimeout(() => resolve(testValue), 50))
      );

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // Wait for initial loading to complete
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      // Start async operation
      act(() => {
        result.current[1].getItem(testKey);
      });

      // Should be loading during operation
      expect(result.current[2]).toBe(true);

      // Wait for operation to complete
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      expect(result.current[0][testKey]).toBe(testValue);
    });
  });

  describe('multiple operations', () => {
    it('should handle multiple concurrent operations correctly', async () => {
      const operations = [
        { key: 'key1', value: 'value1' },
        { key: 'key2', value: 'value2' },
        { key: 'key3', value: 'value3' },
      ];

      mockAsyncStorage.setItem.mockResolvedValue(undefined);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // Wait for initial loading to complete
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      await act(async () => {
        await Promise.all(
          operations.map(({ key, value }) =>
            result.current[1].setItem(key, value)
          )
        );
      });

      operations.forEach(({ key, value }) => {
        expect(result.current[0][key]).toBe(value);
      });

      expect(mockAsyncStorage.setItem).toHaveBeenCalledTimes(3);
      expect(result.current[3]).toBe(3); // hasChanged should be 3 after 3 operations
    });

    it('should handle mixed operations (get, set, remove) concurrently', async () => {
      mockAsyncStorage.getItem.mockResolvedValue('existingValue');
      mockAsyncStorage.setItem.mockResolvedValue(undefined);
      mockAsyncStorage.removeItem.mockResolvedValue(undefined);

      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // Wait for initial loading to complete
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      await act(async () => {
        await Promise.all([
          result.current[1].getItem('getKey'),
          result.current[1].setItem('setKey', 'setValue'),
          result.current[1].removeItem('removeKey'),
        ]);
      });

      expect(result.current[0]['getKey']).toBe('existingValue');
      expect(result.current[0]['setKey']).toBe('setValue');
      expect(result.current[0]['removeKey']).toBeUndefined();
      expect(result.current[3]).toBe(2); // hasChanged should be 2 (set + remove operations)
    });
  });

  describe('context provider', () => {
    it('should work correctly when used within provider', async () => {
      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // Wait for initial loading to complete
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      // The hook should return a valid result after initialization
      expect(result.current).toBeDefined();
      expect(result.current).not.toBeNull();
      expect(Array.isArray(result.current)).toBe(true);
      expect(result.current).toHaveLength(4);

      // Verify the structure
      const [storage, operations, isLoading, hasChanged] = result.current;
      expect(typeof storage).toBe('object');
      expect(typeof operations).toBe('object');
      expect(typeof isLoading).toBe('boolean');
      expect(typeof hasChanged).toBe('number');

      expect(operations).toHaveProperty('getItem');
      expect(operations).toHaveProperty('setItem');
      expect(operations).toHaveProperty('removeItem');

      expect(typeof operations.getItem).toBe('function');
      expect(typeof operations.setItem).toBe('function');
      expect(typeof operations.removeItem).toBe('function');
    });

    it('should return null when used outside provider', () => {
      const { result } = renderHook(() => {
        try {
          return useAsyncStorage();
        } catch {
          return null;
        }
      });

      expect(result.current).toBeNull();
    });
  });
});
