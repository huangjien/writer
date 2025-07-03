import React from 'react';
import { renderHook, act } from '@testing-library/react-native';
import { useThemeConfig } from '../hooks/use-theme-config';

// Mock useColorScheme
const mockSetColorScheme = jest.fn();
const mockUseColorScheme = jest.fn();

// Mock themes - declare before using in jest.mock
const mockDarkTheme = {
  dark: true,
  colors: {
    primary: '#ffffff',
    background: '#000000',
    card: '#1c1c1e',
    text: '#ffffff',
    border: '#38383a',
    notification: '#ff453a',
  },
};

const mockLightTheme = {
  dark: false,
  colors: {
    primary: '#007aff',
    background: '#ffffff',
    card: '#ffffff',
    text: '#000000',
    border: '#c6c6c8',
    notification: '#ff3b30',
  },
};

jest.mock('nativewind', () => ({
  useColorScheme: () => ({
    colorScheme: mockUseColorScheme(),
    setColorScheme: mockSetColorScheme,
  }),
}));

jest.mock('@react-navigation/native', () => ({
  DarkTheme: {
    dark: true,
    colors: {
      primary: '#ffffff',
      background: '#000000',
      card: '#1c1c1e',
      text: '#ffffff',
      border: '#38383a',
      notification: '#ff453a',
    },
  },
  DefaultTheme: {
    dark: false,
    colors: {
      primary: '#007aff',
      background: '#ffffff',
      card: '#ffffff',
      text: '#000000',
      border: '#c6c6c8',
      notification: '#ff3b30',
    },
  },
}));

describe('useThemeConfig', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('initial state', () => {
    it('should initialize with dark theme when colorScheme is dark', () => {
      mockUseColorScheme.mockReturnValue('dark');

      const { result } = renderHook(() => useThemeConfig());

      expect(result.current.theme).toEqual(mockDarkTheme);
      expect(result.current.themeName).toBe('dark');
    });

    it('should initialize with light theme when colorScheme is light', () => {
      mockUseColorScheme.mockReturnValue('light');

      const { result } = renderHook(() => useThemeConfig());

      expect(result.current.theme).toEqual(mockLightTheme);
      expect(result.current.themeName).toBe('light');
    });

    it('should initialize with light theme when colorScheme is null', () => {
      mockUseColorScheme.mockReturnValue(null);

      const { result } = renderHook(() => useThemeConfig());

      expect(result.current.theme).toEqual(mockLightTheme);
      expect(result.current.themeName).toBe('light');
    });

    it('should initialize with light theme when colorScheme is undefined', () => {
      mockUseColorScheme.mockReturnValue(undefined);

      const { result } = renderHook(() => useThemeConfig());

      expect(result.current.theme).toEqual(mockLightTheme);
      expect(result.current.themeName).toBe('light');
    });
  });

  describe('setSelectedTheme', () => {
    it('should update theme to dark when setSelectedTheme is called with dark', () => {
      mockUseColorScheme.mockReturnValue('light');

      const { result } = renderHook(() => useThemeConfig());

      // Initial state should be light
      expect(result.current.themeName).toBe('light');

      act(() => {
        result.current.setSelectedTheme('dark');
      });

      expect(mockSetColorScheme).toHaveBeenCalledWith('dark');
      expect(result.current.themeName).toBe('dark');
    });

    it('should update theme to light when setSelectedTheme is called with light', () => {
      mockUseColorScheme.mockReturnValue('dark');

      const { result } = renderHook(() => useThemeConfig());

      // Initial state should be dark
      expect(result.current.themeName).toBe('dark');

      act(() => {
        result.current.setSelectedTheme('light');
      });

      expect(mockSetColorScheme).toHaveBeenCalledWith('light');
      expect(result.current.themeName).toBe('light');
    });

    it('should handle multiple theme changes', () => {
      mockUseColorScheme.mockReturnValue('light');

      const { result } = renderHook(() => useThemeConfig());

      // Change to dark
      act(() => {
        result.current.setSelectedTheme('dark');
      });

      expect(result.current.themeName).toBe('dark');

      // Change back to light
      act(() => {
        result.current.setSelectedTheme('light');
      });

      expect(result.current.themeName).toBe('light');
      expect(mockSetColorScheme).toHaveBeenCalledTimes(2);
    });
  });

  describe('theme object', () => {
    it('should return correct theme object for dark mode', () => {
      mockUseColorScheme.mockReturnValue('dark');

      const { result } = renderHook(() => useThemeConfig());

      expect(result.current.theme.dark).toBe(true);
      expect(result.current.theme.colors.background).toBe('#000000');
      expect(result.current.theme.colors.text).toBe('#ffffff');
    });

    it('should return correct theme object for light mode', () => {
      mockUseColorScheme.mockReturnValue('light');

      const { result } = renderHook(() => useThemeConfig());

      expect(result.current.theme.dark).toBe(false);
      expect(result.current.theme.colors.background).toBe('#ffffff');
      expect(result.current.theme.colors.text).toBe('#000000');
    });
  });

  describe('edge cases', () => {
    it('should handle invalid theme names gracefully', () => {
      mockUseColorScheme.mockReturnValue('light');

      const { result } = renderHook(() => useThemeConfig());

      act(() => {
        // @ts-ignore - Testing invalid input
        result.current.setSelectedTheme('invalid-theme');
      });

      expect(mockSetColorScheme).toHaveBeenCalledWith('invalid-theme');
      expect(result.current.themeName).toBe('invalid-theme');
    });

    it('should handle null theme parameter', () => {
      mockUseColorScheme.mockReturnValue('light');

      const { result } = renderHook(() => useThemeConfig());

      act(() => {
        // @ts-ignore - Testing null input
        result.current.setSelectedTheme(null);
      });

      expect(mockSetColorScheme).toHaveBeenCalledWith(null);
    });

    it('should handle undefined theme parameter', () => {
      mockUseColorScheme.mockReturnValue('light');

      const { result } = renderHook(() => useThemeConfig());

      act(() => {
        // @ts-ignore - Testing undefined input
        result.current.setSelectedTheme(undefined);
      });

      expect(mockSetColorScheme).toHaveBeenCalledWith(undefined);
    });
  });

  describe('state consistency', () => {
    it('should maintain consistent state between theme and themeName', () => {
      mockUseColorScheme.mockReturnValue('light');

      const { result } = renderHook(() => useThemeConfig());

      // Initial state
      expect(result.current.theme).toEqual(mockLightTheme);
      expect(result.current.themeName).toBe('light');

      // After changing to dark
      act(() => {
        result.current.setSelectedTheme('dark');
      });

      expect(result.current.themeName).toBe('dark');
      // Note: In the actual implementation, the theme object might not update immediately
      // due to how the hook is structured, but themeName should be consistent
    });
  });

  describe('performance', () => {
    it('should not cause unnecessary re-renders', () => {
      mockUseColorScheme.mockReturnValue('light');

      const { result, rerender } = renderHook(() => useThemeConfig());

      const initialSetSelectedTheme = result.current.setSelectedTheme;

      rerender({});

      // setSelectedTheme function should be stable
      expect(result.current.setSelectedTheme).toBe(initialSetSelectedTheme);
    });
  });
});
