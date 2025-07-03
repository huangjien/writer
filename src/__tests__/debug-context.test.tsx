import React from 'react';
import { renderHook } from '@testing-library/react-native';
import { useAsyncStorage } from '../hooks/useAsyncStorage';

describe('Debug Context Test', () => {
  it('should test useAsyncStorage without provider', () => {
    console.log('Testing direct hook call...');
    try {
      // Try calling the hook directly
      const directResult = useAsyncStorage();
      console.log('Direct call result:', directResult);
    } catch (error) {
      console.log('Direct call caught error:', error);
      console.log('Direct call error message:', (error as Error).message);
    }

    console.log('Testing renderHook call...');
    try {
      const result = renderHook(() => useAsyncStorage());
      console.log('RenderHook result keys:', Object.keys(result));
      console.log('RenderHook result:', result);
      console.log('RenderHook result.result:', result.result);
      console.log('RenderHook result.result.current:', result.result.current);
      // Check if there's an error property
      if ('error' in result) {
        console.log('RenderHook result.error:', (result as any).error);
      }
    } catch (error) {
      console.log('RenderHook caught error:', error);
      console.log('RenderHook error message:', (error as Error).message);
    }
  });
});
