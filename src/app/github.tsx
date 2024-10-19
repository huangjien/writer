import { Link } from 'expo-router';
import React, { useEffect } from 'react';
import { Alert, Pressable, Text, View } from 'react-native';
import { Feather } from '@expo/vector-icons';
import * as LocalAuthentication from 'expo-local-authentication';
import AsyncStorage from '@react-native-async-storage/async-storage';

export default function Page() {
  const [settings, setSettings] = React.useState({});

  useEffect(() => {
    AsyncStorage.getItem('@Settings').then((data) => {
      if (data) {
        const parsedData = JSON.parse(data);
        setSettings(parsedData);
      }
    });
  });

  return (
    <>
      {(!settings['githubRepo'] ||
        !settings['githubToken'] ||
        !settings['contentFolder'] ||
        !settings['analysisFolder']) && (
        <View className='flex-1'>
          <View className='py-12 md:py-24 lg:py-32 xl:py-48'>
            <View className='px-4 md:px-6'>
              <View className='flex flex-col items-center gap-4 text-center'>
                <Text
                  role='heading'
                  className='text-2xl text-center native:text-5xl font-bold tracking-tighter sm:text-4xl md:text-5xl lg:text-6xl'
                >
                  Welcome to Project writer
                </Text>
              </View>
            </View>
          </View>
        </View>
      )}
      {settings['githubRepo'] &&
        settings['githubToken'] &&
        settings['contentFolder'] &&
        settings['analysisFolder'] && (
          <View className='flex-1'>
            <View className='py-12 md:py-24 lg:py-32 xl:py-48'>
              <View className='px-4 md:px-6'>
                <View className='flex flex-col items-center gap-4 text-center'>
                  <Text
                    role='heading'
                    className='text-2xl text-center native:text-5xl font-bold tracking-tighter sm:text-4xl md:text-5xl lg:text-6xl'
                  >
                    Setting OK!
                  </Text>
                </View>
              </View>
            </View>
          </View>
        )}
    </>
  );
}
