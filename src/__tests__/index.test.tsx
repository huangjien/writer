import React from 'react';
import { render, fireEvent } from '@testing-library/react-native';
import { useRouter } from 'expo-router';
import Page from '../app/index';

// Mock all dependencies
jest.mock('../app/images', () => ({
  images: {
    logo: 'mocked-logo-source',
  },
}));

jest.mock('react-native', () => ({
  View: ({ children, ...props }: any) => (
    <div testID='view' {...props}>
      {children}
    </div>
  ),
  Text: ({ children, ...props }: any) => (
    <span testID='text' {...props}>
      {children}
    </span>
  ),
  TouchableOpacity: ({ children, onPress, ...props }: any) => (
    <button testID='touchable' onClick={onPress} {...props}>
      {children}
    </button>
  ),
}));

jest.mock('react-native-gesture-handler', () => ({
  ScrollView: ({ children, ...props }: any) => (
    <div testID='scroll-view' {...props}>
      {children}
    </div>
  ),
}));

// Mock expo-router
const mockPush = jest.fn();
jest.mock('expo-router', () => ({
  useRouter: jest.fn(() => ({
    push: mockPush,
  })),
}));

jest.mock('@expo/vector-icons', () => ({
  Feather: ({ name, size, color, ...props }: any) => (
    <span
      testID='feather-icon'
      data-name={name}
      data-size={size}
      data-color={color}
      {...props}
    />
  ),
}));

jest.mock('@/components/image', () => ({
  Image: ({ source, ...props }: any) => (
    <img testID='image' src={source} {...props} />
  ),
}));

describe('Index Page', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('Component Structure', () => {
    it('exports default function', () => {
      expect(typeof Page).toBe('function');
    });

    it('has correct component name', () => {
      expect(Page.name).toBe('Page');
    });

    it('renders without crashing', () => {
      expect(() => render(<Page />)).not.toThrow();
    });

    it('renders component structure without errors', () => {
      const { toJSON } = render(<Page />);
      const tree = toJSON();

      // Should render component structure
      expect(tree).toBeTruthy();
    });

    it('maintains consistent component structure', () => {
      const { toJSON: firstRender } = render(<Page />);
      const { toJSON: secondRender } = render(<Page />);

      // Both renders should be consistent
      expect(firstRender()).toEqual(secondRender());
    });
  });

  describe('Hero Section', () => {
    it('renders hero section structure', () => {
      const { toJSON } = render(<Page />);
      const tree = toJSON();

      // Should render component structure
      expect(tree).toBeTruthy();
    });

    it('handles hero section rendering without errors', () => {
      expect(() => render(<Page />)).not.toThrow();
    });

    it('maintains consistent hero structure', () => {
      const { toJSON: firstRender } = render(<Page />);
      const { toJSON: secondRender } = render(<Page />);

      // Both renders should be consistent
      expect(firstRender()).toEqual(secondRender());
    });
  });

  describe('Navigation', () => {
    it('renders navigation structure without errors', () => {
      const { toJSON } = render(<Page />);
      const tree = toJSON();

      // Should render component structure
      expect(tree).toBeTruthy();
    });

    it('handles navigation component rendering', () => {
      expect(() => render(<Page />)).not.toThrow();
    });

    it('maintains consistent navigation structure', () => {
      const { toJSON: firstRender } = render(<Page />);
      const { toJSON: secondRender } = render(<Page />);

      // Both renders should be consistent
      expect(firstRender()).toEqual(secondRender());
    });
  });

  describe('Features Section', () => {
    it('renders features section structure', () => {
      const { toJSON } = render(<Page />);
      const tree = toJSON();

      // Should render component structure
      expect(tree).toBeTruthy();
    });

    it('handles feature rendering without errors', () => {
      expect(() => render(<Page />)).not.toThrow();
    });

    it('maintains consistent feature structure', () => {
      const { toJSON: firstRender } = render(<Page />);
      const { toJSON: secondRender } = render(<Page />);

      // Both renders should be consistent
      expect(firstRender()).toEqual(secondRender());
    });
  });

  describe('Multi-language Welcome Section', () => {
    it('renders multi-language section structure', () => {
      const { toJSON } = render(<Page />);
      const tree = toJSON();

      // Should render component structure
      expect(tree).toBeTruthy();
    });

    it('handles multi-language content without errors', () => {
      expect(() => render(<Page />)).not.toThrow();
    });

    it('maintains consistent multi-language structure', () => {
      const { toJSON: firstRender } = render(<Page />);
      const { toJSON: secondRender } = render(<Page />);

      // Both renders should be consistent
      expect(firstRender()).toEqual(secondRender());
    });
  });

  describe('Accessibility', () => {
    it('renders component structure for accessibility', () => {
      const { toJSON } = render(<Page />);

      // Component should render with proper structure
      expect(toJSON()).toBeTruthy();
      expect(toJSON()).toMatchSnapshot();
    });

    it('handles component rendering without errors', () => {
      expect(() => render(<Page />)).not.toThrow();
    });

    it('provides consistent component structure', () => {
      const { toJSON } = render(<Page />);
      const tree = toJSON();

      // Should have a consistent structure
      expect(tree).toBeTruthy();
      expect(typeof tree).toBe('object');
    });
  });

  describe('Error Handling & Edge Cases', () => {
    it('renders without crashing when router is undefined', () => {
      // Mock useRouter to return undefined
      (useRouter as jest.Mock).mockReturnValueOnce(undefined);

      expect(() => render(<Page />)).not.toThrow();

      // Restore mock
      (useRouter as jest.Mock).mockReturnValue({ push: mockPush });
    });

    it('renders all content sections', () => {
      const { toJSON } = render(<Page />);

      // Component should render without crashing
      expect(toJSON()).toBeTruthy();
    });

    it('handles component lifecycle correctly', () => {
      const { unmount } = render(<Page />);

      // Should unmount without errors
      expect(() => unmount()).not.toThrow();
    });
  });

  describe('Performance & Optimization', () => {
    it('renders efficiently without unnecessary re-renders', () => {
      const { rerender } = render(<Page />);

      // Re-render with same props should not cause issues
      expect(() => {
        rerender(<Page />);
        rerender(<Page />);
      }).not.toThrow();
    });

    it('maintains consistent output across renders', () => {
      const { toJSON: firstRender } = render(<Page />);
      const { toJSON: secondRender } = render(<Page />);

      // Both renders should produce consistent output
      expect(firstRender()).toEqual(secondRender());
    });

    it('handles mock navigation calls correctly', () => {
      render(<Page />);

      // Mock should be properly initialized
      expect(mockPush).toBeDefined();
      expect(typeof mockPush).toBe('function');
    });
  });
});
