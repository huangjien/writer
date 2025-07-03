import React from 'react';
import { renderHook, act, waitFor } from '@testing-library/react-native';
import {
  AsyncStorageProvider,
  useAsyncStorage,
  StorageManager,
  IAsyncStorage,
} from '../hooks/useAsyncStorage';

// Mock storage implementation for testing
class MockAsyncStorage implements IAsyncStorage {
  private data: Record<string, string | null> = {};
  private shouldThrow = false;
  private delay = 0;

  constructor(initialData: Record<string, string | null> = {}) {
    this.data = { ...initialData };
  }

  setDelay(ms: number) {
    this.delay = ms;
  }

  setShouldThrow(shouldThrow: boolean) {
    this.shouldThrow = shouldThrow;
  }

  private async maybeDelay() {
    if (this.delay > 0) {
      await new Promise((resolve) => setTimeout(resolve, this.delay));
    }
  }

  private maybeThrow() {
    if (this.shouldThrow) {
      throw new Error('Mock storage error');
    }
  }

  async getAllKeys(): Promise<readonly string[]> {
    await this.maybeDelay();
    this.maybeThrow();
    return Object.keys(this.data);
  }

  async multiGet(
    keys: readonly string[]
  ): Promise<readonly [string, string | null][]> {
    await this.maybeDelay();
    this.maybeThrow();
    return keys.map((key) => [key, this.data[key] || null]);
  }

  async getItem(key: string): Promise<string | null> {
    await this.maybeDelay();
    this.maybeThrow();
    return this.data[key] || null;
  }

  async setItem(key: string, value: string): Promise<void> {
    await this.maybeDelay();
    this.maybeThrow();
    this.data[key] = value;
  }

  async removeItem(key: string): Promise<void> {
    await this.maybeDelay();
    this.maybeThrow();
    delete this.data[key];
  }

  // Test helper methods
  getData() {
    return { ...this.data };
  }

  setData(data: Record<string, string | null>) {
    this.data = { ...data };
  }
}

