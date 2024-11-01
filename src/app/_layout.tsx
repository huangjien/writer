import React, { useEffect, useState } from 'react';
import '../global.css';
import { SplashScreen } from 'expo-router';
import { Drawer } from 'expo-router/drawer';
import { AppState, Pressable, Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Feather } from '@expo/vector-icons';
import { ThemeProvider } from '@react-navigation/native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import * as LocalAuthentication from 'expo-local-authentication';
import { DrawerContentComponentProps } from '@react-navigation/drawer';
import { useThemeConfig } from '@/components/use-theme-config';
import { enableFreeze } from 'react-native-screens';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { RootSiblingParent } from 'react-native-root-siblings';
import {
  getStoredSettings,
  SETTINGS_KEY,
  showErrorToast,
} from '../components/global';
import {
  AuthContext,
  CustomDrawerContent,
  useSession,
} from '@/components/CustomDrawerContent';
import { Footer } from '@/components/Footer';
// import * as BackgroundFetch from 'expo-background-fetch';
// import * as TaskManager from 'expo-task-manager';

// const BACKGROUND_FETCH_TASK = 'background-fetch';

// TaskManager.defineTask(BACKGROUND_FETCH_TASK, () => {
//   console.log('background fetch task');

//   return BackgroundFetch.BackgroundFetchResult.NewData;
// });

// async function unregisterBackgroundFetchAsync() {
//   console.log('unregistering background fetch task')
//   return BackgroundFetch.unregisterTaskAsync(BACKGROUND_FETCH_TASK);
// }

// async function registerBackgroundFetchAsync() {
//   const isRegistered = await TaskManager.isTaskRegisteredAsync(BACKGROUND_FETCH_TASK)
//   if (isRegistered) {
//     console.log('background fetch task is already registered')
//     return;
//   } else {
//     console.log('registering background fetch task');
//     return BackgroundFetch.registerTaskAsync(BACKGROUND_FETCH_TASK, {
//       minimumInterval: 60 * 5, // 5 minutes
//       stopOnTerminate: false, // android only,
//       startOnBoot: true, // android only
//     });
//   }

// }

enableFreeze(true);

export default function Layout() {
  const [isBiometricSupported, setIsBiometricSupported] = React.useState(false);
  const [expiry, setExpiry] = useState(Date.now());
  const authContext = useSession();
  const [settings, setSettings] = useState({});
  const [aState, setAppState] = useState(AppState.currentState);

  // Prevent the splash screen from auto-hiding before asset loading is complete.
  SplashScreen.preventAutoHideAsync();
  const { theme } = useThemeConfig();

  useEffect(() => {
    getStoredSettings
      .then((data) => {
        if (data) {
          setSettings(data);
          let temp = settings['expiry'];
          if (!temp) temp = Date.now() - 1000;
          setExpiry(temp);
        }
      })
      .then(() => {
        LocalAuthentication.hasHardwareAsync().then((compatible) => {
          setIsBiometricSupported(compatible);
        });
      })
      .then(() => {
        SplashScreen.hideAsync();
        handleBiometricAuth();
      })
      .catch((err) => {
        SplashScreen.hideAsync().then(() => {
          showErrorToast(err.message);
          console.error(err.status, err.message);
        });
      });
    const appStateListener = AppState.addEventListener(
      'change',
      (nextAppState) => {
        setAppState(nextAppState);
      }
    );
    return () => {
      appStateListener?.remove();
    };
  }, []);

  // useEffect(() => {
  //   if (!expiry || expiry < Date.now()) handleBiometricAuth();
  // }, [expiry]);

  const handleBiometricAuth = async () => {
    // registerBackgroundFetchAsync();
    if (expiry && expiry > Date.now()) return;
    const savedBiometrics = await LocalAuthentication.isEnrolledAsync();
    if (!savedBiometrics)
      return showErrorToast(
        'No Biometrics Authentication\nPlease verify your identity with your password'
      );
    const biometricAuth = await LocalAuthentication.authenticateAsync({
      promptMessage: "You need to be this device's owner to use this app",
      disableDeviceFallback: false,
    });
    if (!biometricAuth.success) {
      setExpiry(Date.now() - 1000 * 60 * 5);
    } else {
      setExpiry(Date.now() + 1000 * 60 * 5);
      getStoredSettings
        .then((data) => {
          if (!data) {
            console.log('no data returned for settings');
            return;
          } else {
            data['expiry'] = expiry;
            setSettings(data);
            AsyncStorage.setItem(SETTINGS_KEY, JSON.stringify(settings));
          }
        })
        .catch((err) => {
          showErrorToast(err.message);
          console.error(err.status, err.message);
        });
    }
  };
  const handleError = (e) => {
    showErrorToast(e.nativeEvent.error);
    console.error(e.nativeEvent.error);
  };
  return (
    <RootSiblingParent>
      <GestureHandlerRootView>
        <AuthContext.Provider value={{ expiry, setExpiry }}>
          <ThemeProvider value={theme}>{major_area()}</ThemeProvider>
        </AuthContext.Provider>
      </GestureHandlerRootView>
    </RootSiblingParent>
  );

  function major_area() {
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
          drawerContent={(props: DrawerContentComponentProps) => (
            <CustomDrawerContent />
          )}
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
}
