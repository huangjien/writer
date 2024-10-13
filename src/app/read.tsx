import { Text, View, Button } from 'react-native';
import * as Speech from 'expo-speech';
import { Platform } from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { useEffect, useRef, useState } from 'react';

export default function Page() {
  const [items, setItems] = useState([]);
  const [selectedLanguage, setSelectedLanguage] = useState('zh');
  const [voice, setVoice] = useState('zh')
  const speak = () => {
    const thingToSay =
      '白日何短短，百年苦易满。苍穹浩茫茫，万劫太极长。麻姑垂两鬓，一半已成霜。天公见玉女，大笑亿千场。吾欲揽六龙，回车挂扶桑。北斗酌美酒，劝龙各一觞。富贵非所愿，与人驻颜光。';
    Speech.speak(thingToSay, { language: selectedLanguage, voice: voice  });
  };
  useEffect(() => {
    
    Speech.getAvailableVoicesAsync()
      .then((res) => {
        // console.log(JSON.stringify(res, null, 2));
        let count = 0;
        let arr = [];
        res.map((v) => {
          v['key'] = count.toString();
          count++;
          // console.log(v)
          arr.push(v)
        });
        return arr;
      }).then(arr => setItems(arr))
      .catch((err) => {
        console.error(err.status, err.message);
      });
  }, []);

  const renderItemList =  items.map((item) => 
        <Picker.Item
          key={item.key}
          label={item.identifier}
          value={item.language}
        />
      );

  const handleSelected = (itemValue, itemPosition) => {
    console.log(itemValue, itemPosition)
    setVoice(items[itemPosition].identifier)
    console.log(items[itemPosition])
    setSelectedLanguage(itemValue)
  }
  return (
    <View className=' inline-flex m-2 p-2 gap-2  justify-between' role='group'>
      <Picker
        prompt='Language: '
        onValueChange={(itemValue, itemPosition) => {handleSelected(itemValue, itemPosition)}}
      >
        {renderItemList}
      </Picker>
      <Button title='Play' onPress={speak} />
      {Platform.OS !== 'android' && (
        <>
          <Button title='Pause' onPress={Speech.pause} />
          <Button title='Resume' onPress={Speech.resume} />
        </>
      )}
      <Button title='Stop' onPress={Speech.stop} />

      <Text>Max Read Length: {Speech.maxSpeechInputLength}</Text>
    </View>
  );
}
