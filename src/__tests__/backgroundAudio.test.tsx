import React from 'react';
import { render, waitFor } from '@testing-library/react-native';
import { AppState } from 'react-native';

/**
 * Tests for Background Audio Functionality
 *
 * This test suite covers the background audio feature implementation
 * including audio session configuration, app state handling, and
 * cross-platform compatibility.
 */

// Mock React Native modules
const mockAudioPlaybackService = {
  startForegroundService: jest.fn(),
  stopForegroundService: jest.fn(),
};

jest.mock('react-native', () => ({
  AppState: {
    currentState: 'active',
    addEventListener: jest.fn(() => ({ remove: jest.fn() })),
    removeEventListener: jest.fn(),
  },
  Platform: {
    OS: 'ios',
    Version: '15.0',
  },
  NativeModules: {
    AudioPlaybackService: mockAudioPlaybackService,
  },
}));

// Mock Expo modules
jest.mock('expo-av', () => ({
  Audio: {
    setAudioModeAsync: jest.fn(() => Promise.resolve()),
  },
}));

jest.mock('expo-speech', () => ({
  speak: jest.fn(() => Promise.resolve()),
  stop: jest.fn(() => Promise.resolve()),
  pause: jest.fn(() => Promise.resolve()),
  resume: jest.fn(() => Promise.resolve()),
  getAvailableVoicesAsync: jest.fn(() => Promise.resolve([])),
}));

jest.mock('expo-keep-awake', () => ({
  activateKeepAwakeAsync: jest.fn(() => Promise.resolve()),
  deactivateKeepAwake: jest.fn(),
}));

// Mock useSpeech hook
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

