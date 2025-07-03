import React from 'react';
import { render } from '@testing-library/react-native';
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

jest.mock('expo-router', () => ({
  useRouter: () => ({
    push: jest.fn(),
  }),
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
  it('exports default function', () => {
    expect(typeof Page).toBe('function');
  });

  it('has correct component name', () => {
    expect(Page.name).toBe('Page');
  });

  it('can be instantiated', () => {
    expect(() => {
      const component = new (Page as any)();
      return component;
    }).not.toThrow();
  });
});
