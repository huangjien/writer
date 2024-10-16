import { Text, View, Button, Pressable, ScrollView } from 'react-native';
import * as Speech from 'expo-speech';
import { Platform } from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { useCallback, useEffect, useRef, useState } from 'react';
import { FontAwesome } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import {
  Gesture,
  GestureDetector,
  GestureHandlerRootView,
} from 'react-native-gesture-handler';

export default function Page() {
  const { bottom } = useSafeAreaInsets();
  const [items, setItems] = useState([]);
  const [selectedLanguage, setSelectedLanguage] = useState('zh');
  const [voice, setVoice] = useState('zh');
  const forceUpdate = useCallback(() => setStatus('stopped'), []);
  const [content, SetContent] = useState(
    '白日何短短，百年苦易满。苍穹浩茫茫，万劫太极长。麻姑垂两鬓，一半已成霜。天公见玉女，大笑亿千场。吾欲揽六龙，回车挂扶桑。北斗酌美酒，劝龙各一觞。富贵非所愿，与人驻颜光。'
  );

  const [status, setStatus] = useState('stopped'); // it only has 3 statuses: stopped, playing, paused
  const speak = () => {
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
          setStatus('stopped');
          console.log('reading finished, what next?');
          forceUpdate();
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

  const doubleTap = Gesture.Tap()
    .numberOfTaps(2)
    .onEnd(() => {
      // console.log('double taps')
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
            setStatus('stopped');
            console.log('reading finished, what next?');
            forceUpdate();
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
  return (
    <>
      <GestureHandlerRootView>
        <ScrollView className='mb-auto min-h-10'>
          <GestureDetector gesture={doubleTap}>
            {content_area()}
          </GestureDetector>
        </ScrollView>
      </GestureHandlerRootView>
      <View className=' bg-gray-200 py-0 items-end px-4 md:px-6 right-0 bottom-0'>
        {play_bar()}
      </View>
    </>
  );

  function play_bar() {
    return (
      <View className='inline-flex flex-row gap-16 justify-between '>
        <View className='hidden lg:inline'>
          <Picker
            prompt='Language: '
            onValueChange={(itemValue, itemPosition) => {
              handleSelected(itemValue, itemPosition);
            }}
          >
            {renderItemList}
          </Picker>
        </View>
        <Text className='hidden lg:inline'>
          Max Read Length: {Speech.maxSpeechInputLength}
        </Text>

        <Pressable disabled={status === 'playing'} onPress={speak}>
          <FontAwesome
            size={24}
            name='play'
            color={status === 'playing' ? 'grey' : 'primary'}
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
              <FontAwesome
                size={24}
                name='pause'
                color={status !== 'playing' ? 'grey' : 'primary'}
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
          <FontAwesome
            size={24}
            name='stop'
            color={status === 'stopped' ? 'grey' : 'primary'}
          />
        </Pressable>
      </View>
    );
  }

  function content_area() {
    return (
      <View className=' py-12 md:py-24 lg:py-32 xl:py-48 px-4 md:px-6'>
        <View className='m-2 p-2 items-center gap-4 text-center'>
          <ScrollView>
            <Text className='text-lg text-pretty'>{content}</Text>
          </ScrollView>
        </View>
      </View>
    );
  }
}
