import { useState, useEffect, useCallback, useRef } from 'react';
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
  const isAuthenticatingRef = useRef(false);

  const [storage, { getItem, setItem }, isStorageLoading, hasChanged] =
    useAsyncStorage();

  // Create stable references to storage functions
  const getItemRef = useRef(getItem);
  const setItemRef = useRef(setItem);

  // Update refs when functions change
  useEffect(() => {
    getItemRef.current = getItem;
    setItemRef.current = setItem;
  }, [getItem, setItem]);

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
    if (isAuthenticatingRef.current) return;

    isAuthenticatingRef.current = true;
    try {
      const success = await handleBiometricAuthFlow(
        getItemRef.current,
        setItemRef.current
      );
      setAuthState((prev) => ({
        ...prev,
        isAuthenticated: success,
        expiry: success ? Date.now() + 3600000 : undefined, // 1 hour from now
      }));
    } catch (error) {
      console.error('Biometric authentication failed:', error);
      setAuthState((prev) => ({ ...prev, isAuthenticated: false }));
    } finally {
      isAuthenticatingRef.current = false;
    }
  }, []);

  /**
   * Check authentication status when storage changes
   */
  useEffect(() => {
    if (!hasChanged || isInitializing || isAuthenticatingRef.current) return;

    const checkAuthStatus = async () => {
      try {
        const expiry = await getItemRef.current('expiry');
        if (!expiry || parseInt(expiry) < Date.now()) {
          // Only trigger auth if we're not already authenticating
          if (!isAuthenticatingRef.current) {
            isAuthenticatingRef.current = true;
            try {
              const success = await handleBiometricAuthFlow(
                getItemRef.current,
                setItemRef.current
              );
              setAuthState((prev) => ({
                ...prev,
                isAuthenticated: success,
                expiry: success ? Date.now() + 3600000 : undefined,
              }));
            } catch (error) {
              console.error('Biometric authentication failed:', error);
              setAuthState((prev) => ({ ...prev, isAuthenticated: false }));
            } finally {
              isAuthenticatingRef.current = false;
            }
          }
        }
      } catch (error) {
        console.error('Failed to check auth status:', error);
      }
    };

    checkAuthStatus();
  }, [hasChanged, isInitializing]);

  return {
    authState,
    isLoading: isInitializing,
    initializeAuth,
    performBiometricAuth,
  };
};