describe('useAsyncStorage (Refactored)', () => {
  let mockStorage: MockAsyncStorage;

  beforeEach(() => {
    mockStorage = new MockAsyncStorage();
  });

  const createWrapper = (
    asyncStorage?: IAsyncStorage,
    storageManager?: StorageManager
  ) => {
    return ({ children }: { children: React.ReactNode }) => (
      <AsyncStorageProvider
        asyncStorage={asyncStorage}
        storageManager={storageManager}
      >
        {children}
      </AsyncStorageProvider>
    );
  };

  describe('initialization', () => {
    it('should initialize with empty storage', async () => {
      const wrapper = createWrapper(mockStorage);
      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      // Initially loading
      expect(result.current[2]).toBe(true);

      // Wait for initialization
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      expect(result.current[0]).toEqual({});
      expect(result.current[3]).toBe(0); // hasChanged
    });

    it('should initialize with existing data', async () => {
      const initialData = { key1: 'value1', key2: 'value2' };
      mockStorage.setData(initialData);

      const wrapper = createWrapper(mockStorage);
      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      expect(result.current[0]).toEqual(initialData);
    });

    it('should handle initialization errors gracefully', async () => {
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();
      mockStorage.setShouldThrow(true);

      const wrapper = createWrapper(mockStorage);
      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      expect(result.current[0]).toEqual({});
      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'Error loading initial storage:',
        expect.any(Error)
      );

      consoleErrorSpy.mockRestore();
    });
  });

  describe('getItem', () => {
    it('should get item and update storage', async () => {
      mockStorage.setData({ testKey: 'testValue' });

      const wrapper = createWrapper(mockStorage);
      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      let returnedValue: string | null;
      await act(async () => {
        returnedValue = await result.current[1].getItem('testKey');
      });

      expect(returnedValue).toBe('testValue');
      expect(result.current[0]['testKey']).toBe('testValue');
    });

    it('should handle non-existent keys', async () => {
      const wrapper = createWrapper(mockStorage);
      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      let returnedValue: string | null;
      await act(async () => {
        returnedValue = await result.current[1].getItem('nonExistent');
      });

      expect(returnedValue).toBeNull();
      expect(result.current[0]['nonExistent']).toBeNull();
    });

    it('should handle errors gracefully', async () => {
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

      const wrapper = createWrapper(mockStorage);
      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      // Set error after initialization
      mockStorage.setShouldThrow(true);

      let returnedValue: string | null;
      await act(async () => {
        returnedValue = await result.current[1].getItem('errorKey');
      });

      expect(returnedValue).toBeNull();
      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'Error getting item:',
        expect.any(Error)
      );

      consoleErrorSpy.mockRestore();
    });
  });

  describe('setItem', () => {
    it('should set item and update storage', async () => {
      const wrapper = createWrapper(mockStorage);
      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      const initialHasChanged = result.current[3];

      await act(async () => {
        await result.current[1].setItem('testKey', 'testValue');
      });

      expect(result.current[0]['testKey']).toBe('testValue');
      expect(result.current[3]).toBe(initialHasChanged + 1);
      expect(mockStorage.getData()['testKey']).toBe('testValue');
    });

    it('should handle errors gracefully', async () => {
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

      const wrapper = createWrapper(mockStorage);
      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      // Set error after initialization
      mockStorage.setShouldThrow(true);

      await act(async () => {
        try {
          await result.current[1].setItem('errorKey', 'errorValue');
        } catch (error) {
          // Expected to throw
        }
      });

      expect(consoleErrorSpy).toHaveBeenCalledWith(
        'Error setting item:',
        expect.any(Error)
      );
      expect(result.current[0]['errorKey']).toBeUndefined();

      consoleErrorSpy.mockRestore();
    });
  });

  describe('removeItem', () => {
    it('should remove item and update storage', async () => {
      mockStorage.setData({ testKey: 'testValue' });

      const wrapper = createWrapper(mockStorage);
      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      const initialHasChanged = result.current[3];

      await act(async () => {
        await result.current[1].removeItem('testKey');
      });

      expect(result.current[0]['testKey']).toBeUndefined();
      expect(result.current[3]).toBe(initialHasChanged + 1);
      expect(mockStorage.getData()['testKey']).toBeUndefined();
    });
  });

  describe('loading states', () => {
    it('should show loading during operations', async () => {
      mockStorage.setDelay(50); // Add delay to operations

      const wrapper = createWrapper(mockStorage);
      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      // Start async operation
      act(() => {
        result.current[1].setItem('testKey', 'testValue');
      });

      // Should be loading
      expect(result.current[2]).toBe(true);

      // Wait for completion
      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

      expect(result.current[0]['testKey']).toBe('testValue');
    });
  });

  describe('StorageManager unit tests', () => {
    it('should work independently of React context', async () => {
      const manager = new StorageManager(mockStorage);

      await manager.initialize();
      expect(manager.getStorage()).toEqual({});
      expect(manager.getHasChanged()).toBe(0);

      await manager.setItem('key1', 'value1');
      expect(manager.getStorage()['key1']).toBe('value1');
      expect(manager.getHasChanged()).toBe(1);

      const value = await manager.getItem('key1');
      expect(value).toBe('value1');

      await manager.removeItem('key1');
      expect(manager.getStorage()['key1']).toBeUndefined();
      expect(manager.getHasChanged()).toBe(2);
    });

    it('should handle direct state manipulation for testing', () => {
      const manager = new StorageManager(mockStorage);

      manager.setStorage({ test: 'value' });
      expect(manager.getStorage()).toEqual({ test: 'value' });

      manager.setHasChanged(5);
      expect(manager.getHasChanged()).toBe(5);
    });
  });

  describe('error handling outside provider', () => {
    it('should throw error when used outside provider', () => {
      const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

      expect(() => {
        const { result } = renderHook(() => useAsyncStorage());
        // Try to access the result to trigger the error
        const _ = result.current;
      }).toThrow('useAsyncStorage must be used within an AsyncStorageProvider');

      consoleErrorSpy.mockRestore();
    });
  });

  describe('concurrent operations', () => {
    it('should handle multiple operations correctly', async () => {
      const wrapper = createWrapper(mockStorage);
      const { result } = renderHook(() => useAsyncStorage(), { wrapper });

      await waitFor(() => {
        expect(result.current[2]).toBe(false);
      });

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
      expect(result.current[3]).toBe(3); // hasChanged should be 3
    });
  });
});
