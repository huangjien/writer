import React, { useEffect } from 'react';
import '../global.css';
import { Drawer } from 'expo-router/drawer';
import { Pressable, Text, View } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { ThemeProvider } from '@react-navigation/native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { useThemeConfig } from '@/hooks/use-theme-config';
import { enableFreeze } from 'react-native-screens';
import { RootSiblingParent } from 'react-native-root-siblings';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { CustomDrawerContent } from '@/components/CustomDrawerContent';
import { Footer } from '@/components/Footer';
import { AsyncStorageProvider } from '@/hooks/useAsyncStorage';
import { useAuthentication } from '@/hooks/useAuthentication';

enableFreeze(true);

export function InnerLayout() {
  console.log('InnerLayout component is rendering');
  const { authState, isLoading, initializeAuth } = useAuthentication();

  console.log('InnerLayout auth state:', {
    authState,
    isLoading,
  });

  useEffect(() => {
    initializeAuth();
  }, [initializeAuth]);

  // Show loading state while initializing
  if (isLoading) {
    return (
      <View className='flex-1 justify-center items-center bg-white dark:bg-black'>
        <Text className='text-black dark:text-white'>Initializing...</Text>
      </View>
    );
  }
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
