import { View, Text } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import packageJson from '@/../package.json';

export const Footer = () => {
  const { bottom } = useSafeAreaInsets();
  return (
    <View
      testID='footer'
      className='fixed bottom-0 inline-flex flex-row h-5'
      style={{ paddingBottom: bottom }}
    >
      <Text
        className={
          'ml-2 text-center bg-white text-black dark:text-gray-200  dark:bg-black'
        }
      >
        © {new Date().getFullYear()} &nbsp; {packageJson.copyright} &nbsp;{' '}
        {packageJson.author} &nbsp; {packageJson.version}
      </Text>
    </View>
  );
};
