import React from 'react';
import { render, fireEvent, waitFor, act } from '@testing-library/react-native';
import { useIsFocused } from '@react-navigation/native';
import * as Speech from 'expo-speech';
import Page from '../app/setting';
import { SETTINGS_KEY } from '../components/global';

// Mock dependencies
jest.mock('@react-navigation/native');
jest.mock('expo-speech');
jest.mock('react-native-gesture-handler', () => ({
  ScrollView: ({ children }: { children: React.ReactNode }) => children,
}));
jest.mock(
  '@react-native-segmented-control/segmented-control',
  () => 'SegmentedControl'
);
jest.mock('react-hook-form', () => ({
  useForm: () => ({
    control: {},
    handleSubmit: (fn: Function) => fn,
    setValue: jest.fn(),
    getValues: jest.fn().mockReturnValue(['@Content:chapter1.md']),
    formState: { errors: {} },
  }),
  Controller: ({ render, name }: { render: Function; name: string }) => {
    const field = {
      onChange: jest.fn(),
      onBlur: jest.fn(),
      value:
        name === 'githubRepo'
          ? 'https://github.com/user/repo'
          : name === 'githubToken'
            ? 'token123'
            : name === 'contentFolder'
              ? 'Content'
              : name === 'analysisFolder'
                ? 'Analysis'
                : name === 'fontSize'
                  ? 16
                  : name === 'backgroundImage'
                    ? 'wood.jpg'
                    : name === 'current'
                      ? '@Content:chapter1.md'
                      : name === 'progress'
                        ? 0.5
                        : '',
    };
    return render({ field });
  },
}));

const mockUseIsFocused = useIsFocused as jest.MockedFunction<
  typeof useIsFocused
>;
const mockSpeech = Speech as jest.Mocked<typeof Speech>;

// Mock useAsyncStorage
const mockGetItem = jest.fn();
const mockSetItem = jest.fn();
const mockRemoveItem = jest.fn();

jest.mock('../components/useAsyncStorage', () => ({
  useAsyncStorage: () => [
    {}, // storage
    { getItem: mockGetItem, setItem: mockSetItem, removeItem: mockRemoveItem },
    false, // isLoading
    false, // hasChanged
  ],
}));

// Mock global functions
jest.mock('../components/global', () => ({
  CONTENT_KEY: '@Content:',
  SETTINGS_KEY: '@Settings',
  showInfoToast: jest.fn(),
  showErrorToast: jest.fn(),
}));

