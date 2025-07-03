import {
  registerBackgroundTask,
  unregisterBackgroundTask,
  isBackgroundTaskRegistered,
  DEFAULT_BACKGROUND_TASK_CONFIG,
} from '@/services/backgroundTaskService';
import * as BackgroundTask from 'expo-background-task';
import { SPEECH_TASK } from '@/components/SpeechTask';

// Mock dependencies
jest.mock('expo-background-task', () => ({
  registerTaskAsync: jest.fn(),
  unregisterTaskAsync: jest.fn(),
  getStatusAsync: jest.fn(),
  BackgroundTaskStatus: {
    Available: 1,
    Restricted: 2,
  },
  BackgroundTaskResult: {
    Success: 1,
    Failed: 2,
  },
}));
jest.mock('@/components/SpeechTask', () => ({
  SPEECH_TASK: 'test-speech-task',
}));

const mockBackgroundTask = BackgroundTask as jest.Mocked<typeof BackgroundTask>;

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
      mockBackgroundTask.registerTaskAsync.mockResolvedValue(undefined);

      const result = await registerBackgroundTask();

      expect(result).toBe(true);
      expect(mockBackgroundTask.registerTaskAsync).toHaveBeenCalledWith(
        SPEECH_TASK,
        DEFAULT_BACKGROUND_TASK_CONFIG
      );
      expect(console.log).toHaveBeenCalledWith(
        `Background task '${SPEECH_TASK}' registered successfully`
      );
    });

    it('should register background task with custom parameters', async () => {
      mockBackgroundTask.registerTaskAsync.mockResolvedValue(undefined);
      const customTaskName = 'custom-task';
      const customConfig = {
        minimumInterval: 15,
      };

      const result = await registerBackgroundTask(customTaskName, customConfig);

      expect(result).toBe(true);
      expect(mockBackgroundTask.registerTaskAsync).toHaveBeenCalledWith(
        customTaskName,
        customConfig
      );
      expect(console.log).toHaveBeenCalledWith(
        `Background task '${customTaskName}' registered successfully`
      );
    });

    it('should return false and log error when registration fails', async () => {
      const error = new Error('Registration failed');
      mockBackgroundTask.registerTaskAsync.mockRejectedValue(error);

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
      mockBackgroundTask.unregisterTaskAsync.mockResolvedValue(undefined);

      const result = await unregisterBackgroundTask();

      expect(result).toBe(true);
      expect(mockBackgroundTask.unregisterTaskAsync).toHaveBeenCalledWith(
        SPEECH_TASK
      );
      expect(console.log).toHaveBeenCalledWith(
        `Background task '${SPEECH_TASK}' unregistered successfully`
      );
    });

    it('should unregister background task with custom task name', async () => {
      mockBackgroundTask.unregisterTaskAsync.mockResolvedValue(undefined);
      const customTaskName = 'custom-task';

      const result = await unregisterBackgroundTask(customTaskName);

      expect(result).toBe(true);
      expect(mockBackgroundTask.unregisterTaskAsync).toHaveBeenCalledWith(
        customTaskName
      );
      expect(console.log).toHaveBeenCalledWith(
        `Background task '${customTaskName}' unregistered successfully`
      );
    });

    it('should return false and log error when unregistration fails', async () => {
      const error = new Error('Unregistration failed');
      mockBackgroundTask.unregisterTaskAsync.mockRejectedValue(error);

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
      mockBackgroundTask.getStatusAsync.mockResolvedValue(
        BackgroundTask.BackgroundTaskStatus.Available
      );

      const result = await isBackgroundTaskRegistered();

      expect(result).toBe(true);
      expect(mockBackgroundTask.getStatusAsync).toHaveBeenCalledTimes(1);
    });

    it('should return false when background fetch is not available', async () => {
      mockBackgroundTask.getStatusAsync.mockResolvedValue(
        BackgroundTask.BackgroundTaskStatus.Restricted
      );

      const result = await isBackgroundTaskRegistered();

      expect(result).toBe(false);
    });

    it('should return false and log error when status check fails', async () => {
      const error = new Error('Status check failed');
      mockBackgroundTask.getStatusAsync.mockRejectedValue(error);

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
      });
    });
  });
});
