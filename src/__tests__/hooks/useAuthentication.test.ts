import { useAuthentication } from '@/hooks/useAuthentication';
import * as authService from '@/services/authService';
import * as splashScreenService from '@/services/splashScreenService';
import * as backgroundTaskService from '@/services/backgroundTaskService';
import { AsyncStorageProvider } from '@/hooks/useAsyncStorage';

// Mock dependencies
jest.mock('@/services/authService');
jest.mock('@/services/splashScreenService');
jest.mock('@/services/backgroundTaskService');
jest.mock('@react-native-async-storage/async-storage', () => ({
  getItem: jest.fn(() => Promise.resolve(null)),
  setItem: jest.fn(() => Promise.resolve()),
  removeItem: jest.fn(() => Promise.resolve()),
  getAllKeys: jest.fn(() => Promise.resolve([])),
  multiGet: jest.fn(() => Promise.resolve([])),
}));

describe('useAuthentication', () => {
  describe('Mock Setup', () => {
    it('should have useAuthentication defined', () => {
      expect(useAuthentication).toBeDefined();
    });

    it('should have authService mock defined', () => {
      expect(authService.checkBiometricHardware).toBeDefined();
    });

    it('should have splashScreenService mock defined', () => {
      expect(splashScreenService.preventSplashScreenAutoHide).toBeDefined();
    });

    it('should have backgroundTaskService mock defined', () => {
      expect(backgroundTaskService.registerBackgroundTask).toBeDefined();
    });

    it('should have AsyncStorageProvider defined', () => {
      expect(AsyncStorageProvider).toBeDefined();
    });
  });
});
