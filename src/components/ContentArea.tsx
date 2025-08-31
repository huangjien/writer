import * as React from 'react';
const { useRef, useEffect, forwardRef } = React;
import { View, Text, ScrollView } from 'react-native';
import { BlurView } from 'expo-blur';
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
      <View className='flex-1 bg-black'>
        <BlurView intensity={20} tint='dark' className='absolute inset-0 z-0' />
        <ScrollView
          ref={scrollViewRef}
          className='flex-grow relative z-10'
          showsVerticalScrollIndicator={false}
          contentContainerStyle={{
            paddingTop: top,
            paddingBottom: 100,
            paddingHorizontal: 16,
          }}
        >
          <View className='py-4 md:py-8 lg:py-12 xl:py-16 px-4 md:px-6'>
            <View className='m-2 p-2 items-start gap-4 text-left'>
              <BlurView
                intensity={40}
                tint='dark'
                className='rounded-2xl mb-8 overflow-hidden'
                style={{
                  backgroundColor: 'rgba(255, 255, 255, 0.1)',
                  borderWidth: 1,
                  borderColor: 'rgba(255, 255, 255, 0.2)',
                  shadowColor: '#000',
                  shadowOffset: { width: 0, height: 8 },
                  shadowOpacity: 0.3,
                  shadowRadius: 16,
                }}
              >
                <Text
                  className='text-white text-center py-6 px-4 font-bold'
                  style={{ fontSize: fontSize }}
                >
                  {current &&
                    current
                      .toString()
                      .replace('_', '  ')
                      .replace(CONTENT_KEY, '')
                      .replace('.md', '')}{' '}
                  &nbsp;&nbsp;
                  <Text className='text-xs leading-8 text-gray-300'>
                    {content.length}
                  </Text>
                </Text>
              </BlurView>

              {content
                .split(/\n\s*\n/)
                .filter((p) => p.trim().length > 0)
                .map((paragraph, index) => (
                  <BlurView
                    key={index}
                    intensity={30}
                    tint='dark'
                    className='rounded-xl mb-4 overflow-hidden'
                    style={{
                      backgroundColor:
                        isReading && index === currentParagraphIndex
                          ? 'rgba(59, 130, 246, 0.2)'
                          : 'rgba(255, 255, 255, 0.05)',
                      borderWidth: 1,
                      borderColor:
                        isReading && index === currentParagraphIndex
                          ? 'rgba(59, 130, 246, 0.3)'
                          : 'rgba(255, 255, 255, 0.1)',
                      shadowColor: '#000',
                      shadowOffset: { width: 0, height: 4 },
                      shadowOpacity: 0.2,
                      shadowRadius: 8,
                    }}
                  >
                    <View
                      ref={(ref) => {
                        paragraphRefs.current[index] = ref;
                      }}
                    >
                      <Text
                        className='text-white leading-relaxed p-4'
                        style={{
                          fontSize: fontSize,
                          lineHeight: fontSize * 1.6,
                          paddingLeft: 20,
                        }}
                      >
                        {paragraph.trim()}
                      </Text>
                    </View>
                  </BlurView>
                ))}
            </View>
          </View>
        </ScrollView>
      </View>
    );
  }
);
