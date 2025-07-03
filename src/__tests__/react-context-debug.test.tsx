import React, { createContext, useContext } from 'react';
import { renderHook } from '@testing-library/react-native';

// Create a simple test context
const TestContext = createContext<string | null>(null);

function useTestContext() {
  const context = useContext(TestContext);
  if (!context) {
    throw new Error('useTestContext must be used within a TestProvider');
  }
  return context;
}

describe('React Context Debug', () => {
  it('should throw error when context is null', () => {
    console.log('Testing React context behavior...');

    // Test direct hook call
    try {
      const result = useTestContext();
      console.log('Direct call result:', result);
    } catch (error) {
      console.log('Direct call error:', (error as Error).message);
    }

    // Test with renderHook
    try {
      const result = renderHook(() => useTestContext());
      console.log('RenderHook result:', result.result.current);
    } catch (error) {
      console.log('RenderHook error:', (error as Error).message);
    }

    // Test the expect pattern
    expect(() => {
      useTestContext();
    }).toThrow('useTestContext must be used within a TestProvider');
  });
});
