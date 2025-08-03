import React from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import {
  AsyncStorageProvider,
  useAsyncStorage,
  StorageManager,
} from './useAsyncStorage';

// Mock React hooks
const mockSetState = jest.fn();
const mockUseState = jest.fn(() => [{}, mockSetState]);
const mockUseCallback = jest.fn((fn: any) => fn);
const mockUseEffect = jest.fn((fn: any) => fn());
const mockUseMemo = jest.fn((fn: any) => fn());
const mockUseContext = jest.fn();

jest.mock('react', () => {
  const mockSetState = jest.fn();
  const mockUseState = jest.fn(() => [{}, mockSetState]);
  const mockUseCallback = jest.fn((fn: any) => fn);
  const mockUseEffect = jest.fn((fn: any) => fn());
  const mockUseMemo = jest.fn((fn: any) => fn());
  const mockUseContext = jest.fn();

  return {
    ...jest.requireActual('react'),
    useState: mockUseState,
    useCallback: mockUseCallback,
    useEffect: mockUseEffect,
    useMemo: mockUseMemo,
    useContext: mockUseContext,
  };
});

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () => ({
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  getAllKeys: jest.fn(),
  multiGet: jest.fn(),
}));

const mockAsyncStorage = AsyncStorage as jest.Mocked<typeof AsyncStorage>;

