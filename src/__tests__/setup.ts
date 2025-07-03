// Mock React Native modules FIRST to ensure proper initialization
jest.mock('react-native', () => {
  const mockNativeModules = {
    ExpoConstants: {
      appOwnership: 'standalone',
      deviceName: 'Test Device',
    },
    RNCNetInfo: {
      getCurrentState: jest.fn(() => Promise.resolve({ isConnected: true })),
      addListener: jest.fn(),
      removeListeners: jest.fn(),
    },
    PlatformConstants: {
      forceTouchAvailable: false,
      reactNativeVersion: { major: 0, minor: 72, patch: 0 },
    },
    StatusBarManager: {
      HEIGHT: 20,
      getHeight: jest.fn((cb) => cb({ height: 20 })),
    },
    UIManager: {
      getViewManagerConfig: jest.fn(() => ({})),
      hasViewManagerConfig: jest.fn(() => false),
      getConstants: jest.fn(() => ({})),
      dispatchViewManagerCommand: jest.fn(),
      measure: jest.fn(),
      measureInWindow: jest.fn(),
      measureLayout: jest.fn(),
    },
  };

  return {
    NativeModules: mockNativeModules,
    Platform: {
      OS: 'ios',
      select: jest.fn((obj) => obj.ios || obj.default),
      Version: '14.0',
    },
    Appearance: {
      getColorScheme: jest.fn(() => 'light'),
      addChangeListener: jest.fn(),
      removeChangeListener: jest.fn(),
    },
    Dimensions: {
      get: jest.fn(() => ({ width: 375, height: 812 })),
      addEventListener: jest.fn(),
      removeEventListener: jest.fn(),
    },
    StyleSheet: {
      create: jest.fn((styles) => styles),
      flatten: jest.fn((style) => style),
    },
    View: ({ children, ...props }: any) => {
      const React = require('react');
      return React.createElement('View', props, children);
    },
    Text: ({ children, ...props }: any) => {
      const React = require('react');
      return React.createElement('Text', props, children);
    },
    ScrollView: ({ children, ...props }: any) => {
      const React = require('react');
      return React.createElement('ScrollView', props, children);
    },
    TouchableOpacity: ({ children, ...props }: any) => {
      const React = require('react');
      return React.createElement('TouchableOpacity', props, children);
    },
    Pressable: ({ children, ...props }: any) => {
      const React = require('react');
      return React.createElement('Pressable', props, children);
    },
    Image: (props: any) => {
      const React = require('react');
      return React.createElement('Image', props);
    },
    TextInput: (props: any) => {
      const React = require('react');
      return React.createElement('TextInput', props);
    },
    Alert: {
      alert: jest.fn(),
    },
  };
});

import 'react-native-gesture-handler/jestSetup';
import mockAsyncStorage from '@react-native-async-storage/async-storage/jest/async-storage-mock';

// Mock AsyncStorage
jest.mock('@react-native-async-storage/async-storage', () => mockAsyncStorage);

// Mock expo-modules-core
jest.mock('expo-modules-core', () => ({
  NativeModulesProxy: {},
  EventEmitter: jest.fn(() => ({
    addListener: jest.fn(),
    removeListener: jest.fn(),
    removeAllListeners: jest.fn(),
  })),
  requireNativeModule: jest.fn(() => ({})),
  requireOptionalNativeModule: jest.fn(() => null),
}));

// Mock expo-font
jest.mock('expo-font', () => ({
  loadAsync: jest.fn(() => Promise.resolve()),
  isLoaded: jest.fn(() => true),
  isLoading: jest.fn(() => false),
}));

