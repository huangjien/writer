import {
  handleError,
  showErrorToast,
  showInfoToast,
  sleep,
  fileNameComparator,
  SETTINGS_KEY,
  CONTENT_KEY,
  ANALYSIS_KEY,
  STATUS_PLAYING,
  STATUS_PAUSED,
  STATUS_STOPPED,
  EXPIRY_KEY,
  TIMEOUT,
} from '../components/global';
import Toast from 'react-native-root-toast';

// Mock Toast
jest.mock('react-native-root-toast');
const mockToast = Toast as jest.Mocked<typeof Toast>;

describe('global utilities', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    jest.spyOn(console, 'error').mockImplementation(() => {});
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('constants', () => {
    it('should have correct constant values', () => {
      expect(SETTINGS_KEY).toBe('@Settings');
      expect(CONTENT_KEY).toBe('@Content:');
      expect(ANALYSIS_KEY).toBe('@Analysis:');
      expect(STATUS_PLAYING).toBe('playing');
      expect(STATUS_PAUSED).toBe('paused');
      expect(STATUS_STOPPED).toBe('stopped');
      expect(EXPIRY_KEY).toBe('expiry');
      expect(TIMEOUT).toBe(1000 * 60 * 60 * 8); // 8 hours
    });
  });

  describe('handleError', () => {
    it('should show error toast and log to console', () => {
      const error = { message: 'Test error', status: 500 };
      handleError(error);

      expect(mockToast.show).toHaveBeenCalledWith(
        'Test error',
        expect.any(Object)
      );
      expect(console.error).toHaveBeenCalledWith(500, 'Test error');
    });

    it('should handle errors without status', () => {
      const error = { message: 'Test error' };
      handleError(error);

      expect(mockToast.show).toHaveBeenCalledWith(
        'Test error',
        expect.any(Object)
      );
      expect(console.error).toHaveBeenCalledWith(undefined, 'Test error');
    });

    it('should handle errors without message', () => {
      const error = { status: 404 };
      handleError(error);

      expect(mockToast.show).toHaveBeenCalledWith(
        undefined,
        expect.any(Object)
      );
      expect(console.error).toHaveBeenCalledWith(404, undefined);
    });
  });

  describe('showErrorToast', () => {
    it('should show error toast with correct parameters', () => {
      const message = 'Error message';
      showErrorToast(message);

      expect(mockToast.show).toHaveBeenCalledWith(message, {
        position: 0,
        shadow: true,
        shadowColor: 'red',
        animation: true,
        hideOnPress: false,
        delay: 100,
        duration: 3500,
      });
    });

    it('should handle empty message', () => {
      showErrorToast('');
      expect(mockToast.show).toHaveBeenCalledWith('', expect.any(Object));
    });
  });

  describe('showInfoToast', () => {
    it('should show info toast with correct parameters', () => {
      const message = 'Info message';
      showInfoToast(message);

      expect(mockToast.show).toHaveBeenCalledWith(message, {
        position: 20,
        shadow: true,
        animation: true,
        hideOnPress: true,
        delay: 100,
        duration: 3500,
      });
    });

    it('should handle empty message', () => {
      showInfoToast('');
      expect(mockToast.show).toHaveBeenCalledWith('', expect.any(Object));
    });
  });

  describe('sleep', () => {
    it('should resolve after specified time', async () => {
      const startTime = Date.now();
      await sleep(100);
      const endTime = Date.now();

      expect(endTime - startTime).toBeGreaterThanOrEqual(90); // Allow some tolerance
    });

    it('should handle zero delay', async () => {
      const startTime = Date.now();
      await sleep(0);
      const endTime = Date.now();

      expect(endTime - startTime).toBeLessThan(50);
    });
  });

  describe('fileNameComparator', () => {
    it('should sort files numerically when both have numbers before underscore', () => {
      const file1 = { name: '1_chapter.md' };
      const file2 = { name: '2_chapter.md' };
      const file10 = { name: '10_chapter.md' };

      expect(fileNameComparator(file1, file2)).toBeLessThan(0);
      expect(fileNameComparator(file2, file10)).toBeLessThan(0);
      expect(fileNameComparator(file10, file1)).toBeGreaterThan(0);
    });

    it('should handle decimal numbers', () => {
      const file1 = { name: '1.5_chapter.md' };
      const file2 = { name: '2.0_chapter.md' };

      expect(fileNameComparator(file1, file2)).toBeLessThan(0);
      expect(fileNameComparator(file2, file1)).toBeGreaterThan(0);
    });

    it('should handle files without underscores', () => {
      const file1 = { name: 'chapter1.md' };
      const file2 = { name: 'chapter2.md' };

      // parseFloat('chapter1.md') returns NaN, so comparison should be 0
      expect(fileNameComparator(file1, file2)).toBe(0);
    });

    it('should handle identical file names', () => {
      const file1 = { name: '5_same.md' };
      const file2 = { name: '5_same.md' };

      expect(fileNameComparator(file1, file2)).toBe(0);
    });

    it('should handle mixed valid and invalid numbers', () => {
      const fileValid = { name: '3_chapter.md' };
      const fileInvalid = { name: 'abc_chapter.md' };

      // parseFloat('3') = 3, parseFloat('abc') = NaN
      // 3 < NaN is false, 3 > NaN is false, so should return 0
      expect(fileNameComparator(fileValid, fileInvalid)).toBe(0);
    });

    it('should handle edge cases', () => {
      const emptyName1 = { name: '' };
      const emptyName2 = { name: '' };
      const normalFile = { name: '1_normal.md' };

      // parseFloat('') = NaN for both, so should be 0
      expect(fileNameComparator(emptyName1, emptyName2)).toBe(0);
      // parseFloat('') = NaN, parseFloat('1') = 1, NaN < 1 is false, NaN > 1 is false
      expect(fileNameComparator(emptyName1, normalFile)).toBe(0);
    });
  });
});
