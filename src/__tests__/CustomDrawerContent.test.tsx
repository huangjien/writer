import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import { CustomDrawerContent } from '../components/CustomDrawerContent';
import { useRouter } from 'expo-router';
import { useThemeConfig } from '@/components/use-theme-config';
import { useAsyncStorage } from '@/components/useAsyncStorage';
import { TIMEOUT } from '../components/global';

// Mock dependencies
jest.mock('expo-router', () => ({
  useRouter: jest.fn(),
}));

jest.mock('@/components/use-theme-config', () => ({
  useThemeConfig: jest.fn(),
}));

jest.mock('@/components/useAsyncStorage', () => ({
  useAsyncStorage: jest.fn(),
}));

jest.mock('@/components/image', () => ({
  Image: ({ source, className, ...props }: any) => {
    const React = require('react');
    return React.createElement('View', {
      testID: 'custom-image',
      'data-source': source,
      'data-classname': className,
      ...props,
    });
  },
}));

jest.mock('@/app/images', () => ({
  images: {
    logo: 'logo-source',
    wood: 'wood-source',
  },
}));

jest.mock('@/../package.json', () => ({
  name: 'writer',
  slogan: 'Listening is the beginning of wisdom.',
  version: '1.5.10',
}));

jest.mock('@expo/vector-icons', () => ({
  Feather: ({ name, size, color, ...props }: any) => {
    const React = require('react');
    return React.createElement(
      'Text',
      {
        testID: `feather-${name}`,
        'data-testid': `feather-${name}`,
        'data-size': size,
        'data-color': color,
        ...props,
      },
      name
    );
  },
}));

jest.mock('@react-navigation/drawer', () => ({
  DrawerItem: ({ label, icon, onPress, ...props }: any) => {
    const React = require('react');
    return React.createElement(
      'div',
      {
        testID: 'drawer-item',
        onClick: onPress,
        ...props,
      },
      [
        typeof icon === 'function' ? icon() : null,
        typeof label === 'function' ? label() : label,
      ]
    );
  },
}));

// Override react-native mock for proper React Testing Library support
jest.mock('react-native', () => {
  const React = require('react');

  return {
    ScrollView: ({ children, ...props }: any) =>
      React.createElement(
        'ScrollView',
        { testID: 'scroll-view', ...props },
        children
      ),
    View: ({ children, ...props }: any) =>
      React.createElement('View', { testID: 'view', ...props }, children),
    Text: ({ children, ...props }: any) => {
      // Ensure children are properly rendered for text content queries
      return React.createElement(
        'span',
        {
          testID: 'text',
          'data-testid': 'text',
          ...props,
        },
        children
      );
    },
    TouchableOpacity: ({ children, onPress, ...props }: any) =>
      React.createElement(
        'TouchableOpacity',
        { testID: 'touchable-opacity', onPress, ...props },
        children
      ),
    Platform: { OS: 'ios' },
    StyleSheet: { create: (styles: any) => styles },
  };
});

jest.mock('@/components/global', () => ({
  TIMEOUT: 3600000, // 1 hour
}));