describe('useAsyncStorage - Enhanced Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockAsyncStorage.getItem.mockResolvedValue(null);
    mockAsyncStorage.setItem.mockResolvedValue(undefined);
    mockAsyncStorage.removeItem.mockResolvedValue(undefined);
    mockAsyncStorage.getAllKeys.mockResolvedValue([]);
    mockAsyncStorage.multiGet.mockResolvedValue([]);

    // Reset React hook mocks
    mockUseState.mockReturnValue([{}, mockSetState]);
    mockUseCallback.mockImplementation((fn) => fn);
    mockUseEffect.mockImplementation((fn) => fn());
    mockUseMemo.mockImplementation((fn) => fn());
    mockUseContext.mockReturnValue(null);
  });

  describe('StorageManager', () => {
    let storageManager: StorageManager;

    beforeEach(() => {
      storageManager = new StorageManager();
    });

    describe('getItem', () => {
      it('should get item from storage', async () => {
        mockAsyncStorage.getItem.mockResolvedValue('test-value');

        const result = await storageManager.getItem('test-key');

        expect(mockAsyncStorage.getItem).toHaveBeenCalledWith('test-key');
        expect(result).toBe('test-value');
      });

      it('should return null for non-existent item', async () => {
        mockAsyncStorage.getItem.mockResolvedValue(null);

        const result = await storageManager.getItem('non-existent');

        expect(result).toBeNull();
      });

      it('should handle storage errors', async () => {
        mockAsyncStorage.getItem.mockRejectedValue(new Error('Storage error'));

        const result = await storageManager.getItem('test-key');

        expect(result).toBeNull();
      });
    });

    describe('setItem', () => {
      it('should set item in storage', async () => {
        await storageManager.setItem('test-key', 'test-value');

        expect(mockAsyncStorage.setItem).toHaveBeenCalledWith(
          'test-key',
          'test-value'
        );
      });

      it('should handle storage errors', async () => {
        mockAsyncStorage.setItem.mockRejectedValue(new Error('Storage error'));

        await expect(
          storageManager.setItem('test-key', 'test-value')
        ).rejects.toThrow('Storage error');
      });

      it('should handle null values', async () => {
        await storageManager.setItem('test-key', null as any);

        expect(mockAsyncStorage.setItem).toHaveBeenCalledWith('test-key', null);
      });

      it('should increment hasChanged counter', async () => {
        const initialCount = storageManager.getHasChanged();
        await storageManager.setItem('test-key', 'test-value');

        expect(storageManager.getHasChanged()).toBe(initialCount + 1);
      });
    });

    describe('removeItem', () => {
      it('should remove item from storage', async () => {
        await storageManager.removeItem('test-key');

        expect(mockAsyncStorage.removeItem).toHaveBeenCalledWith('test-key');
      });

      it('should handle storage errors', async () => {
        mockAsyncStorage.removeItem.mockRejectedValue(
          new Error('Storage error')
        );

        await expect(storageManager.removeItem('test-key')).rejects.toThrow(
          'Storage error'
        );
      });

      it('should increment hasChanged counter', async () => {
        const initialCount = storageManager.getHasChanged();
        await storageManager.removeItem('test-key');

        expect(storageManager.getHasChanged()).toBe(initialCount + 1);
      });
    });

    describe('initialize', () => {
      it('should initialize storage with existing data', async () => {
        mockAsyncStorage.getAllKeys.mockResolvedValue(['key1', 'key2']);
        mockAsyncStorage.multiGet.mockResolvedValue([
          ['key1', 'value1'],
          ['key2', 'value2'],
        ]);

        const result = await storageManager.initialize();

        expect(mockAsyncStorage.getAllKeys).toHaveBeenCalled();
        expect(mockAsyncStorage.multiGet).toHaveBeenCalledWith([
          'key1',
          'key2',
        ]);
        expect(result).toEqual({ key1: 'value1', key2: 'value2' });
      });

      it('should handle empty storage', async () => {
        mockAsyncStorage.getAllKeys.mockResolvedValue([]);
        mockAsyncStorage.multiGet.mockResolvedValue([]);

        const result = await storageManager.initialize();

        expect(result).toEqual({});
      });

      it('should handle initialization errors', async () => {
        mockAsyncStorage.getAllKeys.mockRejectedValue(new Error('Init error'));

        const result = await storageManager.initialize();

        expect(result).toEqual({});
      });
    });

    describe('storage management', () => {
      it('should get and set storage', () => {
        const testStorage = { key1: 'value1', key2: 'value2' };
        storageManager.setStorage(testStorage);

        expect(storageManager.getStorage()).toEqual(testStorage);
      });

      it('should get and set hasChanged counter', () => {
        storageManager.setHasChanged(5);

        expect(storageManager.getHasChanged()).toBe(5);
      });
    });
  });

  describe('AsyncStorageProvider', () => {
    it('should create provider component successfully', () => {
      // Test that the provider can be created without errors
      const mockStorageManager = {
        initialize: jest.fn().mockResolvedValue({}),
        getItem: jest.fn(),
        setItem: jest.fn(),
        removeItem: jest.fn(),
        getStorage: jest.fn().mockReturnValue({}),
        getHasChanged: jest.fn().mockReturnValue(0),
      };

      // Create provider component
      const provider = AsyncStorageProvider({
        children: React.createElement('div'),
        storageManager: mockStorageManager as any,
      });

      // Verify provider was created
      expect(provider).toBeDefined();
      expect(typeof provider).toBe('object');
    });

    it('should accept storage manager prop', () => {
      const mockStorageManager = {
        initialize: jest.fn().mockResolvedValue({}),
        getItem: jest.fn().mockResolvedValue('test-value'),
        setItem: jest.fn().mockResolvedValue(undefined),
        removeItem: jest.fn().mockResolvedValue(undefined),
        getStorage: jest.fn().mockReturnValue({ 'test-key': 'test-value' }),
        getHasChanged: jest.fn().mockReturnValue(1),
      };

      // Create provider with storage manager
      const provider = AsyncStorageProvider({
        children: React.createElement('div'),
        storageManager: mockStorageManager as any,
      });

      // Test that provider accepts the storage manager
      expect(provider).toBeDefined();
      expect(typeof provider).toBe('object');
    });
  });

  describe('useAsyncStorage hook', () => {
    it('should return context value when provider exists', () => {
      const mockContextValue = [
        {},
        { getItem: jest.fn(), setItem: jest.fn(), removeItem: jest.fn() },
        false,
        0,
      ];

      // Get the mocked useContext from React
      const React = require('react');
      const mockUseContextFromReact = React.useContext as jest.MockedFunction<
        typeof React.useContext
      >;
      mockUseContextFromReact.mockReturnValue(mockContextValue);

      const result = useAsyncStorage();

      expect(mockUseContextFromReact).toHaveBeenCalled();
      expect(result).toBe(mockContextValue);

      // Reset the mock
      mockUseContextFromReact.mockReset();
    });

    it('should throw error when used outside provider', () => {
      // Get the mocked useContext from React
      const React = require('react');
      const mockUseContextFromReact = React.useContext as jest.MockedFunction<
        typeof React.useContext
      >;
      mockUseContextFromReact.mockReturnValue(null);

      expect(() => useAsyncStorage()).toThrow(
        'useAsyncStorage must be used within an AsyncStorageProvider'
      );

      // Reset the mock
      mockUseContextFromReact.mockReset();
    });
  });

  describe('Edge Cases and Integration', () => {
    let storageManager: StorageManager;

    beforeEach(() => {
      storageManager = new StorageManager();
    });

    it('should handle very long keys', async () => {
      const longKey = 'a'.repeat(1000);
      await storageManager.setItem(longKey, 'test-value');

      expect(mockAsyncStorage.setItem).toHaveBeenCalledWith(
        longKey,
        'test-value'
      );
    });

    it('should handle very long values', async () => {
      const longValue = 'a'.repeat(10000);
      await storageManager.setItem('test-key', longValue);

      expect(mockAsyncStorage.setItem).toHaveBeenCalledWith(
        'test-key',
        longValue
      );
    });

    it('should handle unicode characters', async () => {
      const unicodeKey = '测试键名🔑';
      const unicodeValue = '测试值🎯';
      await storageManager.setItem(unicodeKey, unicodeValue);

      expect(mockAsyncStorage.setItem).toHaveBeenCalledWith(
        unicodeKey,
        unicodeValue
      );
    });

    it('should handle JSON-like strings', async () => {
      const jsonValue = '{"key": "value", "number": 123, "boolean": true}';
      await storageManager.setItem('json-key', jsonValue);

      expect(mockAsyncStorage.setItem).toHaveBeenCalledWith(
        'json-key',
        jsonValue
      );
    });

    it('should handle rapid successive operations on same key', async () => {
      await storageManager.setItem('rapid-key', 'value1');
      await storageManager.setItem('rapid-key', 'value2');
      await storageManager.setItem('rapid-key', 'value3');
      await storageManager.removeItem('rapid-key');

      expect(mockAsyncStorage.setItem).toHaveBeenCalledTimes(3);
      expect(mockAsyncStorage.removeItem).toHaveBeenCalledTimes(1);
      expect(storageManager.getHasChanged()).toBe(4);
    });

    it('should handle empty string values', async () => {
      await storageManager.setItem('empty-key', '');

      expect(mockAsyncStorage.setItem).toHaveBeenCalledWith('empty-key', '');
    });

    it('should handle special characters in keys and values', async () => {
      const specialKey = 'key-with-special-chars-!@#$%^&*()';
      const specialValue =
        'value with special chars: !@#$%^&*()_+-=[]{}|;:,.<>?';

      await storageManager.setItem(specialKey, specialValue);

      expect(mockAsyncStorage.setItem).toHaveBeenCalledWith(
        specialKey,
        specialValue
      );
    });

    it('should handle multiple concurrent operations', async () => {
      mockAsyncStorage.getItem.mockResolvedValue('test-value');
      mockAsyncStorage.setItem.mockResolvedValue(undefined);

      const promises = [
        storageManager.getItem('key1'),
        storageManager.setItem('key2', 'value2'),
        storageManager.getItem('key3'),
        storageManager.setItem('key4', 'value4'),
      ];

      await Promise.all(promises);

      expect(mockAsyncStorage.getItem).toHaveBeenCalledTimes(2);
      expect(mockAsyncStorage.setItem).toHaveBeenCalledTimes(2);
      expect(storageManager.getHasChanged()).toBe(2);
    });

    it('should maintain storage state correctly', async () => {
      await storageManager.setItem('key1', 'value1');
      await storageManager.setItem('key2', 'value2');

      const storage = storageManager.getStorage();
      expect(storage).toEqual({ key1: 'value1', key2: 'value2' });

      await storageManager.removeItem('key1');
      const updatedStorage = storageManager.getStorage();
      expect(updatedStorage).toEqual({ key2: 'value2' });
    });
  });
});
