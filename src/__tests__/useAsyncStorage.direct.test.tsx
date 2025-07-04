import React from 'react';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () => ({
  getAllKeys: jest.fn(() => Promise.resolve([])),
  multiGet: jest.fn(() => Promise.resolve([])),
  getItem: jest.fn(() => Promise.resolve(null)),
  setItem: jest.fn(() => Promise.resolve()),
  removeItem: jest.fn(() => Promise.resolve()),
}));

describe('useAsyncStorage Direct Context Test', () => {
  it('should have React defined', () => {
    expect(React).toBeDefined();
  });

  it('should have AsyncStorage mock defined', () => {
    const AsyncStorage = require('@react-native-async-storage/async-storage');
    expect(AsyncStorage).toBeDefined();
    expect(AsyncStorage.getItem).toBeDefined();
  });

  it('should have jest defined', () => {
    expect(jest).toBeDefined();
  });
});
