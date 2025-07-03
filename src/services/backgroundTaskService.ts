import * as BackgroundTask from 'expo-background-task';
import { SPEECH_TASK } from '@/components/SpeechTask';

export interface BackgroundTaskConfig {
  minimumInterval: number;
}

/**
 * Default configuration for background tasks
 */
export const DEFAULT_BACKGROUND_TASK_CONFIG: BackgroundTaskConfig = {
  minimumInterval: 10, // minimum interval in minutes
};

/**
 * Register a background task with the given configuration
 */
export const registerBackgroundTask = async (
  taskName: string = SPEECH_TASK,
  config: BackgroundTaskConfig = DEFAULT_BACKGROUND_TASK_CONFIG
): Promise<boolean> => {
  try {
    await BackgroundTask.registerTaskAsync(taskName, config);
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
    await BackgroundTask.unregisterTaskAsync(taskName);
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
    const status = await BackgroundTask.getStatusAsync();
    return status === BackgroundTask.BackgroundTaskStatus.Available;
  } catch (error) {
    console.error(
      `Failed to check background task status for '${taskName}':`,
      error
    );
    return false;
  }
};
