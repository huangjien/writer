import * as TaskManager from 'expo-task-manager';
import * as Speech from 'expo-speech';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { CONTENT_KEY, showErrorToast } from './global';

export const SPEECH_TASK = 'background-speech-task';

function getContentFromProgress(content, progress) {
  // get the content from the progress
  if (!content) return '';
  const content_length: number = Math.round(content.length * progress);
  return content.substring(content_length);
}

TaskManager.defineTask(SPEECH_TASK, async ({ data, error }) => {
  // Use AsyncStorage directly instead of hooks
  const getItem = async (key: string) => {
    try {
      return await AsyncStorage.getItem(key);
    } catch (error) {
      console.error('AsyncStorage getItem error:', error);
      return null;
    }
  };

  const setItem = async (key: string, value: string) => {
    try {
      await AsyncStorage.setItem(key, value);
    } catch (error) {
      console.error('AsyncStorage setItem error:', error);
    }
  };

  const speak = async (current, progress) => {
    // speak current from progress, when finished, speak next
    try {
      const contentKey = current.toString().trim().startsWith(CONTENT_KEY)
        ? current.toString().trim()
        : CONTENT_KEY + current.toString().trim();
      const data = await getItem(contentKey);
      if (!data) {
        showErrorToast('No content for this chapter yet:' + current + '!');
        return;
      } else {
        const content = JSON.parse(data)['content'];
        if (content.length > Speech.maxSpeechInputLength) {
          showErrorToast('Content is too long to be handled by TTS engine');
          return;
        }
        Speech.speak(getContentFromProgress(content, progress), {
          language: 'zh',
          voice: 'zh',
          onDone: () => {
            // Handle async operations in a non-blocking way
            getNext(current)
              .then((new_current) => {
                if (new_current) {
                  speak(new_current, 0);
                }
              })
              .catch((error) => {
                console.error('Error in onDone callback:', error);
              });
          },
        });
      }
    } catch (error) {
      console.error('Error in speak function:', error);
    }
  };

  const getNext = async (current) => {
    try {
      const data = await getItem(CONTENT_KEY);
      if (!data) return;
      const content = JSON.parse(data);
      const index = content.findIndex(
        (item) => item['name'] === current.toString().replace(CONTENT_KEY, '')
      );
      if (index === -1) return; // we don't find this item, how could this happen?!
      const prev = index === 0 ? undefined : content[index - 1]['name'];
      const next =
        index === content.length - 1 ? undefined : content[index + 1]['name'];

      if (next) return CONTENT_KEY + next;
      else return undefined;
    } catch (error) {
      console.error('Error in getNext function:', error);
      return undefined;
    }
  };

  console.log('TaskManager.defineTask called with:', { data, error });
  if (error) {
    console.error('Task Manager Error:', error);
    return;
  }
  if (!data) {
    console.log('No data provided, stopping speech');
    Speech.stop();
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
    await speak(data['current'], data['progress']);
  }
});
