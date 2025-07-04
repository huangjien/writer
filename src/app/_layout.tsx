import React, { useEffect } from 'react';
import '../global.css';
import { Drawer } from 'expo-router/drawer';
import { Pressable, Text, View } from 'react-native';
import { Feather } from '@expo/vector-icons';
import { ThemeProvider, useTheme } from '@react-navigation/native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { useThemeConfig } from '@/hooks/use-theme-config';
import { enableFreeze } from 'react-native-screens';
import { RootSiblingParent } from 'react-native-root-siblings';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { CustomDrawerContent } from '@/components/CustomDrawerContent';
import { Footer } from '@/components/Footer';
import { AsyncStorageProvider } from '@/hooks/useAsyncStorage';
import { useAuthentication } from '@/hooks/useAuthentication';
import { Audio } from 'expo-av';

enableFreeze(true);

export function InnerLayout() {
  const theme = useTheme();
  // console.log('InnerLayout component is rendering');
  const { authState, isLoading, initializeAuth } = useAuthentication();

  useEffect(() => {
    initializeAuth();
  }, []);

  // Show loading state while initializing
  if (isLoading) {
    return (
      <View className='flex-1 justify-center items-center'>
        <Text style={{ color: theme.colors.text }}>Initializing...</Text>
      </View>
    );
  }
  return (
    <View
      className='flex elevation z-auto flex-1 flex-col'
      style={{ backgroundColor: theme.colors.background }}
    >
      {/* <Header /> */}
      <Drawer
        screenOptions={{
          headerTransparent: true,
          headerStyle: {
            backgroundColor: 'transparent',
          },
          headerTitleStyle: {
            color: theme.colors.text,
          },
          headerTintColor: theme.colors.text,
          drawerStyle: {
            backgroundColor: theme.colors.background,
          },
          drawerLabelStyle: {
            color: theme.colors.text,
          },
          drawerActiveBackgroundColor: theme.colors.primary,
          drawerActiveTintColor: theme.colors.text,
          drawerInactiveTintColor: theme.colors.text,
        }}
        drawerContent={() => <CustomDrawerContent />}
      >
        <Drawer.Screen
          name='index'
          options={({ navigation }) => ({
            headerShown: true,
            headerLeft: () => menuButton(navigation), // Now screen-specific
            headerTitle: () => (
              <Text className='text-inherit dark:text-white'>Welcome</Text>
            ),
          })}
        />

        <Drawer.Screen
          name='github'
          options={({ navigation }) => ({
            headerShown: true,
            headerLeft: () => menuButton(navigation), // Now screen-specific
            headerTitle: () => (
              <Text className='text-inherit dark:text-white'>Index</Text>
            ),
          })}
        />
        <Drawer.Screen
          name='read'
          options={({ navigation }) => ({
            headerShown: true,
            headerLeft: () => menuButton(navigation), // Now screen-specific
            headerTitle: () => (
              <Text className='text-inherit dark:text-white'>Reading</Text>
            ),
          })}
        />
        <Drawer.Screen
          name='setting'
          options={({ navigation }) => ({
            headerShown: true,
            headerLeft: () => menuButton(navigation), // Now screen-specific
            headerTitle: () => (
              <Text className='text-inherit dark:text-white'>Settings</Text>
            ),
          })}
        />
      </Drawer>
      <Footer />
    </View>
  );

  function menuButton(navigation): React.ReactNode {
    return (
      <Pressable
        onPress={() => navigation.toggleDrawer()}
        style={{ marginLeft: 16 }}
      >
        <Feather name='menu' size={24} color={theme.colors.border} />
      </Pressable>
    );
  }
}

export default function Layout() {
  console.log('Layout component is rendering');
  const { theme } = useThemeConfig();
  console.log('Layout theme:', theme);

  // Initialize audio session on app start
  useEffect(() => {
    const initializeAudioSession = async () => {
      try {
        await Audio.setAudioModeAsync({
          allowsRecordingIOS: false,
          staysActiveInBackground: true,
          playsInSilentModeIOS: true,
          shouldDuckAndroid: true,
          playThroughEarpieceAndroid: false,
        });
        console.log('Audio session initialized successfully');
      } catch (error) {
        console.error('Failed to initialize audio session:', error);
      }
    };

    initializeAudioSession();
  }, []);

  return (
    <AsyncStorageProvider>
      <RootSiblingParent>
        <ThemeProvider value={theme}>
          <GestureHandlerRootView>
            <SafeAreaProvider>
              <InnerLayout />
            </SafeAreaProvider>
          </GestureHandlerRootView>
        </ThemeProvider>
      </RootSiblingParent>
    </AsyncStorageProvider>
  );
}
