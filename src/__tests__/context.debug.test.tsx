import React, { createContext, useContext } from 'react';
import { renderHook } from '@testing-library/react-native';

// Simple test context
const TestContext = createContext<string | null>(null);

function TestProvider({ children }: { children: React.ReactNode }) {
  return (
    <TestContext.Provider value='test-value'>{children}</TestContext.Provider>
  );
}

function useTestContext() {
  const context = useContext(TestContext);
  if (!context) {
    throw new Error('useTestContext must be used within TestProvider');
  }
  return context;
}

describe('Context Debug Test', () => {
  it('should throw error when used outside provider', () => {
    expect(() => {
      renderHook(() => useTestContext());
    }).toThrow('useTestContext must be used within TestProvider');
  });

  it('should work when used with provider', () => {
    const wrapper = ({ children }: { children: React.ReactNode }) => (
      <TestProvider>{children}</TestProvider>
    );

    const { result } = renderHook(() => useTestContext(), { wrapper });
    expect(result.current).toBe('test-value');
  });
});
