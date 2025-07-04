import React from 'react';
import { render } from '@testing-library/react-native';
import { Text, View } from 'react-native';
import Layout from '../app/_layout';
import { useThemeConfig } from '@/hooks/use-theme-config';
import { useAsyncStorage } from '@/hooks/useAsyncStorage';

// Mock CSS import
jest.mock('../global.css', () => ({}));

// Mock all dependencies
jest.mock('expo-router', () => ({
  SplashScreen: {
    preventAutoHideAsync: jest.fn(),
    hideAsync: jest.fn().mockResolvedValue(undefined),
  },
}));

jest.mock('expo-local-authentication', () => ({
  hasHardwareAsync: jest.fn(),
  isEnrolledAsync: jest.fn(),
  authenticateAsync: jest.fn(),
}));

jest.mock('expo-background-task', () => ({
  registerTaskAsync: jest.fn(),
  unregisterTaskAsync: jest.fn(),
  getStatusAsync: jest.fn(),
  BackgroundTaskStatus: {
    Available: 1,
    Denied: 2,
    Restricted: 3,
  },
}));

jest.mock('@/hooks/use-theme-config', () => ({
  useThemeConfig: jest.fn(),
}));

// Create a mock context that provides the useAsyncStorage hook
const mockAsyncStorageContext = {
  storage: {},
  operations: {
    getItem: jest.fn(),
    setItem: jest.fn(),
    removeItem: jest.fn(),
  },
  isLoading: false,
  hasChanged: 0,
};

jest.mock('@/hooks/useAsyncStorage', () => {
  return {
    useAsyncStorage: jest.fn(() => [
      mockAsyncStorageContext.storage,
      mockAsyncStorageContext.operations,
      mockAsyncStorageContext.isLoading,
      mockAsyncStorageContext.hasChanged,
    ]),
    AsyncStorageProvider: ({ children }: any) => children,
  };
});

jest.mock('@/components/global', () => ({
  handleError: jest.fn(),
  showErrorToast: jest.fn(),
  TIMEOUT: 3600000, // 1 hour
}));

jest.mock('@/components/SpeechTask', () => ({
  SPEECH_TASK: 'SPEECH_TASK',
}));

jest.mock('@/components/CustomDrawerContent', () => ({
  CustomDrawerContent: () => (
    <Text testID='custom-drawer-content'>Custom Drawer</Text>
  ),
}));

jest.mock('@/components/Footer', () => ({
  Footer: () => <Text testID='footer'>Footer</Text>,
}));

jest.mock('@react-navigation/native', () => ({
  ThemeProvider: ({ children }: any) => children,
}));

jest.mock('react-native-gesture-handler', () => ({
  GestureHandlerRootView: ({ children }: any) => children,
}));

jest.mock('react-native-screens', () => ({
  enableFreeze: jest.fn(),
}));

jest.mock('react-native-root-siblings', () => ({
  RootSiblingParent: ({ children }: any) => children,
}));

jest.mock('react-native-safe-area-context', () => ({
  SafeAreaProvider: ({ children }: any) => children,
}));

jest.mock('expo-router/drawer', () => {
  const MockDrawer = ({ children }: any) => children;

  MockDrawer.Screen = ({ name }: any) => {
    return <View testID={`drawer-screen-${name}`} />;
  };

  return {
    Drawer: MockDrawer,
  };
});

jest.mock('@expo/vector-icons', () => ({
  Feather: ({ name, size, color, ...props }: any) => (
    <Text testID={`feather-${name}`} {...props}>
      {name}-{size}-{color}
    </Text>
  ),
}));

describe('Layout Component', () => {
  const mockTheme = { dark: false, colors: { primary: '#000' } };

  beforeEach(() => {
    jest.clearAllMocks();
    (useThemeConfig as jest.Mock).mockReturnValue({ theme: mockTheme });
    mockAsyncStorageContext.operations.getItem.mockResolvedValue(null);
  });

  describe('Mock Setup', () => {
    it('should have mocked dependencies defined', () => {
      expect(useThemeConfig).toBeDefined();
      expect(useAsyncStorage).toBeDefined();
    });

    it('should render basic layout structure', () => {
      const component = render(<Layout />);
      expect(component).toBeTruthy();
    });
  });
});
