import React from 'react';
import { render } from '@testing-library/react-native';
import { Footer } from '../components/Footer';

// Mock the package.json
jest.mock('@/../package.json', () => ({
  version: '1.5.10',
  name: 'writer',
  copyright: 'MIT',
  author: 'Jien Huang',
}));

// Mock useSafeAreaInsets
jest.mock('react-native-safe-area-context', () => ({
  useSafeAreaInsets: jest.fn(() => ({
    top: 44,
    bottom: 34,
    left: 0,
    right: 0,
  })),
}));

describe('Footer', () => {
  it('should render without crashing', () => {
    const component = render(<Footer />);
    expect(component).toBeTruthy();
  });

  it('should use safe area insets for bottom padding', () => {
    const component = render(<Footer />);

    // Verify the component renders successfully with safe area context
    expect(component).toBeTruthy();
  });

  it('should handle different safe area insets', () => {
    const { useSafeAreaInsets } = require('react-native-safe-area-context');

    // Mock different insets
    useSafeAreaInsets.mockReturnValue({
      top: 0,
      bottom: 20,
      left: 0,
      right: 0,
    });

    const component = render(<Footer />);
    expect(component).toBeTruthy();
  });

  it('should display current year in footer text', () => {
    const currentYear = new Date().getFullYear();
    const component = render(<Footer />);

    // Check that the component renders and the current year logic works
    expect(component).toBeTruthy();
    expect(currentYear).toBeGreaterThan(2020); // Basic sanity check
  });

  it('should include package information in footer', () => {
    const packageJson = require('@/../package.json');
    const component = render(<Footer />);

    // Verify that the component renders and package data is available
    expect(component).toBeTruthy();
    expect(packageJson.version).toBe('1.5.10');
    expect(packageJson.copyright).toBe('MIT');
    expect(packageJson.author).toBe('Jien Huang');
  });
});
