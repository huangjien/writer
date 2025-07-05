import React from 'react';
import { View, Text, ScrollView } from 'react-native';
import { CONTENT_KEY } from '@/components/global';

interface ContentAreaProps {
  current: string | undefined;
  content: string;
  fontSize: number;
  top: number;
}

export function ContentArea({
  current,
  content,
  fontSize,
  top,
}: ContentAreaProps) {
  return (
    <View className='flex-1 py-4 md:py-8 lg:py-12 xl:py-16 px-4 md:px-6 bg-white dark:bg-black'>
      <View className='m-2 p-2 items-center gap-4 text-center'>
        <ScrollView>
          <Text
            className='text-black dark:text-white font-bold text-center justify-stretch text-pretty'
            style={{ fontSize: fontSize }}
          >
            {current &&
              current
                .toString()
                .replace('_', '  ')
                .replace(CONTENT_KEY, '')
                .replace('.md', '')}{' '}
            &nbsp;&nbsp;
            <Text className='text-xs leading-8 text-gray-500 dark:text-grey-300 '>
              {content.length}
            </Text>
          </Text>

          <Text
            className='text-black dark:text-white text-pretty'
            style={{ fontSize: fontSize }}
          >
            {content}
          </Text>
        </ScrollView>
      </View>
    </View>
  );
}
