import * as LocalAuthentication from 'expo-local-authentication';
import { showErrorToast, TIMEOUT } from '@/components/global';

export interface BiometricAuthResult {
  success: boolean;
  error?: string;
}

export interface AuthState {
  isBiometricSupported: boolean;
  isAuthenticated: boolean;
  expiry?: number;
}

/**
 * Check if biometric hardware is available on the device
 */
export const checkBiometricHardware = async (): Promise<boolean> => {
  try {
    return await LocalAuthentication.hasHardwareAsync();
  } catch (error) {
    console.error('Error checking biometric hardware:', error);
    return false;
  }
};

/**
 * Check if biometric authentication is enrolled on the device
 */
export const checkBiometricEnrollment = async (): Promise<boolean> => {
  try {
    return await LocalAuthentication.isEnrolledAsync();
  } catch (error) {
    console.error('Error checking biometric enrollment:', error);
    return false;
  }
};

/**
 * Perform biometric authentication
 */
export const authenticateWithBiometrics =
  async (): Promise<BiometricAuthResult> => {
    try {
      const result = await LocalAuthentication.authenticateAsync({
        promptMessage: "You need to be this device's owner to use this app",
        disableDeviceFallback: false,
      });

      return {
        success: result.success,
        error: result.success ? undefined : (result as any).error,
      };
    } catch (error) {
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Authentication failed',
      };
    }
  };

/**
 * Check if the current session is still valid based on expiry time
 */
export const isSessionValid = (expiry: string | null): boolean => {
  if (!expiry) return false;
  return parseInt(expiry) > Date.now();
};

/**
 * Generate new expiry timestamp
 */
export const generateExpiryTime = (): string => {
  return (Date.now() + TIMEOUT).toString();
};

/**
 * Handle the complete biometric authentication flow
 */
export const handleBiometricAuthFlow = async (
  getItem: (key: string) => Promise<string | null>,
  setItem: (key: string, value: string) => Promise<void>
): Promise<boolean> => {
  try {
    // Check if session is still valid
    const expiry = await getItem('expiry');
    if (isSessionValid(expiry)) {
      return true;
    }

    // Check if biometrics are enrolled
    const isEnrolled = await checkBiometricEnrollment();
    if (!isEnrolled) {
      showErrorToast(
        'No Biometrics Authentication\nPlease verify your identity with your password'
      );
      return false;
    }

    // Perform authentication
    const authResult = await authenticateWithBiometrics();
    if (authResult.success) {
      await setItem('expiry', generateExpiryTime());
      return true;
    }

    return false;
  } catch (error) {
    console.error('Biometric authentication flow failed:', error);
    return false;
  }
};
