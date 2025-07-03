import { useState, useEffect } from 'react';
import { useLocalSearchParams } from 'expo-router';
import { useIsFocused } from '@react-navigation/native';
import { useAsyncStorage } from '@/hooks/useAsyncStorage';
import {
  ANALYSIS_KEY,
  CONTENT_KEY,
  SETTINGS_KEY,
  showErrorToast,
  showInfoToast,
} from '@/components/global';

export function useReading() {
  const [storage, { setItem, getItem }, isLoading, hasChanged] =
    useAsyncStorage();
  const [content, setContent] = useState('Please select a file to read');
  const [analysis, setAnalysis] = useState('No analysis for this chapter yet');
  const [preview, setPreview] = useState<string | undefined>(undefined);
  const [next, setNext] = useState<string | undefined>(undefined);
  const { post } = useLocalSearchParams();
  const [current, setCurrent] = useState(post);
  const [progress, setProgress] = useState(0);
  const [isInitialLoad, setIsInitialLoad] = useState(true);
  const [fontSize, setFontSize] = useState(16);
  const isFocused = useIsFocused();

  // Load settings on mount and when hasChanged
  useEffect(() => {
    getItem(SETTINGS_KEY)
      .then((res) => {
        return JSON.parse(res);
      })
      .then((data) => {
        if (!data) {
          showErrorToast('No settings found, please set up settings first');
          console.error('No settings found, please set up settings first');
          return;
        }
        if (data) {
          if (!data.fontSize) {
            setFontSize(16);
          } else {
            setFontSize(data.fontSize);
          }
        }
      });
  }, [hasChanged]);

  // Handle post parameter changes
  useEffect(() => {
    if (!post) {
      // Get current post from local storage
      getItem(SETTINGS_KEY)
        .then((res) => {
          return JSON.parse(res);
        })
        .then((data) => {
          if (data) {
            if (data['current']) {
              setCurrent(data['current']);
              const progressToLoad = data['progress'] ? data['progress'] : 0;
              setProgress(progressToLoad);
              setIsInitialLoad(false);
            } else {
              showInfoToast(
                'No current chapter, please select a chapter to read'
              );
              console.error(
                'No current chapter, please select a chapter to read'
              );
            }
          }
        });
    }
    if (post) {
      setCurrent(post);
      getItem(SETTINGS_KEY)
        .then((res) => {
          return JSON.parse(res);
        })
        .then((data) => {
          if (data) {
            // Check if this is the same chapter as the last one
            const isContinuingFromLastChapter = data['current'] === post;

            if (isContinuingFromLastChapter) {
              // Continue reading from saved progress
              const progressToLoad = data['progress'] ? data['progress'] : 0;
              setProgress(progressToLoad);
              setIsInitialLoad(false);
            } else {
              // New chapter, start from beginning
              setProgress(0);
              setIsInitialLoad(false);
              data['progress'] = 0;
            }

            data['current'] = post;
            setItem(SETTINGS_KEY, JSON.stringify(data));
          }
        });
    }
  }, [post]);

  // Load reading content when current changes
  useEffect(() => {
    if (current) {
      loadReadingByName();
    }
  }, [current, isFocused]);

  // Save progress to local storage
  useEffect(() => {
    if (isInitialLoad) {
      return;
    }

    getItem(SETTINGS_KEY)
      .then((res) => {
        return JSON.parse(res);
      })
      .then((data) => {
        if (data) {
          data['progress'] = progress;
          return setItem(SETTINGS_KEY, JSON.stringify(data));
        }
      })
      .catch((error) => {
        console.error('useReading: Error saving progress:', error);
      });
  }, [progress, isInitialLoad]);

  const loadReadingByName = () => {
    if (!current) return;

    // Load content
    getItem(current.toString().trim()).then((data) => {
      if (!data) {
        showErrorToast('No content for this chapter yet:' + current + '!');
        return;
      }
      setContent(JSON.parse(data)['content']);
    });

    // Load analysis
    getItem(current.toString().replace(CONTENT_KEY, ANALYSIS_KEY)).then(
      (data) => {
        if (!data) {
          setAnalysis(undefined);
          return;
        }
        setAnalysis(JSON.parse(data)['content']);
      }
    );

    // Load prev and next chapter names
    getItem(CONTENT_KEY).then((data) => {
      if (!data) return;
      const content = JSON.parse(data);
      const index = content.findIndex(
        (item) => item['name'] === current.toString().replace(CONTENT_KEY, '')
      );
      if (index === -1) return;
      const prev = index === 0 ? undefined : content[index - 1]['name'];
      const next =
        index === content.length - 1 ? undefined : content[index + 1]['name'];

      if (prev) setPreview(CONTENT_KEY + prev);
      else setPreview(undefined);
      if (next) setNext(CONTENT_KEY + next);
      else setNext(undefined);
    });
  };

  const getContentFromProgress = () => {
    if (!content) return '';
    const content_length: number = Math.round(content.length * progress);
    return content.substring(content_length);
  };

  return {
    content,
    analysis,
    preview,
    next,
    current,
    progress,
    fontSize,
    setProgress,
    getContentFromProgress,
    loadReadingByName,
  };
}
