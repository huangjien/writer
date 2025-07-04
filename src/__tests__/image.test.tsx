// Mock Setup Tests
describe('Image Component', () => {
  it('should have Image defined', () => {
    expect(typeof require('../components/image')).toBe('object');
  });

  it('should have React defined', () => {
    expect(typeof require('react')).toBe('object');
  });

  it('should have expo-image mock', () => {
    expect(typeof require('expo-image')).toBe('object');
  });

  it('should have nativewind mock', () => {
    expect(typeof require('nativewind')).toBe('object');
  });
});
