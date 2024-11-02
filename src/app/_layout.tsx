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

import { handleError, showErrorToast } from '@/components/global';
import { CustomDrawerContent } from '@/components/CustomDrawerContent';
import { Footer } from '@/components/Footer';
import {
  AsyncStorageProvider,
  useAsyncStorage,
} from '@/components/useAsyncStorage';

enableFreeze(true);

export default function Layout() {
  const { theme } = useThemeConfig();

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

  function InnerLayout() {
    const [isBiometricSupported, setIsBiometricSupported] =
      React.useState(false);
    const [storage, { getItem, setItem }, isLoading, hasChanged] =
      useAsyncStorage();

    // Prevent the splash screen from auto-hiding before asset loading is complete.
    SplashScreen.preventAutoHideAsync();

    useEffect(() => {
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
        if (expiry || parseInt(expiry) < Date.now()) handleBiometricAuth();
      });
    }, [hasChanged]);

    const handleBiometricAuth = async () => {
      // registerBackgroundFetchAsync();
      await getItem('expiry').then((expiry) => {
        if (expiry && parseInt(expiry) > Date.now()) return;
        else {
          const savedBiometrics = LocalAuthentication.isEnrolledAsync();
          if (!savedBiometrics)
            return showErrorToast(
              'No Biometrics Authentication\nPlease verify your identity with your password'
            );
          LocalAuthentication.authenticateAsync({
            promptMessage: "You need to be this device's owner to use this app",
            disableDeviceFallback: false,
          }).then((biometricAuth) => {
            if (biometricAuth.success) {
              setItem('expiry', (Date.now() + 1000 * 60 * 5).toString());
            }
          });
        }
      });
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
}
