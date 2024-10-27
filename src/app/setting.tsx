import { Text, View, TextInput, Pressable } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import React, { useEffect } from 'react';
import { useForm, Controller } from 'react-hook-form';
import { Feather } from '@expo/vector-icons';
import SegmentedControl from '@react-native-segmented-control/segmented-control';
import { ScrollView } from 'react-native-gesture-handler';
import Toast from 'react-native-root-toast';
import {
  CONTENT_KEY,
  getStoredSettings,
  SETTINGS_KEY,
  showErrorToast,
  showInfoToast,
} from '../components/global';
import { useIsFocused } from '@react-navigation/native';

export default function Page() {
  const {
    control,
    handleSubmit,
    setValue,
    getValues,
    formState: { errors },
  } = useForm({
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

  const [selectedIndex, setSelectedIndex] = React.useState(0);
  const isFocused = useIsFocused();

  useEffect(() => {
    getStoredSettings.then((res) => {
      if (res) {
        setValue('githubRepo', res.githubRepo);
        setValue('githubToken', res.githubToken);
        setValue('contentFolder', res.contentFolder);
        setValue('analysisFolder', res.analysisFolder);
        setValue('backgroundImage', res.backgroundImage);
        setValue('expiry', res.expiry);
        setValue('current', res.current);
        setValue('progress', res.progress ? res.progress : 0); // current chapter reading progress, if not exist, set to 0, means from beginning
        if (!res.fontSize) {
          setValue('fontSize', 16);
          setSelectedIndex(0);
        } else {
          setValue('fontSize', res.fontSize);
          setSelectedIndex((res.fontSize - 16) / 2);
        }
        if (!res.backgroundImage) setValue('backgroundImage', 'wood.jpg');
      }
    });
  }, [isFocused]);
  const onSubmit = (data: any) => {
    saveToStorage(data);
    showInfoToast('Setting saved!');
  };

  const saveToStorage = async (values: any) => {
    await AsyncStorage.setItem(SETTINGS_KEY, JSON.stringify(values));
  };

  return (
    <View className='flex-1 '>
      <View className='h-full items-stretch justify-stretch gap-2  px-8 md:px-4  bg-white dark:bg-black'>
        <ScrollView>
          <Controller
            control={control}
            rules={{
              required: true,
            }}
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
              </>
            )}
            name='githubRepo'
          />
          {errors.githubRepo && <Text>This is required.</Text>}

          <Controller
            control={control}
            rules={{
              maxLength: 100,
            }}
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
              </>
            )}
            name='githubToken'
          />
          {errors.githubToken && <Text>This is required.</Text>}

          <Controller
            control={control}
            rules={{
              maxLength: 100,
            }}
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
              </>
            )}
            name='contentFolder'
          />

          {errors.contentFolder && <Text>This is required.</Text>}

          <Controller
            control={control}
            rules={{
              maxLength: 100,
            }}
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
              </>
            )}
            name='analysisFolder'
          />

          {errors.analysisFolder && <Text>This is required.</Text>}

          <Controller
            control={control}
            rules={{
              maxLength: 100,
            }}
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

          <Controller
            control={control}
            rules={{
              maxLength: 100,
            }}
            render={({ field: { onChange, onBlur, value } }) => (
              <>
                <Text className='mt-4 block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2'>
                  Current Reading
                </Text>
                <Text
                  className='border-spacing-1 text-black dark:text-white'
                  key={'current'}
                  aria-label='Analysis Folder'
                >
                  {getValues(['current']).toString().replace(CONTENT_KEY, '')}
                </Text>
                <Text className='text-gray-600 text-xs italic'>
                  Current Reading Chapter.
                </Text>
              </>
            )}
            name='current'
          />

          <Controller
            control={control}
            rules={{
              maxLength: 100,
            }}
            render={({ field: { onChange, onBlur, value } }) => (
              <>
                <Text className='mt-4 block uppercase tracking-wide text-gray-700 text-xs font-bold mb-2'>
                  Current Reading Progress
                </Text>
                <Text
                  className='border-spacing-1 text-black dark:text-white'
                  key={'progress'}
                  aria-label='Analysis Folder'
                >
                  {getValues(['progress'])}
                </Text>
                <Text className='text-gray-600 text-xs italic'>
                  Current Reading Progress.
                </Text>
              </>
            )}
            name='progress'
          />

          <View className='mt-8 bg-white dark:bg-black'>
            <Pressable
              className='flex h-12 items-center justify-center overflow-hidden '
              onPress={handleSubmit(onSubmit)}
            >
              <Feather name='save' size={24} color={'green'} />
            </Pressable>
          </View>
        </ScrollView>
      </View>
    </View>
  );
}
