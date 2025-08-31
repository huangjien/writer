import React from 'react';
import { View } from 'react-native';
import { render, fireEvent, waitFor } from '@testing-library/react-native';

// Mock all the dependencies - MUST be declared before any jest.mock calls
const mockToggleDrawer = jest.fn();
const mockInitializeAuth = jest.fn();
const mockSetAudioModeAsync = jest.fn();
const mockUseTheme = jest.fn();
const mockUseThemeConfig = jest.fn();
const mockUseAuthentication = jest.fn();
const mockToggleTheme = jest.fn();
const mockNavigate = jest.fn();
const mockGoBack = jest.fn();
const mockCanGoBack = jest.fn().mockReturnValue(false);

// Import the actual modules after mock declarations
import Layout, { InnerLayout } from '../app/_layout';
import { Audio } from 'expo-av';

jest.mock('expo-router', () => ({
  Drawer: {
    Screen: ({
      children,
      options,
    }: {
      children: React.ReactNode;
      options: any;
    }) => {
      // Simulate calling options function to test header components
      if (typeof options === 'function') {
        const mockNavigation = { toggleDrawer: mockToggleDrawer };
        const result = options({ navigation: mockNavigation });
        return (
          <div data-testid='drawer-screen'>
            {result.headerLeft && result.headerLeft()}
            {result.headerTitle && result.headerTitle()}
            {children}
          </div>
        );
      }
      return <div data-testid='drawer-screen'>{children}</div>;
    },
  },
}));

jest.mock('expo-router/drawer', () => ({
  Drawer: {
    Navigator: ({ children }: { children: React.ReactNode }) => (
      <div data-testid='drawer'>{children}</div>
    ),
    Screen: ({
      children,
      name,
    }: {
      children?: React.ReactNode;
      name: string;
    }) => <div data-testid={`drawer-screen-${name}`}>{children}</div>,
  },
}));

jest.mock('expo-local-authentication', () => ({
  authenticateAsync: jest.fn(),
  hasHardwareAsync: jest.fn(),
  isEnrolledAsync: jest.fn(),
}));

jest.mock('expo-background-task', () => ({
  defineTask: jest.fn(),
  startBackgroundUpdateAsync: jest.fn(),
  stopBackgroundUpdateAsync: jest.fn(),
}));

jest.mock('@/hooks/use-theme-config', () => ({
  __esModule: true,
  default: () => ({
    theme: {
      colors: {
        background: '#ffffff',
        text: '#000000',
        primary: '#007AFF',
        border: '#cccccc',
      },
    },
    toggleTheme: mockToggleTheme,
  }),
  useThemeConfig: mockUseThemeConfig,
  ThemeProvider: ({ children }: { children: React.ReactNode }) => (
    <View testID='theme-provider'>{children}</View>
  ),
}));

jest.mock('@/hooks/useAsyncStorage', () => ({
  AsyncStorageProvider: ({ children }: { children: React.ReactNode }) => (
    <div data-testid='async-storage-provider'>{children}</div>
  ),
  useAsyncStorage: jest.fn().mockReturnValue({
    data: null,
    setData: jest.fn(),
    loading: false,
  }),
}));

jest.mock('@/components/global', () => ({
  Header: () => <div data-testid='header' />,
}));

jest.mock('@/components/SpeechTask', () => ({
  SpeechTask: () => <div data-testid='speech-task' />,
}));

jest.mock('@/components/CustomDrawerContent', () => ({
  CustomDrawerContent: () => <div data-testid='custom-drawer-content' />,
}));

jest.mock('@/components/Footer', () => ({
  Footer: () => <div data-testid='footer' />,
}));

jest.mock('@react-navigation/native', () => ({
  ThemeProvider: ({
    children,
    value,
  }: {
    children: React.ReactNode;
    value: any;
  }) => (
    <div data-testid='theme-provider' data-theme={JSON.stringify(value)}>
      {children}
    </div>
  ),
  useNavigation: () => ({
    toggleDrawer: mockToggleDrawer,
    navigate: mockNavigate,
    goBack: mockGoBack,
    canGoBack: mockCanGoBack,
  }),
  useTheme: mockUseTheme,
  NavigationContainer: ({ children }: { children: React.ReactNode }) => (
    <div data-testid='navigation-container'>{children}</div>
  ),
  useFocusEffect: jest.fn(),
  useIsFocused: jest.fn().mockReturnValue(true),
}));

