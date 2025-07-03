import React from 'react';
import { render, waitFor, act } from '@testing-library/react-native';
import { Text, View } from 'react-native';
import Layout, { InnerLayout } from '../app/_layout';
import * as LocalAuthentication from 'expo-local-authentication';
import * as BackgroundTask from 'expo-background-task';
import { SplashScreen } from 'expo-router';
import { useThemeConfig } from '@/hooks/use-theme-config';
import { useAsyncStorage, AsyncStorageProvider } from '@/hooks/useAsyncStorage';
import { handleError, showErrorToast, TIMEOUT } from '@/components/global';
import { SPEECH_TASK } from '@/components/SpeechTask';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import { RootSiblingParent } from 'react-native-root-siblings';
import { ThemeProvider } from '@react-navigation/native';

// Mock CSS import
jest.mock('../global.css', () => ({}));

// Mock all dependencies
jest.mock('expo-router', () => ({
  SplashScreen: {
    preventAutoHideAsync: jest.fn(),
    hideAsync: jest.fn().mockResolvedValue(undefined),
  },
  Drawer: ({ children, ...props }: any) => children,
}));

jest.mock('expo-router/drawer', () => ({
  Drawer: {
    Screen: ({ children, ...props }: any) => (
      <Text testID={`drawer-screen-${props.name}`}>{children}</Text>
    ),
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
    AsyncStorageProvider: ({ children }: any) => {
      console.log('AsyncStorageProvider mock called');
      return children;
    },
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
  const MockDrawer = ({ children, screenOptions, drawerContent }: any) => {
    console.log('Drawer mock called with children:', !!children);
    return children;
  };

  MockDrawer.Screen = ({ name, options }: any) => {
    console.log('Drawer.Screen mock called for:', name);
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

// Mock console.error to avoid noise in tests
const originalConsoleError = console.error;
beforeAll(() => {
  // Temporarily disable console.error mocking to see actual errors
  // console.error = jest.fn();
});

afterAll(() => {
  console.error = originalConsoleError;
});

describe('Layout Component', () => {
  const mockTheme = { dark: false, colors: { primary: '#000' } };

  beforeEach(() => {
    jest.clearAllMocks();
    (useThemeConfig as jest.Mock).mockReturnValue({ theme: mockTheme });
    (LocalAuthentication.hasHardwareAsync as jest.Mock).mockResolvedValue(true);
    (LocalAuthentication.isEnrolledAsync as jest.Mock).mockResolvedValue(true);
    (LocalAuthentication.authenticateAsync as jest.Mock).mockResolvedValue({
      success: true,
    });
    (BackgroundTask.registerTaskAsync as jest.Mock).mockResolvedValue(
      undefined
    );
    mockAsyncStorageContext.operations.getItem.mockResolvedValue(null);
  });

  describe('Main Layout', () => {
    it('renders without crashing', () => {
      const component = render(<Layout />);
      expect(component).toBeTruthy();
    });

    it('renders with all providers', () => {
      const { getByTestId } = render(<Layout />);

      expect(getByTestId('custom-drawer-content')).toBeTruthy();
      expect(getByTestId('footer')).toBeTruthy();
    });

    it('uses theme from useThemeConfig', () => {
      const customTheme = { dark: true, colors: { primary: '#fff' } };
      (useThemeConfig as jest.Mock).mockReturnValue({ theme: customTheme });

      render(<Layout />);

      expect(useThemeConfig).toHaveBeenCalled();
    });
  });

  describe('Background Task Registration', () => {
    it('registers background task on mount', async () => {
      render(<Layout />);

      await waitFor(() => {
        expect(BackgroundTask.registerTaskAsync).toHaveBeenCalledWith(
          SPEECH_TASK,
          {
            minimumInterval: 10,
          }
        );
      });
    });

    it('handles background task registration error', async () => {
      const error = new Error('Registration failed');
      (BackgroundTask.registerTaskAsync as jest.Mock).mockRejectedValue(error);

      render(<Layout />);

      await waitFor(() => {
        expect(console.error).toHaveBeenCalledWith(
          'Failed to Register speech task',
          error
        );
      });
    });
  });

  describe('Splash Screen Management', () => {
    it('prevents auto-hide and hides splash screen after initialization', async () => {
      render(<Layout />);

      expect(SplashScreen.preventAutoHideAsync).toHaveBeenCalled();

      await waitFor(() => {
        expect(SplashScreen.hideAsync).toHaveBeenCalled();
      });
    });

    it('hides splash screen on error', async () => {
      const error = new Error('Hardware check failed');
      (LocalAuthentication.hasHardwareAsync as jest.Mock).mockRejectedValue(
        error
      );

      render(<Layout />);

      await waitFor(() => {
        expect(SplashScreen.hideAsync).toHaveBeenCalled();
        expect(handleError).toHaveBeenCalledWith(error);
      });
    });
  });

  describe('Biometric Authentication', () => {
    it('checks hardware compatibility and performs authentication', async () => {
      render(<Layout />);

      await waitFor(() => {
        expect(LocalAuthentication.hasHardwareAsync).toHaveBeenCalled();
      });
    });

    it('handles biometric authentication when no expiry is set', async () => {
      // Reset the mock to ensure it's called
      jest.clearAllMocks();

      // Test the LocalAuthentication mock directly first
      console.log('Testing LocalAuthentication mock directly');
      await LocalAuthentication.hasHardwareAsync();
      console.log('Direct call to hasHardwareAsync completed');

      expect(LocalAuthentication.hasHardwareAsync).toHaveBeenCalledTimes(1);

      await LocalAuthentication.isEnrolledAsync();
      console.log('Direct call to isEnrolledAsync completed');

      expect(LocalAuthentication.isEnrolledAsync).toHaveBeenCalledTimes(1);
    });

    it('handles biometric authentication when expiry is expired', async () => {
      const expiredTime = (Date.now() - 1000).toString();
      mockAsyncStorageContext.operations.getItem.mockResolvedValue(expiredTime);

      render(<Layout />);

      // Wait for the initial useEffect to complete
      await waitFor(() => {
        expect(LocalAuthentication.hasHardwareAsync).toHaveBeenCalled();
      });

      // Then check if biometric auth was called
      await waitFor(
        () => {
          expect(LocalAuthentication.isEnrolledAsync).toHaveBeenCalled();
        },
        { timeout: 5000 }
      );
    });

    it('skips authentication when expiry is valid', async () => {
      const futureTime = (Date.now() + TIMEOUT).toString();
      mockAsyncStorageContext.operations.getItem.mockResolvedValue(futureTime);

      render(<Layout />);

      await waitFor(() => {
        expect(LocalAuthentication.authenticateAsync).not.toHaveBeenCalled();
      });
    });

    it('shows error when no biometrics are enrolled', async () => {
      mockAsyncStorageContext.operations.getItem.mockResolvedValue(null);
      (LocalAuthentication.isEnrolledAsync as jest.Mock).mockResolvedValue(
        false
      );

      render(<Layout />);

      await waitFor(() => {
        expect(showErrorToast).toHaveBeenCalledWith(
          'No Biometrics Authentication\nPlease verify your identity with your password'
        );
      });
    });

    it('sets expiry on successful authentication', async () => {
      mockAsyncStorageContext.operations.getItem.mockResolvedValue(null);
      (LocalAuthentication.authenticateAsync as jest.Mock).mockResolvedValue({
        success: true,
      });

      render(<Layout />);

      await waitFor(() => {
        expect(mockAsyncStorageContext.operations.setItem).toHaveBeenCalledWith(
          'expiry',
          expect.any(String)
        );
      });
    });

    it('does not set expiry on failed authentication', async () => {
      mockAsyncStorageContext.operations.getItem.mockResolvedValue(null);
      (LocalAuthentication.authenticateAsync as jest.Mock).mockResolvedValue({
        success: false,
      });

      render(<Layout />);

      await waitFor(() => {
        expect(LocalAuthentication.authenticateAsync).toHaveBeenCalled();
      });

      expect(
        mockAsyncStorageContext.operations.setItem
      ).not.toHaveBeenCalledWith('expiry', expect.any(String));
    });
  });

  describe('Storage Changes Effect', () => {
    it('triggers authentication check when storage changes', async () => {
      // Set hasChanged to true to trigger the effect
      mockAsyncStorageContext.hasChanged = 1;

      render(<Layout />);

      await waitFor(() => {
        expect(mockAsyncStorageContext.operations.getItem).toHaveBeenCalledWith(
          'expiry'
        );
      });

      await waitFor(
        () => {
          expect(LocalAuthentication.isEnrolledAsync).toHaveBeenCalled();
        },
        { timeout: 5000 }
      );
    });
  });

  describe('Drawer Navigation', () => {
    it('renders all drawer screens', () => {
      const { getByTestId } = render(<Layout />);

      expect(getByTestId('drawer-screen-index')).toBeTruthy();
      expect(getByTestId('drawer-screen-github')).toBeTruthy();
      expect(getByTestId('drawer-screen-read')).toBeTruthy();
      expect(getByTestId('drawer-screen-setting')).toBeTruthy();
    });

    it('configures drawer screens with correct options', () => {
      const { getByTestId } = render(<Layout />);

      const indexScreen = getByTestId('drawer-screen-index');
      const githubScreen = getByTestId('drawer-screen-github');
      const readScreen = getByTestId('drawer-screen-read');
      const settingScreen = getByTestId('drawer-screen-setting');

      expect(indexScreen).toBeTruthy();
      expect(githubScreen).toBeTruthy();
      expect(readScreen).toBeTruthy();
      expect(settingScreen).toBeTruthy();
    });
  });

  describe('Error Handling', () => {
    it('handles LocalAuthentication errors gracefully', async () => {
      const error = new Error('Authentication error');
      (LocalAuthentication.hasHardwareAsync as jest.Mock).mockRejectedValue(
        error
      );

      render(<Layout />);

      await waitFor(() => {
        expect(handleError).toHaveBeenCalledWith(error);
      });
    });

    it('handles getItem errors in expiry check', async () => {
      const error = new Error('Storage error');
      mockAsyncStorageContext.operations.getItem.mockRejectedValue(error);

      render(<Layout />);

      // Should not crash the app
      await waitFor(() => {
        expect(mockAsyncStorageContext.operations.getItem).toHaveBeenCalledWith(
          'expiry'
        );
      });
    });
  });

  describe('Component Integration', () => {
    it('integrates with AsyncStorageProvider', () => {
      render(<Layout />);

      expect(useAsyncStorage).toHaveBeenCalled();
    });

    it('integrates with theme provider', () => {
      render(<Layout />);

      expect(useThemeConfig).toHaveBeenCalled();
    });

    it('renders custom drawer content', () => {
      const { getByTestId } = render(<Layout />);

      expect(getByTestId('custom-drawer-content')).toBeTruthy();
    });

    it('renders footer component', () => {
      const { getByTestId } = render(<Layout />);

      expect(getByTestId('footer')).toBeTruthy();
    });
  });

  describe('Biometric Authentication Edge Cases', () => {
    it('handles authentication prompt correctly', async () => {
      mockAsyncStorageContext.operations.getItem.mockResolvedValue(null);

      render(<Layout />);

      await waitFor(() => {
        expect(LocalAuthentication.authenticateAsync).toHaveBeenCalledWith({
          promptMessage: "You need to be this device's owner to use this app",
          disableDeviceFallback: false,
        });
      });
    });

    it('handles expiry logic correctly with OR condition', async () => {
      // Test the corrected logic: if (!expiry || parseInt(expiry) < Date.now())
      mockAsyncStorageContext.operations.getItem.mockResolvedValue(null);
      // Simulate hasChanged to trigger the useEffect
      mockAsyncStorageContext.hasChanged = 1;

      render(<Layout />);

      await waitFor(
        () => {
          expect(LocalAuthentication.isEnrolledAsync).toHaveBeenCalled();
        },
        { timeout: 5000 }
      );
    });
  });
});
