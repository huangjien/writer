import { useState, useEffect, useCallback } from 'react';
import { useAsyncStorage } from '@/hooks/useAsyncStorage';
import {
  checkBiometricHardware,
  handleBiometricAuthFlow,
  AuthState,
} from '@/services/authService';
import {
  preventSplashScreenAutoHide,
  hideSplashScreen,
  hideSplashScreenWithErrorHandling,
} from '@/services/splashScreenService';
import { registerBackgroundTask } from '@/services/backgroundTaskService';

export interface UseAuthenticationReturn {
  authState: AuthState;
  isLoading: boolean;
  initializeAuth: () => Promise<void>;
  performBiometricAuth: () => Promise<void>;
}

/**
 * Custom hook to manage authentication state and operations
 */
export const useAuthentication = (): UseAuthenticationReturn => {
  const [authState, setAuthState] = useState<AuthState>({
    isBiometricSupported: false,
    isAuthenticated: false,
  });
  const [isInitializing, setIsInitializing] = useState(false);

  const [storage, { getItem, setItem }, isStorageLoading, hasChanged] =
    useAsyncStorage();

  /**
   * Initialize authentication system
   */
  const initializeAuth = useCallback(async (): Promise<void> => {
    setIsInitializing(true);

    try {
      // Prevent splash screen from auto-hiding
      preventSplashScreenAutoHide();

      // Register background task
      await registerBackgroundTask();

      // Check biometric hardware support
      const isBiometricSupported = await checkBiometricHardware();
      setAuthState((prev) => ({ ...prev, isBiometricSupported }));

      // Hide splash screen and perform initial auth
      await hideSplashScreen();
      await performBiometricAuth();
    } catch (error) {
      console.error('Authentication initialization failed:', error);
      await hideSplashScreenWithErrorHandling(error as Error);
    } finally {
      setIsInitializing(false);
    }
  }, []);

  /**
   * Perform biometric authentication
   */
  const performBiometricAuth = useCallback(async (): Promise<void> => {
    try {
      const success = await handleBiometricAuthFlow(getItem, setItem);
      setAuthState((prev) => ({
        ...prev,
        isAuthenticated: success,
        expiry: success ? Date.now() + 3600000 : undefined, // 1 hour from now
      }));
    } catch (error) {
      console.error('Biometric authentication failed:', error);
      setAuthState((prev) => ({ ...prev, isAuthenticated: false }));
    }
  }, [getItem, setItem]);

  /**
   * Check authentication status when storage changes
   */
  useEffect(() => {
    if (!hasChanged || isStorageLoading) return;

    const checkAuthStatus = async () => {
      try {
        const expiry = await getItem('expiry');
        if (!expiry || parseInt(expiry) < Date.now()) {
          await performBiometricAuth();
        }
      } catch (error) {
        console.error('Failed to check auth status:', error);
      }
    };

    checkAuthStatus();
  }, [hasChanged, isStorageLoading, getItem, performBiometricAuth]);

  return {
    authState,
    isLoading: isInitializing || isStorageLoading,
    initializeAuth,
    performBiometricAuth,
  };
};
