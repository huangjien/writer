import { Text, View, TextInput, Button, Alert } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useEffect, useState } from 'react';
import { useForm, Controller } from 'react-hook-form';

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
        setValue("analysisFolder", parsedData.analysisFolder);
      }
    });
  });
  const onSubmit = (data: any) => saveToStorage(data);

  const saveToStorage = async (values: any) => {
    await AsyncStorage.setItem('@Settings', JSON.stringify(values));
  };

  return (
    <View>
      <Controller
        control={control}
        rules={{
          required: true,
        }}
        render={({ field: { onChange, onBlur, value } }) => (
          <TextInput
            className='m-2 p-2 border-spacing-1'
            key={'githubRepo'}
            placeholder='GitHub Repository URL'
            onBlur={onBlur}
            onChangeText={onChange}
            value={value}
          />
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
          <TextInput
            className='m-2 p-2 border-spacing-1'
            key={'githubToken'}
            placeholder='GitHub Token'
            onBlur={onBlur}
            onChangeText={onChange}
            value={value}
          />
        )}
        name='githubToken'
      />

      <Controller
        control={control}
        rules={{
          maxLength: 100,
        }}
        render={({ field: { onChange, onBlur, value } }) => (
          <TextInput
            className='m-2 p-2 border-spacing-1'
            key={'contentFolder'}
            placeholder='Content Folder'
            onBlur={onBlur}
            onChangeText={onChange}
            value={value}
          />
        )}
        name='contentFolder'
      />

      <Controller
        control={control}
        rules={{
          maxLength: 100,
        }}
        render={({ field: { onChange, onBlur, value } }) => (
          <TextInput
            className='m-2 p-2 border-spacing-1'
            key={'analysisFolder'}
            placeholder='Analysis Folder'
            onBlur={onBlur}
            onChangeText={onChange}
            value={value}
          />
        )}
        name='analysisFolder'
      />

      <Button title='Submit' onPress={handleSubmit(onSubmit)} />
    </View>
  );
}
