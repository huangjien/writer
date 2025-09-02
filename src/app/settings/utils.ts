import { SETTINGS_KEY, showInfoToast } from '@/components/global';
import { SettingsFormData, SettingsUtilsParams } from './types';

export const loadSettingsData = async (
  getItem: (key: string) => Promise<string | null>,
  setValue: (name: string, value: any) => void,
  setSelectedIndex: (index: number) => void
) => {
  try {
    const settingsData = await getItem(SETTINGS_KEY);
    if (settingsData) {
      const settings = JSON.parse(settingsData);
      setValue('githubRepo', settings.githubRepo || '');
      setValue('githubToken', settings.githubToken || '');
      setValue('contentFolder', settings.contentFolder || 'Content');
      setValue('analysisFolder', settings.analysisFolder || 'Analysis');
      setValue('fontSize', settings.fontSize || 16);
      setValue('backgroundImage', settings.backgroundImage || 'wood.jpg');
      setValue('progress', settings.progress || 0);
      setValue('current', settings.current || '');

      // Set font size index based on fontSize value
      const fontSizeIndex = Math.max(0, (settings.fontSize - 16) / 2);
      setSelectedIndex(fontSizeIndex);
    }
  } catch (error) {
    console.error('Error loading settings data:', error);
    // Set default values on error
    setValue('contentFolder', 'Content');
    setValue('analysisFolder', 'Analysis');
    setValue('fontSize', 16);
    setValue('backgroundImage', 'wood.jpg');
    setValue('progress', 0);
    setSelectedIndex(0);
  }
};

export const saveToStorage = async (
  setItem: (key: string, value: string) => Promise<void>,
  values: SettingsFormData
) => {
  await setItem(SETTINGS_KEY, JSON.stringify(values));
};

export const getProgressPercentage = (
  getValues: (names?: string | string[]) => any
): string => {
  const progress = getValues('progress');
  return (progress * 100).toFixed(2).toString() + ' %';
};

export const onSubmit =
  (setItem: (key: string, value: string) => Promise<void>) =>
  (data: SettingsFormData) => {
    saveToStorage(setItem, data);
    showInfoToast('Setting saved!');
  };
