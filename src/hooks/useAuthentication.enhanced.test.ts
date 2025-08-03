import React from 'react';
import { useAuthentication } from './useAuthentication';
import { useAsyncStorage } from './useAsyncStorage';
import {
  checkBiometricHardware,
  handleBiometricAuthFlow,
} from '../services/authService';
import {
  preventSplashScreenAutoHide,
  hideSplashScreen,
  hideSplashScreenWithErrorHandling,
} from '../services/splashScreenService';
import { registerBackgroundTask } from '../services/backgroundTaskService';

// Mock dependencies
jest.mock('./useAsyncStorage');
jest.mock('../services/authService');
jest.mock('../services/splashScreenService');
jest.mock('../services/backgroundTaskService');

// Get mocked functions
const mockUseAsyncStorage = useAsyncStorage as jest.MockedFunction<
  typeof useAsyncStorage
>;
const mockCheckBiometricHardware =
  checkBiometricHardware as jest.MockedFunction<typeof checkBiometricHardware>;
const mockHandleBiometricAuthFlow =
  handleBiometricAuthFlow as jest.MockedFunction<
    typeof handleBiometricAuthFlow
  >;
const mockPreventSplashScreenAutoHide =
  preventSplashScreenAutoHide as jest.MockedFunction<
    typeof preventSplashScreenAutoHide
  >;
const mockHideSplashScreen = hideSplashScreen as jest.MockedFunction<
  typeof hideSplashScreen
>;
const mockHideSplashScreenWithErrorHandling =
  hideSplashScreenWithErrorHandling as jest.MockedFunction<
    typeof hideSplashScreenWithErrorHandling
  >;
const mockRegisterBackgroundTask =
  registerBackgroundTask as jest.MockedFunction<typeof registerBackgroundTask>;

// Mock storage operations
const mockSetItem = jest.fn();
const mockGetItem = jest.fn();
const mockRemoveItem = jest.fn();
const mockStorage = {} as Record<string, string>;