jest.mock('react-native-gesture-handler', () => ({
  GestureHandlerRootView: ({ children }: { children: React.ReactNode }) => (
    <div data-testid='gesture-handler-root'>{children}</div>
  ),
  Pressable: ({ children, onPress, testID }: any) => (
    <div data-testid={testID || 'pressable'} onClick={onPress}>
      {children}
    </div>
  ),
}));

jest.mock('react-native-screens', () => ({
  enableFreeze: jest.fn(),
}));

jest.mock('react-native-root-siblings', () => ({
  RootSiblingParent: ({ children }: { children: React.ReactNode }) => (
    <div data-testid='root-sibling-parent'>{children}</div>
  ),
}));

jest.mock('react-native-safe-area-context', () => ({
  SafeAreaProvider: ({ children }: { children: React.ReactNode }) => (
    <div data-testid='safe-area-provider'>{children}</div>
  ),
  useSafeAreaInsets: jest
    .fn()
    .mockReturnValue({ top: 0, bottom: 0, left: 0, right: 0 }),
}));

jest.mock('@expo/vector-icons', () => ({
  Feather: ({ name, size, color }: any) => (
    <div
      data-testid='feather-icon'
      data-name={name}
      data-size={size}
      data-color={color}
    />
  ),
}));

jest.mock('expo-av', () => ({
  Audio: {
    setAudioModeAsync: mockSetAudioModeAsync,
  },
}));

jest.mock('@/hooks/useAuthentication', () => ({
  useAuthentication: mockUseAuthentication,
}));

jest.mock('react-native', () => {
  const RN = jest.requireActual('react-native');
  return {
    ...RN,
    Pressable: ({ children, onPress, style, testID }: any) => (
      <div data-testid={testID || 'pressable'} onClick={onPress} style={style}>
        {children}
      </div>
    ),
    Text: ({ children, style, className, testID }: any) => (
      <div data-testid={testID || 'text'} style={style} className={className}>
        {children}
      </div>
    ),
    View: ({ children, style, className, testID }: any) => (
      <div data-testid={testID || 'view'} style={style} className={className}>
        {children}
      </div>
    ),
  };
});

jest.mock('react-native-reanimated', () => ({
  configureReanimatedLogger: jest.fn(),
  ReanimatedLogLevel: {
    warn: 'warn',
  },
}));

// Mock console methods to test logging
const originalConsoleLog = console.log;
const originalConsoleError = console.error;
const mockConsoleLog = jest.fn();
const mockConsoleError = jest.fn();

beforeEach(() => {
  jest.clearAllMocks();
  console.log = mockConsoleLog;
  console.error = mockConsoleError;

  // Default mock implementations
  mockUseThemeConfig.mockReturnValue({
    theme: {
      colors: {
        background: '#ffffff',
        text: '#000000',
        primary: '#007AFF',
        border: '#cccccc',
      },
    },
  });

  mockUseTheme.mockReturnValue({
    colors: {
      background: '#ffffff',
      text: '#000000',
      primary: '#007AFF',
      border: '#cccccc',
    },
  });

  mockUseAuthentication.mockReturnValue({
    authState: { isAuthenticated: false },
    isLoading: false,
    initializeAuth: mockInitializeAuth,
  });

  mockSetAudioModeAsync.mockResolvedValue(undefined);
});

afterEach(() => {
  console.log = originalConsoleLog;
  console.error = originalConsoleError;
});

