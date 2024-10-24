import { Text, View, Pressable, ScrollView } from 'react-native';
import * as Speech from 'expo-speech';
import { Platform } from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { useEffect, useState } from 'react';
import { Feather } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { router, useLocalSearchParams } from 'expo-router';
import {
  Gesture,
  GestureDetector,
  Swipeable,
} from 'react-native-gesture-handler';
import AsyncStorage from '@react-native-async-storage/async-storage';
import Modal from 'react-native-modal';
import Markdown from 'react-native-markdown-display';
import { activateKeepAwakeAsync, deactivateKeepAwake } from 'expo-keep-awake';
import Toast from 'react-native-root-toast';

export default function Page() {
  useSafeAreaInsets();
  const [items, setItems] = useState([]);
  const [selectedLanguage, setSelectedLanguage] = useState('zh');
  const [voice, setVoice] = useState('zh');
  const [status, setStatus] = useState('stopped'); // it only has 3 statuses: stopped, playing, paused
  const [content, SetContent] = useState('Please select a file to read');
  const [analysis, setAnalysis] = useState('No analysis for this chapter yet');
  const [modalVisible, setModalVisible] = useState(false);
  const [preview, setPreview] = useState(undefined);
  const [next, setNext] = useState(undefined);
  const { post } = useLocalSearchParams();
  const [fontSize, setFontSize] = useState(16);

  // const pinchGesture = Gesture.Pinch()
  //   .onUpdate((e) => {
  //     if (e.scale > 1) {
  //       setFontSize(fontSize + 2);
  //       console.log(fontSize);
  //     }
  //     if (e.scale < 1) {
  //       setFontSize(fontSize - 2);
  //       console.log(fontSize);
  //     }

  //   })
  //   .onEnd(() => {
  //     console.log(fontSize);
  //   }).runOnJS(true);

  const enableKeepAwake = async () => {
    await activateKeepAwakeAsync();
  };

  useEffect(() => {
    AsyncStorage.getItem('@Settings').then((data) => {
      if (data) {
        const parsedData = JSON.parse(data);

        if (!parsedData.fontSize) {
          setFontSize(16);
        } else {
          setFontSize(parsedData.fontSize);
        }
      }
    });
  }, [post]);

  useEffect(() => {
    if (status === 'playing') {
      enableKeepAwake();
    } else {
      deactivateKeepAwake();
    }
  }, [status]);

  useEffect(() => {
    // This is used for switch to another chapter, if was reading before, then read new chapter
    if (status === 'playing' && content.length > 64) {
      Speech.stop();
      speak(true);
    }
  }, [content]);

  useEffect(() => {
    if (post) {
      AsyncStorage.getItem(post.toString()).then((data) => {
        if (!data) {
          SetContent(undefined);
          return;
        }
        SetContent(JSON.parse(data)['content']);
      });
      AsyncStorage.getItem(
        post.toString().replace('@Content:', '@Analysis:')
      ).then((data) => {
        if (!data) {
          setAnalysis(undefined);
          return;
        }
        setAnalysis(JSON.parse(data)['content']);
      });

      AsyncStorage.getItem('@Content:').then((data) => {
        if (!data) return;
        const content = JSON.parse(data);
        const index = content.findIndex(
          (item) => item['name'] === post.toString().replace('@Content:', '')
        );
        if (index === -1) return; // we don't find this item, how could this happen?!
        const prev = index === 0 ? undefined : content[index - 1]['name'];
        const next =
          index === content.length - 1 ? undefined : content[index + 1]['name'];

        if (prev) setPreview('@Content:' + prev);
        else setPreview(undefined);
        if (next) setNext('@Content:' + next);
        else setNext(undefined);
      });
    }
  }, [post]);

  const speak = (force: boolean = false) => {
    if (content.length > Speech.maxSpeechInputLength) {
      alert('Content is too long to handle by TTS engine');
      return;
    }
    if (status === 'paused') {
      setStatus('playing');
      Speech.resume();
    }
    if (status === 'stopped' || force === true) {
      setStatus('playing');
      Speech.speak(content, {
        language: selectedLanguage,
        voice: voice,
        onDone: () => {
          toNext();
        },
      });
    }
  };
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
        Toast.show(
          'network issue or folder not exist in the github \n' + err.message,
          {
            position: Toast.positions.CENTER,
            shadow: true,
            animation: true,
            hideOnPress: true,
            delay: 100,
            duration: Toast.durations.LONG,
          }
        );
        console.error(err.status, err.message);
      });
  }, []);

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

  const doubleTap = Gesture.Tap()
    .numberOfTaps(2)
    .onEnd(() => {
      if (status === 'paused') {
        setStatus('playing');
        Speech.resume();
      }
      if (status === 'stopped') {
        setStatus('playing');
        Speech.speak(content, {
          language: selectedLanguage,
          voice: voice,
          onDone: () => {
            toNext();
          },
        });
      }
      if (status === 'playing') {
        if (Platform.OS === 'android') {
          Speech.stop();
          setStatus('stopped');
        } else {
          Speech.pause();
          setStatus('paused');
        }
      }
    })
    .runOnJS(true);

  const composed = Gesture.Simultaneous(longPress, doubleTap);

  return (
    <>
      <ScrollView className='mb-auto min-h-10 '>
        <Swipeable
          onSwipeableClose={(direction) => {
            direction === 'left' ? toPreview() : toNext();
          }}
        >
          {post && (
            <GestureDetector gesture={composed}>
              {content_area()}
            </GestureDetector>
          )}
        </Swipeable>
        <Modal
          isVisible={modalVisible}
          backdropOpacity={0.9}
          onBackdropPress={() => setModalVisible(false)}
          onSwipeComplete={() => setModalVisible(false)}
          swipeDirection={'right'}
        >
          <ScrollView className='flex-grow m-4 p-4 bg-opacity-10 py-4 md:py-8 lg:py-12 xl:py-16 px-4 md:px-6 text-white'>
            <Markdown style={{ body: { color: 'white', fontSize: fontSize } }}>
              {analysis ? analysis : 'No analysis for this chapter yet'}
            </Markdown>
            <Pressable
              className='bottom-4 gap-8 items-center justify-center '
              onPress={() => setModalVisible(false)}
            >
              <Feather name='check' size={24} color={'white'} />
            </Pressable>
          </ScrollView>
        </Modal>
      </ScrollView>

      <View className='  py-0 right-0 bottom-0'>{play_bar()}</View>
    </>
  );

  function play_bar() {
    return (
      <View className='bg-white dark:bg-black text-black dark:text-white  inline-flex flex-row lg:gap-16 md:gap-4 justify-evenly '>
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
        <Pressable disabled={status === 'playing'} onPress={() => speak()}>
          <Feather
            className='text-black dark:text-white '
            size={24}
            name='play'
            color={status === 'playing' ? 'grey' : 'green'}
          />
        </Pressable>

        {/* <Button title='Play' onPress={speak} /> */}
        {Platform.OS !== 'android' && (
          <>
            <Pressable
              disabled={status !== 'playing'}
              onPress={() => {
                Speech.pause();
                setStatus('paused');
              }}
            >
              <Feather
                size={24}
                name='pause'
                color={status !== 'playing' ? 'grey' : 'green'}
              />
            </Pressable>
          </>
        )}
        <Pressable
          disabled={status === 'stopped'}
          onPress={() => {
            Speech.stop();
            setStatus('stopped');
          }}
        >
          <Feather
            size={24}
            name='square'
            color={status === 'stopped' ? 'grey' : 'green'}
          />
        </Pressable>
      </View>
    );
  }

  function content_area() {
    return (
      <View className=' py-4 md:py-8 lg:py-12 xl:py-16 px-4 md:px-6 bg-white  dark:bg-black'>
        <View className='m-2 p-2 items-center gap-4 text-center'>
          <ScrollView>
            <Text
              className=' text-black dark:text-white font-bold text-center justify-stretch text-pretty'
              style={{ fontSize: fontSize }}
            >
              {post
                .toString()
                .replace('_', '  ')
                .replace('@Content:', '')
                .replace('.md', '')}{' '}
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <Text className='items-end text-gray-500 dark:text-grey-300 '>
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
