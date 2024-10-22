import { Text, View, TextInput, Button, Alert, Pressable } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useEffect, useState } from 'react';
import { useForm, Controller } from 'react-hook-form';
import { Feather } from '@expo/vector-icons';

export default function Page() {
  const {
    control,
    handleSubmit,
    setValue,
    formState: { errors },
  } = useForm({
    defaultValues: {
      githubRepo: '',
      githubToken: '',
      contentFolder: 'Content',
      analysisFolder: 'Analysis',
    },
  });

  useEffect(() => {
    AsyncStorage.getItem('@Settings').then((data) => {
      if (data) {
        const parsedData = JSON.parse(data);
        setValue('githubRepo', parsedData.githubRepo);
        setValue('githubToken', parsedData.githubToken);
        setValue('contentFolder', parsedData.contentFolder);
        setValue('analysisFolder', parsedData.analysisFolder);
      }
    });
  });
  const onSubmit = (data: any) => saveToStorage(data);

  const saveToStorage = async (values: any) => {
    await AsyncStorage.setItem('@Settings', JSON.stringify(values));
  };

  return (
    <View className='flex-1 '>
      <View className='h-full items-stretch justify-stretch  px-8 md:px-4  bg-white dark:bg-black'>
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
                className='m-2 p-2 border-spacing-1 text-black dark:text-white'
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
                className='m-2 p-2 border-1 rounded-md text-black dark:text-white'
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
                className='m-2 p-2 border-spacing-1 text-black dark:text-white'
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
                className='m-2 p-2 border-spacing-1 text-black dark:text-white'
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

        <View className='mt-8 bg-white dark:bg-black'>
          <Pressable
            className='flex h-12 items-center justify-center overflow-hidden 
          text-black dark:text-white bg-white dark:bg-black'
            onPress={handleSubmit(onSubmit)}
          >
            <Feather name='save' size={24} color={'green'} />
          </Pressable>
        </View>
      </View>
    </View>
  );
}
