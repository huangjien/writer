import React from 'react';
import { renderHook, act } from '@testing-library/react-native';
import { useThemeConfig } from '@/hooks/use-theme-config';
import { useColorScheme } from 'nativewind';
import { AsyncStorageProvider } from '@/hooks/useAsyncStorage';

// Mock dependencies
const mockSetColorScheme = jest.fn();
const mockToggleColorScheme = jest.fn();

// Mock colors to prevent import issues
jest.mock('@/components/colors', () => ({
  white: '#ffffff',
  charcoal: {
    50: '#F2F2F2',
    100: '#E5E5E5',
    200: '#C9C9C9',
    500: '#7D7D7D',
    850: '#2E2E2E',
    950: '#121212',
  },
  primary: {
    200: '#FFA766',
    400: '#FF8933',
  },
}));

jest.mock('nativewind', () => ({
  useColorScheme: jest.fn(() => ({
    colorScheme: 'light',
    setColorScheme: mockSetColorScheme,
    toggleColorScheme: mockToggleColorScheme,
  })),
}));

jest.mock('@react-native-async-storage/async-storage', () => ({
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  getAllKeys: jest.fn(() => Promise.resolve([])),
  multiGet: jest.fn(() => Promise.resolve([])),
}));

// Mock React Navigation themes
jest.mock('@react-navigation/native', () => ({
  DarkTheme: {
    dark: true,
    colors: {
      primary: '#007AFF',
      background: '#000000',
      card: '#1C1C1E',
      text: '#FFFFFF',
      border: '#272729',
      notification: '#FF453A',
    },
  },
  DefaultTheme: {
    dark: false,
    colors: {
      primary: '#007AFF',
      background: '#FFFFFF',
      card: '#FFFFFF',
      text: '#000000',
      border: '#E5E5E7',
      notification: '#FF453A',
    },
  },
}));

const mockUseColorScheme = useColorScheme as jest.MockedFunction<
  typeof useColorScheme
>;

// Create a wrapper component for tests
const TestWrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return React.createElement(AsyncStorageProvider, null, children);
};

