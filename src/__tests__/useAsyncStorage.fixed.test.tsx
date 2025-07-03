import React from 'react';
import { renderHook, waitFor } from '@testing-library/react-native';
import {
  AsyncStorageProvider,
  useAsyncStorage,
} from '../hooks/useAsyncStorage.fixed';

describe('useAsyncStorage - Fixed Version', () => {
  it('should provide context value', async () => {
    // Create a mock storage that resolves immediately
    const mockStorage = {
      getAllKeys: jest.fn().mockResolvedValue([]),
      multiGet: jest.fn().mockResolvedValue([]),
      getItem: jest.fn().mockResolvedValue(null),
      setItem: jest.fn().mockResolvedValue(undefined),
      removeItem: jest.fn().mockResolvedValue(undefined),
    };

    const wrapper = ({ children }: { children: React.ReactNode }) => (
      <AsyncStorageProvider asyncStorage={mockStorage}>
        {children}
      </AsyncStorageProvider>
    );

    const { result } = renderHook(() => useAsyncStorage(), { wrapper });

    console.log('Initial result.current:', result.current);

    // Wait for initialization
    await waitFor(
      () => {
        console.log('Waiting - result.current:', result.current);
        expect(result.current).not.toBeNull();
      },
      { timeout: 2000 }
    );

    console.log('Final result.current:', result.current);
    expect(Array.isArray(result.current)).toBe(true);
    expect(result.current).toHaveLength(4);

    const [storage, operations, isLoading, hasChanged] = result.current;
    expect(typeof storage).toBe('object');
    expect(typeof operations).toBe('object');
    expect(typeof isLoading).toBe('boolean');
    expect(typeof hasChanged).toBe('number');
  }, 10000);

  it('should throw when used outside provider', () => {
    const consoleErrorSpy = jest
      .spyOn(console, 'error')
      .mockImplementation(() => {});

    expect(() => {
      renderHook(() => useAsyncStorage());
    }).toThrow('useAsyncStorage must be used within an AsyncStorageProvider');

    consoleErrorSpy.mockRestore();
  });
});
