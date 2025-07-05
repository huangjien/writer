import { Text, View, TextInput, Pressable } from 'react-native';
import { useAsyncStorage } from '@/hooks/useAsyncStorage';
// Removed useSafeAreaInsets import due to navigation context issues
import React, { useEffect } from 'react';
import * as Speech from 'expo-speech';
import { useForm, Controller } from 'react-hook-form';
import { Feather } from '@expo/vector-icons';
import SegmentedControl from '@react-native-segmented-control/segmented-control';
import { ScrollView } from 'react-native-gesture-handler';
import { CONTENT_KEY, SETTINGS_KEY, showInfoToast } from '@/components/global';
import { useIsFocused } from '@react-navigation/native';

const useSettingsForm = () => {
  const [storage, { setItem, getItem }, isLoading, hasChanged] =
    useAsyncStorage();
  const [selectedIndex, setSelectedIndex] = React.useState(0);
  let isFocused = true;
  try {
    isFocused = useIsFocused();
  } catch (error) {
    console.warn('Navigation context not available for useIsFocused:', error);
    isFocused = true; // Default to true when navigation context is not available
  }

  const form = useForm({
    defaultValues: {
      githubRepo: '',
      githubToken: '',
      contentFolder: 'Content',
      analysisFolder: 'Analysis',
      fontSize: 16,
      backgroundImage: '',
      expiry: Date.now(),
      current: '',
      progress: 0,
    },
  });

  const {
    control,
    handleSubmit,
    setValue,
    getValues,
    formState: { errors },
  } = form;

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

const loadSettingsData = async (
  getItem: any,
  setValue: any,
  setSelectedIndex: any
) => {
  try {
    const data = await getItem(SETTINGS_KEY);
    if (!data) {
      // Set default values if no data exists
      setValue('contentFolder', 'Content');
      setValue('analysisFolder', 'Analysis');
      setValue('fontSize', 16);
      setValue('backgroundImage', 'wood.jpg');
      setValue('progress', 0);
      setSelectedIndex(0);
      return;
    }

    const res = JSON.parse(data);
    if (res) {
      setValue('githubRepo', res.githubRepo || '');
      setValue('githubToken', res.githubToken || '');
      setValue('contentFolder', res.contentFolder || 'Content');
      setValue('analysisFolder', res.analysisFolder || 'Analysis');
      setValue('backgroundImage', res.backgroundImage || 'wood.jpg');
      setValue('expiry', res.expiry || Date.now());
      setValue('current', res.current || '');
      setValue('progress', res.progress || 0);

      if (!res.fontSize) {
        setValue('fontSize', 16);
        setSelectedIndex(0);
      } else {
        setValue('fontSize', res.fontSize);
        setSelectedIndex(Math.max(0, Math.min(6, (res.fontSize - 16) / 2)));
      }
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

const saveToStorage = async (setItem: any, values: any) => {
  await setItem(SETTINGS_KEY, JSON.stringify(values));
};

const getProgressPercentage = (getValues: any) => {
  const progress = getValues('progress');
  return (progress * 100).toFixed(2).toString() + ' %';
};

const onSubmit = (setItem: any) => (data: any) => {
  saveToStorage(setItem, data);
  showInfoToast('Setting saved!');
};

const GitHubRepoField = ({ control, errors }: any) => (
  <Controller
    control={control}
    rules={{ required: true }}
    render={({ field: { onChange, onBlur, value } }) => (
      <>
        <Text className='mt-4 block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2'>
          GitHub Repository URL
        </Text>
        <TextInput
          className='border-spacing-1 text-black dark:text-white'
          key={'githubRepo'}
          placeholder='GitHub Repository URL'
          onBlur={onBlur}
          onChangeText={onChange}
          value={value}
        />
        <Text className='text-gray-600 text-xs italic'>
          Where to get the content
        </Text>
        {errors.githubRepo && <Text>This is required.</Text>}
      </>
    )}
    name='githubRepo'
  />
);

const GitHubTokenField = ({ control, errors }: any) => (
  <Controller
    control={control}
    rules={{ maxLength: 100 }}
    render={({ field: { onChange, onBlur, value } }) => (
      <>
        <Text className='mt-4 block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2'>
          GitHub Token
        </Text>
        <TextInput
          className='border-1 rounded-md text-black dark:text-white'
          secureTextEntry={true}
          key={'githubToken'}
          placeholder='GitHub Token'
          onBlur={onBlur}
          onChangeText={onChange}
          value={value}
        />
        <Text className='text-gray-600 text-xs italic'>
          GitHub Token to access the repository.
        </Text>
        {errors.githubToken && <Text>This is required.</Text>}
      </>
    )}
    name='githubToken'
  />
);

const ContentFolderField = ({ control, errors }: any) => (
  <Controller
    control={control}
    rules={{ maxLength: 100 }}
    render={({ field: { onChange, onBlur, value } }) => (
      <>
        <Text className='mt-4 block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2'>
          Content Folder
        </Text>
        <TextInput
          className='border-spacing-1 text-black dark:text-white'
          key={'contentFolder'}
          placeholder='Content Folder'
          onBlur={onBlur}
          onChangeText={onChange}
          value={value}
        />
        <Text className='text-gray-600 text-xs italic'>
          Novel Content stored here.
        </Text>
        {errors.contentFolder && <Text>This is required.</Text>}
      </>
    )}
    name='contentFolder'
  />
);

const AnalysisFolderField = ({ control, errors }: any) => (
  <Controller
    control={control}
    rules={{ maxLength: 100 }}
    render={({ field: { onChange, onBlur, value } }) => (
      <>
        <Text className='mt-4 block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2'>
          Analysis Folder
        </Text>
        <TextInput
          className='border-spacing-1 text-black dark:text-white'
          key={'analysisFolder'}
          placeholder='Analysis Folder'
          onBlur={onBlur}
          onChangeText={onChange}
          value={value}
          aria-label='Analysis Folder'
        />
        <Text className='text-gray-600 text-xs italic'>
          AI analysis results will be saved here.
        </Text>
        {errors.analysisFolder && <Text>This is required.</Text>}
      </>
    )}
    name='analysisFolder'
  />
);

const FontSizeField = ({
  control,
  selectedIndex,
  setSelectedIndex,
  setValue,
}: any) => (
  <Controller
    control={control}
    rules={{ maxLength: 100 }}
    render={({ field: { onChange, onBlur, value } }) => (
      <>
        <Text className='mt-4 block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2'>
          Font Size
        </Text>
        <SegmentedControl
          className='border-spacing-1 text-black dark:text-white'
          values={['16', '18', '20', '22', '24', '26', '28']}
          key={'fontSize'}
          selectedIndex={selectedIndex}
          onChange={(event) => {
            const index = event.nativeEvent.selectedSegmentIndex;
            setSelectedIndex(index);
            setValue('fontSize', 16 + index * 2);
          }}
        />
        <Text className='text-gray-600 text-xs italic'>
          Font size for reading, prefer between 16 to 28.
        </Text>
      </>
    )}
    name='fontSize'
  />
);

const CurrentReadingField = ({ control, getValues }: any) => (
  <Controller
    control={control}
    rules={{ maxLength: 100 }}
    render={({ field: { onChange, onBlur, value } }) => (
      <>
        <Text className='mt-4 block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2'>
          Current Reading
        </Text>
        <Text
          className='border-spacing-1 text-black dark:text-white'
          key={'current'}
          aria-label='Current Reading'
        >
          {getValues(['current']).toString()}
        </Text>
        <Text className='text-gray-600 text-xs italic'>
          Current Reading Chapter.
        </Text>
      </>
    )}
    name='current'
  />
);

const ReadingProgressField = ({ control, getProgressPercentage }: any) => (
  <Controller
    control={control}
    rules={{ maxLength: 100 }}
    render={({ field: { onChange, onBlur, value } }) => (
      <>
        <Text className='mt-4 block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2'>
          Current Reading Progress
        </Text>
        <Text
          className='border-spacing-1 text-black dark:text-white'
          key={'progress'}
          aria-label='Reading Progress'
        >
          {getProgressPercentage()}
        </Text>
        <Text className='text-gray-600 text-xs italic'>
          Current Reading Progress.
        </Text>
      </>
    )}
    name='progress'
  />
);

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
    <View
      style={{ paddingTop: 100 }}
      className='flex-1 bg-white dark: bg-black'
    >
      <View className='h-full items-stretch justify-stretch gap-2  px-8 md:px-4  bg-white dark:bg-black'>
        <ScrollView>
          <GitHubRepoField control={control} errors={errors} />
          <GitHubTokenField control={control} errors={errors} />
          <ContentFolderField control={control} errors={errors} />
          <AnalysisFolderField control={control} errors={errors} />
          <FontSizeField
            control={control}
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
