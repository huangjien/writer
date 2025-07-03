import React, { useEffect } from 'react';
import '../global.css';
import { SplashScreen } from 'expo-router';
import { Drawer } from 'expo-router/drawer';
import { Pressable, Text, View } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { ThemeProvider } from '@react-navigation/native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import * as LocalAuthentication from 'expo-local-authentication';
import { useThemeConfig } from '@/components/use-theme-config';
import { enableFreeze } from 'react-native-screens';
import { RootSiblingParent } from 'react-native-root-siblings';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { handleError, showErrorToast, TIMEOUT } from '@/components/global';
import { CustomDrawerContent } from '@/components/CustomDrawerContent';
import { Footer } from '@/components/Footer';
import {
  AsyncStorageProvider,
  useAsyncStorage,
} from '@/components/useAsyncStorage';
import { SPEECH_TASK } from '@/components/SpeechTask';
import * as BackgroundFetch from 'expo-background-fetch';

const registerBackgroundTask = async () => {
  try {
    await BackgroundFetch.registerTaskAsync(SPEECH_TASK, {
      minimumInterval: 10,
      stopOnTerminate: true,
      startOnBoot: false,
    });
  } catch (err) {
    console.error('Failed to Register speech task', err);
  }
};

enableFreeze(true);

export function InnerLayout() {
  console.log('InnerLayout component is rendering');
  const [isBiometricSupported, setIsBiometricSupported] = React.useState(false);
  const [storage, { getItem, setItem }, isLoading, hasChanged] =
    useAsyncStorage();
  console.log('InnerLayout useAsyncStorage result:', {
    storage,
    isLoading,
    hasChanged,
  });

  // Prevent the splash screen from auto-hiding before asset loading is complete.
  SplashScreen.preventAutoHideAsync();

  useEffect(() => {
    registerBackgroundTask();
    LocalAuthentication.hasHardwareAsync()
      .then((compatible) => {
        setIsBiometricSupported(compatible);
      })
      .then(() => {
        SplashScreen.hideAsync();
        handleBiometricAuth();
      })
      .catch((err) => {
        SplashScreen.hideAsync().then(() => {
          handleError(err);
        });
      });
  }, []);

  useEffect(() => {
    getItem('expiry').then((expiry) => {
      if (!expiry || parseInt(expiry) < Date.now()) handleBiometricAuth();
    });
  }, [hasChanged]);

  const handleBiometricAuth = async () => {
    // registerBackgroundFetchAsync();
    const expiry = await getItem('expiry');
    if (expiry && parseInt(expiry) > Date.now()) return;

    const savedBiometrics = await LocalAuthentication.isEnrolledAsync();
    if (!savedBiometrics) {
      return showErrorToast(
        'No Biometrics Authentication\nPlease verify your identity with your password'
      );
    }

    const biometricAuth = await LocalAuthentication.authenticateAsync({
      promptMessage: "You need to be this device's owner to use this app",
      disableDeviceFallback: false,
    });

    if (biometricAuth.success) {
      setItem('expiry', (Date.now() + TIMEOUT).toString());
    }
  };
  return (
    <View className='flex elevation z-auto flex-1 flex-col text-black dark:text-white bg-white dark:bg-black'>
      {/* <Header /> */}
      <Drawer
        screenOptions={({ navigation }) => ({
          headerMode: 'float',
          headerLeft: () => (
            <Pressable onPress={() => navigation.toggleDrawer()}>
              <Feather name='menu' size={24} color={'green'} />
            </Pressable>
          ),
        })}
        drawerContent={() => <CustomDrawerContent />}
      >
        <Drawer.Screen
          name='index'
          options={{
            headerShown: true,
            headerTitle() {
              return (
                <Text className='bg-white dark:bg-black text-black dark:text-white'>
                  Welcome
                </Text>
              );
            },
            headerBackground() {
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
            headerTitle() {
              return (
                <Text className='bg-white dark:bg-black text-black dark:text-white'>
                  Index
                </Text>
              );
            },
            headerBackground() {
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
            headerTitle() {
              return (
                <Text className='bg-white dark:bg-black text-black dark:text-white'>
                  Reading
                </Text>
              );
            },
            headerBackground() {
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
            headerTitle() {
              return (
                <Text className='bg-white dark:bg-black text-black dark:text-white'>
                  Configuration
                </Text>
              );
            },
            headerBackground() {
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
  );
}

export default function Layout() {
  console.log('Layout component is rendering');
  const { theme } = useThemeConfig();
  console.log('Layout theme:', theme);

  return (
    <AsyncStorageProvider>
      <RootSiblingParent>
        <GestureHandlerRootView>
          <ThemeProvider value={theme}>
            <SafeAreaProvider>
              <InnerLayout />
            </SafeAreaProvider>
          </ThemeProvider>
        </GestureHandlerRootView>
      </RootSiblingParent>
    </AsyncStorageProvider>
  );
}