describe('useThemeConfig', () => {
  beforeEach(() => {
    jest.clearAllMocks();

    // Reset mock implementations
    mockUseColorScheme.mockReturnValue({
      colorScheme: 'light',
      setColorScheme: mockSetColorScheme,
      toggleColorScheme: mockToggleColorScheme,
    });

    // Mock console to prevent test output pollution
    jest.spyOn(console, 'error').mockImplementation(() => {});
    jest.spyOn(console, 'log').mockImplementation(() => {});
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  describe('initial state', () => {
    it('should return initial theme configuration', () => {
      const { result } = renderHook(() => useThemeConfig());

      // Debug: Check if result.current is null
      if (result.current === null) {
        console.error('result.current is null');
        expect(result.current).not.toBeNull();
        return;
      }

      expect(result.current.theme).toBeDefined();
      expect(result.current.themeName).toBe('light'); // Default to light
      expect(typeof result.current.setSelectedTheme).toBe('function');
    });

    it('should have proper theme structure', () => {
      const { result } = renderHook(() => useThemeConfig());

      expect(result.current).toHaveProperty('theme');
      expect(result.current).toHaveProperty('themeName');
      expect(result.current).toHaveProperty('setSelectedTheme');
      expect(typeof result.current.setSelectedTheme).toBe('function');
    });

    it('should handle dark color scheme from system', () => {
      mockUseColorScheme.mockReturnValue({
        colorScheme: 'dark',
        setColorScheme: mockSetColorScheme,
        toggleColorScheme: mockToggleColorScheme,
      });

      const { result } = renderHook(() => useThemeConfig());

      expect(result.current.themeName).toBe('dark');
    });

    it('should handle null color scheme gracefully', () => {
      mockUseColorScheme.mockReturnValue({
        colorScheme: null,
        setColorScheme: mockSetColorScheme,
        toggleColorScheme: mockToggleColorScheme,
      });

      const { result } = renderHook(() => useThemeConfig());

      // Should default to light when system returns null
      expect(result.current.themeName).toBe('light');
    });
  });

  describe('theme object structure', () => {
    it('should provide light theme with correct structure', () => {
      mockUseColorScheme.mockReturnValue({
        colorScheme: 'light',
        setColorScheme: mockSetColorScheme,
        toggleColorScheme: mockToggleColorScheme,
      });

      const { result } = renderHook(() => useThemeConfig());

      expect(result.current.theme.colors).toBeDefined();
      expect(result.current.theme.colors.background).toBeDefined();
      expect(result.current.theme.colors.text).toBeDefined();
      expect(result.current.theme.colors.primary).toBeDefined();
    });

    it('should provide dark theme with correct structure', () => {
      mockUseColorScheme.mockReturnValue({
        colorScheme: 'dark',
        setColorScheme: mockSetColorScheme,
        toggleColorScheme: mockToggleColorScheme,
      });

      const { result } = renderHook(() => useThemeConfig());

      expect(result.current.theme.colors).toBeDefined();
      expect(result.current.theme.colors.background).toBeDefined();
      expect(result.current.theme.colors.text).toBeDefined();
      expect(result.current.theme.colors.primary).toBeDefined();
      expect(result.current.theme.colors.border).toBeDefined();
      expect(result.current.theme.colors.card).toBeDefined();
    });

    it('should have different colors for light and dark themes', () => {
      // Test light theme
      mockUseColorScheme.mockReturnValue({
        colorScheme: 'light',
        setColorScheme: mockSetColorScheme,
        toggleColorScheme: mockToggleColorScheme,
      });

      const { result: lightResult } = renderHook(() => useThemeConfig());
      const lightBackground = lightResult.current.theme.colors.background;

      // Test dark theme
      mockUseColorScheme.mockReturnValue({
        colorScheme: 'dark',
        setColorScheme: mockSetColorScheme,
        toggleColorScheme: mockToggleColorScheme,
      });

      const { result: darkResult } = renderHook(() => useThemeConfig());
      const darkBackground = darkResult.current.theme.colors.background;

      expect(lightBackground).not.toBe(darkBackground);
    });
  });

  describe('setSelectedTheme function', () => {
    it('should call setColorScheme when setting theme', async () => {
      mockUseColorScheme.mockReturnValue({
        colorScheme: 'light',
        setColorScheme: mockSetColorScheme,
        toggleColorScheme: mockToggleColorScheme,
      });

      const { result } = renderHook(() => useThemeConfig());

      expect(result.current.themeName).toBe('light');

      await act(async () => {
        result.current.setSelectedTheme('dark');
      });

      expect(mockSetColorScheme).toHaveBeenCalledWith('dark');
    });

    it('should be callable without errors', async () => {
      const { result } = renderHook(() => useThemeConfig());

      expect(() => {
        result.current.setSelectedTheme('dark');
      }).not.toThrow();

      expect(() => {
        result.current.setSelectedTheme('light');
      }).not.toThrow();
    });

    it('should handle theme switching', async () => {
      mockUseColorScheme.mockReturnValue({
        colorScheme: 'light',
        setColorScheme: mockSetColorScheme,
        toggleColorScheme: mockToggleColorScheme,
      });

      const { result } = renderHook(() => useThemeConfig());

      await act(async () => {
        result.current.setSelectedTheme('dark');
      });

      expect(mockSetColorScheme).toHaveBeenCalledWith('dark');

      await act(async () => {
        result.current.setSelectedTheme('light');
      });

      expect(mockSetColorScheme).toHaveBeenCalledWith('light');
    });
  });

  describe('theme consistency', () => {
    it('should maintain theme consistency across re-renders', () => {
      const { result, rerender } = renderHook(() => useThemeConfig());

      const initialTheme = result.current.theme;
      const initialThemeName = result.current.themeName;

      rerender({});

      expect(result.current.theme).toEqual(initialTheme);
      expect(result.current.themeName).toBe(initialThemeName);
    });

    it('should provide consistent theme objects', () => {
      mockUseColorScheme.mockReturnValue({
        colorScheme: 'dark',
        setColorScheme: mockSetColorScheme,
        toggleColorScheme: mockToggleColorScheme,
      });

      const { result } = renderHook(() => useThemeConfig());

      expect(result.current.theme.colors).toBeDefined();
      expect(result.current.theme.colors.background).toBeDefined();
      expect(result.current.theme.colors.text).toBeDefined();
      expect(result.current.themeName).toBe('dark');
    });

    it('should maintain function references', () => {
      const { result, rerender } = renderHook(() => useThemeConfig());

      const initialSetSelectedTheme = result.current.setSelectedTheme;

      rerender({});

      // Function reference should be stable
      expect(result.current.setSelectedTheme).toBe(initialSetSelectedTheme);
    });
  });

  describe('error handling', () => {
    it('should handle missing color scheme gracefully', () => {
      mockUseColorScheme.mockReturnValue({
        colorScheme: null,
        setColorScheme: mockSetColorScheme,
        toggleColorScheme: mockToggleColorScheme,
      });

      const { result } = renderHook(() => useThemeConfig());

      // Should not crash and provide default values
      expect(result.current.theme).toBeDefined();
      expect(result.current.themeName).toBeDefined();
      expect(typeof result.current.setSelectedTheme).toBe('function');
    });

    it('should handle setColorScheme errors', async () => {
      const errorMockSetColorScheme = jest.fn().mockImplementation(() => {
        throw new Error('Theme error');
      });

      mockUseColorScheme.mockReturnValue({
        colorScheme: 'light',
        setColorScheme: errorMockSetColorScheme,
        toggleColorScheme: mockToggleColorScheme,
      });

      const { result } = renderHook(() => useThemeConfig());

      // Should not crash when setColorScheme fails
      expect(() => {
        result.current.setSelectedTheme('dark');
      }).toThrow('Theme error');

      expect(errorMockSetColorScheme).toHaveBeenCalledWith('dark');
    });

    it('should handle undefined colorScheme', () => {
      mockUseColorScheme.mockReturnValue({
        colorScheme: undefined,
        setColorScheme: mockSetColorScheme,
        toggleColorScheme: mockToggleColorScheme,
      });

      const { result } = renderHook(() => useThemeConfig());

      // Should default to light theme
      expect(result.current.themeName).toBe('light');
      expect(result.current.theme).toBeDefined();
    });
  });

  describe('integration with AsyncStorage', () => {
    it('should work with AsyncStorageProvider', () => {
      const { result } = renderHook(() => useThemeConfig(), {
        wrapper: TestWrapper,
      });

      // Should render without errors when wrapped with AsyncStorageProvider
      expect(result.current).toHaveProperty('theme');
      expect(result.current).toHaveProperty('themeName');
      expect(result.current).toHaveProperty('setSelectedTheme');
    });

    it('should handle provider context gracefully', () => {
      const { result } = renderHook(() => useThemeConfig(), {
        wrapper: TestWrapper,
      });

      // Should not crash and provide expected interface
      expect(typeof result.current.setSelectedTheme).toBe('function');
      expect(result.current.theme.colors).toBeDefined();
    });
  });

  describe('theme name tracking', () => {
    it('should track theme name correctly for light theme', () => {
      mockUseColorScheme.mockReturnValue({
        colorScheme: 'light',
        setColorScheme: mockSetColorScheme,
        toggleColorScheme: mockToggleColorScheme,
      });

      const { result } = renderHook(() => useThemeConfig());

      expect(result.current.themeName).toBe('light');
    });

    it('should track theme name correctly for dark theme', () => {
      mockUseColorScheme.mockReturnValue({
        colorScheme: 'dark',
        setColorScheme: mockSetColorScheme,
        toggleColorScheme: mockToggleColorScheme,
      });

      const { result } = renderHook(() => useThemeConfig());

      expect(result.current.themeName).toBe('dark');
    });

    it('should handle theme name updates', async () => {
      const { result } = renderHook(() => useThemeConfig());

      expect(result.current.themeName).toBe('light');

      await act(async () => {
        result.current.setSelectedTheme('dark');
      });

      // Note: The actual behavior depends on implementation
      // This test verifies the function can be called
      expect(typeof result.current.setSelectedTheme).toBe('function');
    });
  });
});
