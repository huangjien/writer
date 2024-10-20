import React from 'react';
import '../global.css';
import { Link } from 'expo-router';
import { Drawer } from 'expo-router/drawer';
import { Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Feather } from '@expo/vector-icons';
import packageJson from '../../package.json';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { SessionProvider, useSession } from '../components/ctx';

export default function Layout() {
  const {} = useSession();
  return (
    <GestureHandlerRootView>
      <SessionProvider>
        <View className='flex flex-shrink-0 flex-1 flex-col h-screen'>
          {/* <Header /> */}
          <Drawer>
            <Drawer.Screen
              name='index'
              options={{
                drawerLabel: 'Home',
                title: 'Welcome',
                drawerIcon: ({ focused, size }) => (
                  <Feather
                    name='home'
                    size={size}
                    color={focused ? '#7cc' : '#ccc'}
                  />
                ),
              }}
            />
            <Drawer.Screen
              name='github'
              options={{
                drawerLabel: 'GitHub',
                title: 'Repository',
                drawerIcon: ({ focused, size }) => (
                  <Feather
                    name='code'
                    size={size}
                    color={focused ? '#7cc' : '#ccc'}
                  />
                ),
              }}
            />
            <Drawer.Screen
              name='read'
              options={{
                drawerLabel: 'Read',
                title: 'Chapter',
                drawerIcon: ({ focused, size }) => (
                  <Feather
                    name='play'
                    size={size}
                    color={focused ? '#7cc' : '#ccc'}
                  />
                ),
              }}
            />
            <Drawer.Screen
              name='setting'
              options={{
                drawerLabel: 'Setting',
                title: 'Configuration',
                drawerIcon: ({ focused, size }) => (
                  <Feather
                    name='settings'
                    size={size}
                    color={focused ? '#7cc' : '#ccc'}
                  />
                ),
              }}
            />
          </Drawer>
          <Footer />
        </View>
      </SessionProvider>
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
      className='fixed bottom-0 inline-flex flex-row bg-gray-100 h-5'
      style={{ paddingBottom: bottom }}
    >
      {/* <Text className='sm:hidden xs:inline'>xs</Text>
      <Text className='hidden sm:inline md:hidden'>sm</Text>
      <Text className='hidden md:inline lg:hidden'>md</Text>
      <Text className='hidden lg:inline xl:hidden'>lg</Text>
      <Text className='hidden xl:inline'>xl</Text>
      <Text className='hidden 2xl:inline'>2xl</Text> */}

      <Text className={'ml-2 text-center text-gray-700'}>
        © {new Date().getFullYear()} &nbsp; {packageJson.copyright} &nbsp;{' '}
        {packageJson.author} &nbsp; {packageJson.version}
      </Text>
    </View>
  );
}
