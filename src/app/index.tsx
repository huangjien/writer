import { Link } from 'expo-router';
import React, { useEffect } from 'react';
import { Alert, Pressable, Text, View } from 'react-native';
import { FontAwesome } from '@expo/vector-icons';
import * as LocalAuthentication from 'expo-local-authentication';

export default function Page() {
  // wherever the useState is located
  const [isBiometricSupported, setIsBiometricSupported] = React.useState(false);

  // Check if hardware supports biometrics
  useEffect(() => {
    (async () => {
      const compatible = await LocalAuthentication.hasHardwareAsync();
      setIsBiometricSupported(compatible);
    })();
  });

  const handleBiometricAuth = async () => {
    const savedBiometrics = await LocalAuthentication.isEnrolledAsync();
    if (!savedBiometrics)
      return Alert.alert(
        'No Biometrics Authentication',
        'Please verify your identity with your password',
        [{ text: 'OK', onPress: () => console.log('OK Pressed') }],
        { cancelable: false }
      );
    const biometricAuth = await LocalAuthentication.authenticateAsync({
      promptMessage: "You need to be this device's owner to use this app",
      disableDeviceFallback: false,
    });
    console.log(biometricAuth.success);
  };

  return (
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
            <Text className='mx-auto max-w-[700px] text-lg text-center text-gray-500 md:text-xl dark:text-gray-400'>
              This project will allow you sync with a GitHub repository. Can you
              can call local TTS service to read content of files.
            </Text>

            <View className='gap-4'>
              <Pressable
                className='flex h-9 items-center justify-center overflow-hidden rounded-md bg-gray-100 px-4 py-2 text-sm font-medium text-gray-50 web:shadow ios:shadow transition-colors hover:bg-gray-900/90 active:bg-gray-400/90 web:focus-visible:outline-none web:focus-visible:ring-1 focus-visible:ring-gray-950 disabled:pointer-events-none disabled:opacity-50 dark:bg-gray-50 dark:text-gray-900 dark:hover:bg-gray-50/90 dark:focus-visible:ring-gray-300'
                onPress={handleBiometricAuth}
              >
                <FontAwesome name='user' size={24} />
              </Pressable>
            </View>

            <Text>
              {isBiometricSupported
                ? 'Your device is compatible with Biometrics'
                : 'Face or Fingerprint scanner is available on this device'}
            </Text>
          </View>
        </View>
      </View>
    </View>
  );
}
