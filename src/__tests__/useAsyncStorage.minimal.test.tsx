import React from 'react';
import { useAsyncStorage } from '../hooks/useAsyncStorage';

// Minimal test to isolate the error throwing behavior
describe('useAsyncStorage minimal test', () => {
  it('should throw error when used outside provider', () => {
    // Mock console.error to avoid noise
    const consoleErrorSpy = jest.spyOn(console, 'error').mockImplementation();

    let thrownError: Error | null = null;

    // Create a test component that calls the hook
    const TestComponent = () => {
      try {
        useAsyncStorage();
        return React.createElement('div', null, 'Should not reach here');
      } catch (error) {
        thrownError = error as Error;
        throw error; // Re-throw to be caught by test
      }
    };

    // Test that rendering the component throws
    expect(() => {
      React.createElement(TestComponent);
      // Actually call the component function to trigger the hook
      TestComponent();
    }).toThrow('useAsyncStorage must be used within an AsyncStorageProvider');

    consoleErrorSpy.mockRestore();
  });
});
