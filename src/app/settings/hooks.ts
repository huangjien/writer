import { useState } from 'react';
import { useAsyncStorage } from '@/hooks/useAsyncStorage';
import { useForm } from 'react-hook-form';
import { useIsFocused } from '@react-navigation/native';
import { UseSettingsFormReturn, SettingsFormData } from './types';

export const useSettingsForm = (): UseSettingsFormReturn => {
  const {
    control,
    handleSubmit,
    setValue,
    getValues,
    formState: { errors },
  } = useForm<SettingsFormData>({
    defaultValues: {
      githubRepo: '',
      githubToken: '',
      contentFolder: 'Content',
      analysisFolder: 'Analysis',
      fontSize: 16,
      backgroundImage: 'wood.jpg',
      progress: 0,
      current: '',
    },
  });

  const [selectedIndex, setSelectedIndex] = useState(0);
  const isFocused = useIsFocused();
  const [storage, operations, isLoading, hasChanged] = useAsyncStorage();
  const { setItem, getItem } = operations;

  return {
    control,
    handleSubmit,
    setValue,
    getValues,
    errors,
    selectedIndex,
    setSelectedIndex,
    isFocused,
    setItem,
    getItem,
  };
};
