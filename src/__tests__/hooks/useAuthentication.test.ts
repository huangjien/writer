import React from 'react';
import { renderHook, act, waitFor } from '@testing-library/react-native';
import { useAuthentication } from '@/hooks/useAuthentication';
import * as authService from '@/services/authService';
import * as splashScreenService from '@/services/splashScreenService';
import * as backgroundTaskService from '@/services/backgroundTaskService';
import { AsyncStorageProvider } from '@/hooks/useAsyncStorage';

// Mock AsyncStorage with proper implementation
const mockAsyncStorage = {
  getItem: jest.fn(() => Promise.resolve(null)),
  setItem: jest.fn(() => Promise.resolve()),
  removeItem: jest.fn(() => Promise.resolve()),
  getAllKeys: jest.fn(() => Promise.resolve([])),
  multiGet: jest.fn(() => Promise.resolve([])),
};

// Mock dependencies
jest.mock('@/services/authService');
jest.mock('@/services/splashScreenService');
jest.mock('@/services/backgroundTaskService');
jest.mock('@react-native-async-storage/async-storage', () => mockAsyncStorage);

const mockAuthService = authService as jest.Mocked<typeof authService>;
const mockSplashScreenService = splashScreenService as jest.Mocked<
  typeof splashScreenService
>;
const mockBackgroundTaskService = backgroundTaskService as jest.Mocked<
  typeof backgroundTaskService
>;

// Create a wrapper component for tests
const TestWrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return React.createElement(AsyncStorageProvider, null, children);
};

describe('useAuthentication', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Mock console.error to prevent test output pollution
    jest.spyOn(console, 'error').mockImplementation(() => {});
    jest.spyOn(console, 'log').mockImplementation(() => {});

    // Reset AsyncStorage mocks
    mockAsyncStorage.getItem.mockResolvedValue(null);
    mockAsyncStorage.setItem.mockResolvedValue();
    mockAsyncStorage.removeItem.mockResolvedValue();
    mockAsyncStorage.getAllKeys.mockResolvedValue([]);
    mockAsyncStorage.multiGet.mockResolvedValue([]);

    // Default mock implementations
    mockAuthService.checkBiometricHardware.mockResolvedValue(true);
    mockAuthService.handleBiometricAuthFlow.mockResolvedValue(true);
    mockSplashScreenService.preventSplashScreenAutoHide.mockImplementation(
      () => {}
    );
    mockSplashScreenService.hideSplashScreen.mockResolvedValue(undefined);
    mockBackgroundTaskService.registerBackgroundTask.mockResolvedValue(true);
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('initial state', () => {
    it('should return initial auth state', () => {
      const { result } = renderHook(() => useAuthentication(), {
        wrapper: TestWrapper,
      });

      expect(result.current.authState).toEqual({
        isBiometricSupported: false,
        isAuthenticated: false,
      });
      expect(result.current.isLoading).toBe(true); // Initially loading due to AsyncStorage
    });
  });

  describe('initializeAuth', () => {
    it('should initialize authentication successfully', async () => {
      const { result } = renderHook(() => useAuthentication(), {
        wrapper: TestWrapper,
      });

      await act(async () => {
        await result.current.initializeAuth();
      });

      expect(
        mockSplashScreenService.preventSplashScreenAutoHide
      ).toHaveBeenCalledTimes(1);
      expect(
        mockBackgroundTaskService.registerBackgroundTask
      ).toHaveBeenCalledTimes(1);
      expect(mockAuthService.checkBiometricHardware).toHaveBeenCalledTimes(1);
      expect(mockSplashScreenService.hideSplashScreen).toHaveBeenCalledTimes(1);
      expect(mockAuthService.handleBiometricAuthFlow).toHaveBeenCalled();
    });

    it('should update biometric support state', async () => {
      mockAuthService.checkBiometricHardware.mockResolvedValue(true);

      const { result } = renderHook(() => useAuthentication(), {
        wrapper: TestWrapper,
      });

      await act(async () => {
        await result.current.initializeAuth();
      });

      await waitFor(() => {
        expect(result.current.authState.isBiometricSupported).toBe(true);
      });
    });

    it('should update authentication state on successful auth', async () => {
      mockAuthService.handleBiometricAuthFlow.mockResolvedValue(true);

      const { result } = renderHook(() => useAuthentication(), {
        wrapper: TestWrapper,
      });

      await act(async () => {
        await result.current.initializeAuth();
      });

      await waitFor(() => {
        expect(result.current.authState.isAuthenticated).toBe(true);
        expect(result.current.authState.expiry).toBeDefined();
      });
    });

    it('should handle initialization errors gracefully', async () => {
      const error = new Error('Initialization failed');
      mockAuthService.checkBiometricHardware.mockRejectedValue(error);

      const { result } = renderHook(() => useAuthentication(), {
        wrapper: TestWrapper,
      });

      await act(async () => {
        await result.current.initializeAuth();
      });

      expect(console.error).toHaveBeenCalledWith(
        'Authentication initialization failed:',
        error
      );
      expect(
        mockSplashScreenService.hideSplashScreenWithErrorHandling
      ).toHaveBeenCalledWith(error);
    });
  });

  describe('performBiometricAuth', () => {
    it('should perform biometric authentication successfully', async () => {
      mockAuthService.handleBiometricAuthFlow.mockResolvedValue(true);

      const { result } = renderHook(() => useAuthentication(), {
        wrapper: TestWrapper,
      });

      await act(async () => {
        await result.current.performBiometricAuth();
      });

      expect(mockAuthService.handleBiometricAuthFlow).toHaveBeenCalled();
      expect(result.current.authState.isAuthenticated).toBe(true);
    });

    it('should handle authentication failure', async () => {
      mockAuthService.handleBiometricAuthFlow.mockResolvedValue(false);

      const { result } = renderHook(() => useAuthentication(), {
        wrapper: TestWrapper,
      });

      await act(async () => {
        await result.current.performBiometricAuth();
      });

      expect(result.current.authState.isAuthenticated).toBe(false);
    });

    it('should handle authentication errors', async () => {
      const error = new Error('Auth failed');
      mockAuthService.handleBiometricAuthFlow.mockRejectedValue(error);

      const { result } = renderHook(() => useAuthentication(), {
        wrapper: TestWrapper,
      });

      await act(async () => {
        await result.current.performBiometricAuth();
      });

      expect(console.error).toHaveBeenCalledWith(
        'Biometric authentication failed:',
        error
      );
      expect(result.current.authState.isAuthenticated).toBe(false);
    });
  });

  describe('storage change effects', () => {
    it('should render without errors', async () => {
      const { result } = renderHook(() => useAuthentication(), {
        wrapper: TestWrapper,
      });

      // Just verify the hook renders and has the expected structure
      expect(result.current).toHaveProperty('authState');
      expect(result.current).toHaveProperty('isLoading');
      expect(result.current).toHaveProperty('initializeAuth');
      expect(result.current).toHaveProperty('performBiometricAuth');
    });
  });

  describe('loading states', () => {
    it('should show loading when storage is loading', () => {
      const { result } = renderHook(() => useAuthentication(), {
        wrapper: TestWrapper,
      });

      expect(result.current.isLoading).toBe(true);
    });
  });
});
