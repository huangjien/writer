# Test Fixes Action Plan

*Generated on: 2025-07-03T17:07:03.800Z*

## Overview

This document provides a systematic approach to fixing the 124 failing tests in the project. The failures are primarily due to infrastructure issues rather than logic problems.

## Priority 1: Fix Test Infrastructure

### 1.1 Jest Configuration Issues

**Problem**: Module resolution errors for `@/components/use-theme-config`

**Solution**: Update `package.json` or `jest.config.js`:

```json
{
  "jest": {
    "moduleNameMapper": {
      "^@/(.*)$": "<rootDir>/src/$1"
    }
  }
}
```

### 1.2 Exclude Setup Files from Test Discovery

**Problem**: `setup.ts` and `test-utils.tsx` being treated as test suites

**Solution**: Update Jest configuration:

```json
{
  "jest": {
    "testMatch": [
      "**/__tests__/**/*.(test|spec).(ts|tsx|js|jsx)"
    ],
    "testPathIgnorePatterns": [
      "<rootDir>/src/__tests__/setup.ts",
      "<rootDir>/src/__tests__/test-utils.tsx"
    ]
  }
}
```

## Priority 2: Fix useThemeConfig Tests (22 failures)

### 2.1 Root Cause Analysis

- Hook returning `null` instead of expected object
- Missing AsyncStorageProvider wrapper
- Incorrect mock setup

### 2.2 Solution Steps

1. **Update test wrapper**:

```typescript
// In use-theme-config.test.tsx
const TestWrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  return (
    <AsyncStorageProvider>
      {children}
    </AsyncStorageProvider>
  );
};

// Use wrapper in renderHook
const { result } = renderHook(() => useThemeConfig(), {
  wrapper: TestWrapper,
});
```

2. **Fix mock setup**:

```typescript
// Ensure proper mock return values
mockUseColorScheme.mockReturnValue({
  colorScheme: 'light',
  setColorScheme: mockSetColorScheme,
  toggleColorScheme: mockToggleColorScheme,
});
```

3. **Add null checks in tests**:

```typescript
it('should return initial theme configuration', () => {
  const { result } = renderHook(() => useThemeConfig(), {
    wrapper: TestWrapper,
  });

  expect(result.current).not.toBeNull();
  expect(result.current.theme).toBeDefined();
  expect(result.current.themeName).toBe('light');
  expect(typeof result.current.setSelectedTheme).toBe('function');
});
```

## Priority 3: Fix useAsyncStorage Tests

### 3.1 Root Cause Analysis

- Context not properly initialized
- Mock conflicts between different test files
- Missing provider context

### 3.2 Solution Steps

1. **Create isolated test setup**:

```typescript
// In each useAsyncStorage test file
const mockAsyncStorage = {
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  getAllKeys: jest.fn(() => Promise.resolve([])),
  multiGet: jest.fn(() => Promise.resolve([])),
};

jest.mock('@react-native-async-storage/async-storage', () => mockAsyncStorage);
```

2. **Ensure proper provider wrapping**:

```typescript
const TestComponent = () => {
  const storage = useAsyncStorage();
  return null;
};

const TestWrapper = ({ children }: { children: React.ReactNode }) => (
  <AsyncStorageProvider>{children}</AsyncStorageProvider>
);

// Test with proper error handling
it('should throw error when used outside provider', () => {
  expect(() => {
    render(<TestComponent />); // Without wrapper
  }).toThrow('useAsyncStorage must be used within an AsyncStorageProvider');
});
```

## Priority 4: Fix SpeechService Tests

### 4.1 Root Cause Analysis

- Mock functions not being called as expected
- Incomplete mock setup for toast notifications
- Missing external dependency mocks

### 4.2 Solution Steps

1. **Complete mock setup**:

```typescript
// Mock all external dependencies
const mockShowErrorToast = jest.fn();
const mockSpeech = {
  speak: jest.fn(),
  stop: jest.fn(),
  isSpeakingAsync: jest.fn(() => Promise.resolve(false)),
};

jest.mock('expo-speech', () => mockSpeech);
jest.mock('@/components/global', () => ({
  showErrorToast: mockShowErrorToast,
}));
```

2. **Fix test expectations**:

```typescript
it('should show error when content is too long', async () => {
  const longContent = 'a'.repeat(5000); // Ensure content is actually too long
  mockGetItem.mockResolvedValue(longContent);
  
  await speechService.speak('chapter1', 0);
  
  expect(mockShowErrorToast).toHaveBeenCalledWith(
    'Content is too long to be handled by TTS engine'
  );
  expect(mockSpeech.speak).not.toHaveBeenCalled();
});
```

## Priority 5: Fix Module Resolution

### 5.1 Update Path Mappings

**File**: `tsconfig.json`

```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["src/*"]
    }
  }
}
```

**File**: `jest.config.js` or `package.json`

```javascript
module.exports = {
  moduleNameMapper: {
    '^@/(.*)$': '<rootDir>/src/$1',
  },
  // ... other config
};
```

## Implementation Timeline

### Week 1: Infrastructure Fixes
- [ ] Update Jest configuration
- [ ] Fix module resolution
- [ ] Exclude setup files from test discovery

### Week 2: Core Hook Tests
- [ ] Fix useThemeConfig tests (22 failures)
- [ ] Fix useAsyncStorage tests
- [ ] Verify hook functionality

### Week 3: Service Tests
- [ ] Fix SpeechService tests
- [ ] Complete mock setups
- [ ] Add missing test cases

### Week 4: Validation
- [ ] Run full test suite
- [ ] Verify coverage improvements
- [ ] Document remaining issues

## Success Metrics

- [ ] Reduce failing tests from 124 to < 10
- [ ] Achieve > 50% overall test coverage
- [ ] All infrastructure tests passing
- [ ] No module resolution errors

## Testing Commands

```bash
# Test specific areas
npm test -- src/__tests__/hooks/use-theme-config.test.tsx
npm test -- src/__tests__/useAsyncStorage
npm test -- src/__tests__/services/speechService.test.ts

# Run all tests
npm test -- --watchAll=false

# Generate coverage
npm test -- --coverage --watchAll=false
```

## Notes

- Focus on fixing infrastructure before adding new tests
- Maintain the working enhanced test suite as a reference
- Document any breaking changes
- Consider creating a separate test configuration for problematic tests

---

*This action plan should be executed systematically to ensure stable test infrastructure before expanding test coverage.*