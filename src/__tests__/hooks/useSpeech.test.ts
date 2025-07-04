// Mock Setup Tests
describe('useSpeech', () => {
  it('should have useSpeech defined', () => {
    expect(typeof require('@/hooks/useSpeech')).toBe('object');
  });

  it('should have expo-speech mock', () => {
    expect(typeof require('expo-speech')).toBe('object');
  });

  it('should have expo-keep-awake mock', () => {
    expect(typeof require('expo-keep-awake')).toBe('object');
  });

  it('should have React defined', () => {
    expect(typeof require('react')).toBe('object');
  });
});
