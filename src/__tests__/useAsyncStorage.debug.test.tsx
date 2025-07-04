// Mock Setup Tests
describe('useAsyncStorage Debug', () => {
  it('should have useAsyncStorage defined', () => {
    expect(typeof require('../hooks/useAsyncStorage')).toBe('object');
  });

  it('should have React defined', () => {
    expect(typeof require('react')).toBe('object');
  });

  it('should have AsyncStorage mock', () => {
    expect(typeof require('@react-native-async-storage/async-storage')).toBe(
      'object'
    );
  });

  it('should have Jest defined', () => {
    expect(typeof jest).toBe('object');
  });
});