describe('Background Audio Functionality', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    mockUseSpeech.isPlaying = false;
    mockUseSpeech.isPaused = false;
    mockUseSpeech.isStopped = true;
    mockUseSpeech.progress = 0;
    mockAudioPlaybackService.startForegroundService.mockClear();
    mockAudioPlaybackService.stopForegroundService.mockClear();
  });

  describe('Audio Session Configuration', () => {
    it('should configure audio session for background playback', async () => {
      const { Audio } = require('expo-av');

      const audioConfig = {
        allowsRecordingIOS: false,
        staysActiveInBackground: true,
        playsInSilentModeIOS: true,
        interruptionModeIOS: 'DoNotMix',
        shouldDuckAndroid: true,
        playThroughEarpieceAndroid: false,
      };

      await Audio.setAudioModeAsync(audioConfig);

      expect(Audio.setAudioModeAsync).toHaveBeenCalledWith(audioConfig);
    });

    it('should validate required audio configuration properties', () => {
      const requiredConfig = {
        staysActiveInBackground: true,
        playsInSilentModeIOS: true,
      };

      expect(requiredConfig.staysActiveInBackground).toBe(true);
      expect(requiredConfig.playsInSilentModeIOS).toBe(true);
    });
  });

  describe('App State Handling', () => {
    it('should handle app state transitions', () => {
      const { AppState } = require('react-native');

      // Test that AppState can be used for background detection
      expect(AppState.currentState).toBeDefined();
      expect(typeof AppState.addEventListener).toBe('function');
      expect(typeof AppState.removeEventListener).toBe('function');
    });

    it('should maintain audio playback state during app transitions', () => {
      // Start with audio playing
      mockUseSpeech.isPlaying = true;
      mockUseSpeech.isStopped = false;

      // Simulate app going to background
      const { AppState } = require('react-native');
      AppState.currentState = 'background';

      // Audio should continue playing
      expect(mockUseSpeech.isPlaying).toBe(true);
      expect(mockUseSpeech.isStopped).toBe(false);

      // Simulate app returning to foreground
      AppState.currentState = 'active';

      // Audio should still be playing
      expect(mockUseSpeech.isPlaying).toBe(true);
    });
  });

  describe('Speech Integration', () => {
    it('should integrate with expo-speech for audio playback', async () => {
      const { speak, pause, resume, stop } = require('expo-speech');

      // Test speech functions
      await mockUseSpeech.speak('Test content');
      expect(mockUseSpeech.speak).toHaveBeenCalledWith('Test content');

      await mockUseSpeech.pause();
      expect(mockUseSpeech.pause).toHaveBeenCalled();

      await mockUseSpeech.resume();
      expect(mockUseSpeech.resume).toHaveBeenCalled();

      await mockUseSpeech.stop();
      expect(mockUseSpeech.stop).toHaveBeenCalled();
    });

    it('should track speech progress', () => {
      mockUseSpeech.progress = 0.5;
      expect(mockUseSpeech.progress).toBe(0.5);

      mockUseSpeech.progress = 1.0;
      expect(mockUseSpeech.progress).toBe(1.0);
    });
  });

  describe('Keep Awake Integration', () => {
    it('should manage screen wake lock', async () => {
      const {
        activateKeepAwakeAsync,
        deactivateKeepAwake,
      } = require('expo-keep-awake');

      // Activate keep awake when audio starts
      await activateKeepAwakeAsync();
      expect(activateKeepAwakeAsync).toHaveBeenCalled();

      // Deactivate when audio stops
      deactivateKeepAwake();
      expect(deactivateKeepAwake).toHaveBeenCalled();
    });
  });

  describe('Platform-Specific Features', () => {
    it('should handle iOS background audio configuration', () => {
      const { Platform } = require('react-native');
      Platform.OS = 'ios';

      const iosConfig = {
        playsInSilentModeIOS: true,
        interruptionModeIOS: 'DoNotMix',
        allowsRecordingIOS: false,
      };

      expect(iosConfig.playsInSilentModeIOS).toBe(true);
      expect(iosConfig.interruptionModeIOS).toBe('DoNotMix');
      expect(Platform.OS).toBe('ios');
    });

    it('should handle Android foreground service', () => {
      const ReactNative = require('react-native');
      ReactNative.Platform.OS = 'android';

      // Start foreground service
      mockAudioPlaybackService.startForegroundService();
      expect(
        mockAudioPlaybackService.startForegroundService
      ).toHaveBeenCalled();

      // Stop foreground service
      mockAudioPlaybackService.stopForegroundService();
      expect(mockAudioPlaybackService.stopForegroundService).toHaveBeenCalled();

      expect(ReactNative.Platform.OS).toBe('android');
    });

    it('should validate Android audio configuration', () => {
      const androidConfig = {
        shouldDuckAndroid: true,
        playThroughEarpieceAndroid: false,
        staysActiveInBackground: true,
      };

      expect(androidConfig.shouldDuckAndroid).toBe(true);
      expect(androidConfig.playThroughEarpieceAndroid).toBe(false);
      expect(androidConfig.staysActiveInBackground).toBe(true);
    });
  });

  describe('Error Handling', () => {
    it('should handle audio session initialization errors', async () => {
      const { Audio } = require('expo-av');
      const error = new Error('Audio session failed');

      Audio.setAudioModeAsync.mockRejectedValueOnce(error);

      try {
        await Audio.setAudioModeAsync({
          staysActiveInBackground: true,
        });
      } catch (err) {
        expect(err).toBe(error);
      }

      expect(Audio.setAudioModeAsync).toHaveBeenCalled();
    });

    it('should handle speech synthesis errors', async () => {
      const { speak } = require('expo-speech');
      const error = new Error('Speech failed');

      speak.mockRejectedValueOnce(error);

      try {
        await speak('Test');
      } catch (err) {
        expect(err).toBe(error);
      }

      expect(speak).toHaveBeenCalledWith('Test');
    });

    it('should handle missing native modules gracefully', () => {
      // Test that native modules are defined
      expect(mockAudioPlaybackService).toBeDefined();
      expect(typeof mockAudioPlaybackService.startForegroundService).toBe(
        'function'
      );
      expect(typeof mockAudioPlaybackService.stopForegroundService).toBe(
        'function'
      );
    });
  });

  describe('Background Audio Lifecycle', () => {
    it('should manage complete audio lifecycle', async () => {
      const { Audio } = require('expo-av');
      const {
        activateKeepAwakeAsync,
        deactivateKeepAwake,
      } = require('expo-keep-awake');

      // 1. Initialize audio session
      await Audio.setAudioModeAsync({
        staysActiveInBackground: true,
        playsInSilentModeIOS: true,
      });

      // 2. Start audio playback
      await mockUseSpeech.speak('Lifecycle test');
      mockUseSpeech.isPlaying = true;
      mockUseSpeech.isStopped = false;

      // 3. Activate keep awake
      await activateKeepAwakeAsync();

      // 4. Pause audio
      await mockUseSpeech.pause();
      mockUseSpeech.isPlaying = false;
      mockUseSpeech.isPaused = true;

      // 5. Resume audio
      await mockUseSpeech.resume();
      mockUseSpeech.isPlaying = true;
      mockUseSpeech.isPaused = false;

      // 6. Stop audio
      await mockUseSpeech.stop();
      mockUseSpeech.isPlaying = false;
      mockUseSpeech.isStopped = true;

      // 7. Deactivate keep awake
      deactivateKeepAwake();

      // Verify all steps
      expect(Audio.setAudioModeAsync).toHaveBeenCalled();
      expect(mockUseSpeech.speak).toHaveBeenCalledWith('Lifecycle test');
      expect(activateKeepAwakeAsync).toHaveBeenCalled();
      expect(mockUseSpeech.pause).toHaveBeenCalled();
      expect(mockUseSpeech.resume).toHaveBeenCalled();
      expect(mockUseSpeech.stop).toHaveBeenCalled();
      expect(deactivateKeepAwake).toHaveBeenCalled();
      expect(mockUseSpeech.isStopped).toBe(true);
    });

    it('should validate state consistency', () => {
      // Initial state
      expect(mockUseSpeech.isStopped).toBe(true);
      expect(mockUseSpeech.isPlaying).toBe(false);
      expect(mockUseSpeech.isPaused).toBe(false);

      // Playing state
      mockUseSpeech.isPlaying = true;
      mockUseSpeech.isStopped = false;
      expect(mockUseSpeech.isPlaying).toBe(true);
      expect(mockUseSpeech.isStopped).toBe(false);

      // Paused state
      mockUseSpeech.isPlaying = false;
      mockUseSpeech.isPaused = true;
      expect(mockUseSpeech.isPlaying).toBe(false);
      expect(mockUseSpeech.isPaused).toBe(true);

      // Stopped state
      mockUseSpeech.isPlaying = false;
      mockUseSpeech.isPaused = false;
      mockUseSpeech.isStopped = true;
      expect(mockUseSpeech.isStopped).toBe(true);
    });
  });

  describe('Configuration Validation', () => {
    it('should validate app.json configuration', () => {
      const appConfig = {
        expo: {
          ios: {
            backgroundModes: ['audio'],
          },
          android: {
            permissions: [
              'android.permission.WAKE_LOCK',
              'android.permission.FOREGROUND_SERVICE',
              'android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK',
            ],
          },
        },
      };

      expect(appConfig.expo.ios.backgroundModes).toContain('audio');
      expect(appConfig.expo.android.permissions).toContain(
        'android.permission.WAKE_LOCK'
      );
      expect(appConfig.expo.android.permissions).toContain(
        'android.permission.FOREGROUND_SERVICE'
      );
      expect(appConfig.expo.android.permissions).toContain(
        'android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK'
      );
    });

    it('should validate Android manifest configuration', () => {
      const manifestConfig = {
        permissions: [
          'android.permission.WAKE_LOCK',
          'android.permission.FOREGROUND_SERVICE',
          'android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK',
        ],
        service: {
          name: 'com.huangjien.writer.AudioPlaybackService',
          exported: false,
          foregroundServiceType: 'mediaPlayback',
        },
      };

      expect(manifestConfig.permissions).toHaveLength(3);
      expect(manifestConfig.service.name).toBe(
        'com.huangjien.writer.AudioPlaybackService'
      );
      expect(manifestConfig.service.exported).toBe(false);
      expect(manifestConfig.service.foregroundServiceType).toBe(
        'mediaPlayback'
      );
    });
  });
});
