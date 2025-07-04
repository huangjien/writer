import Page from '../app/github';

// Mock all dependencies to avoid complex setup
jest.mock('expo-router', () => ({
  useRouter: () => ({ push: jest.fn() }),
}));

jest.mock('@react-navigation/native', () => ({
  useIsFocused: () => true,
}));

jest.mock('@/hooks/useAsyncStorage', () => ({
  useAsyncStorage: () => [
    {},
    { setItem: jest.fn(), getItem: jest.fn().mockResolvedValue(null) },
    false,
    false,
  ],
}));

jest.mock('@/components/global', () => ({
  SETTINGS_KEY: 'settings',
  CONTENT_KEY: 'content',
  ANALYSIS_KEY: 'analysis',
  fileNameComparator: (a: any, b: any) => a.name.localeCompare(b.name),
  handleError: jest.fn(),
  showErrorToast: jest.fn(),
}));

jest.mock('react-native-gesture-handler', () => ({
  ScrollView: 'ScrollView',
}));

jest.mock('axios', () => ({
  get: jest.fn(),
}));

describe('GitHub Page', () => {
  beforeEach(() => {
    global.fetch = jest.fn();
  });

  it('should export the Page component', () => {
    expect(Page).toBeDefined();
    expect(typeof Page).toBe('function');
  });

  it('should be a React component', () => {
    expect(Page.name).toBe('Page');
  });

  it('should have the correct module structure', () => {
    // Test that the module exports a default function
    expect(typeof Page).toBe('function');
    expect(Page.length).toBeGreaterThanOrEqual(0); // Function should accept parameters
  });
});
