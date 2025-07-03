import {
  registerBackgroundTask,
  unregisterBackgroundTask,
  isBackgroundTaskRegistered,
  DEFAULT_BACKGROUND_TASK_CONFIG,
} from '@/services/backgroundTaskService';
import * as BackgroundFetch from 'expo-background-fetch';
import { SPEECH_TASK } from '@/components/SpeechTask';

// Mock dependencies
jest.mock('expo-background-fetch');
jest.mock('@/components/SpeechTask', () => ({
  SPEECH_TASK: 'test-speech-task',
}));

const mockBackgroundFetch = BackgroundFetch as jest.Mocked<
  typeof BackgroundFetch
>;

describe('backgroundTaskService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Mock console.error to prevent test output pollution
    jest.spyOn(console, 'error').mockImplementation(() => {});
    jest.spyOn(console, 'log').mockImplementation(() => {});
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('registerBackgroundTask', () => {
    it('should register background task with default parameters', async () => {
      mockBackgroundFetch.registerTaskAsync.mockResolvedValue(undefined);

      const result = await registerBackgroundTask();

      expect(result).toBe(true);
      expect(mockBackgroundFetch.registerTaskAsync).toHaveBeenCalledWith(
        SPEECH_TASK,
        DEFAULT_BACKGROUND_TASK_CONFIG
      );
      expect(console.log).toHaveBeenCalledWith(
        `Background task '${SPEECH_TASK}' registered successfully`
      );
    });

    it('should register background task with custom parameters', async () => {
      mockBackgroundFetch.registerTaskAsync.mockResolvedValue(undefined);
      const customTaskName = 'custom-task';
      const customConfig = {
        minimumInterval: 20,
        stopOnTerminate: false,
        startOnBoot: true,
      };

      const result = await registerBackgroundTask(customTaskName, customConfig);

      expect(result).toBe(true);
      expect(mockBackgroundFetch.registerTaskAsync).toHaveBeenCalledWith(
        customTaskName,
        customConfig
      );
      expect(console.log).toHaveBeenCalledWith(
        `Background task '${customTaskName}' registered successfully`
      );
    });

    it('should return false and log error when registration fails', async () => {
      const error = new Error('Registration failed');
      mockBackgroundFetch.registerTaskAsync.mockRejectedValue(error);

      const result = await registerBackgroundTask();

      expect(result).toBe(false);
      expect(console.error).toHaveBeenCalledWith(
        `Failed to register background task '${SPEECH_TASK}':`,
        error
      );
    });
  });

  describe('unregisterBackgroundTask', () => {
    it('should unregister background task with default task name', async () => {
      mockBackgroundFetch.unregisterTaskAsync.mockResolvedValue(undefined);

      const result = await unregisterBackgroundTask();

      expect(result).toBe(true);
      expect(mockBackgroundFetch.unregisterTaskAsync).toHaveBeenCalledWith(
        SPEECH_TASK
      );
      expect(console.log).toHaveBeenCalledWith(
        `Background task '${SPEECH_TASK}' unregistered successfully`
      );
    });

    it('should unregister background task with custom task name', async () => {
      mockBackgroundFetch.unregisterTaskAsync.mockResolvedValue(undefined);
      const customTaskName = 'custom-task';

      const result = await unregisterBackgroundTask(customTaskName);

      expect(result).toBe(true);
      expect(mockBackgroundFetch.unregisterTaskAsync).toHaveBeenCalledWith(
        customTaskName
      );
      expect(console.log).toHaveBeenCalledWith(
        `Background task '${customTaskName}' unregistered successfully`
      );
    });

    it('should return false and log error when unregistration fails', async () => {
      const error = new Error('Unregistration failed');
      mockBackgroundFetch.unregisterTaskAsync.mockRejectedValue(error);

      const result = await unregisterBackgroundTask();

      expect(result).toBe(false);
      expect(console.error).toHaveBeenCalledWith(
        `Failed to unregister background task '${SPEECH_TASK}':`,
        error
      );
    });
  });

  describe('isBackgroundTaskRegistered', () => {
    it('should return true when background fetch is available', async () => {
      mockBackgroundFetch.getStatusAsync.mockResolvedValue(
        BackgroundFetch.BackgroundFetchStatus.Available
      );

      const result = await isBackgroundTaskRegistered();

      expect(result).toBe(true);
      expect(mockBackgroundFetch.getStatusAsync).toHaveBeenCalledTimes(1);
    });

    it('should return false when background fetch is not available', async () => {
      mockBackgroundFetch.getStatusAsync.mockResolvedValue(
        BackgroundFetch.BackgroundFetchStatus.Denied
      );

      const result = await isBackgroundTaskRegistered();

      expect(result).toBe(false);
    });

    it('should return false and log error when status check fails', async () => {
      const error = new Error('Status check failed');
      mockBackgroundFetch.getStatusAsync.mockRejectedValue(error);

      const result = await isBackgroundTaskRegistered();

      expect(result).toBe(false);
      expect(console.error).toHaveBeenCalledWith(
        `Failed to check background task status for '${SPEECH_TASK}':`,
        error
      );
    });
  });

  describe('DEFAULT_BACKGROUND_TASK_CONFIG', () => {
    it('should have correct default values', () => {
      expect(DEFAULT_BACKGROUND_TASK_CONFIG).toEqual({
        minimumInterval: 10,
        stopOnTerminate: true,
        startOnBoot: false,
      });
    });
  });
});
