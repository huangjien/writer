import * as BackgroundFetch from 'expo-background-fetch';
import { SPEECH_TASK } from '@/components/SpeechTask';

export interface BackgroundTaskConfig {
  minimumInterval: number;
  stopOnTerminate: boolean;
  startOnBoot: boolean;
}

/**
 * Default configuration for background tasks
 */
export const DEFAULT_BACKGROUND_TASK_CONFIG: BackgroundTaskConfig = {
  minimumInterval: 10,
  stopOnTerminate: true,
  startOnBoot: false,
};

/**
 * Register a background task with the given configuration
 */
export const registerBackgroundTask = async (
  taskName: string = SPEECH_TASK,
  config: BackgroundTaskConfig = DEFAULT_BACKGROUND_TASK_CONFIG
): Promise<boolean> => {
  try {
    await BackgroundFetch.registerTaskAsync(taskName, config);
    console.log(`Background task '${taskName}' registered successfully`);
    return true;
  } catch (error) {
    console.error(`Failed to register background task '${taskName}':`, error);
    return false;
  }
};

/**
 * Unregister a background task
 */
export const unregisterBackgroundTask = async (
  taskName: string = SPEECH_TASK
): Promise<boolean> => {
  try {
    await BackgroundFetch.unregisterTaskAsync(taskName);
    console.log(`Background task '${taskName}' unregistered successfully`);
    return true;
  } catch (error) {
    console.error(`Failed to unregister background task '${taskName}':`, error);
    return false;
  }
};

/**
 * Check if a background task is registered
 */
export const isBackgroundTaskRegistered = async (
  taskName: string = SPEECH_TASK
): Promise<boolean> => {
  try {
    const isRegistered = await BackgroundFetch.getStatusAsync();
    return isRegistered === BackgroundFetch.BackgroundFetchStatus.Available;
  } catch (error) {
    console.error(
      `Failed to check background task status for '${taskName}':`,
      error
    );
    return false;
  }
};
