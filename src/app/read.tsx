import { View, ScrollView } from 'react-native';
import { useRef, useState, useEffect } from 'react';
import { useNavigation } from '@react-navigation/native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import {
  Gesture,
  GestureDetector,
  Swipeable,
} from 'react-native-gesture-handler';
import {
  STATUS_PLAYING,
  STATUS_PAUSED,
  STATUS_STOPPED,
} from '@/components/global';
import { AnalysisModal } from '@/components/AnalysisModal';
import { PlayBar } from '@/components/PlayBar';
import { ContentArea } from '@/components/ContentArea';
import { useSpeech } from '@/hooks/useSpeech';
import { useReading } from '@/hooks/useReading';
import {
  navigateToChapter,
  handleProgressChange,
  handleContentChange,
  handleSpeechProgressUpdate,
} from '@/utils/readingUtils';

export default function Page() {
  // Navigation and safe area setup
  let navigation;
  try {
    navigation = useNavigation();
  } catch (error) {
    console.warn('Navigation context not available:', error);
    navigation = null;
  }
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

  const {
    status,
    progress: speechProgress,
    currentSentenceIndex,
    speak: speakHook,
    stop: stopHook,
    pause,
    resume,
  } = useSpeech();

  // Local state
  const [selectedLanguage, setSelectedLanguage] = useState('zh');
  const [voice, setVoice] = useState('zh');
  const [modalVisible, setModalVisible] = useState(false);
  const [showBar, setShowBar] = useState(true);
  const scrollViewRef = useRef(null);

  // Effects for handling content changes and playing time updates
  useEffect(() => {
    handleContentChange(status, content.length, () => {
      speak();
    });
  }, [content]);

  useEffect(() => {
    handleSpeechProgressUpdate(
      speechProgress,
      setProgress,
      content.length,
      status,
      () => navigateToChapter(next)
    );
  }, [speechProgress]);

  const getContentFromProgress = () => {
    const start = Math.round(content.length * progress);
    const end = Math.min(start + 64, content.length);
    return content.substring(start, end);
  };

  const speak = () => {
    if (status === STATUS_PAUSED) {
      resume();
      return;
    }

    const contentToSpeak = getContentFromProgress();
    speakHook(contentToSpeak, {
      language: selectedLanguage,
      onDone: () => {
        navigateToChapter(next);
      },
    });
  };

  const stop = () => {
    stopHook();
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
      if (navigation && navigation.setOptions) {
        navigation.setOptions({
          headerShown: !showBar,
        });
      }
      setShowBar(!showBar);
    })
    .runOnJS(true);

  const doubleTap = Gesture.Tap()
    .numberOfTaps(2)
    .onEnd(() => {
      if (status === STATUS_PAUSED) {
        resume();
      } else if (status === STATUS_STOPPED) {
        const contentToSpeak = getContentFromProgress();
        speakHook(contentToSpeak, {
          language: selectedLanguage,
          onDone: () => {
            toNext();
          },
        });
      } else if (status === STATUS_PLAYING) {
        stopHook();
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
              <ContentArea
                current={current as string}
                content={content}
                fontSize={fontSize}
                top={top}
              />
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
          speechProgress={speechProgress}
          currentSentenceIndex={currentSentenceIndex}
          status={status}
          analysis={analysis}
          preview={preview}
          next={next}
          onProgressChange={(value: number) =>
            handleProgressChange(value, setProgress, status, speak)
          }
          onShowAnalysis={showEval}
          onGoToPreview={toPreview}
          onGoToNext={toNext}
          onPlay={() => speak()}
          onStop={() => stop()}
        />
      )}
    </>
  );
}
