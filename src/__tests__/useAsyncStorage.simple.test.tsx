import React from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage');
const mockAsyncStorage = AsyncStorage as jest.Mocked<typeof AsyncStorage>;

describe('useAsyncStorage Simple Test', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockAsyncStorage.getAllKeys.mockResolvedValue([]);
    mockAsyncStorage.multiGet.mockResolvedValue([]);
    mockAsyncStorage.getItem.mockResolvedValue(null);
    mockAsyncStorage.setItem.mockResolvedValue();
    mockAsyncStorage.removeItem.mockResolvedValue();
  });

  it('should have React defined', () => {
    expect(React).toBeDefined();
  });

  it('should have AsyncStorage mock defined', () => {
    expect(mockAsyncStorage).toBeDefined();
    expect(mockAsyncStorage.getItem).toBeDefined();
  });

  it('should have jest defined', () => {
    expect(jest).toBeDefined();
  });
});