describe('CustomDrawerContent', () => {
  const mockPush = jest.fn();
  const mockSetSelectedTheme = jest.fn();
  const mockSetItem = jest.fn();
  const mockGetItem = jest.fn();
  const mockRemoveItem = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();

    (useRouter as jest.Mock).mockReturnValue({
      push: mockPush,
    });

    (useThemeConfig as jest.Mock).mockReturnValue({
      themeName: 'light',
      setSelectedTheme: mockSetSelectedTheme,
    });

    (useAsyncStorage as jest.Mock).mockReturnValue([
      {},
      {
        setItem: mockSetItem,
        getItem: mockGetItem,
        removeItem: mockRemoveItem,
      },
      false,
      false,
    ]);
  });

  describe('Component Rendering', () => {
    it('renders without crashing', () => {
      let renderResult;
      try {
        renderResult = render(<CustomDrawerContent />);
        console.log('Component rendered successfully');
      } catch (error) {
        console.error('Error rendering component:', error);
        throw error;
      }

      // Just check that render didn't throw an error
      expect(renderResult).toBeDefined();
    });

    it('displays app logo and information', () => {
      const { getByText } = render(<CustomDrawerContent />);

      // Check that the app name and slogan are displayed
      expect(getByText('writer')).toBeTruthy();
      expect(getByText('Listening is the beginning of wisdom.')).toBeTruthy();
    });

    it('renders all navigation items', () => {
      const { getByText } = render(<CustomDrawerContent />);

      expect(getByText('Home')).toBeTruthy();
      expect(getByText('Index')).toBeTruthy();
      expect(getByText('Read')).toBeTruthy();
      expect(getByText('Settings')).toBeTruthy();
      expect(getByText('Theme')).toBeTruthy();
      expect(getByText('Log out')).toBeTruthy();
    });

    it('renders correct icons for navigation items', () => {
      const { getByTestId } = render(<CustomDrawerContent />);

      expect(getByTestId('feather-home')).toBeTruthy();
      expect(getByTestId('feather-code')).toBeTruthy();
      expect(getByTestId('feather-play')).toBeTruthy();
      expect(getByTestId('feather-settings')).toBeTruthy();
      expect(getByTestId('feather-log-out')).toBeTruthy();
    });
  });

  describe('Navigation', () => {
    it('navigates to home when Home is pressed', () => {
      const { getByText } = render(<CustomDrawerContent />);

      fireEvent.press(getByText('Home').parent);

      expect(mockPush).toHaveBeenCalledWith('/');
    });

    it('navigates to github when Index is pressed', () => {
      const { getByText } = render(<CustomDrawerContent />);

      fireEvent.press(getByText('Index').parent);

      expect(mockPush).toHaveBeenCalledWith('/github');
    });

    it('navigates to read when Read is pressed', () => {
      const { getByText } = render(<CustomDrawerContent />);

      fireEvent.press(getByText('Read').parent);

      expect(mockPush).toHaveBeenCalledWith('/read');
    });

    it('navigates to setting when Settings is pressed', () => {
      const { getByText } = render(<CustomDrawerContent />);

      fireEvent.press(getByText('Settings').parent);

      expect(mockPush).toHaveBeenCalledWith('/setting');
    });
  });

  describe('Theme Switching', () => {
    it('displays sun icon when theme is light', () => {
      (useThemeConfig as jest.Mock).mockReturnValue({
        themeName: 'light',
        setSelectedTheme: mockSetSelectedTheme,
      });

      const { getByTestId } = render(<CustomDrawerContent />);

      expect(getByTestId('feather-sun')).toBeTruthy();
    });

    it('displays moon icon when theme is dark', () => {
      (useThemeConfig as jest.Mock).mockReturnValue({
        themeName: 'dark',
        setSelectedTheme: mockSetSelectedTheme,
      });

      const { getByTestId } = render(<CustomDrawerContent />);

      expect(getByTestId('feather-moon')).toBeTruthy();
    });

    it('switches to dark theme when light theme is active', () => {
      (useThemeConfig as jest.Mock).mockReturnValue({
        themeName: 'light',
        setSelectedTheme: mockSetSelectedTheme,
      });

      const { getByText } = render(<CustomDrawerContent />);

      fireEvent.press(getByText('Theme').parent);

      expect(mockSetSelectedTheme).toHaveBeenCalledWith('dark');
    });

    it('switches to light theme when dark theme is active', () => {
      (useThemeConfig as jest.Mock).mockReturnValue({
        themeName: 'dark',
        setSelectedTheme: mockSetSelectedTheme,
      });

      const { getByText } = render(<CustomDrawerContent />);

      fireEvent.press(getByText('Theme').parent);

      expect(mockSetSelectedTheme).toHaveBeenCalledWith('light');
    });
  });

  describe('Logout Functionality', () => {
    it('sets expired expiry when logout is pressed', () => {
      const { getByText } = render(<CustomDrawerContent />);

      const currentTime = Date.now();
      jest.spyOn(Date, 'now').mockReturnValue(currentTime);

      fireEvent.press(getByText('Log out').parent);

      expect(mockSetItem).toHaveBeenCalledWith(
        'expiry',
        (currentTime - TIMEOUT).toString()
      );

      jest.restoreAllMocks();
    });
  });

  describe('Hook Integration', () => {
    it('uses router hook correctly', () => {
      render(<CustomDrawerContent />);

      expect(useRouter).toHaveBeenCalled();
    });

    it('uses theme config hook correctly', () => {
      render(<CustomDrawerContent />);

      expect(useThemeConfig).toHaveBeenCalled();
    });

    it('uses async storage hook correctly', () => {
      render(<CustomDrawerContent />);

      expect(useAsyncStorage).toHaveBeenCalled();
    });
  });

  describe('Icon Properties', () => {
    it('renders icons with correct size and color', () => {
      const { getByTestId } = render(<CustomDrawerContent />);

      const homeIcon = getByTestId('feather-home');
      expect(homeIcon.props['data-size']).toBe(24);
      expect(homeIcon.props['data-color']).toBe('green');

      const codeIcon = getByTestId('feather-code');
      expect(codeIcon.props['data-size']).toBe(24);
      expect(codeIcon.props['data-color']).toBe('green');
    });
  });

  describe('Empty Drawer Item', () => {
    it('renders empty drawer item as spacer', () => {
      const { getByTestId } = render(<CustomDrawerContent />);

      // Check that scroll view exists (basic structure test)
      expect(getByTestId('scroll-view')).toBeTruthy();
    });
  });

  describe('Accessibility', () => {
    it('provides proper structure for screen readers', () => {
      const { getByTestId } = render(<CustomDrawerContent />);

      // Check that main container exists
      expect(getByTestId('scroll-view')).toBeTruthy();

      // Check that drawer items are accessible
      expect(getByTestId('feather-home')).toBeTruthy();
      expect(getByTestId('feather-code')).toBeTruthy();
    });
  });

  describe('Theme Integration', () => {
    it('handles different theme names correctly', () => {
      // Test with undefined theme name
      (useThemeConfig as jest.Mock).mockReturnValue({
        themeName: undefined,
        setSelectedTheme: mockSetSelectedTheme,
      });

      const { getByTestId } = render(<CustomDrawerContent />);

      // Should default to sun icon when theme name is not 'dark'
      expect(getByTestId('feather-sun')).toBeTruthy();
    });

    it('handles custom theme names', () => {
      (useThemeConfig as jest.Mock).mockReturnValue({
        themeName: 'custom',
        setSelectedTheme: mockSetSelectedTheme,
      });

      const { getByText } = render(<CustomDrawerContent />);

      // Should have theme option available
      expect(getByText('Theme')).toBeTruthy();

      // Should switch to dark when pressed (custom theme is treated as non-dark)
      fireEvent.press(getByText('Theme').parent);
      expect(mockSetSelectedTheme).toHaveBeenCalledWith('dark');
    });
  });
});
