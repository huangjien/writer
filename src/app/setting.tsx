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
    <View className='w-full m-2 p-2 md:w-1/2 px-3 mb-6 md:mb-0'>
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
              className='m-2 p-2 border-spacing-1'
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
              className='m-2 p-2 border-1 rounded-md'
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
              className='m-2 p-2 border-spacing-1'
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
              className='m-2 p-2 border-spacing-1'
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

      <View className='mt-8'>
        <Pressable
          className='flex h-12 items-center justify-center overflow-hidden rounded-md bg-gray-100 px-4 py-2 text-sm font-medium text-gray-50 web:shadow ios:shadow transition-colors hover:bg-gray-900/90 active:bg-gray-400/90 web:focus-visible:outline-none web:focus-visible:ring-1 focus-visible:ring-gray-950 disabled:pointer-events-none disabled:opacity-50 dark:bg-gray-50 dark:text-gray-900 dark:hover:bg-gray-50/90 dark:focus-visible:ring-gray-300'
          onPress={handleSubmit(onSubmit)}
        >
          <Feather name='save' size={24} />
        </Pressable>
      </View>
    </View>
  );
}
