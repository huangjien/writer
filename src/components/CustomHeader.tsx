import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { DrawerHeaderProps } from '@react-navigation/drawer';
import { useTheme } from '@react-navigation/native';
import { Ionicons } from '@expo/vector-icons';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { useColorScheme } from 'nativewind';
import { GlassHeader } from './GlassComponents';

export default function CustomHeader({
  navigation,
  options,
}: DrawerHeaderProps) {
  const theme = useTheme();
  const insets = useSafeAreaInsets();
  const { colorScheme } = useColorScheme();
  const isDark = colorScheme === 'dark';

  return (
    <GlassHeader
      className={`flex-row items-center justify-between px-4 py-3 border-b ${
        isDark ? 'border-glass-borderDark' : 'border-glass-border'
      }`}
      style={{
        paddingTop: insets.top + 12,
      }}
    >
      <TouchableOpacity
        onPress={() => navigation.openDrawer()}
        className={`p-2 rounded-lg glass-effect ${
          isDark
            ? 'bg-glass-lightDark border-glass-borderDark'
            : 'bg-glass-light border-glass-border'
        }`}
        style={{
          shadowColor: isDark ? '#000000' : '#1f2687',
          shadowOffset: { width: 0, height: 2 },
          shadowOpacity: isDark ? 0.2 : 0.25,
          shadowRadius: 8,
          elevation: 3,
        }}
      >
        <Ionicons
          name='menu'
          size={24}
          color={isDark ? '#f1f5f9' : '#334155'}
          style={{
            textShadowColor: isDark
              ? 'rgba(0, 0, 0, 0.3)'
              : 'rgba(255, 255, 255, 0.8)',
            textShadowOffset: { width: 0, height: 1 },
            textShadowRadius: 2,
          }}
        />
      </TouchableOpacity>

      <Text
        className={`text-lg font-semibold ${
          isDark ? 'text-slate-100' : 'text-slate-800'
        }`}
        style={{
          textShadowColor: isDark
            ? 'rgba(0, 0, 0, 0.3)'
            : 'rgba(255, 255, 255, 0.8)',
          textShadowOffset: { width: 0, height: 1 },
          textShadowRadius: 2,
        }}
      >
        {options.title || 'Writer'}
      </Text>

      <View className='w-10' />
    </GlassHeader>
  );
}
