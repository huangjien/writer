import React from 'react';
import '../global.css';
import { Link, Slot } from 'expo-router';
import { Text, View } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { FontAwesome } from '@expo/vector-icons';
import packageJson from '../../package.json';

export default function Layout() {
  return (
    <View className='flex flex-1'>
      <Header />
      <Slot />
      <Footer />
    </View>
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
    <View className='flex bg-gray-100 ' style={{ paddingBottom: bottom }}>
      <View className='py-2 flex-1 items-start px-4 md:px-6 '>
        <Text className={'text-center text-gray-700'}>
          © {new Date().getFullYear()} &nbsp; {packageJson.copyright} &nbsp;{' '}
          {packageJson.author} &nbsp; {packageJson.version}
        </Text>
      </View>
    </View>
  );
}
