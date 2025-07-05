import * as Speech from 'expo-speech';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { CONTENT_KEY, showErrorToast } from '@/components/global';

export interface SpeechOptions {
  language?: string;
  voice?: string;
  onDone?: () => void;
}

export class SpeechService {
  private static instance: SpeechService;

  public static getInstance(): SpeechService {
    if (!SpeechService.instance) {
      SpeechService.instance = new SpeechService();
    }
    return SpeechService.instance;
  }

  private async getItem(key: string): Promise<string | null> {
    try {
      return await AsyncStorage.getItem(key);
    } catch (error) {
      console.error('AsyncStorage getItem error:', error);
      return null;
    }
  }

  private async setItem(key: string, value: string): Promise<void> {
    try {
      await AsyncStorage.setItem(key, value);
    } catch (error) {
      console.error('AsyncStorage setItem error:', error);
    }
  }

  private getContentFromProgress(content: string, progress: number): string {
    if (!content) return '';
    const contentLength: number = Math.round(content.length * progress);
    return content.substring(contentLength);
  }

  public async getNext(current: string): Promise<string | undefined> {
    try {
      const data = await this.getItem(CONTENT_KEY);
      if (!data) return undefined;

      let content;
      try {
        content = JSON.parse(data);
      } catch (parseError) {
        console.error('Error in getNext function:', parseError);
        return undefined;
      }

      const index = content.findIndex(
        (item: any) =>
          item['name'] === current.toString().replace(CONTENT_KEY, '')
      );

      if (index === -1) return undefined;

      const next =
        index === content.length - 1 ? undefined : content[index + 1]['name'];
      return next ? CONTENT_KEY + next : undefined;
    } catch (error) {
      console.error('Error in getNext function:', error);
      return undefined;
    }
  }

  public async speak(
    current: string,
    progress: number,
    options: SpeechOptions = {}
  ): Promise<void> {
    try {
      const contentKey = current.toString().trim().startsWith(CONTENT_KEY)
        ? current.toString().trim()
        : CONTENT_KEY + current.toString().trim();

      const data = await this.getItem(contentKey);
      if (!data) {
        showErrorToast('No content for this chapter yet: ' + current + '!');
        return;
      }

      let parsedData;
      try {
        parsedData = JSON.parse(data);
      } catch (parseError) {
        console.error('Error parsing content data in speak:', parseError);
        showErrorToast('Error loading content for chapter: ' + current);
        return;
      }

      const content = parsedData['content'] || '';

      const speechOptions = {
        language: options.language || 'zh',
        voice: options.voice || 'zh',
        onDone:
          options.onDone ||
          (() => {
            this.getNext(current)
              .then((newCurrent) => {
                if (newCurrent) {
                  this.speak(newCurrent, 0, options);
                }
              })
              .catch((error) => {
                console.error('Error in onDone callback:', error);
              });
          }),
      };

      Speech.speak(
        this.getContentFromProgress(content, progress),
        speechOptions
      );
    } catch (error) {
      console.error('Error in speak function:', error);
    }
  }

  public stop(): void {
    Speech.stop();
  }

  public async isSpeaking(): Promise<boolean> {
    return await Speech.isSpeakingAsync();
  }

  public pause(): void {
    Speech.pause();
  }

  public resume(): void {
    Speech.resume();
  }
}

export const speechService = SpeechService.getInstance();
