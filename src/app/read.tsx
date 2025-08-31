import { View, ScrollView } from 'react-native';
import { useRef, useState, useEffect, useCallback } from 'react';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import * as Speech from 'expo-speech';
import {
  Gesture,
  GestureDetector,
  Swipeable,
} from 'react-native-gesture-handler';
import { AnalysisModal } from '@/components/AnalysisModal';
import { PlayBar } from '@/components/PlayBar';
import { ContentArea } from '@/components/ContentArea';
import { useReading } from '@/hooks/useReading';
import {
  navigateToChapter,
  handleProgressChange,
  handleContentChange,
  handleSpeechProgressUpdate,
} from '@/utils/readingUtils';

export default function Page() {
  // Safe area setup
  let top = 0;
  try {
    const safeAreaInsets = useSafeAreaInsets();
    top = safeAreaInsets.top;
  } catch (error) {
    console.warn('SafeAreaProvider context not available:', error);
    top = 0;
  }

  // Custom hooks
  const {
    content,
    analysis,
    preview,
    next,
    current,
    progress,
    fontSize,
    setProgress,
  } = useReading();

  // Add logging We're using Speech.speak directly instead of useSpeech hook
  // to avoid interference with chunk-based reading

  // Local state
  const [selectedLanguage, setSelectedLanguage] = useState('zh');
  const [voice, setVoice] = useState('zh');
  const [modalVisible, setModalVisible] = useState(false);
  const [showBar, setShowBar] = useState(true);
  const [speechProgress, setSpeechProgress] = useState(0);
  const [currentSentenceIndex, setCurrentSentenceIndex] = useState(0);
  const [status, setStatus] = useState('stopped');
  const [shouldAutoPlay, setShouldAutoPlay] = useState(false);
  const scrollViewRef = useRef(null);
  const isSpeakingRef = useRef(false);

  // Effects for handling content changes and playing time updates
  useEffect(() => {
    // Auto-play when new content loads after chapter completion
    if (content && content.length > 0 && shouldAutoPlay) {
      setShouldAutoPlay(false); // Reset the flag
      // Reset progress to 0 for new chapter and start speaking
      setProgress(0);
      setSpeechProgress(0);
      setCurrentSentenceIndex(0);
      // Stop any existing speech first
      Speech.stop();
      isSpeakingRef.current = false;
      // Longer delay to ensure speak function is recreated with new content
      setTimeout(() => {
        speak(0); // Start from beginning with fresh content
      }, 300);
    }
  }, [content, shouldAutoPlay]);

  // Removed the speechProgress useEffect that was interfering with chunk-based progress updates
  // The speak() function now handles progress updates directly

  const getContentFromProgress = (currentProgress = progress) => {
    // Split content into paragraphs
    const paragraphs = content
      .split(/\n\s*\n/)
      .filter((p) => p.trim().length > 0);
    if (paragraphs.length === 0) return '';

    // Calculate which paragraph to start from based on progress
    // Use Math.round to avoid floating point precision issues
    const paragraphIndex = Math.min(
      Math.round(currentProgress * paragraphs.length),
      paragraphs.length - 1
    );

    // Return the current paragraph, or empty string if we've reached the end
    return paragraphIndex < paragraphs.length
      ? paragraphs[paragraphIndex].trim()
      : '';
  };

  const speak = useCallback(
    (currentProgress = progress) => {
      // Prevent multiple simultaneous speech calls
      if (isSpeakingRef.current) {
        return;
      }

      isSpeakingRef.current = true;
      setStatus('playing');
      const contentToSpeak = getContentFromProgress(currentProgress);

      // Update speech progress and paragraph index
      const paragraphs = content
        .split(/\n\s*\n/)
        .filter((p) => p.trim().length > 0);
      const currentParagraphIndex = Math.min(
        Math.round(currentProgress * paragraphs.length),
        paragraphs.length - 1
      );
      setSpeechProgress(currentProgress);
      setCurrentSentenceIndex(currentParagraphIndex); // Current paragraph index

      // Update the global progress to match what we're speaking
      setProgress(currentProgress);

      // Use Speech.speak directly instead of speakHook to avoid interference
      Speech.speak(contentToSpeak, {
        language: selectedLanguage,
        onDone: () => {
          // Calculate new progress after speaking this paragraph
          const paragraphs = content
            .split(/\n\s*\n/)
            .filter((p) => p.trim().length > 0);
          const currentParagraphIndex = Math.min(
            Math.round(currentProgress * paragraphs.length),
            paragraphs.length - 1
          );
          const newProgress = (currentParagraphIndex + 1) / paragraphs.length;

          // Reset speaking flag before continuing
          isSpeakingRef.current = false;

          if (newProgress >= 1) {
            // Finished the entire content, go to next chapter
            setSpeechProgress(1);
            setProgress(1);
            setStatus('stopped');
            setShouldAutoPlay(true); // Set flag for auto-play on next chapter
            navigateToChapter(next);
          } else {
            // Continue with next chunk
            setProgress(newProgress);
            // Use a shorter timeout and call speak directly with new progress
            setTimeout(() => {
              speak(newProgress);
            }, 50);
          }
        },
      });
    },
    [content, selectedLanguage, next, navigateToChapter, progress] // Include progress to ensure function updates
  );

  const stop = (source = 'unknown') => {
    isSpeakingRef.current = false;
    setStatus('stopped');
    Speech.stop();
  };

  const showEval = () => {
    setModalVisible(true);
  };

  const toPreview = () => {
    if (preview) {
      navigateToChapter(preview);
    }
  };

  const toNext = () => {
    if (next) {
      navigateToChapter(next);
    }
  };

  const longPress = Gesture.LongPress().onEnd(showEval).runOnJS(true);

  const oneTap = Gesture.Tap()
    .numberOfTaps(1)
    .onEnd(() => {
      setShowBar(!showBar);
    })
    .runOnJS(true);

  const doubleTap = Gesture.Tap()
    .numberOfTaps(2)
    .onEnd(() => {
      if (status === 'stopped') {
        speak();
      } else if (status === 'playing') {
        stop('doubleTap');
      }
    })
    .runOnJS(true);

  const composed = Gesture.Simultaneous(longPress, doubleTap, oneTap);

  return (
    <>
      <ScrollView ref={scrollViewRef} className='mb-auto min-h-10 '>
        <Swipeable
          onSwipeableClose={(direction) => {
            direction === 'left' ? toPreview() : toNext();
          }}
        >
          {current && (
            <GestureDetector gesture={composed}>
              <View collapsable={false}>
                <ContentArea
                  current={current as string}
                  content={content}
                  fontSize={fontSize}
                  top={top}
                  currentParagraphIndex={currentSentenceIndex}
                  isReading={status === 'playing'}
                  scrollViewRef={scrollViewRef}
                />
              </View>
            </GestureDetector>
          )}
        </Swipeable>
        <AnalysisModal
          isVisible={modalVisible}
          analysis={analysis}
          fontSize={fontSize}
          onClose={() => setModalVisible(false)}
        />
      </ScrollView>

      {showBar && (
        <PlayBar
          progress={progress}
          currentSentenceIndex={currentSentenceIndex}
          status={status}
          analysis={analysis}
          preview={preview}
          next={next}
          onProgressChange={(value: number) => {
            // Prevent accidental resets to 0 unless it's a genuine user action
            if (value === 0 && progress > 0.01) {
              return; // Ignore slider resets
            }

            // Only stop speech if user manually changes progress
            if (status === 'playing') {
              stop('manualProgressChange');
            }
            setProgress(value);
            if (status === 'playing') {
              speak(value);
            }
          }}
          onShowAnalysis={showEval}
          onGoToPreview={toPreview}
          onGoToNext={toNext}
          onPlay={() => speak()}
          onStop={() => stop('playBarStop')}
        />
      )}
    </>
  );
}
