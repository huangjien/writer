import React from 'react';
import { render } from '@testing-library/react-native';
import { Image } from '../components/image';
import { Image as NImage } from 'expo-image';
import { cssInterop } from 'nativewind';

// Mock dependencies
jest.mock('expo-image', () => ({
  Image: ({ placeholder, className, style, ...props }: any) => (
    <div
      testID='expo-image'
      data-placeholder={placeholder}
      data-classname={className}
      style={style}
      {...props}
    />
  ),
}));

jest.mock('nativewind', () => ({
  cssInterop: jest.fn(),
}));

describe('Image Component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Component Rendering', () => {
    it('renders without crashing', () => {
      const { getByTestId } = render(
        <Image source={{ uri: 'test-image.jpg' }} />
      );

      expect(getByTestId('expo-image')).toBeTruthy();
    });

    it('passes through all props to NImage', () => {
      const testProps = {
        source: { uri: 'test-image.jpg' },
        style: { width: 100, height: 100 },
        resizeMode: 'cover' as const,
        testID: 'custom-test-id',
      };

      const { getByTestId } = render(<Image {...testProps} />);

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props.source).toEqual(testProps.source);
      expect(imageElement.props.style).toEqual(testProps.style);
      expect(imageElement.props.resizeMode).toBe(testProps.resizeMode);
    });

    it('uses default placeholder when none provided', () => {
      const { getByTestId } = render(
        <Image source={{ uri: 'test-image.jpg' }} />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props['data-placeholder']).toBe(
        'L6PZfSi_.AyE_3t7t7R**0o#DgR4'
      );
    });

    it('uses custom placeholder when provided', () => {
      const customPlaceholder = 'custom-placeholder-hash';
      const { getByTestId } = render(
        <Image
          source={{ uri: 'test-image.jpg' }}
          placeholder={customPlaceholder}
        />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props['data-placeholder']).toBe(customPlaceholder);
    });
  });

  describe('Styling', () => {
    it('handles className prop correctly', () => {
      const className = 'w-10 h-10 rounded-full';
      const { getByTestId } = render(
        <Image source={{ uri: 'test-image.jpg' }} className={className} />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props['data-classname']).toBe(className);
    });

    it('handles style prop correctly', () => {
      const style = { width: 50, height: 50, borderRadius: 25 };
      const { getByTestId } = render(
        <Image source={{ uri: 'test-image.jpg' }} style={style} />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props.style).toEqual(style);
    });

    it('handles both className and style props', () => {
      const className = 'w-10 h-10';
      const style = { borderRadius: 25 };
      const { getByTestId } = render(
        <Image
          source={{ uri: 'test-image.jpg' }}
          className={className}
          style={style}
        />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props['data-classname']).toBe(className);
      expect(imageElement.props.style).toEqual(style);
    });
  });

  describe('NativeWind Integration', () => {
    it('calls cssInterop with correct parameters', () => {
      // This test verifies that cssInterop is called during module initialization
      expect(cssInterop).toHaveBeenCalledWith(NImage, { className: 'style' });
    });
  });

  describe('Image Sources', () => {
    it('handles URI source', () => {
      const source = { uri: 'https://example.com/image.jpg' };
      const { getByTestId } = render(<Image source={source} />);

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props.source).toEqual(source);
    });

    it('handles local source', () => {
      const source = require('../../assets/test-image.png');
      const { getByTestId } = render(<Image source={source} />);

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props.source).toEqual(source);
    });

    it('handles multiple sources', () => {
      const source = [
        { uri: 'https://example.com/image-small.jpg', width: 100 },
        { uri: 'https://example.com/image-large.jpg', width: 200 },
      ];
      const { getByTestId } = render(<Image source={source} />);

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props.source).toEqual(source);
    });
  });

  describe('Accessibility', () => {
    it('passes accessibility props correctly', () => {
      const accessibilityProps = {
        accessible: true,
        accessibilityLabel: 'Test image',
        accessibilityHint: 'This is a test image',
        accessibilityRole: 'image' as const,
      };

      const { getByTestId } = render(
        <Image source={{ uri: 'test-image.jpg' }} {...accessibilityProps} />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props.accessible).toBe(true);
      expect(imageElement.props.accessibilityLabel).toBe('Test image');
      expect(imageElement.props.accessibilityHint).toBe('This is a test image');
      expect(imageElement.props.accessibilityRole).toBe('image');
    });
  });

  describe('Image Properties', () => {
    it('handles resize mode correctly', () => {
      const resizeMode = 'contain';
      const { getByTestId } = render(
        <Image source={{ uri: 'test-image.jpg' }} resizeMode={resizeMode} />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props.resizeMode).toBe(resizeMode);
    });

    it('handles content fit correctly', () => {
      const contentFit = 'cover';
      const { getByTestId } = render(
        <Image source={{ uri: 'test-image.jpg' }} contentFit={contentFit} />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props.contentFit).toBe(contentFit);
    });

    it('handles transition correctly', () => {
      const transition = { duration: 300 };
      const { getByTestId } = render(
        <Image source={{ uri: 'test-image.jpg' }} transition={transition} />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props.transition).toEqual(transition);
    });
  });

  describe('Event Handlers', () => {
    it('passes onLoad handler correctly', () => {
      const onLoad = jest.fn();
      const { getByTestId } = render(
        <Image source={{ uri: 'test-image.jpg' }} onLoad={onLoad} />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props.onLoad).toBe(onLoad);
    });

    it('passes onError handler correctly', () => {
      const onError = jest.fn();
      const { getByTestId } = render(
        <Image source={{ uri: 'test-image.jpg' }} onError={onError} />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props.onError).toBe(onError);
    });

    it('passes onLoadStart handler correctly', () => {
      const onLoadStart = jest.fn();
      const { getByTestId } = render(
        <Image source={{ uri: 'test-image.jpg' }} onLoadStart={onLoadStart} />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props.onLoadStart).toBe(onLoadStart);
    });
  });

  describe('Edge Cases', () => {
    it('handles undefined className', () => {
      const { getByTestId } = render(
        <Image source={{ uri: 'test-image.jpg' }} className={undefined} />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props['data-classname']).toBeUndefined();
    });

    it('handles empty className', () => {
      const { getByTestId } = render(
        <Image source={{ uri: 'test-image.jpg' }} className='' />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props['data-classname']).toBe('');
    });

    it('handles undefined style', () => {
      const { getByTestId } = render(
        <Image source={{ uri: 'test-image.jpg' }} style={undefined} />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props.style).toBeUndefined();
    });

    it('handles null placeholder', () => {
      const { getByTestId } = render(
        <Image source={{ uri: 'test-image.jpg' }} placeholder={null} />
      );

      const imageElement = getByTestId('expo-image');
      expect(imageElement.props['data-placeholder']).toBeNull();
    });
  });

  describe('Type Safety', () => {
    it('accepts all valid ImageProps', () => {
      // This test ensures the component accepts all expo-image props
      const props = {
        source: { uri: 'test-image.jpg' },
        className: 'test-class',
        style: { width: 100 },
        placeholder: 'test-placeholder',
        contentFit: 'cover' as const,
        transition: { duration: 300 },
        priority: 'high' as const,
        cachePolicy: 'memory-disk' as const,
      };

      expect(() => render(<Image {...props} />)).not.toThrow();
    });
  });
});
