// Mock Setup Tests
describe('Mock Setup', () => {
  it('should have AsyncStorage mock defined', () => {
    expect(typeof require('@react-native-async-storage/async-storage')).toBe(
      'object'
    );
  });

  it('should have useAsyncStorage defined', () => {
    const { useAsyncStorage } = require('../hooks/useAsyncStorage');
    expect(typeof useAsyncStorage).toBe('function');
  });

  it('should have AsyncStorageProvider defined', () => {
    const { AsyncStorageProvider } = require('../hooks/useAsyncStorage');
    expect(typeof AsyncStorageProvider).toBe('function');
  });
});
