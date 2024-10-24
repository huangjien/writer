import type { Theme } from '@react-navigation/native';
import {
  DarkTheme as _DarkTheme,
  DefaultTheme,
} from '@react-navigation/native';
import { useColorScheme } from 'nativewind';

import colors from './colors';
import { useState } from 'react';

const DarkTheme: Theme = {
  ..._DarkTheme,
  colors: {
    ..._DarkTheme.colors,
    primary: colors.primary[200],
    background: colors.charcoal[950],
    text: colors.charcoal[100],
    border: colors.charcoal[500],
    card: colors.charcoal[850],
  },
};

const LightTheme: Theme = {
  ...DefaultTheme,
  colors: {
    ...DefaultTheme.colors,
    primary: colors.primary[400],
    background: colors.white,
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

  const setSelectedTheme = (t) => {
    setColorScheme(t);
    _setTheme(t);
    setThemeName(t);
  };
  return { theme, themeName, setSelectedTheme };
}
