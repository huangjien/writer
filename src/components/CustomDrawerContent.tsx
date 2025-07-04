import { Image } from '@/components/image';
import { Feather } from '@expo/vector-icons';
import { DrawerItem } from '@react-navigation/drawer';
import { useRouter } from 'expo-router';
import { ReactElement } from 'react';
import { ScrollView, View } from 'react-native';
import { useThemeConfig } from '@/hooks/use-theme-config';
import { images } from '@/app/images';
import { Text } from 'react-native';
import packageJson from '@/../package.json';
import { useAsyncStorage } from '@/hooks/useAsyncStorage';
import { TIMEOUT } from './global';

export const CustomDrawerContent = (): ReactElement => {
  const router = useRouter();
  const [storage, { setItem }, isLoading, hasChanged] = useAsyncStorage();
  const { theme, themeName, setSelectedTheme } = useThemeConfig();

  return (
    <ScrollView
      contentContainerClassName='flex-1 py-4'
      style={{ backgroundColor: theme.colors.background }}
    >
      <View className='container m-4 p-4'>
        <Image
          source={images.logo}
          className='flex w-12 h-12 m-2 rounded-full'
        />
        <Text className='text-black dark:text-white font-bold'>
          {packageJson.name}
        </Text>
        <Text className='text-black dark:text-white text-xs'>
          {packageJson.slogan}
        </Text>
      </View>

      <DrawerItem
        label={() => <Text className='text-black dark:text-white '>Home</Text>}
        icon={() => <Feather name='home' size={24} color={theme.colors.text} />}
        onPress={() => {
          router.push('/');
        }}
      />
      <DrawerItem
        label={() => <Text className='text-black dark:text-white '>Index</Text>}
        icon={() => <Feather name='code' size={24} color={theme.colors.text} />}
        onPress={() => {
          router.push('/github');
        }}
      />
      <DrawerItem
        label={() => <Text className='text-black dark:text-white '>Read</Text>}
        icon={() => <Feather name='play' size={24} color={theme.colors.text} />}
        onPress={() => {
          router.push('/read');
        }}
      />
      <DrawerItem
        label={() => (
          <Text className='text-black dark:text-white '>Settings</Text>
        )}
        icon={() => (
          <Feather name='settings' size={24} color={theme.colors.text} />
        )}
        onPress={() => {
          router.push('/setting');
        }}
      />
      <DrawerItem label={''} onPress={() => {}} />
      <DrawerItem
        label={() => <Text className='text-black dark:text-white '>Theme</Text>}
        icon={() => {
          if (themeName === 'dark') {
            return <Feather name='moon' size={24} color={'green'} />;
          } else {
            return <Feather name='sun' size={24} color={'green'} />;
          }
        }}
        onPress={() => {
          if (themeName === 'dark') {
            setSelectedTheme('light');
          } else {
            setSelectedTheme('dark');
          }
        }}
      />
      <DrawerItem
        label={() => (
          <Text className='text-black dark:text-white '>Log out</Text>
        )}
        icon={() => <Feather name='log-out' size={24} color={'green'} />}
        onPress={() => {
          setItem('expiry', (Date.now() - TIMEOUT).toString());
        }}
      />
    </ScrollView>
  );
};
