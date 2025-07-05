import { View, Text } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useTheme } from '@react-navigation/native';
import packageJson from '@/../package.json';

export const Footer = () => {
  const { bottom } = useSafeAreaInsets();
  const theme = useTheme();

  return (
    <View
      testID='footer'
      className='fixed bottom-0 inline-flex flex-row h-5 text-inherit dark:text-white bg-transparent dark:bg-black '
    >
      <Text className='margin-left-8 text-inherit dark:text-white'>
        © {new Date().getFullYear()} &nbsp; {packageJson.copyright} &nbsp;{' '}
        {packageJson.author} &nbsp; {packageJson.version}
      </Text>
    </View>
  );
};