// Mock @expo/vector-icons
jest.mock('@expo/vector-icons', () => ({
  AntDesign: ({ name, ...props }: any) => `AntDesign-${name}`,
  Entypo: ({ name, ...props }: any) => `Entypo-${name}`,
  EvilIcons: ({ name, ...props }: any) => `EvilIcons-${name}`,
  Feather: ({ name, size, color, ...props }: any) => {
    const React = require('react');
    const { Text } = require('react-native');
    return React.createElement(Text, {
      testID: `feather-${name}`,
      'data-testid': `feather-${name}`,
      'data-size': size,
      'data-color': color,
      children: `feather-${name}`,
      ...props,
    });
  },
  FontAwesome: ({ name, ...props }: any) => `FontAwesome-${name}`,
  FontAwesome5: ({ name, ...props }: any) => `FontAwesome5-${name}`,
  Fontisto: ({ name, ...props }: any) => `Fontisto-${name}`,
  Foundation: ({ name, ...props }: any) => `Foundation-${name}`,
  Ionicons: ({ name, ...props }: any) => `Ionicons-${name}`,
  MaterialCommunityIcons: ({ name, ...props }: any) =>
    `MaterialCommunityIcons-${name}`,
  MaterialIcons: ({ name, ...props }: any) => `MaterialIcons-${name}`,
  Octicons: ({ name, ...props }: any) => `Octicons-${name}`,
  SimpleLineIcons: ({ name, ...props }: any) => `SimpleLineIcons-${name}`,
  Zocial: ({ name, ...props }: any) => `Zocial-${name}`,
}));

jest.mock('expo-constants', () => ({
  default: {
    appOwnership: 'standalone',
    deviceName: 'Test Device',
  },
}));

jest.mock('expo-splash-screen', () => ({
  hideAsync: jest.fn(),
  preventAutoHideAsync: jest.fn(),
}));

jest.mock('expo-keep-awake', () => ({
  activateKeepAwake: jest.fn(),
  deactivateKeepAwake: jest.fn(),
}));

jest.mock('expo-background-fetch', () => ({
  BackgroundFetchStatus: {
    Available: 1,
    Denied: 2,
    Restricted: 3,
  },
  setMinimumIntervalAsync: jest.fn(),
  registerTaskAsync: jest.fn(),
  unregisterTaskAsync: jest.fn(),
}));

jest.mock('expo-image', () => ({
  Image: 'Image',
}));

// Mock expo-speech
jest.mock('expo-speech', () => ({
  speak: jest.fn(),
  stop: jest.fn(),
  pause: jest.fn(),
  resume: jest.fn(),
  getAvailableVoicesAsync: jest.fn(() => Promise.resolve([])),
  isSpeakingAsync: jest.fn(() => Promise.resolve(false)),
}));

// Mock expo-local-authentication
jest.mock('expo-local-authentication', () => ({
  hasHardwareAsync: jest.fn(() => Promise.resolve(true)),
  isEnrolledAsync: jest.fn(() => Promise.resolve(true)),
  authenticateAsync: jest.fn(() => Promise.resolve({ success: true })),
  AuthenticationType: {
    FINGERPRINT: 1,
    FACIAL_RECOGNITION: 2,
  },
}));

// Mock expo-task-manager
jest.mock('expo-task-manager', () => ({
  defineTask: jest.fn(),
  startBackgroundFetchAsync: jest.fn(),
  stopBackgroundFetchAsync: jest.fn(),
  getRegisteredTasksAsync: jest.fn(() => Promise.resolve([])),
}));

// Mock expo-router
jest.mock('expo-router', () => {
  const React = require('react');
  const { View } = require('react-native');

  const MockDrawer = ({ children, screenOptions, drawerContent }: any) => {
    return React.createElement(View, { testID: 'mock-drawer' }, children);
  };

  MockDrawer.Screen = ({ name, options, children }: any) => {
    return React.createElement(
      View,
      {
        testID: `drawer-screen-${name}`,
        'data-name': name,
      },
      children
    );
  };

  return {
    useRouter: jest.fn(() => ({
      push: jest.fn(),
      replace: jest.fn(),
      back: jest.fn(),
    })),
    useLocalSearchParams: jest.fn(() => ({})),
    router: {
      push: jest.fn(),
      replace: jest.fn(),
      back: jest.fn(),
    },
    SplashScreen: {
      hideAsync: jest.fn(),
      preventAutoHideAsync: jest.fn(),
    },
    Drawer: MockDrawer,
  };
});