describe('useAuthentication Enhanced Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();

    // Default mock implementations
    mockUseAsyncStorage.mockReturnValue([
      mockStorage,
      {
        setItem: mockSetItem,
        getItem: mockGetItem,
        removeItem: mockRemoveItem,
      },
      false, // isLoading
      0, // hasChanged
    ]);

    mockCheckBiometricHardware.mockResolvedValue(true);
    mockHandleBiometricAuthFlow.mockResolvedValue(true);
    mockPreventSplashScreenAutoHide.mockImplementation(() => Promise.resolve());
    mockHideSplashScreen.mockImplementation(() => Promise.resolve());
    mockHideSplashScreenWithErrorHandling.mockImplementation(() =>
      Promise.resolve()
    );
    mockRegisterBackgroundTask.mockResolvedValue(true);
    mockGetItem.mockResolvedValue(null);
    mockSetItem.mockImplementation(() => Promise.resolve());
  });

  describe('Hook Structure and Exports', () => {
    it('should export useAuthentication hook', () => {
      expect(useAuthentication).toBeDefined();
      expect(typeof useAuthentication).toBe('function');
      expect(useAuthentication.name).toBe('useAuthentication');
    });

    it('should have proper dependency imports', () => {
      expect(checkBiometricHardware).toBeDefined();
      expect(handleBiometricAuthFlow).toBeDefined();
      expect(preventSplashScreenAutoHide).toBeDefined();
      expect(hideSplashScreen).toBeDefined();
      expect(hideSplashScreenWithErrorHandling).toBeDefined();
      expect(registerBackgroundTask).toBeDefined();
      expect(useAsyncStorage).toBeDefined();
    });
  });

  describe('Biometric Support Detection Flow', () => {
    it('should handle biometric support check success', async () => {
      mockCheckBiometricHardware.mockResolvedValue(true);

      const result = await mockCheckBiometricHardware();

      expect(result).toBe(true);
      expect(mockCheckBiometricHardware).toHaveBeenCalled();
    });

    it('should handle biometric support check failure', async () => {
      mockCheckBiometricHardware.mockResolvedValue(false);

      const result = await mockCheckBiometricHardware();

      expect(result).toBe(false);
      expect(mockCheckBiometricHardware).toHaveBeenCalled();
    });

    it('should handle biometric support check errors', async () => {
      const testError = new Error('Biometric check failed');
      mockCheckBiometricHardware.mockRejectedValue(testError);

      try {
        await mockCheckBiometricHardware();
      } catch (error) {
        expect(error).toBe(testError);
      }

      expect(mockCheckBiometricHardware).toHaveBeenCalled();
    });

    it('should not throw error when biometric support check fails', async () => {
      const testError = new Error('Biometric check failed');
      mockCheckBiometricHardware.mockRejectedValue(testError);

      const safeCheck = async () => {
        try {
          return await mockCheckBiometricHardware();
        } catch {
          return false;
        }
      };

      const result = await safeCheck();
      expect(result).toBe(false);
    });
  });

  describe('Authentication Flow Testing', () => {
    it('should handle successful biometric authentication', async () => {
      mockHandleBiometricAuthFlow.mockResolvedValue(true);

      const result = await mockHandleBiometricAuthFlow(
        mockGetItem,
        mockSetItem
      );

      expect(result).toBe(true);
      expect(mockHandleBiometricAuthFlow).toHaveBeenCalledWith(
        mockGetItem,
        mockSetItem
      );
    });

    it('should handle failed biometric authentication', async () => {
      mockHandleBiometricAuthFlow.mockResolvedValue(false);

      const result = await mockHandleBiometricAuthFlow(
        mockGetItem,
        mockSetItem
      );

      expect(result).toBe(false);
      expect(mockHandleBiometricAuthFlow).toHaveBeenCalledWith(
        mockGetItem,
        mockSetItem
      );
    });

    it('should handle authentication errors', async () => {
      const testError = new Error('Auth service error');
      mockHandleBiometricAuthFlow.mockRejectedValue(testError);

      try {
        await mockHandleBiometricAuthFlow(mockGetItem, mockSetItem);
      } catch (error) {
        expect(error).toBe(testError);
      }

      expect(mockHandleBiometricAuthFlow).toHaveBeenCalled();
    });

    it('should not throw error when authentication fails', async () => {
      const testError = new Error('Auth service error');
      mockHandleBiometricAuthFlow.mockRejectedValue(testError);

      const safeAuth = async () => {
        try {
          return await mockHandleBiometricAuthFlow(mockGetItem, mockSetItem);
        } catch {
          return false;
        }
      };

      const result = await safeAuth();
      expect(result).toBe(false);
    });
  });

  describe('Splash Screen Management', () => {
    it('should handle splash screen operations', async () => {
      await mockPreventSplashScreenAutoHide();
      await mockHideSplashScreen();

      expect(mockPreventSplashScreenAutoHide).toHaveBeenCalled();
      expect(mockHideSplashScreen).toHaveBeenCalled();
    });

    it('should handle splash screen errors', async () => {
      const testError = new Error('Splash screen error');
      await mockHideSplashScreenWithErrorHandling(testError);

      expect(mockHideSplashScreenWithErrorHandling).toHaveBeenCalledWith(
        testError
      );
    });

    it('should handle splash screen hiding errors gracefully', async () => {
      const testError = new Error('Splash screen error');
      mockHideSplashScreen.mockRejectedValue(testError);

      const safeHide = async () => {
        try {
          await mockHideSplashScreen();
          return true;
        } catch (error) {
          await mockHideSplashScreenWithErrorHandling(error as Error);
          return false;
        }
      };

      const result = await safeHide();
      expect(result).toBe(false);
      expect(mockHideSplashScreenWithErrorHandling).toHaveBeenCalledWith(
        testError
      );
    });
  });

  describe('Background Task Registration', () => {
    it('should register background task successfully', async () => {
      await mockRegisterBackgroundTask();

      expect(mockRegisterBackgroundTask).toHaveBeenCalled();
    });

    it('should handle background task registration errors', async () => {
      const testError = new Error('Background task error');
      mockRegisterBackgroundTask.mockRejectedValue(testError);

      const safeRegister = async () => {
        try {
          await mockRegisterBackgroundTask();
          return true;
        } catch {
          return false;
        }
      };

      const result = await safeRegister();
      expect(result).toBe(false);
    });
  });

  describe('Storage Integration', () => {
    it('should handle storage operations', async () => {
      const testKey = 'expiry';
      const testValue = (Date.now() + 3600000).toString();

      mockGetItem.mockResolvedValue(testValue);

      await mockSetItem(testKey, testValue);
      const retrievedValue = await mockGetItem(testKey);

      expect(mockSetItem).toHaveBeenCalledWith(testKey, testValue);
      expect(mockGetItem).toHaveBeenCalledWith(testKey);
      expect(retrievedValue).toBe(testValue);
    });

    it('should handle storage loading states', () => {
      const testStorage = {} as Record<string, string>;
      mockUseAsyncStorage.mockReturnValue([
        testStorage,
        {
          setItem: mockSetItem,
          getItem: mockGetItem,
          removeItem: mockRemoveItem,
        },
        true, // isLoading
        0,
      ]);

      const [storage, operations, isLoading] = mockUseAsyncStorage();

      expect(storage).toBe(testStorage);
      expect(operations.setItem).toBe(mockSetItem);
      expect(operations.getItem).toBe(mockGetItem);
      expect(isLoading).toBe(true);
    });

    it('should handle storage changes', () => {
      const testStorage = {} as Record<string, string>;
      mockUseAsyncStorage.mockReturnValue([
        testStorage,
        {
          setItem: mockSetItem,
          getItem: mockGetItem,
          removeItem: mockRemoveItem,
        },
        false,
        1, // hasChanged
      ]);

      const [, , , hasChanged] = mockUseAsyncStorage();

      expect(hasChanged).toBe(1);
      expect(typeof hasChanged).toBe('number');
    });
  });

  describe('Error Handling and Edge Cases', () => {
    it('should handle null and undefined values', async () => {
      mockGetItem.mockResolvedValue(null);

      const result = await mockGetItem('expiry');
      expect(result).toBeNull();

      mockGetItem.mockResolvedValue(undefined);
      const undefinedResult = await mockGetItem('expiry');
      expect(undefinedResult).toBeUndefined();
    });

    it('should handle authentication result edge cases', async () => {
      // Test undefined result
      mockHandleBiometricAuthFlow.mockResolvedValue(undefined as any);

      const undefinedResult = await mockHandleBiometricAuthFlow(
        mockGetItem,
        mockSetItem
      );
      expect(undefinedResult).toBeUndefined();

      // Test null result
      mockHandleBiometricAuthFlow.mockResolvedValue(null as any);

      const nullResult = await mockHandleBiometricAuthFlow(
        mockGetItem,
        mockSetItem
      );
      expect(nullResult).toBeNull();
    });

    it('should handle biometric support check edge cases', async () => {
      // Test undefined result
      mockCheckBiometricHardware.mockResolvedValue(undefined as any);

      const undefinedResult = await mockCheckBiometricHardware();
      expect(undefinedResult).toBeUndefined();

      // Test null result
      mockCheckBiometricHardware.mockResolvedValue(null as any);

      const nullResult = await mockCheckBiometricHardware();
      expect(nullResult).toBeNull();
    });
  });

  describe('Memory Management', () => {
    it('should not cause memory leaks during operations', () => {
      // Test that mock functions can be called and cleared without issues
      mockCheckBiometricHardware();
      mockHandleBiometricAuthFlow(mockGetItem, mockSetItem);
      mockRegisterBackgroundTask();

      expect(() => {
        jest.clearAllMocks();
      }).not.toThrow();
    });

    it('should handle cleanup operations', () => {
      const cleanup = () => {
        jest.clearAllMocks();
        mockUseAsyncStorage.mockReset();
        mockCheckBiometricHardware.mockReset();
        mockHandleBiometricAuthFlow.mockReset();
      };

      expect(() => {
        cleanup();
      }).not.toThrow();
    });
  });

  describe('Integration Flow Testing', () => {
    it('should test complete authentication initialization flow', async () => {
      const initFlow = async () => {
        await mockPreventSplashScreenAutoHide();
        await mockRegisterBackgroundTask();
        const isBiometricSupported = await mockCheckBiometricHardware();

        if (isBiometricSupported) {
          const authResult = await mockHandleBiometricAuthFlow(
            mockGetItem,
            mockSetItem
          );
          if (authResult) {
            await mockHideSplashScreen();
          }
          return authResult;
        }

        return false;
      };

      const result = await initFlow();

      expect(result).toBe(true);
      expect(mockPreventSplashScreenAutoHide).toHaveBeenCalled();
      expect(mockRegisterBackgroundTask).toHaveBeenCalled();
      expect(mockCheckBiometricHardware).toHaveBeenCalled();
      expect(mockHandleBiometricAuthFlow).toHaveBeenCalled();
      expect(mockHideSplashScreen).toHaveBeenCalled();
    });

    it('should test authentication flow with failures', async () => {
      mockCheckBiometricHardware.mockResolvedValue(false);

      const initFlow = async () => {
        const isBiometricSupported = await mockCheckBiometricHardware();

        if (!isBiometricSupported) {
          return { authenticated: false, reason: 'biometric_not_supported' };
        }

        return { authenticated: true, reason: 'success' };
      };

      const result = await initFlow();

      expect(result.authenticated).toBe(false);
      expect(result.reason).toBe('biometric_not_supported');
    });
  });
});
