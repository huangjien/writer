import React from 'react';
import '../global.css';
import { Link } from 'expo-router';
import { Drawer } from 'expo-router/drawer';
import { Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { FontAwesome } from '@expo/vector-icons';
import packageJson from '../../package.json';
import { GestureHandlerRootView } from 'react-native-gesture-handler';

export default function Layout() {
  return (
    <GestureHandlerRootView>
      <View className='flex flex-shrink-0 flex-1 flex-col h-screen'>
        {/* <Header /> */}
        <Drawer >
          <Drawer.Screen name='index' options={{ drawerLabel : 'Home', title: 'Welcome'}} />
          <Drawer.Screen name='github' options={{ drawerLabel : 'GitHub', title: 'Repository'}} />
          <Drawer.Screen name='read' options={{ drawerLabel : 'Read', title: 'Chapter'}} />
          <Drawer.Screen name='setting' options={{ drawerLabel : 'Setting', title: 'Configuration'}} />
        </Drawer>
        <Footer />
      </View>
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
            <FontAwesome className='m-1 p-1' name='info' />
            About
          </Link>
          <Link
            className='text-md font-medium hover:underline web:underline-offset-4'
            href='/'
          >
            <FontAwesome className='m-1 p-1' name='code' />
            GitHub
          </Link>
          <Link
            className='text-md font-medium hover:underline web:underline-offset-4'
            href='/read'
          >
            <FontAwesome className='m-1 p-1' name='bookmark' />
            Read
          </Link>
          <Link
            className='text-md font-medium hover:underline web:underline-offset-4'
            href='/setting'
          >
            <FontAwesome className='m-1 p-1' name='gear' />
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
