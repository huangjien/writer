import React from 'react';
import { View, Text, Pressable } from 'react-native';
import { Feather } from '@expo/vector-icons';
import Slider from '@react-native-community/slider';
import { BlurView } from 'expo-blur';
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
    <BlurView
      intensity={60}
      tint='dark'
      className='rounded-t-3xl overflow-hidden'
      style={{
        backgroundColor: 'rgba(0, 0, 0, 0.3)',
        borderTopWidth: 1,
        borderLeftWidth: 1,
        borderRightWidth: 1,
        borderColor: 'rgba(255, 255, 255, 0.2)',
        shadowColor: '#000',
        shadowOffset: { width: 0, height: -4 },
        shadowOpacity: 0.3,
        shadowRadius: 12,
      }}
    >
      <View className='p-4 gap-4'>
        <Slider
          className='w-full h-8'
          value={progress}
          onValueChange={onProgressChange}
          minimumValue={0}
          maximumValue={1}
          minimumTrackTintColor='rgba(59, 130, 246, 0.8)'
          maximumTrackTintColor='rgba(255, 255, 255, 0.3)'
          thumbTintColor='rgba(59, 130, 246, 1)'
        />
        <Text className='text-white text-center font-medium'>
          Paragraph: {currentSentenceIndex + 1} &nbsp; Reading:{' '}
          {(progress * 100).toFixed(2)}%
        </Text>

        <View className='flex-row justify-evenly items-center'>
          <Pressable
            onPress={onShowAnalysis}
            className='p-3 rounded-full'
            style={{
              backgroundColor: 'rgba(255, 255, 255, 0.1)',
              borderWidth: 1,
              borderColor: 'rgba(255, 255, 255, 0.2)',
            }}
          >
            <Feather
              size={24}
              name='cpu'
              color={
                analysis ? 'rgba(34, 197, 94, 1)' : 'rgba(156, 163, 175, 1)'
              }
            />
          </Pressable>

          <Pressable
            onPress={onGoToPreview}
            className='p-3 rounded-full'
            style={{
              backgroundColor: 'rgba(255, 255, 255, 0.1)',
              borderWidth: 1,
              borderColor: 'rgba(255, 255, 255, 0.2)',
            }}
          >
            <Feather
              size={24}
              name='chevrons-left'
              color={
                preview ? 'rgba(34, 197, 94, 1)' : 'rgba(156, 163, 175, 1)'
              }
            />
          </Pressable>

          <Pressable
            onPress={onGoToNext}
            className='p-3 rounded-full'
            style={{
              backgroundColor: 'rgba(255, 255, 255, 0.1)',
              borderWidth: 1,
              borderColor: 'rgba(255, 255, 255, 0.2)',
            }}
          >
            <Feather
              size={24}
              name='chevrons-right'
              color={next ? 'rgba(34, 197, 94, 1)' : 'rgba(156, 163, 175, 1)'}
            />
          </Pressable>

          <Pressable
            disabled={status === 'playing'}
            onPress={onPlay}
            className='p-3 rounded-full'
            style={{
              backgroundColor:
                status === 'playing'
                  ? 'rgba(59, 130, 246, 0.3)'
                  : 'rgba(34, 197, 94, 0.2)',
              borderWidth: 1,
              borderColor:
                status === 'playing'
                  ? 'rgba(59, 130, 246, 0.5)'
                  : 'rgba(34, 197, 94, 0.4)',
            }}
          >
            <Feather
              size={24}
              name='play'
              color={
                status === 'playing'
                  ? 'rgba(156, 163, 175, 1)'
                  : 'rgba(34, 197, 94, 1)'
              }
            />
          </Pressable>

          <Pressable
            disabled={status === 'stopped'}
            onPress={onStop}
            className='p-3 rounded-full'
            style={{
              backgroundColor:
                status === 'stopped'
                  ? 'rgba(156, 163, 175, 0.2)'
                  : 'rgba(239, 68, 68, 0.2)',
              borderWidth: 1,
              borderColor:
                status === 'stopped'
                  ? 'rgba(156, 163, 175, 0.3)'
                  : 'rgba(239, 68, 68, 0.4)',
            }}
          >
            <Feather
              size={24}
              name='square'
              color={
                status === 'stopped'
                  ? 'rgba(156, 163, 175, 1)'
                  : 'rgba(239, 68, 68, 1)'
              }
            />
          </Pressable>
        </View>
      </View>
    </BlurView>
  );
}
