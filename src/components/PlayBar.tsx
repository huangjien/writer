import React from 'react';
import { View, Text, Pressable } from 'react-native';
import { Feather } from '@expo/vector-icons';
import Slider from '@react-native-community/slider';
// Removed STATUS imports - using string literals directly

interface PlayBarProps {
  progress: number;
  currentSentenceIndex: number;
  status: string;
  analysis: string | undefined;
  preview: string | undefined;
  next: string | undefined;
  onProgressChange: (value: number) => void;
  onShowAnalysis: () => void;
  onGoToPreview: () => void;
  onGoToNext: () => void;
  onPlay: () => void;
  onStop: () => void;
}

export function PlayBar({
  progress,
  currentSentenceIndex,
  status,
  analysis,
  preview,
  next,
  onProgressChange,
  onShowAnalysis,
  onGoToPreview,
  onGoToNext,
  onPlay,
  onStop,
}: PlayBarProps) {
  return (
    <View className='bg-white dark:bg-black text-black dark:text-white gap-4 '>
      <Slider
        className='w-full h-8 m-2 p-2'
        value={progress}
        onValueChange={onProgressChange}
        minimumValue={0}
        maximumValue={1}
        minimumTrackTintColor='grey'
        maximumTrackTintColor='green'
      />
      <Text className='text-black dark:text-white'>
        Paragraph: {currentSentenceIndex + 1} &nbsp; Reading:{' '}
        {(progress * 100).toFixed(2)}%
      </Text>

      <View className='inline-flex flex-row lg:gap-16 md:gap-4 justify-evenly'>
        <Pressable onPress={onShowAnalysis}>
          <Feather size={24} name='cpu' color={analysis ? 'green' : 'grey'} />
        </Pressable>

        <Pressable onPress={onGoToPreview}>
          <Feather
            size={24}
            name='chevrons-left'
            color={preview ? 'green' : 'grey'}
          />
        </Pressable>
        <Pressable onPress={onGoToNext}>
          <Feather
            size={24}
            name='chevrons-right'
            color={next ? 'green' : 'grey'}
          />
        </Pressable>
        <Pressable disabled={status === 'playing'} onPress={onPlay}>
          <Feather
            className='text-black dark:text-white '
            size={24}
            name='play'
            color={status === 'playing' ? 'grey' : 'green'}
          />
        </Pressable>

        <Pressable disabled={status === 'stopped'} onPress={onStop}>
          <Feather
            size={24}
            name='square'
            color={status === 'stopped' ? 'grey' : 'green'}
          />
        </Pressable>
      </View>
    </View>
  );
}
