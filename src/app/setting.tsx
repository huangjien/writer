import React, { useEffect } from 'react';
import { ScrollView, View, Pressable, Text } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { useSettingsForm } from './settings/hooks';
import {
  loadSettingsData,
  getProgressPercentage,
  onSubmit,
} from './settings/utils';
import {
  GitHubRepoField,
  GitHubTokenField,
  ContentFolderField,
  AnalysisFolderField,
  FontSizeField,
  CurrentReadingField,
  ReadingProgressField,
} from './settings/components';

export default function Page() {
  const {
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
  } = useSettingsForm();

  useEffect(() => {
    loadSettingsData(getItem, setValue, setSelectedIndex);
  }, [isFocused]);

  return (
    <View style={{ paddingTop: 100 }} className='flex-1 bg-white dark:bg-black'>
      <View className='h-full items-stretch justify-stretch gap-2  px-8 md:px-4  bg-white dark:bg-black'>
        <ScrollView>
          <GitHubRepoField control={control} errors={errors} />
          <GitHubTokenField control={control} errors={errors} />
          <ContentFolderField control={control} errors={errors} />
          <AnalysisFolderField control={control} errors={errors} />
          <FontSizeField
            control={control}
            errors={errors}
            selectedIndex={selectedIndex}
            setSelectedIndex={setSelectedIndex}
            setValue={setValue}
          />
          <CurrentReadingField control={control} getValues={getValues} />
          <ReadingProgressField
            control={control}
            getProgressPercentage={() => getProgressPercentage(getValues)}
          />

          <View className='mt-8 bg-white dark:bg-black'>
            <Pressable
              className='flex h-12 items-center justify-center overflow-hidden '
              onPress={handleSubmit(onSubmit(setItem))}
            >
              <Feather name='save' size={24} color={'green'} />
            </Pressable>
          </View>
        </ScrollView>
      </View>
    </View>
  );
}
