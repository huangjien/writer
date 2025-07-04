import { useTheme } from '@react-navigation/native';
import { Text, View } from 'react-native';

export default function CustomHeader({ title }: { title: string }) {
  const theme = useTheme();
  return (
    <View
      className='flex-row items-center px-4 py-3'
      style={{ backgroundColor: theme.colors.background }}
    >
      <Text
        className='text-lg font-semibold tracking-tight'
        style={{ color: theme.colors.text }}
      >
        {title}
      </Text>
    </View>
  );
}
