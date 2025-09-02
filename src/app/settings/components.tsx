import React from 'react';
import { Text, TextInput } from 'react-native';
import { Controller } from 'react-hook-form';
import SegmentedControl from '@react-native-segmented-control/segmented-control';
import {
  FieldComponentProps,
  FontSizeFieldProps,
  CurrentReadingFieldProps,
  ReadingProgressFieldProps,
} from './types';

export const GitHubRepoField = ({ control, errors }: FieldComponentProps) => (
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

export const GitHubTokenField = ({ control, errors }: FieldComponentProps) => (
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

export const ContentFolderField = ({
  control,
  errors,
}: FieldComponentProps) => (
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

export const AnalysisFolderField = ({
  control,
  errors,
}: FieldComponentProps) => (
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

export const FontSizeField = ({
  control,
  selectedIndex,
  setSelectedIndex,
  setValue,
}: FontSizeFieldProps) => (
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

export const CurrentReadingField = ({
  control,
  getValues,
}: CurrentReadingFieldProps) => (
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

export const ReadingProgressField = ({
  control,
  getProgressPercentage,
}: ReadingProgressFieldProps) => (
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
