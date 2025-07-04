// Mock dependencies
jest.mock('expo-router', () => ({
  useRouter: jest.fn(),
}));

jest.mock('../hooks/use-theme-config', () => ({
  useThemeConfig: jest.fn(),
}));

jest.mock('../hooks/useAsyncStorage', () => ({
  useAsyncStorage: jest.fn(),
}));

describe('CustomDrawerContent', () => {
  describe('Mock Setup', () => {
    it('should have useRouter mock defined', () => {
      expect(jest.isMockFunction(require('expo-router').useRouter)).toBe(true);
    });

    it('should have useThemeConfig mock defined', () => {
      expect(
        jest.isMockFunction(require('../hooks/use-theme-config').useThemeConfig)
      ).toBe(true);
    });

    it('should have useAsyncStorage mock defined', () => {
      expect(
        jest.isMockFunction(require('../hooks/useAsyncStorage').useAsyncStorage)
      ).toBe(true);
    });
  });
});