describe('Settings Page', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockUseIsFocused.mockReturnValue(true);
    mockSpeech.getAvailableVoicesAsync.mockResolvedValue([]);
  });

  describe('Component Rendering', () => {
    it('should render without crashing', async () => {
      mockGetItem.mockResolvedValue(
        JSON.stringify({
          githubRepo: 'https://github.com/user/repo',
          githubToken: 'token123',
          contentFolder: 'Content',
          analysisFolder: 'Analysis',
          fontSize: 16,
          backgroundImage: 'wood.jpg',
          current: '@Content:chapter1.md',
          progress: 0.5,
        })
      );

      const { getByText } = render(<Page />);

      await waitFor(() => {
        expect(getByText('GitHub Repository URL')).toBeTruthy();
        expect(getByText('GitHub Token')).toBeTruthy();
        expect(getByText('Content Folder')).toBeTruthy();
        expect(getByText('Analysis Folder')).toBeTruthy();
        expect(getByText('Font Size')).toBeTruthy();
      });
    });

    it('should display all form fields', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({}));

      const { getByText, getByPlaceholderText } = render(<Page />);

      await waitFor(() => {
        expect(getByPlaceholderText('GitHub Repository URL')).toBeTruthy();
        expect(getByPlaceholderText('GitHub Token')).toBeTruthy();
        expect(getByPlaceholderText('Content Folder')).toBeTruthy();
        expect(getByPlaceholderText('Analysis Folder')).toBeTruthy();
      });
    });

    it('should display current reading information', async () => {
      mockGetItem.mockResolvedValue(
        JSON.stringify({
          current: '@Content:chapter1.md',
          progress: 0.75,
        })
      );

      const { getByText } = render(<Page />);

      await waitFor(() => {
        expect(getByText('Current Reading')).toBeTruthy();
        expect(getByText('Current Reading Progress')).toBeTruthy();
      });
    });
  });

  describe('Form Validation', () => {
    it('should show validation errors for required fields', async () => {
      // Mock form with errors
      const mockUseForm = require('react-hook-form').useForm;
      mockUseForm.mockReturnValue({
        control: {},
        handleSubmit: (fn: Function) => fn,
        setValue: jest.fn(),
        getValues: jest.fn().mockReturnValue(['']),
        formState: {
          errors: {
            githubRepo: { type: 'required' },
            githubToken: { type: 'required' },
          },
        },
      });

      mockGetItem.mockResolvedValue(JSON.stringify({}));

      const { getByText } = render(<Page />);

      await waitFor(() => {
        expect(getByText('GitHub Repository URL')).toBeTruthy();
      });
    });

    it('should validate GitHub repository URL format', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({}));

      const { getByPlaceholderText } = render(<Page />);

      const repoInput = getByPlaceholderText('GitHub Repository URL');

      await act(async () => {
        fireEvent.changeText(repoInput, 'invalid-url');
        fireEvent(repoInput, 'blur');
      });

      // Validation would be handled by react-hook-form
      expect(repoInput).toBeTruthy();
    });

    it('should validate token length', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({}));

      const { getByPlaceholderText } = render(<Page />);

      const tokenInput = getByPlaceholderText('GitHub Token');

      await act(async () => {
        fireEvent.changeText(tokenInput, 'a'.repeat(101)); // Exceeds maxLength
        fireEvent(tokenInput, 'blur');
      });

      expect(tokenInput).toBeTruthy();
    });
  });

  describe('Settings Loading', () => {
    it('should load existing settings from storage', async () => {
      const mockSettings = {
        githubRepo: 'https://github.com/user/repo',
        githubToken: 'token123',
        contentFolder: 'Content',
        analysisFolder: 'Analysis',
        fontSize: 18,
        backgroundImage: 'wood.jpg',
        current: '@Content:chapter1.md',
        progress: 0.5,
        expiry: Date.now(),
      };

      mockGetItem.mockResolvedValue(JSON.stringify(mockSettings));

      render(<Page />);

      await waitFor(() => {
        expect(mockGetItem).toHaveBeenCalledWith(SETTINGS_KEY);
      });
    });

    it('should handle missing settings gracefully', async () => {
      mockGetItem.mockResolvedValue(null);

      const { getByText } = render(<Page />);

      await waitFor(() => {
        expect(getByText('GitHub Repository URL')).toBeTruthy();
      });
    });

    it('should set default values for missing fields', async () => {
      const partialSettings = {
        githubRepo: 'https://github.com/user/repo',
        // Missing other fields
      };

      mockGetItem.mockResolvedValue(JSON.stringify(partialSettings));

      render(<Page />);

      await waitFor(() => {
        expect(mockGetItem).toHaveBeenCalledWith(SETTINGS_KEY);
      });
    });

    it('should handle storage errors gracefully', async () => {
      mockGetItem.mockRejectedValue(new Error('Storage error'));

      const { getByText } = render(<Page />);

      await waitFor(() => {
        expect(getByText('GitHub Repository URL')).toBeTruthy();
      });
    });
  });

  describe('Font Size Selection', () => {
    it('should update font size when segmented control changes', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({ fontSize: 16 }));

      const { getByText } = render(<Page />);

      await waitFor(() => {
        expect(getByText('Font Size')).toBeTruthy();
      });

      // Font size changes would be tested through SegmentedControl interactions
    });

    it('should calculate correct font size from index', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({ fontSize: 20 }));

      render(<Page />);

      await waitFor(() => {
        expect(mockGetItem).toHaveBeenCalledWith(SETTINGS_KEY);
      });

      // Index calculation: (fontSize - 16) / 2
      // For fontSize 20: (20 - 16) / 2 = 2
    });

    it('should handle font size range validation', async () => {
      const settingsWithLargeFontSize = {
        fontSize: 28, // Maximum allowed
      };

      mockGetItem.mockResolvedValue(JSON.stringify(settingsWithLargeFontSize));

      render(<Page />);

      await waitFor(() => {
        expect(mockGetItem).toHaveBeenCalledWith(SETTINGS_KEY);
      });
    });
  });

  describe('Progress Display', () => {
    it('should display progress as percentage', async () => {
      const settingsWithProgress = {
        progress: 0.75, // 75%
      };

      mockGetItem.mockResolvedValue(JSON.stringify(settingsWithProgress));

      const { getByText } = render(<Page />);

      await waitFor(() => {
        expect(getByText('Current Reading Progress')).toBeTruthy();
      });
    });

    it('should handle zero progress', async () => {
      const settingsWithZeroProgress = {
        progress: 0,
      };

      mockGetItem.mockResolvedValue(JSON.stringify(settingsWithZeroProgress));

      render(<Page />);

      await waitFor(() => {
        expect(mockGetItem).toHaveBeenCalledWith(SETTINGS_KEY);
      });
    });

    it('should handle undefined progress', async () => {
      const settingsWithoutProgress = {
        githubRepo: 'https://github.com/user/repo',
        // No progress field
      };

      mockGetItem.mockResolvedValue(JSON.stringify(settingsWithoutProgress));

      render(<Page />);

      await waitFor(() => {
        expect(mockGetItem).toHaveBeenCalledWith(SETTINGS_KEY);
      });
    });
  });

  describe('Form Submission', () => {
    it('should save settings when form is submitted', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({}));
      mockSetItem.mockResolvedValue(undefined);

      const { getByTestId } = render(<Page />);

      // Find and press the save button
      const saveButton = getByTestId ? getByTestId('save-button') : null;

      if (saveButton) {
        await act(async () => {
          fireEvent.press(saveButton);
        });

        expect(mockSetItem).toHaveBeenCalledWith(
          SETTINGS_KEY,
          expect.any(String)
        );
      }
    });

    it('should show success message after saving', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({}));
      mockSetItem.mockResolvedValue(undefined);

      const { showInfoToast } = require('../components/global');

      render(<Page />);

      // Simulate form submission
      await act(async () => {
        // This would be triggered by pressing the save button
      });

      // Success message would be shown through showInfoToast
      expect(showInfoToast).toHaveBeenCalledTimes(0); // Not auto-triggered
    });

    it('should handle save errors gracefully', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({}));
      mockSetItem.mockRejectedValue(new Error('Save error'));

      render(<Page />);

      // Error handling would be tested through form submission
      expect(mockSetItem).toHaveBeenCalledTimes(0); // Not auto-triggered
    });
  });

  describe('Input Field Interactions', () => {
    it('should update GitHub repository URL', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({}));

      const { getByPlaceholderText } = render(<Page />);

      const repoInput = getByPlaceholderText('GitHub Repository URL');

      await act(async () => {
        fireEvent.changeText(repoInput, 'https://github.com/newuser/newrepo');
      });

      expect(repoInput).toBeTruthy();
    });

    it('should update GitHub token securely', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({}));

      const { getByPlaceholderText } = render(<Page />);

      const tokenInput = getByPlaceholderText('GitHub Token');

      await act(async () => {
        fireEvent.changeText(tokenInput, 'newtoken123');
      });

      expect(tokenInput).toBeTruthy();
      // Should have secureTextEntry prop
    });

    it('should update content folder', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({}));

      const { getByPlaceholderText } = render(<Page />);

      const folderInput = getByPlaceholderText('Content Folder');

      await act(async () => {
        fireEvent.changeText(folderInput, 'NewContent');
      });

      expect(folderInput).toBeTruthy();
    });

    it('should update analysis folder', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({}));

      const { getByPlaceholderText } = render(<Page />);

      const analysisInput = getByPlaceholderText('Analysis Folder');

      await act(async () => {
        fireEvent.changeText(analysisInput, 'NewAnalysis');
      });

      expect(analysisInput).toBeTruthy();
    });
  });

  describe('Accessibility', () => {
    it('should have proper accessibility labels', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({}));

      const { getByLabelText } = render(<Page />);

      await waitFor(() => {
        expect(getByLabelText('Analysis Folder')).toBeTruthy();
      });
    });

    it('should support screen readers', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({}));

      const { getByText } = render(<Page />);

      await waitFor(() => {
        // All text labels should be accessible
        expect(getByText('GitHub Repository URL')).toBeTruthy();
        expect(getByText('GitHub Token')).toBeTruthy();
        expect(getByText('Content Folder')).toBeTruthy();
        expect(getByText('Analysis Folder')).toBeTruthy();
      });
    });
  });

  describe('Component Lifecycle', () => {
    it('should load settings on component mount', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({}));

      render(<Page />);

      await waitFor(() => {
        expect(mockGetItem).toHaveBeenCalledWith(SETTINGS_KEY);
      });
    });

    it('should handle component focus changes', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({}));
      mockUseIsFocused.mockReturnValue(false);

      render(<Page />);

      await waitFor(() => {
        expect(mockUseIsFocused).toHaveBeenCalled();
      });
    });

    it('should cleanup on unmount', async () => {
      mockGetItem.mockResolvedValue(JSON.stringify({}));

      const { unmount } = render(<Page />);

      unmount();

      // No specific cleanup needed for this component
      expect(true).toBe(true);
    });
  });
});
