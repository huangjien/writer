import React from 'react';
import {
  ScrollView,
  TouchableOpacity,
  Pressable,
  Text,
  View,
} from 'react-native';
import Modal from 'react-native-modal';
import Markdown from 'react-native-markdown-display';
import { Feather } from '@expo/vector-icons';
import { BlurView } from 'expo-blur';
import { CONSTANTS } from '@/constants/appConstants';

interface AnalysisModalProps {
  isVisible: boolean;
  analysis: string | undefined;
  fontSize: number;
  onClose: () => void;
}

export function AnalysisModal({
  isVisible,
  analysis,
  fontSize,
  onClose,
}: AnalysisModalProps) {
  return (
    <Modal
      isVisible={isVisible}
      animationIn={'zoomInUp'}
      animationOut={'zoomOutDown'}
      coverScreen={true}
      backdropOpacity={0.3}
      onBackdropPress={onClose}
      onSwipeComplete={onClose}
      swipeDirection={'right'}
    >
      <BlurView
        intensity={80}
        tint='dark'
        className='flex-1 m-4 rounded-3xl overflow-hidden'
        style={{
          backgroundColor: 'rgba(0, 0, 0, 0.4)',
          borderWidth: 1,
          borderColor: 'rgba(255, 255, 255, 0.2)',
          shadowColor: '#000',
          shadowOffset: { width: 0, height: 8 },
          shadowOpacity: 0.4,
          shadowRadius: 20,
        }}
      >
        <View className='flex-1 p-6'>
          <ScrollView
            className='flex-1'
            showsVerticalScrollIndicator={false}
            contentContainerStyle={{ paddingBottom: 80 }}
          >
            <Markdown
              style={{
                body: {
                  color: 'rgba(255, 255, 255, 0.95)',
                  fontSize: fontSize,
                  lineHeight: fontSize * 1.6,
                },
                heading1: {
                  color: 'rgba(255, 255, 255, 1)',
                  fontSize: fontSize * 1.5,
                  fontWeight: CONSTANTS.UI.FONT_WEIGHT.SEMI_BOLD,
                  marginBottom: 16,
                },
                heading2: {
                  color: 'rgba(255, 255, 255, 0.9)',
                  fontSize: fontSize * 1.3,
                  fontWeight: CONSTANTS.UI.FONT_WEIGHT.MEDIUM,
                  marginBottom: 12,
                },
                paragraph: {
                  color: 'rgba(255, 255, 255, 0.85)',
                  fontSize: fontSize,
                  lineHeight: fontSize * 1.6,
                  marginBottom: 12,
                },
              }}
            >
              {analysis ? analysis : 'No analysis for this chapter yet'}
            </Markdown>
          </ScrollView>

          <View className='absolute bottom-6 right-6'>
            <Pressable
              onPress={onClose}
              className='p-4 rounded-full'
              style={{
                backgroundColor: 'rgba(59, 130, 246, 0.3)',
                borderWidth: 1,
                borderColor: 'rgba(59, 130, 246, 0.5)',
                shadowColor: '#000',
                shadowOffset: { width: 0, height: 4 },
                shadowOpacity: 0.3,
                shadowRadius: 8,
              }}
            >
              <Feather name='check' size={24} color='rgba(59, 130, 246, 1)' />
            </Pressable>
          </View>
        </View>
      </BlurView>
    </Modal>
  );
}