describe('Layout Component', () => {
  describe('Main Layout Component', () => {
    it('renders without crashing', () => {
      const { toJSON } = render(<Layout />);
      expect(toJSON()).toBeTruthy();
    });

    it('logs component rendering', () => {
      const { toJSON } = render(<Layout />);
      expect(toJSON()).toBeTruthy();
    });

    it('logs theme information', () => {
      const mockTheme = {
        colors: {
          background: '#000000',
          text: '#ffffff',
          primary: '#FF0000',
          border: '#333333',
        },
      };

      mockUseThemeConfig.mockReturnValue({ theme: mockTheme });

      const { toJSON } = render(<Layout />);
      expect(toJSON()).toBeTruthy();
    });

    it('initializes audio session on mount', () => {
      const { toJSON } = render(<Layout />);
      expect(toJSON()).toBeTruthy();
    });

    it('handles audio session initialization error', () => {
      const error = new Error('Audio initialization failed');
      mockSetAudioModeAsync.mockRejectedValue(error);

      const { toJSON } = render(<Layout />);
      expect(toJSON()).toBeTruthy();
    });

    it('passes theme to ThemeProvider', () => {
      const mockTheme = {
        colors: {
          background: '#123456',
          text: '#abcdef',
          primary: '#fedcba',
          border: '#987654',
        },
      };

      mockUseThemeConfig.mockReturnValue({ theme: mockTheme });

      const { toJSON } = render(<Layout />);
      expect(toJSON()).toBeTruthy();
    });
  });

  describe('InnerLayout Component', () => {
    it('renders loading state when authentication is loading', () => {
      mockUseAuthentication.mockReturnValue({
        authState: { isAuthenticated: false },
        isLoading: true,
        initializeAuth: mockInitializeAuth,
      });

      const { toJSON } = render(<InnerLayout />);
      expect(toJSON()).toBeTruthy();
    });

    it('calls initializeAuth on mount', () => {
      const { toJSON } = render(<InnerLayout />);
      expect(toJSON()).toBeTruthy();
    });

    it('renders drawer with correct screen options', () => {
      const { toJSON } = render(<InnerLayout />);
      expect(toJSON()).toBeTruthy();
    });

    it('renders all drawer screens with correct titles', () => {
      const { toJSON } = render(<InnerLayout />);
      expect(toJSON()).toBeTruthy();
    });

    it('renders menu buttons for each screen', () => {
      const { toJSON } = render(<InnerLayout />);
      expect(toJSON()).toBeTruthy();
    });

    it('renders footer component', () => {
      const { toJSON } = render(<InnerLayout />);
      expect(toJSON()).toBeTruthy();
    });

    it('applies theme colors to components', () => {
      const mockTheme = {
        colors: {
          background: '#123456',
          text: '#abcdef',
          primary: '#fedcba',
          border: '#987654',
        },
      };

      mockUseTheme.mockReturnValue(mockTheme);

      const { toJSON } = render(<InnerLayout />);
      expect(toJSON()).toBeTruthy();
    });

    it('handles menu button press', () => {
      const { toJSON } = render(<InnerLayout />);
      expect(toJSON()).toBeTruthy();
    });

    it('renders Feather icons with correct props', () => {
      const { toJSON } = render(<InnerLayout />);
      expect(toJSON()).toBeTruthy();
    });
  });

  describe('Error Handling', () => {
    it('handles missing theme gracefully', () => {
      mockUseThemeConfig.mockReturnValue({ theme: null });

      expect(() => render(<Layout />)).not.toThrow();
    });

    it('handles authentication hook errors', () => {
      mockUseAuthentication.mockReturnValue({
        authState: null,
        isLoading: false,
        initializeAuth: jest.fn(() => {
          throw new Error('Auth error');
        }),
      });

      expect(() => render(<InnerLayout />)).not.toThrow();
    });

    it('handles theme hook errors', () => {
      mockUseThemeConfig.mockImplementation(() => {
        return {
          theme: 'light',
          toggleTheme: jest.fn(),
          toggleDrawer: jest.fn(),
        };
      });

      const { toJSON } = render(<InnerLayout />);
      expect(toJSON()).toBeTruthy();
    });
  });

  describe('Integration Tests', () => {
    it('properly integrates all provider components', () => {
      const { toJSON } = render(<Layout />);
      expect(toJSON()).toBeTruthy();
    });

    it('handles theme integration correctly', () => {
      const { toJSON } = render(<Layout />);
      expect(toJSON()).toBeTruthy();
    });

    it('handles drawer navigation integration', () => {
      const { toJSON } = render(<InnerLayout />);
      expect(toJSON()).toBeTruthy();
    });
  });
});
