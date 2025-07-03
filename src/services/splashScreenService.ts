import { SplashScreen } from 'expo-router';
import { handleError } from '@/components/global';

/**
 * Prevent the splash screen from auto-hiding
 */
export const preventSplashScreenAutoHide = (): void => {
  try {
    SplashScreen.preventAutoHideAsync();
  } catch (error) {
    console.error('Failed to prevent splash screen auto-hide:', error);
  }
};

/**
 * Hide the splash screen
 */
export const hideSplashScreen = async (): Promise<void> => {
  try {
    await SplashScreen.hideAsync();
  } catch (error) {
    console.error('Failed to hide splash screen:', error);
  }
};

/**
 * Hide splash screen and handle any errors that occur
 */
export const hideSplashScreenWithErrorHandling = async (
  error?: Error
): Promise<void> => {
  try {
    await hideSplashScreen();
    if (error) {
      handleError(error);
    }
  } catch (hideError) {
    console.error(
      'Failed to hide splash screen with error handling:',
      hideError
    );
    if (error) {
      handleError(error);
    }
  }
};
