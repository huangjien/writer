/**
 * Clean test for useAsyncStorage hook error handling
 */
import React from 'react';
import { render } from '@testing-library/react-native';
import { renderHook } from '@testing-library/react-native';

// Import the hook directly without any mocks
import { useAsyncStorage } from '../hooks/useAsyncStorage';

// Test component that uses the hook
function TestComponent() {
  const storage = useAsyncStorage();
  return null;
}

describe('useAsyncStorage Error Handling - Clean Test', () => {
  it('should throw error when used outside provider in component', () => {
    console.log('Testing component that uses hook...');

    // Mock console.error to avoid noise in test output
    const originalError = console.error;
    console.error = jest.fn();

    expect(() => {
      render(<TestComponent />);
    }).toThrow('useAsyncStorage must be used within an AsyncStorageProvider');

    // Restore console.error
    console.error = originalError;
  });

  it('should handle error with renderHook outside provider', () => {
    console.log('Testing renderHook behavior...');

    // Mock console.error to avoid noise in test output
    const originalError = console.error;
    console.error = jest.fn();

    // renderHook should throw when the hook throws
    expect(() => {
      renderHook(() => useAsyncStorage());
    }).toThrow();

    // Restore console.error
    console.error = originalError;
  });
});
