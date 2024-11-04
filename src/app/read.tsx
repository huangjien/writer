import {
  Text,
  View,
  Pressable,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import * as Speech from 'expo-speech';
import { Platform } from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { useEffect, useRef, useState } from 'react';
import { Feather } from '@expo/vector-icons';
import { router, useLocalSearchParams } from 'expo-router';
import {
  Gesture,
  GestureDetector,
  Swipeable,
} from 'react-native-gesture-handler';
import Modal from 'react-native-modal';
import Markdown from 'react-native-markdown-display';
import { activateKeepAwakeAsync, deactivateKeepAwake } from 'expo-keep-awake';
import {
  ANALYSIS_KEY,
  CONTENT_KEY,
  handleError,
  SETTINGS_KEY,
  showErrorToast,
  showInfoToast,
  sleep,
  STATUS_PAUSED,
  STATUS_PLAYING,
  STATUS_STOPPED,
} from '@/components/global';
import { useIsFocused, useNavigation } from '@react-navigation/native';
import Slider from '@react-native-community/slider';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useAsyncStorage } from '@/components/useAsyncStorage';

export default function Page() {
  const navigation = useNavigation();
  const { top } = useSafeAreaInsets();
  const [storage, { setItem, getItem }, isLoading, hasChanged] =
    useAsyncStorage();
  const [items, setItems] = useState([]);
  const [selectedLanguage, setSelectedLanguage] = useState('zh');
  const [voice, setVoice] = useState('zh');
  const [status, setStatus] = useState(STATUS_STOPPED); // it only has 3 statuses: stopped, playing, paused
  const [content, SetContent] = useState('Please select a file to read');
  const [analysis, setAnalysis] = useState('No analysis for this chapter yet');
  const [modalVisible, setModalVisible] = useState(false);
  const [preview, setPreview] = useState(undefined);
  const [next, setNext] = useState(undefined);
  const { post } = useLocalSearchParams();
  const [current, setCurrent] = useState(post);
  const [progress, setProgress] = useState(0);
  const [fontSize, setFontSize] = useState(16);
  const isFocused = useIsFocused();
  const [showBar, setShowBar] = useState(true);
  const [playingTime, setPlayingTime] = useState(0);
  const [intervalId, setIntervalId] = useState(null);
  const scrollViewRef = useRef(null);

  const enableKeepAwake = async () => {
    await activateKeepAwakeAsync();
  };

  // 1st time enter this page, get settings from local storage
  // if cannot get settings, then that's seariously problem, no need to proceed, we need to show error message
  useEffect(() => {
    getItem(SETTINGS_KEY)
      .then((res) => {
        return JSON.parse(res);
      })
      .then((data) => {
        if (!data) {
          // how could this happen!
          showErrorToast('No settings found, please set up settings first');
          console.error('No settings found, please set up settings first');
          return;
        }
        if (data) {
          if (!data.fontSize) {
            // default 16
            setFontSize(16);
          } else {
            setFontSize(data.fontSize);
          }
        }
      });
  }, [hasChanged]);

  useEffect(() => {
    if (status === STATUS_PLAYING) {
      const id = setInterval(() => {
        setPlayingTime((prevTime) => prevTime + 1);
      }, 1000);

      setIntervalId(id);
    } else {
      if (intervalId) {
        clearInterval(intervalId);
        setIntervalId(null);
      }
    }

    return () => {
      if (intervalId) {
        clearInterval(intervalId);
      }
    };
  }, [status]);

  useEffect(() => {
    setProgress(progress + 6.17 / content.length);
    if (progress > 1) {
      // we need to go to next chapter
      Speech.stop();
      setStatus(STATUS_PLAYING);
      toNext();
    }
    // if (isFocused){
    //   console.log('isFocused, it should scroll, x:' + Math.round(height * progress));
    //   scrollViewRef.current?.scrollTo({y: Math.round(100 * progress) + 128, x: 0, animated: true});
    // }
  }, [playingTime]);

  useEffect(() => {
    if (status === STATUS_PLAYING) {
      enableKeepAwake();
    } else {
      deactivateKeepAwake();
    }
  }, [status]);

  useEffect(() => {
    // This is used for switch to another chapter, if was reading before, then read new chapter
    if (status === STATUS_PLAYING && content.length > 64) {
      Speech.stop();
      sleep(2000).then(() => {
        speak();
      });
    }
  }, [content]);

  useEffect(() => {
    if (!post) {
      // get current post from local storage, we'd better also get progress, then can resume from last breaking point
      getItem(SETTINGS_KEY)
        .then((res) => {
          return JSON.parse(res);
        })
        .then((data) => {
          if (data) {
            if (data['current']) {
              // default 16
              setCurrent(data['current']);
              setProgress(data['progress'] ? data['progress'] : 0);
            } else {
              // if nothing exist, no post, no current, I don't know either.
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
      // console.log(post)
      setCurrent(post);
      setProgress(0);
      setPlayingTime(0);
      getItem(SETTINGS_KEY)
        .then((res) => {
          return JSON.parse(res);
        })
        .then((data) => {
          if (data) {
            data['current'] = post;
            data['progress'] = 0;
            setItem(SETTINGS_KEY, JSON.stringify(data));
          }
        });
    }
  }, [post]);

  useEffect(() => {
    if (current) {
      loadReadingByName();
    }
  }, [current, isFocused]);

  useEffect(() => {
    // save it to local storage
    getItem(SETTINGS_KEY)
      .then((res) => {
        return JSON.parse(res);
      })
      .then((data) => {
        if (data) {
          data['progress'] = progress;
          setItem(SETTINGS_KEY, JSON.stringify(data));
        }
      });
  }, [progress]);

  useEffect(() => {
    Speech.getAvailableVoicesAsync()
      .then((res) => {
        let count = 0;
        let arr = [];
        res.map((v) => {
          v['key'] = count.toString();
          count++;
          arr.push(v);
        });
        return arr;
      })
      .then((arr) => setItems(arr))
      .catch((err) => {
        handleError(err);
      });
  }, []);

  const speak = () => {
    if (content.length > Speech.maxSpeechInputLength) {
      setStatus(STATUS_STOPPED);
      showErrorToast('Content is too long to be handled by TTS engine');
      return;
    }
    if (status === STATUS_PAUSED) {
      setStatus(STATUS_PLAYING);
      Speech.resume();
    }
    if (status === STATUS_STOPPED || status === STATUS_PLAYING) {
      setStatus(STATUS_PLAYING);
      Speech.speak(getContentFromProgress(), {
        language: selectedLanguage,
        voice: voice,
        onDone: () => {
          toNext();
        },
      });
    }
  };

  const renderItemList = items.map((item) => (
    <Picker.Item key={item.key} label={item.identifier} value={item.language} />
  ));

  const handleSelected = (itemValue, itemPosition) => {
    setVoice(items[itemPosition].identifier);
    setSelectedLanguage(itemValue);
  };

  const showEval = () => {
    if (analysis) {
      setModalVisible(true);
    }
  };

  const toPreview = () => {
    if (preview) {
      router.push({
        pathname: '/read',
        params: { post: preview },
      });
    }
  };

  const toNext = () => {
    if (next) {
      router.push({
        pathname: '/read',
        params: { post: next },
      });
    }
  };

  const longPress = Gesture.LongPress().onEnd(showEval).runOnJS(true);

  const oneTap = Gesture.Tap()
    .numberOfTaps(1)
    .onEnd(() => {
      navigation.setOptions({
        headerShown: !showBar,
      });
      setShowBar(!showBar);
    })
    .runOnJS(true);

  const doubleTap = Gesture.Tap()
    .numberOfTaps(2)
    .onEnd(() => {
      if (status === STATUS_PAUSED) {
        setStatus(STATUS_PLAYING);
        Speech.resume();
      }
      if (status === STATUS_STOPPED) {
        setStatus(STATUS_PLAYING);
        Speech.speak(getContentFromProgress(), {
          language: selectedLanguage,
          voice: voice,
          onDone: () => {
            setStatus(STATUS_PLAYING);
            toNext();
          },
          // onBoundary: ({ charIndex, charLength }) => {
          //   console.log(charIndex, charLength);
          // },
        });
      }
      if (status === STATUS_PLAYING) {
        Speech.stop();
        setStatus(STATUS_STOPPED);
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
              {content_area()}
            </GestureDetector>
          )}
        </Swipeable>
        {analysis_modal()}
      </ScrollView>

      {showBar && <View className='  py-0 right-0 bottom-0'>{play_bar()}</View>}
    </>
  );

  function analysis_modal() {
    return (
      <Modal
        isVisible={modalVisible}
        animationIn={'slideInUp'}
        animationOut={'slideOutDown'}
        coverScreen={true}
        backdropOpacity={0.9}
        onBackdropPress={() => setModalVisible(false)}
        onSwipeComplete={() => setModalVisible(false)}
        swipeDirection={'right'}
      >
        <ScrollView className='flex-grow m-4 p-4 bg-opacity-10 py-4 md:py-8 lg:py-12 xl:py-16 px-4 md:px-6 text-white'>
          <TouchableOpacity>
            <Markdown style={{ body: { color: 'white', fontSize: fontSize } }}>
              {analysis ? analysis : 'No analysis for this chapter yet'}
            </Markdown>
            <Pressable
              className='bottom-4 gap-8 items-center justify-center '
              onPress={() => setModalVisible(false)}
            >
              <Feather name='check' size={24} color={'white'} />
            </Pressable>
          </TouchableOpacity>
        </ScrollView>
      </Modal>
    );
  }

  function loadReadingByName() {
    if (!current) return;
    getItem(current.toString().trim()).then((data) => {
      if (!data) {
        showErrorToast('No content for this chapter yet:' + current + '!');
        return;
      }
      // console.log(data);
      SetContent(JSON.parse(data)['content']);
    });

    // get analysis from local storage
    getItem(current.toString().replace(CONTENT_KEY, ANALYSIS_KEY)).then(
      (data) => {
        if (!data) {
          setAnalysis(undefined);
          return;
        }
        setAnalysis(JSON.parse(data)['content']);
      }
    );

    // get prev and next chapter name
    getItem(CONTENT_KEY).then((data) => {
      if (!data) return;
      const content = JSON.parse(data);
      const index = content.findIndex(
        (item) => item['name'] === current.toString().replace(CONTENT_KEY, '')
      );
      if (index === -1) return; // we don't find this item, how could this happen?!
      const prev = index === 0 ? undefined : content[index - 1]['name'];
      const next =
        index === content.length - 1 ? undefined : content[index + 1]['name'];

      if (prev) setPreview(CONTENT_KEY + prev);
      else setPreview(undefined);
      if (next) setNext(CONTENT_KEY + next);
      else setNext(undefined);
    });
  }

  function getContentFromProgress() {
    // get the content from the progress
    if (!content) return '';
    const content_length: number = Math.round(content.length * progress);
    return content.substring(content_length);
  }

  function onProgressChanged(e) {
    setProgress(e);
    if (status === STATUS_PLAYING) {
      Speech.stop();
      speak();
    }
  }

  function play_bar() {
    return (
      <View className='bg-white dark:bg-black text-black dark:text-white gap-4 '>
        <Slider
          className='w-full h-8 m-2 p-2'
          value={progress}
          onValueChange={(e) => onProgressChanged(e)}
          minimumValue={0}
          maximumValue={1}
          minimumTrackTintColor='grey'
          maximumTrackTintColor='green'
        />
        <Text className='text-black dark:text-white'>
          Playing Time: {formatTime(playingTime)} &nbsp;{' '}
          {(progress * 100).toFixed(2) + ' %'}
        </Text>
        {/* <View className='hidden lg:inline'>
          <Picker
            prompt='Language: '
            onValueChange={(itemValue, itemPosition) => {
              handleSelected(itemValue, itemPosition);
            }}
          >
            {renderItemList}
          </Picker>
        </View> */}

        {/* <Text className='text-black dark:text-white bg-white dark:bg-black block sm:hidden xs:hidden'>
          Max Read: {Speech.maxSpeechInputLength}
        </Text> */}
        <View className='inline-flex flex-row lg:gap-16 md:gap-4 justify-evenly'>
          <Pressable onPress={showEval}>
            <Feather size={24} name='cpu' color={analysis ? 'green' : 'grey'} />
          </Pressable>

          <Pressable onPress={toPreview}>
            <Feather
              size={24}
              name='chevrons-left'
              color={preview ? 'green' : 'grey'}
            />
          </Pressable>
          <Pressable onPress={toNext}>
            <Feather
              size={24}
              name='chevrons-right'
              color={next ? 'green' : 'grey'}
            />
          </Pressable>
          <Pressable
            disabled={status === STATUS_PLAYING}
            onPress={() => speak()}
          >
            <Feather
              className='text-black dark:text-white '
              size={24}
              name='play'
              color={status === STATUS_PLAYING ? 'grey' : 'green'}
            />
          </Pressable>

          <Pressable
            disabled={status === STATUS_STOPPED}
            onPress={() => {
              Speech.stop();
              setStatus(STATUS_STOPPED);
            }}
          >
            <Feather
              size={24}
              name='square'
              color={status === STATUS_STOPPED ? 'grey' : 'green'}
            />
          </Pressable>
        </View>
      </View>
    );
  }

  // Helper function to format time
  function formatTime(seconds) {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds < 10 ? '0' : ''}${remainingSeconds}`;
  }

  function content_area() {
    return (
      <View
        className='flex-1 py-4 md:py-8 lg:py-12 xl:py-16 px-4 md:px-6 bg-white  dark:bg-black'
        style={{ paddingTop: top }}
      >
        <View className='m-2 p-2 items-center gap-4 text-center'>
          <ScrollView>
            <Text
              className=' text-black  dark:text-white font-bold text-center justify-stretch text-pretty'
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

            <Text
              className='text-black dark:text-white text-pretty'
              style={{ fontSize: fontSize }}
            >
              {content}
            </Text>
          </ScrollView>
        </View>
      </View>
    );
  }
}
