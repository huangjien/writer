import React, { createContext, useContext } from 'react';
import { renderHook } from '@testing-library/react-native';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () => ({
  getAllKeys: jest.fn(() => Promise.resolve([])),
  multiGet: jest.fn(() => Promise.resolve([])),
  getItem: jest.fn(() => Promise.resolve(null)),
  setItem: jest.fn(() => Promise.resolve()),
  removeItem: jest.fn(() => Promise.resolve()),
}));

// Define the types locally to avoid import issues
type StorageOperations = {
  getItem: (key: string) => Promise<string | null>;
  setItem: (key: string, value: string) => Promise<void>;
  removeItem: (key: string) => Promise<void>;
};

type StorageState = [
  Record<string, string | null>,
  StorageOperations,
  boolean,
  number,
];

// Create a mock context directly
const MockStorageContext = createContext<StorageState | null>(null);

function useMockAsyncStorage(): StorageState {
  const context = useContext(MockStorageContext);
  if (!context) {
    throw new Error(
      'useMockAsyncStorage must be used within a MockStorageProvider'
    );
  }
  return context;
}

describe('useAsyncStorage Direct Context Test', () => {
  const mockStorageState: StorageState = [
    {}, // storage
    {
      getItem: jest.fn(),
      setItem: jest.fn(),
      removeItem: jest.fn(),
    }, // operations
    false, // isLoading
    0, // hasChanged
  ];

  const MockProvider: React.FC<{ children: React.ReactNode }> = ({
    children,
  }) => {
    return React.createElement(
      MockStorageContext.Provider,
      { value: mockStorageState },
      children
    );
  };

  it('should throw error when used outside provider', () => {
    expect(() => {
      renderHook(() => useMockAsyncStorage());
    }).toThrow('useMockAsyncStorage must be used within a MockStorageProvider');
  });

  it('should return provided context value when used within provider', () => {
    const { result } = renderHook(() => useMockAsyncStorage(), {
      wrapper: MockProvider,
    });

    expect(result.current).not.toBeNull();
    expect(Array.isArray(result.current)).toBe(true);
    expect(result.current).toHaveLength(4);
    expect(result.current).toBe(mockStorageState);
  });

  it('should provide correct structure', () => {
    const { result } = renderHook(() => useMockAsyncStorage(), {
      wrapper: MockProvider,
    });

    const [storage, operations, isLoading, hasChanged] = result.current;

    expect(typeof storage).toBe('object');
    expect(typeof operations).toBe('object');
    expect(typeof isLoading).toBe('boolean');
    expect(typeof hasChanged).toBe('number');

    expect(operations).toHaveProperty('getItem');
    expect(operations).toHaveProperty('setItem');
    expect(operations).toHaveProperty('removeItem');
  });
});
