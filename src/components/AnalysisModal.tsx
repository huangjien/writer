import React from 'react';
import { ScrollView, TouchableOpacity, Pressable, Text } from 'react-native';
import Modal from 'react-native-modal';
import Markdown from 'react-native-markdown-display';
import { Feather } from '@expo/vector-icons';

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
      backdropOpacity={0.9}
      onBackdropPress={onClose}
      onSwipeComplete={onClose}
      swipeDirection={'right'}
    >
      <ScrollView className='flex-grow m-4 p-4 bg-opacity-10 py-4 md:py-8 lg:py-12 xl:py-16 px-4 md:px-6 text-white'>
        <TouchableOpacity>
          <Markdown style={{ body: { color: 'white', fontSize: fontSize } }}>
            {analysis ? analysis : 'No analysis for this chapter yet'}
          </Markdown>
          <Pressable
            className='bottom-4 gap-8 items-center justify-center '
            onPress={onClose}
          >
            <Feather name='check' size={24} color={'white'} />
          </Pressable>
        </TouchableOpacity>
      </ScrollView>
    </Modal>
  );
}
