import * as TaskManager from 'expo-task-manager';
import * as Speech from 'expo-speech';
import { useState } from 'react';
import { useAsyncStorage } from '@/components/useAsyncStorage';
import { CONTENT_KEY, showErrorToast } from './global';

export const SPEECH_TASK = 'background-speech-task';

function getContentFromProgress(content, progress) {
  // get the content from the progress
  if (!content) return '';
  const content_length: number = Math.round(content.length * progress);
  return content.substring(content_length);
}

TaskManager.defineTask(SPEECH_TASK, ({ data, error }) => {
  const [current, setCurrent] = useState('');
  const [progress, setProgress] = useState(0.0);
  const [language, setLanguage] = useState('zh');
  const [voice, setVoice] = useState('zh');
  const [storage, { setItem, getItem }, isLoading, hasChanged] =
    useAsyncStorage();

  const speak = (current, progress) => {
    // speak current from progress, when finished, speak next
    getItem(current.toString().trim()).then((data) => {
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
          language: language,
          voice: voice,
          onDone: () => {
            const new_current = getNext(current);
            // set settings
            speak(current, 0);
          },
        });
      }
    });
  };

  const getNext = (current) => {
    return getItem(CONTENT_KEY).then((data) => {
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
    });
  };

  if (error) {
    console.error('Task Manager Error:', error);
  }
  if (!data) {
    Speech.stop();
  }
  if (data) {
    // if pass empty data, then stop
    // if pass chapter and percentage, then start from there
    // onDone, then calculate next chapter
    // keep updating the current chapter and percentage to @setting
    speak(data['current'], data['progress']);
  }
});
