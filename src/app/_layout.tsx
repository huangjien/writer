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
import Footer from '@/components/Footer';
import { AsyncStorageProvider } from '@/hooks/useAsyncStorage';
import { useAuthentication } from '@/hooks/useAuthentication';
import { Audio } from 'expo-av';
import { StatusBar } from 'expo-status-bar';
import { useColorScheme } from 'nativewind';
import {
  configureReanimatedLogger,
  ReanimatedLogLevel,
} from 'react-native-reanimated';

// Configure Reanimated logger to reduce warnings
configureReanimatedLogger({
  level: ReanimatedLogLevel.warn,
  strict: false, // Disable strict mode to reduce warnings about writing to value during render
});

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

  return (
    <View
      className='flex elevation z-auto flex-1 flex-col'
      style={{ backgroundColor: 'transparent' }}
    >
      <StatusBar
        style={theme.dark ? 'light' : 'dark'}
        translucent
        backgroundColor='transparent'
      />
      {/* <Header /> */}
      <Drawer
        screenOptions={{
          headerTransparent: true,
          headerStyle: {
            backgroundColor: 'transparent',
            elevation: 0,
            shadowOpacity: 0,
            borderBottomWidth: 0,
          },
          headerTitleStyle: {
            color: theme.colors.text,
            fontWeight: '600',
            textShadowColor: theme.dark
              ? 'rgba(0, 0, 0, 0.3)'
              : 'rgba(255, 255, 255, 0.8)',
            textShadowOffset: { width: 0, height: 1 },
            textShadowRadius: 2,
          },
          headerTintColor: theme.colors.text,
          drawerStyle: {
            backgroundColor: 'transparent',
            width: 320,
          },
          drawerType: 'slide',
          overlayColor: theme.dark
            ? 'rgba(15, 23, 42, 0.6)'
            : 'rgba(248, 250, 252, 0.6)',
          drawerLabelStyle: {
            color: theme.colors.text,
          },
          drawerActiveBackgroundColor: theme.dark
            ? 'rgba(165, 180, 252, 0.2)'
            : 'rgba(79, 70, 229, 0.1)',
          drawerActiveTintColor: theme.dark ? '#a5b4fc' : '#4f46e5',
          drawerInactiveTintColor: theme.dark ? '#cbd5e1' : '#64748b',
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
        console.log(
          'Audio session initialized successfully for background playback'
        );
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
          <GestureHandlerRootView
            style={{ flex: 1, backgroundColor: 'transparent' }}
          >
            <SafeAreaProvider>
              <View
                style={{
                  flex: 1,
                  backgroundColor: theme.dark
                    ? 'rgba(15, 23, 42, 0.95)'
                    : 'rgba(248, 250, 252, 0.95)',
                }}
              >
                <InnerLayout />
              </View>
            </SafeAreaProvider>
          </GestureHandlerRootView>
        </ThemeProvider>
      </RootSiblingParent>
    </AsyncStorageProvider>
  );
}
