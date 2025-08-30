import React from 'react';
import { View, Text } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useTheme } from '@react-navigation/native';
import { useColorScheme } from 'nativewind';
import { GlassView } from './GlassComponents';
import packageJson from '@/../package.json';

export default function Footer() {
  const insets = useSafeAreaInsets();
  const theme = useTheme();
  const { colorScheme } = useColorScheme();
  const isDark = colorScheme === 'dark';

  return (
    <GlassView
      testID='footer'
      variant='light'
      className='fixed bottom-0 inline-flex flex-row h-5 border-t'
      style={{
        paddingBottom: insets.bottom + 8,
        paddingTop: 8,
        paddingHorizontal: 16,
        borderTopColor: isDark
          ? 'rgba(148, 163, 184, 0.2)'
          : 'rgba(100, 116, 139, 0.2)',
        shadowColor: isDark ? '#000000' : '#1f2687',
        shadowOffset: { width: 0, height: -2 },
        shadowOpacity: isDark ? 0.15 : 0.1,
        shadowRadius: 8,
        elevation: 4,
      }}
    >
      <Text
        className={`text-xs opacity-70 font-medium ${
          isDark ? 'text-slate-300' : 'text-slate-600'
        }`}
        style={{
          textShadowColor: isDark
            ? 'rgba(0, 0, 0, 0.3)'
            : 'rgba(255, 255, 255, 0.8)',
          textShadowOffset: { width: 0, height: 1 },
          textShadowRadius: 1,
        }}
      >
        © {new Date().getFullYear()} &nbsp; {packageJson.copyright} &nbsp;{' '}
        {packageJson.author} &nbsp; {packageJson.version}
      </Text>
    </GlassView>
  );
}
