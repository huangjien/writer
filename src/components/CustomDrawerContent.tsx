import { Image } from '@/components/image';
import { Feather } from '@expo/vector-icons';
import { DrawerItem } from '@react-navigation/drawer';
import { useRouter } from 'expo-router';
import { createContext, ReactElement, useContext } from 'react';
import { ScrollView, View } from 'react-native';
import { useThemeConfig } from './use-theme-config';
import { images } from '@/app/images';
import { Drawer } from 'expo-router/drawer';
import { AppState, Pressable, Text } from 'react-native';
import packageJson from '../../package.json';

export const AuthContext = createContext({
  expiry: Date.now(),
  setExpiry: (expiry) => {
    expiry = expiry;
  },
});

export function useSession() {
  return useContext(AuthContext);
}

export const CustomDrawerContent = (): ReactElement => {
  const router = useRouter();
  const AuthContext = useSession();
  const { themeName, setSelectedTheme } = useThemeConfig();

  return (
    <ScrollView contentContainerClassName='flex-1 py-4  text-black dark:text-white bg-white dark:bg-black'>
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
        icon={() => <Feather name='home' size={24} color={'green'} />}
        onPress={() => {
          router.push('/');
        }}
      />
      <DrawerItem
        label={() => <Text className='text-black dark:text-white '>Index</Text>}
        icon={() => <Feather name='code' size={24} color={'green'} />}
        onPress={() => {
          router.push('/github');
        }}
      />
      <DrawerItem
        label={() => <Text className='text-black dark:text-white '>Read</Text>}
        icon={() => <Feather name='play' size={24} color={'green'} />}
        onPress={() => {
          router.push('/read');
        }}
      />
      <DrawerItem
        label={() => (
          <Text className='text-black dark:text-white '>Settings</Text>
        )}
        icon={() => <Feather name='settings' size={24} color={'green'} />}
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
          AuthContext.setExpiry(Date.now() - 1000);
          // unregisterBackgroundFetchAsync();
        }}
      />
    </ScrollView>
  );
};
