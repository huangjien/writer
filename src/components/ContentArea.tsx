import * as React from 'react';
const { useRef, useEffect, forwardRef } = React;
import { View, Text, ScrollView } from 'react-native';
import { CONTENT_KEY } from '@/components/global';

interface ContentAreaProps {
  current: string | undefined;
  content: string;
  fontSize: number;
  top: number;
  currentParagraphIndex?: number;
  isReading?: boolean;
  scrollViewRef?: React.RefObject<ScrollView>;
}

export const ContentArea = forwardRef<ScrollView, ContentAreaProps>(
  function ContentArea(
    {
      current,
      content,
      fontSize,
      top,
      currentParagraphIndex = -1,
      isReading = false,
      scrollViewRef,
    },
    ref
  ) {
    const paragraphRefs = useRef<(View | null)[]>([]);

    // Auto-scroll to current paragraph when reading
    useEffect(() => {
      if (isReading && currentParagraphIndex >= 0 && scrollViewRef?.current) {
        // Calculate approximate scroll position based on paragraph index
        // Account for title height (~60px) + padding + estimated paragraph height
        const titleHeight = 60;
        const paddingTop = 32; // py-4 md:py-8 etc.
        const estimatedParagraphHeight = 120; // Estimated height per paragraph
        const estimatedY =
          titleHeight +
          paddingTop +
          currentParagraphIndex * estimatedParagraphHeight;

        scrollViewRef.current.scrollTo({ y: estimatedY, animated: true });
      }
    }, [currentParagraphIndex, isReading, scrollViewRef]);

    return (
      <View className='flex-1 py-4 md:py-8 lg:py-12 xl:py-16 px-4 md:px-6 bg-white dark:bg-black'>
        <View className='m-2 p-2 items-start gap-4 text-left'>
          <Text
            className='text-black dark:text-white font-bold text-left justify-stretch text-pretty'
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

          {content
            .split(/\n\s*\n/)
            .filter((p) => p.trim().length > 0)
            .map((paragraph, index) => (
              <View
                key={index}
                ref={(ref) => {
                  paragraphRefs.current[index] = ref;
                }}
              >
                <Text
                  className={`text-black dark:text-white text-pretty ${
                    isReading && index === currentParagraphIndex
                      ? 'underline'
                      : ''
                  }`}
                  style={{ fontSize: fontSize, marginBottom: 16 }}
                >
                  {paragraph.trim()}
                </Text>
              </View>
            ))}
        </View>
      </View>
    );
  }
);
