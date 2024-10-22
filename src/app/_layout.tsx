import React, {
  createContext,
  ReactElement,
  useContext,
  useEffect,
  useState,
} from 'react';
import '../global.css';
import { Link, SplashScreen, useRouter } from 'expo-router';
import { Drawer } from 'expo-router/drawer';
import { Alert, Text, View, SafeAreaView, Pressable } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Feather } from '@expo/vector-icons';
import packageJson from '../../package.json';
import { DarkTheme, ThemeProvider, useTheme } from '@react-navigation/native';
import { Image } from '@/components/image';
import {
  GestureHandlerRootView,
  ScrollView,
} from 'react-native-gesture-handler';
import { SessionProvider, useSession } from '../components/ctx';
import * as LocalAuthentication from 'expo-local-authentication';
import {
  DrawerContentComponentProps,
  DrawerItem,
} from '@react-navigation/drawer';
import { useThemeConfig } from '@/components/use-theme-config';
import { enableFreeze } from 'react-native-screens';

enableFreeze(true);

export const AuthContext = createContext({
  authenticated: false,
  setAuthenticated: (authenticated: boolean) => {
    authenticated = authenticated;
  },
});

const images = {
  logo: require('assets/favicon.png'),
};

const CustomDrawerContent = ({
  drawerPosition,
  navigation,
}: any): ReactElement => {
  const router = useRouter();
  const authContext = useContext(AuthContext);
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
          authContext.setAuthenticated(false);
        }}
      />
    </ScrollView>
  );
};

export default function Layout() {
  const [isBiometricSupported, setIsBiometricSupported] = React.useState(false);
  const [authenticated, setAuthenticated] = useState(false);

  // Prevent the splash screen from auto-hiding before asset loading is complete.
  SplashScreen.preventAutoHideAsync();
  const { theme } = useThemeConfig();

  useEffect(() => {
    LocalAuthentication.hasHardwareAsync().then((compatible) => {
      setIsBiometricSupported(compatible);
    });
  }, [isBiometricSupported]);

  useEffect(() => {
    if (!authenticated) handleBiometricAuth();
  }, [authenticated]);

  const handleBiometricAuth = async () => {
    if (authenticated) return;
    const savedBiometrics = await LocalAuthentication.isEnrolledAsync();
    if (!savedBiometrics)
      return Alert.alert(
        'No Biometrics Authentication',
        'Please verify your identity with your password',
        [{ text: 'OK', onPress: () => console.log('OK Pressed') }],
        { cancelable: false }
      );
    const biometricAuth = await LocalAuthentication.authenticateAsync({
      promptMessage: "You need to be this device's owner to use this app",
      disableDeviceFallback: false,
    });
    if (!biometricAuth.success) {
      handleBiometricAuth();
    } else {
      setAuthenticated(true);
    }
  };

  return (
    <GestureHandlerRootView>
      <AuthContext.Provider value={{ authenticated, setAuthenticated }}>
        <ThemeProvider value={theme}>
          <View className='flex flex-1 flex-col text-black dark:text-white bg-white dark:bg-black'>
            {/* <Header /> */}
            <Drawer
              drawerContent={(props: DrawerContentComponentProps) => (
                <CustomDrawerContent drawerPosition={undefined} {...props} />
              )}
            >
              <Drawer.Screen
                name='index'
                options={{
                  headerShown: true,
                  headerTitle(props) {
                    return (
                      <Text className='bg-white dark:bg-black text-black dark:text-white'>
                        Welcome
                      </Text>
                    );
                  },
                  headerBackground(props) {
                    return (
                      <View className='bg-white dark:bg-black text-black dark:text-white'>
                        <View style={{ height: 100 }} />
                      </View>
                    );
                  },
                }}
              />
              <Drawer.Screen
                name='github'
                options={{
                  headerShown: true,
                  headerTitle(props) {
                    return (
                      <Text className='bg-white dark:bg-black text-black dark:text-white'>
                        Index
                      </Text>
                    );
                  },
                  headerBackground(props) {
                    return (
                      <View className='bg-white dark:bg-black text-black dark:text-white'>
                        <View style={{ height: 100 }} />
                      </View>
                    );
                  },
                }}
              />
              <Drawer.Screen
                name='read'
                options={{
                  headerShown: true,
                  headerTitle(props) {
                    return (
                      <Text className='bg-white dark:bg-black text-black dark:text-white'>
                        Configuration
                      </Text>
                    );
                  },
                  headerBackground(props) {
                    return (
                      <View className='bg-white dark:bg-black text-black dark:text-white'>
                        <View style={{ height: 100 }} />
                      </View>
                    );
                  },
                }}
              />
              <Drawer.Screen
                name='setting'
                options={{
                  headerShown: true,
                  headerTitle(props) {
                    return (
                      <Text className='bg-white dark:bg-black text-black dark:text-white'>
                        Configuration
                      </Text>
                    );
                  },
                  headerBackground(props) {
                    return (
                      <View className='bg-white dark:bg-black text-black dark:text-white'>
                        <View style={{ height: 100 }} />
                      </View>
                    );
                  },
                }}
              />
            </Drawer>
            <Footer />
          </View>
        </ThemeProvider>
      </AuthContext.Provider>
    </GestureHandlerRootView>
  );
}

function Header() {
  const { top } = useSafeAreaInsets();
  return (
    <View style={{ paddingTop: top }}>
      <View className='px-4 lg:px-6 h-14 flex items-center flex-row justify-between '>
        <Link className='font-bold flex-1 items-center justify-center' href='/'>
          writer
        </Link>
        <View className='flex flex-row gap-2 sm:gap-6'>
          <Link
            className='text-md  font-medium hover:underline web:underline-offset-4'
            href='/'
          >
            <Feather className='m-1 p-1' name='info' />
            About
          </Link>
          <Link
            className='text-md font-medium hover:underline web:underline-offset-4'
            href='/'
          >
            <Feather className='m-1 p-1' name='code' />
            GitHub
          </Link>
          <Link
            className='text-md font-medium hover:underline web:underline-offset-4'
            href='/read'
          >
            <Feather className='m-1 p-1' name='bookmark' />
            Read
          </Link>
          <Link
            className='text-md font-medium hover:underline web:underline-offset-4'
            href='/setting'
          >
            <Feather className='m-1 p-1' name='settings' />
            Setting
          </Link>
        </View>
      </View>
    </View>
  );
}

function Footer() {
  const { bottom } = useSafeAreaInsets();
  return (
    <View
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
}
