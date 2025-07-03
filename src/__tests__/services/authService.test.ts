import {
  checkBiometricHardware,
  checkBiometricEnrollment,
  authenticateWithBiometrics,
  isSessionValid,
  generateExpiryTime,
  handleBiometricAuthFlow,
} from '@/services/authService';
import * as LocalAuthentication from 'expo-local-authentication';
import { showErrorToast, TIMEOUT } from '@/components/global';

// Mock dependencies
jest.mock('expo-local-authentication');
jest.mock('@/components/global');

const mockLocalAuthentication = LocalAuthentication as jest.Mocked<
  typeof LocalAuthentication
>;
const mockShowErrorToast = showErrorToast as jest.MockedFunction<
  typeof showErrorToast
>;

describe('authService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Mock console.error to prevent test output pollution
    jest.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('checkBiometricHardware', () => {
    it('should return true when biometric hardware is available', async () => {
      mockLocalAuthentication.hasHardwareAsync.mockResolvedValue(true);

      const result = await checkBiometricHardware();

      expect(result).toBe(true);
      expect(mockLocalAuthentication.hasHardwareAsync).toHaveBeenCalledTimes(1);
    });

    it('should return false when biometric hardware is not available', async () => {
      mockLocalAuthentication.hasHardwareAsync.mockResolvedValue(false);

      const result = await checkBiometricHardware();

      expect(result).toBe(false);
    });

    it('should return false when an error occurs', async () => {
      mockLocalAuthentication.hasHardwareAsync.mockRejectedValue(
        new Error('Hardware check failed')
      );

      const result = await checkBiometricHardware();

      expect(result).toBe(false);
    });
  });

  describe('checkBiometricEnrollment', () => {
    it('should return true when biometrics are enrolled', async () => {
      mockLocalAuthentication.isEnrolledAsync.mockResolvedValue(true);

      const result = await checkBiometricEnrollment();

      expect(result).toBe(true);
      expect(mockLocalAuthentication.isEnrolledAsync).toHaveBeenCalledTimes(1);
    });

    it('should return false when biometrics are not enrolled', async () => {
      mockLocalAuthentication.isEnrolledAsync.mockResolvedValue(false);

      const result = await checkBiometricEnrollment();

      expect(result).toBe(false);
    });

    it('should return false when an error occurs', async () => {
      mockLocalAuthentication.isEnrolledAsync.mockRejectedValue(
        new Error('Enrollment check failed')
      );

      const result = await checkBiometricEnrollment();

      expect(result).toBe(false);
    });
  });

  describe('authenticateWithBiometrics', () => {
    it('should return success when authentication succeeds', async () => {
      mockLocalAuthentication.authenticateAsync.mockResolvedValue({
        success: true,
      });

      const result = await authenticateWithBiometrics();

      expect(result.success).toBe(true);
      expect(result.error).toBeUndefined();
      expect(mockLocalAuthentication.authenticateAsync).toHaveBeenCalledWith({
        promptMessage: "You need to be this device's owner to use this app",
        disableDeviceFallback: false,
      });
    });

    it('should return failure when authentication fails', async () => {
      mockLocalAuthentication.authenticateAsync.mockResolvedValue({
        success: false,
        error: 'UserCancel' as any,
      });

      const result = await authenticateWithBiometrics();

      expect(result.success).toBe(false);
      expect(result.error).toBe('UserCancel');
    });

    it('should handle exceptions during authentication', async () => {
      mockLocalAuthentication.authenticateAsync.mockRejectedValue(
        new Error('Auth failed')
      );

      const result = await authenticateWithBiometrics();

      expect(result.success).toBe(false);
      expect(result.error).toBe('Auth failed');
    });
  });

  describe('isSessionValid', () => {
    it('should return false for null expiry', () => {
      expect(isSessionValid(null)).toBe(false);
    });

    it('should return false for expired session', () => {
      const pastTime = (Date.now() - 1000).toString();
      expect(isSessionValid(pastTime)).toBe(false);
    });

    it('should return true for valid session', () => {
      const futureTime = (Date.now() + 1000).toString();
      expect(isSessionValid(futureTime)).toBe(true);
    });
  });

  describe('generateExpiryTime', () => {
    it('should generate expiry time in the future', () => {
      const now = Date.now();
      const expiry = parseInt(generateExpiryTime());

      expect(expiry).toBeGreaterThan(now);
      expect(expiry).toBeLessThanOrEqual(now + TIMEOUT + 100); // Allow small margin
    });
  });

  describe('handleBiometricAuthFlow', () => {
    const mockGetItem = jest.fn();
    const mockSetItem = jest.fn();

    beforeEach(() => {
      mockGetItem.mockClear();
      mockSetItem.mockClear();
    });

    it('should return true if session is still valid', async () => {
      const futureTime = (Date.now() + 1000).toString();
      mockGetItem.mockResolvedValue(futureTime);

      const result = await handleBiometricAuthFlow(mockGetItem, mockSetItem);

      expect(result).toBe(true);
      expect(mockGetItem).toHaveBeenCalledWith('expiry');
      expect(mockLocalAuthentication.isEnrolledAsync).not.toHaveBeenCalled();
    });

    it('should show error toast if biometrics are not enrolled', async () => {
      mockGetItem.mockResolvedValue(null);
      mockLocalAuthentication.isEnrolledAsync.mockResolvedValue(false);

      const result = await handleBiometricAuthFlow(mockGetItem, mockSetItem);

      expect(result).toBe(false);
      expect(mockShowErrorToast).toHaveBeenCalledWith(
        'No Biometrics Authentication\nPlease verify your identity with your password'
      );
    });

    it('should authenticate and set expiry on success', async () => {
      mockGetItem.mockResolvedValue(null);
      mockLocalAuthentication.isEnrolledAsync.mockResolvedValue(true);
      mockLocalAuthentication.authenticateAsync.mockResolvedValue({
        success: true,
      });

      const result = await handleBiometricAuthFlow(mockGetItem, mockSetItem);

      expect(result).toBe(true);
      expect(mockSetItem).toHaveBeenCalledWith('expiry', expect.any(String));
    });

    it('should return false on authentication failure', async () => {
      mockGetItem.mockResolvedValue(null);
      mockLocalAuthentication.isEnrolledAsync.mockResolvedValue(true);
      mockLocalAuthentication.authenticateAsync.mockResolvedValue({
        success: false,
        error: 'UserCancel' as any,
      });

      const result = await handleBiometricAuthFlow(mockGetItem, mockSetItem);

      expect(result).toBe(false);
      expect(mockSetItem).not.toHaveBeenCalled();
    });
  });
});