// Mock expo-router/drawer
jest.mock('expo-router/drawer', () => ({
  Drawer: {
    Screen: ({ children, ...props }: any) => children,
  },
}));

// Mock react-navigation
jest.mock('@react-navigation/native', () => {
  const React = require('react');
  return {
    useNavigation: jest.fn(() => ({
      navigate: jest.fn(),
      goBack: jest.fn(),
      setOptions: jest.fn(),
      toggleDrawer: jest.fn(),
    })),
    useIsFocused: jest.fn(() => true),
    ThemeProvider: ({
      children,
      value,
    }: {
      children: React.ReactNode;
      value: any;
    }) => children,
    DarkTheme: {},
    DefaultTheme: {},
  };
});

// Mock @react-navigation/drawer
jest.mock('@react-navigation/drawer', () => ({
  createDrawerNavigator: jest.fn(() => ({
    Navigator: ({ children }: { children: React.ReactNode }) => children,
    Screen: ({ children }: { children: React.ReactNode }) => children,
  })),
  DrawerContentScrollView: ({ children }: { children: React.ReactNode }) =>
    children,
  DrawerItemList: () => null,
  DrawerItem: () => null,
}));

// Mock @react-navigation/elements
jest.mock('@react-navigation/elements', () => ({
  HeaderBackButton: () => null,
  Header: () => null,
  getHeaderTitle: jest.fn(),
}));

// Mock react-native-safe-area-context
jest.mock('react-native-safe-area-context', () => ({
  SafeAreaProvider: ({ children }: { children: React.ReactNode }) => children,
  useSafeAreaInsets: jest.fn(() => ({ top: 0, bottom: 0, left: 0, right: 0 })),
}));

// Mock react-native-root-toast
jest.mock('react-native-root-toast', () => ({
  show: jest.fn(),
  hide: jest.fn(),
  durations: {
    LONG: 3500,
    SHORT: 2000,
  },
  positions: {
    TOP: 20,
    BOTTOM: -20,
    CENTER: 0,
  },
}));

// Mock axios
jest.mock('axios', () => ({
  get: jest.fn(() => Promise.resolve({ data: {} })),
  post: jest.fn(() => Promise.resolve({ data: {} })),
  put: jest.fn(() => Promise.resolve({ data: {} })),
  delete: jest.fn(() => Promise.resolve({ data: {} })),
}));

// Mock react-hook-form
jest.mock('react-hook-form', () => ({
  useForm: () => ({
    control: {},
    handleSubmit: jest.fn((fn) => fn),
    setValue: jest.fn(),
    getValues: jest.fn(() => ({})),
    formState: { errors: {} },
  }),
  Controller: ({ render }: any) =>
    render({ field: { onChange: jest.fn(), value: '' } }),
}));

// Silence console warnings during tests
const originalConsoleForSilencing = global.console;
global.console = {
  ...originalConsoleForSilencing,
  warn: (() => {}) as any,
  // Keep error for Jest functionality
  error: originalConsoleForSilencing.error,
};

// Mock NativeWind and react-native-css-interop
jest.mock('nativewind', () => ({
  styled: (Component: any) => Component,
  withExpoSnack: jest.fn((component) => component),
}));

jest.mock('react-native-css-interop', () => ({
  getColorScheme: jest.fn(() => 'light'),
  cssInterop: jest.fn(),
}));

jest.mock('react-native-css-interop/jsx-runtime', () => ({
  jsx: jest.fn(),
  jsxs: jest.fn(),
  Fragment: jest.fn(),
}));

jest.mock('react-native-css-interop/jsx-dev-runtime', () => ({
  jsxDEV: jest.fn(),
  Fragment: jest.fn(),
}));

