import { Link } from 'expo-router';
import React, { useEffect } from 'react';
import { Alert, Pressable, Text, View } from 'react-native';
import { Feather } from '@expo/vector-icons';
import * as LocalAuthentication from 'expo-local-authentication';

export default function Page() {
  return (
    <View className='flex-1'>
      <View className='py-12 md:py-24 lg:py-32 xl:py-48'>
        <View className='px-4 md:px-6'>
          <View className='flex flex-col items-center gap-4 text-center'>
            <Text
              role='heading'
              className='text-2xl text-center native:text-5xl font-bold tracking-tighter sm:text-4xl md:text-5xl lg:text-6xl'
            >
              Welcome to Project writer
            </Text>
            <Text className='mx-auto max-w-[700px] text-lg text-center text-gray-500 md:text-xl dark:text-gray-400'>
              This project will allow you sync with a GitHub repository. Can you
              can call local TTS service to read content of files.
            </Text>
          </View>
        </View>
      </View>
    </View>
  );
}
