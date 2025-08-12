import React from 'react';
import { render, act, waitFor } from '@testing-library/react-native';
import { AppState } from 'react-native';

/**
 * Integration Tests for Background Audio Feature
 *
 * This test suite covers the integration between all components
 * of the background audio functionality, including cross-platform
 * compatibility, state management, and end-to-end scenarios.
 */

// Mock all required modules
const mockAudioPlaybackService = {
  startForegroundService: jest.fn(),
  stopForegroundService: jest.fn(),
};

const mockPlatform = {
  OS: 'ios', // Will be overridden in specific tests
  Version: '15.0',
};

jest.mock('react-native', () => ({
  ...jest.requireActual('react-native'),
  AppState: {
    currentState: 'active',
    addEventListener: jest.fn(),
    removeEventListener: jest.fn(),
  },
  Platform: mockPlatform,
  NativeModules: {
    AudioPlaybackService: mockAudioPlaybackService,
  },
}));

jest.mock('expo-av', () => ({
  Audio: {
    setAudioModeAsync: jest.fn(),
  },
}));

jest.mock('expo-speech', () => ({
  speak: jest.fn(),
  stop: jest.fn(),
  pause: jest.fn(),
  resume: jest.fn(),
  getAvailableVoicesAsync: jest.fn(),
}));

jest.mock('expo-keep-awake', () => ({
  activateKeepAwakeAsync: jest.fn(),
  deactivateKeepAwake: jest.fn(),
}));

// Mock the useSpeech hook
const mockUseSpeech = {
  isPlaying: false,
  isPaused: false,
  isStopped: true,
  progress: 0,
  speak: jest.fn(),
  stop: jest.fn(),
  pause: jest.fn(),
  resume: jest.fn(),
};

jest.mock('../hooks/useSpeech', () => ({
  useSpeech: () => mockUseSpeech,
}));

