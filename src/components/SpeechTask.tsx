import * as TaskManager from 'expo-task-manager';
import { speechService } from '@/services/speechService';

export const SPEECH_TASK = 'background-speech-task';

TaskManager.defineTask(SPEECH_TASK, async ({ data, error }) => {
  console.log('TaskManager.defineTask called with:', { data, error });
  if (error) {
    console.error('Task Manager Error:', error);
    return;
  }
  if (!data) {
    console.log('No data provided, stopping speech');
    speechService.stop();
    return;
  }
  if (data) {
    console.log(
      'Data provided, calling speak with:',
      data['current'],
      data['progress']
    );
    // if pass empty data, then stop
    // if pass chapter and percentage, then start from there
    // onDone, then calculate next chapter
    // keep updating the current chapter and percentage to @setting
    await speechService.speak(data['current'], data['progress'], {
      language: 'zh',
      voice: 'zh',
    });
  }
});

// Export speechService for use in other components
export { speechService };
