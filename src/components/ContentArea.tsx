import * as React from 'react';
const { useRef, useEffect, forwardRef } = React;
import { View, Text, ScrollView } from 'react-native';
import { CONTENT_KEY } from '@/components/global';
import { useColorScheme } from 'nativewind';
import { GlassBackground, GlassCard } from './GlassComponents';

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
    const { colorScheme } = useColorScheme();
    const isDark = colorScheme === 'dark';

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
      <GlassBackground className='flex-1'>
        <View className='flex-1 py-4 md:py-8 lg:py-12 xl:py-16 px-4 md:px-6'>
          <GlassCard className='m-2 p-6 md:p-8 lg:p-10 items-start gap-4 text-left'>
            <Text
              className={`font-bold text-left justify-stretch text-pretty ${
                isDark ? 'text-slate-100' : 'text-slate-800'
              }`}
              style={[
                { fontSize: fontSize },
                {
                  textShadowColor: isDark
                    ? 'rgba(0, 0, 0, 0.3)'
                    : 'rgba(255, 255, 255, 0.8)',
                  textShadowOffset: { width: 0, height: 1 },
                  textShadowRadius: 2,
                },
              ]}
            >
              {current &&
                current
                  .toString()
                  .replace('_', '  ')
                  .replace(CONTENT_KEY, '')
                  .replace('.md', '')}{' '}
              &nbsp;&nbsp;
              <Text
                className={`text-xs leading-8 ${
                  isDark ? 'text-slate-400' : 'text-slate-500'
                }`}
              >
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
                    className={`text-pretty ${
                      isDark ? 'text-slate-100' : 'text-slate-800'
                    } ${
                      isReading && index === currentParagraphIndex
                        ? 'underline decoration-2 decoration-primary-500'
                        : ''
                    }`}
                    style={[
                      { fontSize: fontSize, marginBottom: 16 },
                      {
                        textShadowColor: isDark
                          ? 'rgba(0, 0, 0, 0.3)'
                          : 'rgba(255, 255, 255, 0.8)',
                        textShadowOffset: { width: 0, height: 1 },
                        textShadowRadius: 2,
                      },
                      isReading &&
                        index === currentParagraphIndex && {
                          backgroundColor: isDark
                            ? 'rgba(99, 102, 241, 0.1)'
                            : 'rgba(99, 102, 241, 0.05)',
                          borderRadius: 8,
                          paddingHorizontal: 8,
                          paddingVertical: 4,
                        },
                    ]}
                  >
                    {'    '}
                    {paragraph.trim()}
                  </Text>
                </View>
              ))}
          </GlassCard>
        </View>
      </GlassBackground>
    );
  }
);