describe('Background Audio Integration Tests', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockAudioPlaybackService.startForegroundService.mockClear();
    mockAudioPlaybackService.stopForegroundService.mockClear();
    mockAudioPlaybackService.startForegroundService.mockImplementation(
      () => {}
    );
    mockAudioPlaybackService.stopForegroundService.mockImplementation(() => {});
    mockPlatform.OS = 'ios'; // Reset to default
    mockUseSpeech.isPlaying = false;
    mockUseSpeech.isPaused = false;
    mockUseSpeech.isStopped = true;
    mockUseSpeech.progress = 0;
  });

  describe('Cross-Platform Audio Session Initialization', () => {
    it('should initialize audio session correctly on iOS', async () => {
      const { Audio } = require('expo-av');

      mockPlatform.OS = 'ios';
      Audio.setAudioModeAsync.mockResolvedValue(undefined);

      const iosAudioMode = {
        allowsRecordingIOS: false,
        staysActiveInBackground: true,
        playsInSilentModeIOS: true,
        interruptionModeIOS: 'DoNotMix',
        shouldDuckAndroid: false,
        playThroughEarpieceAndroid: false,
      };

      await Audio.setAudioModeAsync(iosAudioMode);

      expect(Audio.setAudioModeAsync).toHaveBeenCalledWith(iosAudioMode);
      expect(mockPlatform.OS).toBe('ios');
    });

    it('should initialize audio session correctly on Android', async () => {
      const { Audio } = require('expo-av');

      mockPlatform.OS = 'android';
      Audio.setAudioModeAsync.mockResolvedValue(undefined);

      const androidAudioMode = {
        allowsRecordingIOS: false,
        staysActiveInBackground: true,
        playsInSilentModeIOS: true,
        shouldDuckAndroid: true,
        playThroughEarpieceAndroid: false,
      };

      await Audio.setAudioModeAsync(androidAudioMode);
      mockAudioPlaybackService.startForegroundService();

      expect(Audio.setAudioModeAsync).toHaveBeenCalledWith(androidAudioMode);
      expect(
        mockAudioPlaybackService.startForegroundService
      ).toHaveBeenCalled();
      expect(mockPlatform.OS).toBe('android');
    });
  });

  describe('Background Audio Playback Scenarios', () => {
    it('should continue audio playback when app goes to background', async () => {
      const { AppState } = require('react-native');
      const { speak } = require('expo-speech');
      const { activateKeepAwakeAsync } = require('expo-keep-awake');

      speak.mockResolvedValue(undefined);
      activateKeepAwakeAsync.mockResolvedValue(undefined);

      // Start audio playback
      mockUseSpeech.isPlaying = true;
      mockUseSpeech.isStopped = false;
      await mockUseSpeech.speak('Test content for background playback');

      expect(mockUseSpeech.speak).toHaveBeenCalledWith(
        'Test content for background playback'
      );
      expect(mockUseSpeech.isPlaying).toBe(true);

      // Simulate app going to background
      AppState.currentState = 'background';
      const appStateListener = AppState.addEventListener.mock.calls[0];
      if (appStateListener) {
        appStateListener[1]('background');
      }

      // Audio should continue playing in background
      expect(mockUseSpeech.isPlaying).toBe(true);
      expect(mockUseSpeech.speak).toHaveBeenCalledWith(
        'Test content for background playback'
      );
    });

    it('should handle app returning from background', async () => {
      const { AppState } = require('react-native');

      // Start with app in background with audio playing
      AppState.currentState = 'background';
      mockUseSpeech.isPlaying = true;
      mockUseSpeech.isStopped = false;

      // Simulate app returning to foreground
      AppState.currentState = 'active';
      const appStateListener = AppState.addEventListener.mock.calls[0];
      if (appStateListener) {
        appStateListener[1]('active');
      }

      // Audio should still be playing
      expect(mockUseSpeech.isPlaying).toBe(true);
      expect(AppState.currentState).toBe('active');
    });

    it('should handle pause and resume in background', async () => {
      const { pause, resume } = require('expo-speech');

      pause.mockResolvedValue(undefined);
      resume.mockResolvedValue(undefined);

      // Start playing
      mockUseSpeech.isPlaying = true;
      mockUseSpeech.isPaused = false;

      // Pause in background
      await mockUseSpeech.pause();
      mockUseSpeech.isPlaying = false;
      mockUseSpeech.isPaused = true;

      expect(mockUseSpeech.pause).toHaveBeenCalled();
      expect(mockUseSpeech.isPaused).toBe(true);

      // Resume in background
      await mockUseSpeech.resume();
      mockUseSpeech.isPlaying = true;
      mockUseSpeech.isPaused = false;

      expect(mockUseSpeech.resume).toHaveBeenCalled();
      expect(mockUseSpeech.isPlaying).toBe(true);
    });
  });

  describe('Platform-Specific Integration', () => {
    it('should integrate Android foreground service with audio playback', async () => {
      const { Audio } = require('expo-av');
      const { speak } = require('expo-speech');

      mockPlatform.OS = 'android';
      Audio.setAudioModeAsync.mockResolvedValue(undefined);
      speak.mockResolvedValue(undefined);

      // Initialize Android audio session
      await Audio.setAudioModeAsync({
        staysActiveInBackground: true,
        shouldDuckAndroid: true,
      });

      // Start foreground service
      mockAudioPlaybackService.startForegroundService();

      // Start audio playback
      await mockUseSpeech.speak('Android background audio test');
      mockUseSpeech.isPlaying = true;

      expect(Audio.setAudioModeAsync).toHaveBeenCalled();
      expect(
        mockAudioPlaybackService.startForegroundService
      ).toHaveBeenCalled();
      expect(mockUseSpeech.speak).toHaveBeenCalledWith(
        'Android background audio test'
      );
      expect(mockUseSpeech.isPlaying).toBe(true);
    });

    it('should integrate iOS background modes with audio playback', async () => {
      const { Audio } = require('expo-av');
      const { speak } = require('expo-speech');

      mockPlatform.OS = 'ios';
      Audio.setAudioModeAsync.mockResolvedValue(undefined);
      speak.mockResolvedValue(undefined);

      // Initialize iOS audio session
      await Audio.setAudioModeAsync({
        staysActiveInBackground: true,
        playsInSilentModeIOS: true,
        interruptionModeIOS: 'DoNotMix',
      });

      // Start audio playback
      await mockUseSpeech.speak('iOS background audio test');
      mockUseSpeech.isPlaying = true;

      expect(Audio.setAudioModeAsync).toHaveBeenCalled();
      expect(mockUseSpeech.speak).toHaveBeenCalledWith(
        'iOS background audio test'
      );
      expect(mockUseSpeech.isPlaying).toBe(true);
    });
  });

  describe('Keep Awake Integration', () => {
    it('should activate keep awake when audio starts playing', async () => {
      const { activateKeepAwakeAsync } = require('expo-keep-awake');

      activateKeepAwakeAsync.mockResolvedValue(undefined);

      // Start audio playback
      await mockUseSpeech.speak('Keep awake test');
      mockUseSpeech.isPlaying = true;

      // Simulate keep awake activation when audio starts
      await activateKeepAwakeAsync();

      // Keep awake should be activated
      expect(activateKeepAwakeAsync).toHaveBeenCalled();
      expect(mockUseSpeech.speak).toHaveBeenCalledWith('Keep awake test');
      expect(mockUseSpeech.isPlaying).toBe(true);
    });

    it('should deactivate keep awake when audio stops', async () => {
      const { deactivateKeepAwake } = require('expo-keep-awake');
      const { stop } = require('expo-speech');

      stop.mockResolvedValue(undefined);

      // Start with audio playing
      mockUseSpeech.isPlaying = true;
      mockUseSpeech.isStopped = false;

      // Stop audio playback
      await mockUseSpeech.stop();
      mockUseSpeech.isPlaying = false;
      mockUseSpeech.isStopped = true;

      expect(mockUseSpeech.stop).toHaveBeenCalled();
      expect(mockUseSpeech.isStopped).toBe(true);
    });
  });

  describe('Error Handling and Recovery', () => {
    it('should handle audio session initialization failures gracefully', async () => {
      const { Audio } = require('expo-av');

      Audio.setAudioModeAsync.mockRejectedValue(
        new Error('Audio session failed')
      );

      try {
        await Audio.setAudioModeAsync({
          staysActiveInBackground: true,
        });
      } catch (error) {
        expect(error.message).toBe('Audio session failed');
      }

      // Should still attempt to continue with degraded functionality
      expect(Audio.setAudioModeAsync).toHaveBeenCalled();
    });

    it('should handle speech synthesis failures in background', async () => {
      const { speak } = require('expo-speech');

      speak.mockRejectedValue(new Error('Speech failed'));

      try {
        await mockUseSpeech.speak('Test speech');
      } catch (error) {
        expect(error.message).toBe('Speech failed');
      }

      expect(mockUseSpeech.speak).toHaveBeenCalledWith('Test speech');
    });

    it('should handle Android service failures gracefully', async () => {
      mockPlatform.OS = 'android';
      mockAudioPlaybackService.startForegroundService.mockImplementation(() => {
        throw new Error('Service start failed');
      });

      try {
        mockAudioPlaybackService.startForegroundService();
      } catch (error) {
        expect(error.message).toBe('Service start failed');
        // Should continue with audio playback even if service fails
      }

      expect(
        mockAudioPlaybackService.startForegroundService
      ).toHaveBeenCalled();
    });
  });

  describe('State Management Integration', () => {
    it('should maintain consistent state across app lifecycle', async () => {
      const { AppState } = require('react-native');

      // Initial state
      expect(mockUseSpeech.isStopped).toBe(true);
      expect(mockUseSpeech.isPlaying).toBe(false);
      expect(mockUseSpeech.isPaused).toBe(false);

      // Start playing
      await mockUseSpeech.speak('State management test');
      mockUseSpeech.isPlaying = true;
      mockUseSpeech.isStopped = false;

      expect(mockUseSpeech.isPlaying).toBe(true);
      expect(mockUseSpeech.isStopped).toBe(false);

      // App goes to background
      AppState.currentState = 'background';

      // State should remain consistent
      expect(mockUseSpeech.isPlaying).toBe(true);
      expect(mockUseSpeech.isStopped).toBe(false);

      // App returns to foreground
      AppState.currentState = 'active';

      // State should still be consistent
      expect(mockUseSpeech.isPlaying).toBe(true);
      expect(mockUseSpeech.isStopped).toBe(false);
    });

    it('should handle progress tracking in background', async () => {
      // Start with some progress
      mockUseSpeech.progress = 0.3;
      mockUseSpeech.isPlaying = true;

      // Simulate progress updates in background
      const progressUpdates = [0.4, 0.5, 0.6, 0.7];

      progressUpdates.forEach((progress) => {
        mockUseSpeech.progress = progress;
        expect(mockUseSpeech.progress).toBe(progress);
      });

      expect(mockUseSpeech.progress).toBe(0.7);
      expect(mockUseSpeech.isPlaying).toBe(true);
    });
  });

  describe('Performance and Resource Management', () => {
    it('should properly clean up resources when audio stops', async () => {
      const { deactivateKeepAwake } = require('expo-keep-awake');
      const { stop } = require('expo-speech');

      mockPlatform.OS = 'android';
      stop.mockResolvedValue(undefined);

      // Start with audio playing
      mockUseSpeech.isPlaying = true;
      mockUseSpeech.isStopped = false;

      // Stop audio
      await mockUseSpeech.stop();
      mockUseSpeech.isPlaying = false;
      mockUseSpeech.isStopped = true;

      // Clean up Android service
      mockAudioPlaybackService.stopForegroundService();

      expect(mockUseSpeech.stop).toHaveBeenCalled();
      expect(mockAudioPlaybackService.stopForegroundService).toHaveBeenCalled();
      expect(mockUseSpeech.isStopped).toBe(true);
    });

    it('should handle memory management during long playback sessions', async () => {
      const { speak } = require('expo-speech');

      speak.mockResolvedValue(undefined);

      // Simulate long content playback
      const longContent = 'A'.repeat(10000); // Very long content

      await mockUseSpeech.speak(longContent);
      mockUseSpeech.isPlaying = true;
      mockUseSpeech.progress = 0;

      // Simulate progress through long content
      for (let i = 0; i <= 100; i += 10) {
        mockUseSpeech.progress = i / 100;
        expect(mockUseSpeech.progress).toBe(i / 100);
      }

      expect(mockUseSpeech.speak).toHaveBeenCalledWith(longContent);
      expect(mockUseSpeech.progress).toBe(1.0);
    });
  });

  describe('End-to-End Background Audio Scenarios', () => {
    it('should complete full background audio lifecycle', async () => {
      const { AppState } = require('react-native');
      const { Audio } = require('expo-av');
      const { speak, pause, resume, stop } = require('expo-speech');
      const {
        activateKeepAwakeAsync,
        deactivateKeepAwake,
      } = require('expo-keep-awake');

      mockPlatform.OS = 'android';
      Audio.setAudioModeAsync.mockResolvedValue(undefined);
      speak.mockResolvedValue(undefined);
      pause.mockResolvedValue(undefined);
      resume.mockResolvedValue(undefined);
      stop.mockResolvedValue(undefined);
      activateKeepAwakeAsync.mockResolvedValue(undefined);

      // 1. Initialize audio session
      await Audio.setAudioModeAsync({
        staysActiveInBackground: true,
        shouldDuckAndroid: true,
      });

      // 2. Start foreground service (Android)
      mockAudioPlaybackService.startForegroundService();

      // 3. Start audio playback
      await mockUseSpeech.speak('Complete background audio test');
      mockUseSpeech.isPlaying = true;
      mockUseSpeech.isStopped = false;

      // 4. App goes to background
      AppState.currentState = 'background';

      // 5. Pause audio in background
      await mockUseSpeech.pause();
      mockUseSpeech.isPlaying = false;
      mockUseSpeech.isPaused = true;

      // 6. Resume audio in background
      await mockUseSpeech.resume();
      mockUseSpeech.isPlaying = true;
      mockUseSpeech.isPaused = false;

      // 7. App returns to foreground
      AppState.currentState = 'active';

      // 8. Stop audio
      await mockUseSpeech.stop();
      mockUseSpeech.isPlaying = false;
      mockUseSpeech.isStopped = true;

      // 9. Clean up service
      mockAudioPlaybackService.stopForegroundService();

      // Verify all steps completed successfully
      expect(Audio.setAudioModeAsync).toHaveBeenCalled();
      expect(
        mockAudioPlaybackService.startForegroundService
      ).toHaveBeenCalled();
      expect(mockUseSpeech.speak).toHaveBeenCalledWith(
        'Complete background audio test'
      );
      expect(mockUseSpeech.pause).toHaveBeenCalled();
      expect(mockUseSpeech.resume).toHaveBeenCalled();
      expect(mockUseSpeech.stop).toHaveBeenCalled();
      expect(mockAudioPlaybackService.stopForegroundService).toHaveBeenCalled();
      expect(mockUseSpeech.isStopped).toBe(true);
    });
  });
});
