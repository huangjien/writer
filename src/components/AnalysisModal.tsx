import React from 'react';
import { View, Text, Modal, TouchableOpacity, ScrollView } from 'react-native';
import { useTheme } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useColorScheme } from 'nativewind';
import { GlassModal, GlassCard, GlassView } from './GlassComponents';

interface AnalysisModalProps {
  visible: boolean;
  onClose: () => void;
  analysis: {
    wordCount: number;
    readingTime: number;
    sentiment: string;
    keyTopics: string[];
  } | null;
}

export default function AnalysisModal({
  visible,
  onClose,
  analysis,
}: AnalysisModalProps) {
  const theme = useTheme();
  const insets = useSafeAreaInsets();
  const { colorScheme } = useColorScheme();
  const isDark = colorScheme === 'dark';

  if (!analysis) return null;

  return (
    <Modal
      visible={visible}
      transparent
      animationType='slide'
      onRequestClose={onClose}
    >
      <GlassModal
        className='flex-1 justify-end'
        style={{
          backgroundColor: isDark
            ? 'rgba(15, 23, 42, 0.8)'
            : 'rgba(248, 250, 252, 0.8)',
        }}
      >
        <GlassCard
          className='rounded-t-3xl px-6 py-8 max-h-[80%]'
          style={{
            paddingBottom: insets.bottom + 32,
            backgroundColor: isDark
              ? 'rgba(30, 41, 59, 0.95)'
              : 'rgba(248, 250, 252, 0.95)',
          }}
        >
          <View className='flex-row items-center justify-between mb-6'>
            <Text
              className={`text-2xl font-bold ${
                isDark ? 'text-slate-100' : 'text-slate-800'
              }`}
              style={{
                textShadowColor: isDark
                  ? 'rgba(0, 0, 0, 0.3)'
                  : 'rgba(255, 255, 255, 0.8)',
                textShadowOffset: { width: 0, height: 1 },
                textShadowRadius: 2,
              }}
            >
              Content Analysis
            </Text>
            <TouchableOpacity
              onPress={onClose}
              className={`p-3 rounded-full glass-effect ${
                isDark
                  ? 'bg-glass-lightDark border-glass-borderDark'
                  : 'bg-glass-light border-glass-border'
              }`}
              style={{
                shadowColor: isDark ? '#000000' : '#1f2687',
                shadowOffset: { width: 0, height: 4 },
                shadowOpacity: isDark ? 0.25 : 0.3,
                shadowRadius: 12,
                elevation: 4,
              }}
            >
              <Ionicons
                name='close'
                size={24}
                color={isDark ? '#f1f5f9' : '#334155'}
                style={{
                  textShadowColor: isDark
                    ? 'rgba(0, 0, 0, 0.3)'
                    : 'rgba(255, 255, 255, 0.8)',
                  textShadowOffset: { width: 0, height: 1 },
                  textShadowRadius: 2,
                }}
              />
            </TouchableOpacity>
          </View>

          <ScrollView showsVerticalScrollIndicator={false}>
            <View className='space-y-6'>
              <View
                className='p-6'
                style={{
                  backgroundColor: isDark
                    ? 'rgba(51, 65, 85, 0.8)'
                    : 'rgba(255, 255, 255, 0.8)',
                  borderRadius: 16,
                  borderWidth: 1,
                  borderColor: isDark
                    ? 'rgba(148, 163, 184, 0.2)'
                    : 'rgba(148, 163, 184, 0.3)',
                }}
              >
                <Text
                  className={`text-lg font-semibold mb-4 ${
                    isDark ? 'text-slate-100' : 'text-slate-800'
                  }`}
                  style={{
                    textShadowColor: isDark
                      ? 'rgba(0, 0, 0, 0.3)'
                      : 'rgba(255, 255, 255, 0.8)',
                    textShadowOffset: { width: 0, height: 1 },
                    textShadowRadius: 2,
                  }}
                >
                  Statistics
                </Text>
                <View className='flex-row justify-between items-center mb-3'>
                  <Text
                    className={`text-base ${
                      isDark ? 'text-slate-200' : 'text-slate-700'
                    }`}
                    style={{
                      textShadowColor: isDark
                        ? 'rgba(0, 0, 0, 0.2)'
                        : 'rgba(255, 255, 255, 0.6)',
                      textShadowOffset: { width: 0, height: 1 },
                      textShadowRadius: 1,
                    }}
                  >
                    Word Count
                  </Text>
                  <Text
                    className={`text-base font-medium ${
                      isDark ? 'text-indigo-300' : 'text-indigo-600'
                    }`}
                    style={{
                      textShadowColor: isDark
                        ? 'rgba(0, 0, 0, 0.3)'
                        : 'rgba(255, 255, 255, 0.8)',
                      textShadowOffset: { width: 0, height: 1 },
                      textShadowRadius: 2,
                    }}
                  >
                    {analysis.wordCount.toLocaleString()}
                  </Text>
                </View>
                <View className='flex-row justify-between items-center'>
                  <Text
                    className={`text-base ${
                      isDark ? 'text-slate-200' : 'text-slate-700'
                    }`}
                    style={{
                      textShadowColor: isDark
                        ? 'rgba(0, 0, 0, 0.2)'
                        : 'rgba(255, 255, 255, 0.6)',
                      textShadowOffset: { width: 0, height: 1 },
                      textShadowRadius: 1,
                    }}
                  >
                    Reading Time
                  </Text>
                  <Text
                    className={`text-base font-medium ${
                      isDark ? 'text-indigo-300' : 'text-indigo-600'
                    }`}
                    style={{
                      textShadowColor: isDark
                        ? 'rgba(0, 0, 0, 0.3)'
                        : 'rgba(255, 255, 255, 0.8)',
                      textShadowOffset: { width: 0, height: 1 },
                      textShadowRadius: 2,
                    }}
                  >
                    {analysis.readingTime} min
                  </Text>
                </View>
              </View>

              <View
                className='p-6'
                style={{
                  backgroundColor: isDark
                    ? 'rgba(51, 65, 85, 0.8)'
                    : 'rgba(255, 255, 255, 0.8)',
                  borderRadius: 16,
                  borderWidth: 1,
                  borderColor: isDark
                    ? 'rgba(148, 163, 184, 0.2)'
                    : 'rgba(148, 163, 184, 0.3)',
                }}
              >
                <Text
                  className={`text-lg font-semibold mb-3 ${
                    isDark ? 'text-slate-100' : 'text-slate-800'
                  }`}
                  style={{
                    textShadowColor: isDark
                      ? 'rgba(0, 0, 0, 0.3)'
                      : 'rgba(255, 255, 255, 0.8)',
                    textShadowOffset: { width: 0, height: 1 },
                    textShadowRadius: 2,
                  }}
                >
                  Sentiment
                </Text>
                <View
                  className='px-4 py-3'
                  style={{
                    backgroundColor: isDark
                      ? 'rgba(71, 85, 105, 0.6)'
                      : 'rgba(241, 245, 249, 0.8)',
                    borderRadius: 12,
                  }}
                >
                  <Text
                    className={`text-base capitalize font-medium ${
                      isDark ? 'text-slate-100' : 'text-slate-800'
                    }`}
                    style={{
                      textShadowColor: isDark
                        ? 'rgba(0, 0, 0, 0.3)'
                        : 'rgba(255, 255, 255, 0.8)',
                      textShadowOffset: { width: 0, height: 1 },
                      textShadowRadius: 2,
                    }}
                  >
                    {analysis.sentiment}
                  </Text>
                </View>
              </View>

              <View
                className='p-6'
                style={{
                  backgroundColor: isDark
                    ? 'rgba(51, 65, 85, 0.8)'
                    : 'rgba(255, 255, 255, 0.8)',
                  borderRadius: 16,
                  borderWidth: 1,
                  borderColor: isDark
                    ? 'rgba(148, 163, 184, 0.2)'
                    : 'rgba(148, 163, 184, 0.3)',
                }}
              >
                <Text
                  className={`text-lg font-semibold mb-4 ${
                    isDark ? 'text-slate-100' : 'text-slate-800'
                  }`}
                  style={{
                    textShadowColor: isDark
                      ? 'rgba(0, 0, 0, 0.3)'
                      : 'rgba(255, 255, 255, 0.8)',
                    textShadowOffset: { width: 0, height: 1 },
                    textShadowRadius: 2,
                  }}
                >
                  Key Topics
                </Text>
                <View className='flex-row flex-wrap gap-3'>
                  {analysis.keyTopics.map((topic, index) => (
                    <View
                      key={index}
                      className='px-4 py-2'
                      style={{
                        backgroundColor: isDark
                          ? 'rgba(99, 102, 241, 0.15)'
                          : 'rgba(99, 102, 241, 0.1)',
                        borderRadius: 12,
                      }}
                    >
                      <Text
                        className={`text-sm font-medium ${
                          isDark ? 'text-indigo-300' : 'text-indigo-600'
                        }`}
                        style={{
                          textShadowColor: isDark
                            ? 'rgba(0, 0, 0, 0.3)'
                            : 'rgba(255, 255, 255, 0.8)',
                          textShadowOffset: { width: 0, height: 1 },
                          textShadowRadius: 2,
                        }}
                      >
                        {topic}
                      </Text>
                    </View>
                  ))}
                </View>
              </View>
            </View>
          </ScrollView>
        </GlassCard>
      </GlassModal>
    </Modal>
  );
}
