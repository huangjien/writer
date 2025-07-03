import {
  preventSplashScreenAutoHide,
  hideSplashScreen,
  hideSplashScreenWithErrorHandling,
} from '@/services/splashScreenService';
import { SplashScreen } from 'expo-router';
import { handleError } from '@/components/global';

// Mock dependencies
jest.mock('expo-router', () => ({
  SplashScreen: {
    preventAutoHideAsync: jest.fn(),
    hideAsync: jest.fn(),
  },
}));
jest.mock('@/components/global');

const mockSplashScreen = SplashScreen as jest.Mocked<typeof SplashScreen>;
const mockHandleError = handleError as jest.MockedFunction<typeof handleError>;

describe('splashScreenService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Reset console.error mock
    jest.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('preventSplashScreenAutoHide', () => {
    it('should call SplashScreen.preventAutoHideAsync', () => {
      preventSplashScreenAutoHide();

      expect(mockSplashScreen.preventAutoHideAsync).toHaveBeenCalledTimes(1);
    });

    it('should handle errors gracefully', () => {
      const error = new Error('Prevent auto-hide failed');
      mockSplashScreen.preventAutoHideAsync.mockImplementation(() => {
        throw error;
      });

      preventSplashScreenAutoHide();

      expect(console.error).toHaveBeenCalledWith(
        'Failed to prevent splash screen auto-hide:',
        error
      );
    });
  });

  describe('hideSplashScreen', () => {
    it('should call SplashScreen.hideAsync successfully', async () => {
      mockSplashScreen.hideAsync.mockResolvedValue(undefined);

      await hideSplashScreen();

      expect(mockSplashScreen.hideAsync).toHaveBeenCalledTimes(1);
    });

    it('should handle errors and log them', async () => {
      const error = new Error('Hide failed');
      mockSplashScreen.hideAsync.mockRejectedValue(error);

      await hideSplashScreen();

      expect(console.error).toHaveBeenCalledWith(
        'Failed to hide splash screen:',
        error
      );
    });
  });

  describe('hideSplashScreenWithErrorHandling', () => {
    it('should hide splash screen without additional error when no error provided', async () => {
      mockSplashScreen.hideAsync.mockResolvedValue(undefined);

      await hideSplashScreenWithErrorHandling();

      expect(mockSplashScreen.hideAsync).toHaveBeenCalledTimes(1);
      expect(mockHandleError).not.toHaveBeenCalled();
    });

    it('should hide splash screen and handle provided error', async () => {
      mockSplashScreen.hideAsync.mockResolvedValue(undefined);
      const originalError = new Error('Original error');

      await hideSplashScreenWithErrorHandling(originalError);

      expect(mockSplashScreen.hideAsync).toHaveBeenCalledTimes(1);
      expect(mockHandleError).toHaveBeenCalledWith(originalError);
    });

    it('should handle both splash screen hide failure and original error', async () => {
      const hideError = new Error('Hide failed');
      const originalError = new Error('Original error');
      mockSplashScreen.hideAsync.mockRejectedValue(hideError);

      await hideSplashScreenWithErrorHandling(originalError);

      expect(console.error).toHaveBeenCalledWith(
        'Failed to hide splash screen with error handling:',
        hideError
      );
      expect(mockHandleError).toHaveBeenCalledWith(originalError);
    });

    it('should handle splash screen hide failure without original error', async () => {
      const hideError = new Error('Hide failed');
      mockSplashScreen.hideAsync.mockRejectedValue(hideError);

      await hideSplashScreenWithErrorHandling();

      expect(console.error).toHaveBeenCalledWith(
        'Failed to hide splash screen with error handling:',
        hideError
      );
      expect(mockHandleError).not.toHaveBeenCalled();
    });

    it('should handle splash screen hide failure and still process original error', async () => {
      const hideError = new Error('Hide failed');
      const originalError = new Error('Original error');
      mockSplashScreen.hideAsync.mockRejectedValue(hideError);

      await hideSplashScreenWithErrorHandling(originalError);

      expect(console.error).toHaveBeenCalledWith(
        'Failed to hide splash screen with error handling:',
        hideError
      );
      expect(mockHandleError).toHaveBeenCalledWith(originalError);
    });
  });
});
