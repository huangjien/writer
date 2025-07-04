import type { Theme } from '@react-navigation/native';
import {
  DarkTheme as _DarkTheme,
  DefaultTheme,
} from '@react-navigation/native';
import { useColorScheme } from 'nativewind';

import colors from '@/components/colors';
import { useState } from 'react';

const DarkTheme: Theme = {
  ..._DarkTheme,
  colors: {
    ..._DarkTheme.colors,
    primary: colors.primary[200],
    background: colors.charcoal[950],
    text: colors.charcoal[100],
    border: colors.charcoal[500],
    card: 'transparent',
  },
};

const LightTheme: Theme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    primary: colors.primary[400],
    background: colors.white,
    card: 'transparent',
  },
};

export function useThemeConfig() {
  const { colorScheme, setColorScheme } = useColorScheme();
  const [theme, _setTheme] = useState(
    colorScheme === 'dark' ? DarkTheme : LightTheme
  );
  const [themeName, setThemeName] = useState(
    colorScheme === 'dark' ? 'dark' : 'light'
  );

  const setSelectedTheme = (themeName: 'light' | 'dark') => {
    setColorScheme(themeName);
    const newTheme = themeName === 'dark' ? DarkTheme : LightTheme;
    _setTheme(newTheme);
    setThemeName(themeName);
  };
  return { theme, themeName, setSelectedTheme };
}
