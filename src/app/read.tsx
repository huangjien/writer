import React from 'react';
import { ScrollView, View } from 'react-native';
import { Swipeable, GestureDetector } from 'react-native-gesture-handler';
import { useSafeAreaInsets } from 'react-native-safe-area-context';

import { AnalysisModal } from '@/components/AnalysisModal';
import { PlayBar } from '@/components/PlayBar';
import { ContentArea } from '@/components/ContentArea';
import { useReadingPage } from './read/useReadingPage';

export default function Page() {
  const safeAreaTop = useSafeAreaInsets().top;

  // Use the consolidated reading page hook
  const {
    // State
    speechState,
    uiState,
    scrollViewRef,

    // Content
    content,
    analysis,
    preview,
    next,
    current,
    progress,
    fontSize,

    // Handlers
    navigationHandlers,
    speechHandlers,
    contentUtils,
    gestureHandlers,
    handleModalClose,
  } = useReadingPage();

  return (
    <>
      <ScrollView ref={scrollViewRef} className='mb-auto min-h-10 '>
        <Swipeable onSwipeableClose={gestureHandlers.handleSwipe}>
          {current && (
            <GestureDetector gesture={gestureHandlers.composed}>
              <View collapsable={false}>
                <ContentArea
                  current={current as string}
                  content={content}
                  fontSize={fontSize}
                  top={safeAreaTop}
                  currentParagraphIndex={speechState.currentSentenceIndex}
                  isReading={speechState.status === 'playing'}
                  scrollViewRef={scrollViewRef}
                />
              </View>
            </GestureDetector>
          )}
        </Swipeable>
        <AnalysisModal
          isVisible={uiState.modalVisible}
          analysis={analysis}
          fontSize={fontSize}
          onClose={handleModalClose}
        />
      </ScrollView>

      {uiState.showBar && (
        <PlayBar
          progress={progress}
          currentSentenceIndex={speechState.currentSentenceIndex}
          status={speechState.status}
          analysis={analysis}
          preview={preview}
          next={next}
          onProgressChange={speechHandlers.handleProgressChange}
          onShowAnalysis={navigationHandlers.showEval}
          onGoToPreview={navigationHandlers.toPreview}
          onGoToNext={navigationHandlers.toNext}
          onPlay={speechHandlers.handlePlay}
          onStop={speechHandlers.handleStop}
        />
      )}
    </>
  );
}