// Mock React Native components
jest.mock('react-native-modal', () => 'Modal');
jest.mock('react-native-markdown-display', () => 'MarkdownDisplay');
jest.mock('@react-native-community/slider', () => 'Slider');
jest.mock('@react-native-picker/picker', () => ({
  Picker: 'Picker',
}));
jest.mock('@react-native-segmented-control/segmented-control', () => ({
  default: 'SegmentedControl',
}));
jest.mock('react-native-background-timer', () => ({
  setInterval: jest.fn(),
  clearInterval: jest.fn(),
}));
jest.mock('react-native-screens', () => ({
  enableFreeze: jest.fn(),
}));

// Mock react-native-reanimated
jest.mock('react-native-reanimated', () => {
  const Reanimated = require('react-native-reanimated/mock');
  Reanimated.default.call = () => {};
  return Reanimated;
});
jest.mock('react-native-root-siblings', () => ({
  RootSiblingParent: ({ children }: { children: React.ReactNode }) => children,
}));

// Mock package.json
jest.mock(
  '../../package.json',
  () => ({
    name: 'writer',
    description: 'A writer app for iOS and Android',
    slogan: 'Listening is the beginning of wisdom.',
  }),
  { virtual: true }
);

// Mock global variables
(global as any).__DEV__ = true;
(global as any).CONTENT_KEY = 'test-content-key';
(global as any).showErrorToast = jest.fn();
(global as any).showInfoToast = jest.fn();

// Add DOM globals conditionally to avoid redefinition errors
if (typeof global.window === 'undefined') {
  global.window = {
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    dispatchEvent: jest.fn(),
    location: { href: 'http://localhost' },
    navigator: { userAgent: 'test' },
    setTimeout: global.setTimeout,
    clearTimeout: global.clearTimeout,
    setInterval: global.setInterval,
    clearInterval: global.clearInterval,
  } as any;
}

if (typeof global.document === 'undefined') {
  global.document = {
    createElement: jest.fn(() => ({
      setAttribute: jest.fn(),
      style: {},
      addEventListener: jest.fn(),
      removeEventListener: jest.fn(),
    })),
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
    body: {
      appendChild: jest.fn(),
      removeChild: jest.fn(),
    },
  } as any;
}

if (typeof global.navigator === 'undefined') {
  global.navigator = {
    userAgent: 'test',
    platform: 'test',
  } as any;
}

// Use real timers for React Native Testing Library compatibility
jest.useRealTimers();

// Ensure timer functions are available globally
if (!global.setTimeout) {
  global.setTimeout = setTimeout;
}
if (!global.clearTimeout) {
  global.clearTimeout = clearTimeout;
}
if (!global.setInterval) {
  global.setInterval = setInterval;
}
if (!global.clearInterval) {
  global.clearInterval = clearInterval;
}

// Mock react-test-renderer to avoid React version compatibility issues
jest.mock('react-test-renderer', () => ({
  create: jest.fn(() => ({
    toJSON: jest.fn(() => ({})),
    getInstance: jest.fn(() => ({})),
    update: jest.fn(),
    unmount: jest.fn(),
  })),
  act: jest.fn((callback) => {
    if (typeof callback === 'function') {
      callback();
    }
    return Promise.resolve();
  }),
}));

// Mock react-test-renderer/shallow to avoid compatibility issues
jest.mock('react-test-renderer/shallow', () => ({
  createRenderer: jest.fn(() => ({
    render: jest.fn(),
    getRenderOutput: jest.fn(() => ({})),
  })),
}));

// Mock require for assets
jest.mock('assets/favicon.png', () => 'mocked-favicon', { virtual: true });
jest.mock('assets/wood.jpg', () => 'mocked-wood', { virtual: true });

// Don't mock @testing-library/react-native - use the real implementation

// Final console setup for tests - keep console.log for debugging
const finalOriginalConsole = global.console;
global.console = {
  ...finalOriginalConsole,
  warn: (() => {}) as any,
  // Keep error and log for debugging
  error: finalOriginalConsole.error,
  log: finalOriginalConsole.log,
};
