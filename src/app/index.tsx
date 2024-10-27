import React from 'react';
import { Text, View } from 'react-native';

export default function Page() {
  return (
    <View className='flex-1 bg-white dark:bg-black'>
      <View className='py-12 md:py-24 lg:py-32 xl:py-48'>
        <View className='px-4 md:px-6'>
          <View className='flex flex-col items-center gap-4 text-center'>
            <Text
              role='heading'
              className='text-black dark:text-white text-2xl text-center native:text-5xl font-bold tracking-tighter sm:text-4xl md:text-5xl lg:text-6xl'
            >
              Writer
            </Text>
            <Text className='mx-auto max-w-[700px] text-xl text-center text-gray-500 md:text-xl dark:text-gray-400'>
              This app is a very personal helper for novel author. It will allow
              you sync with a GitHub repository, then you can use local TTS
              service to read content of files.
            </Text>
            <View className='mx-auto max-w-[700px] m-4 p-4 gap-4'>
              <Text className='mx-auto max-w-[700px] text-2xl text-center text-gray-700  dark:text-gray-200'>
                兼听则明
              </Text>
              <Text className='mx-auto max-w-[700px] text-2xl text-center text-gray-700  dark:text-gray-200'>
                Listening is the beginning of wisdom
              </Text>
              <Text className='mx-auto max-w-[700px] text-2xl text-center text-gray-700  dark:text-gray-200'>
                Διότι η σοφία αρχίζει από την περιέργεια
              </Text>
              <Text className='mx-auto max-w-[700px] text-2xl text-center text-gray-700  dark:text-gray-200'>
                Auditus est initium sapientiae
              </Text>
              <Text className='mx-auto max-w-[700px] text-2xl text-center text-gray-700  dark:text-gray-200'>
                Das Zuhören ist der Anfang der Weisheit
              </Text>
              <Text className='mx-auto max-w-[700px] text-2xl text-center text-gray-700  dark:text-gray-200'>
                Escuchar es el comienzo de la sabiduría
              </Text>
            </View>
          </View>
        </View>
      </View>
    </View>
  );
}
