# Background Audio Enhancement Implementation

## Overview

This document describes the enhanced background audio implementation for the Writer app, specifically addressing audio playback continuity when the screen is locked or the app goes to the background.

## Problem Statement

The original implementation had limitations with audio playback when:
- The device screen was turned off/locked
- The app was moved to the background
- Android devices experienced speech interruptions during background playback

## Solution Architecture

### 1. Audio Session Configuration

Implemented `expo-av` Audio.setAudioModeAsync configuration for proper background audio handling:

```typescript
const configureAudioSession = async () => {
  try {
    await Audio.setAudioModeAsync({
      allowsRecordingIOS: false,
      staysActiveInBackground: true,
      interruptionModeIOS: InterruptionModeIOS.DoNotMix,
      playsInSilentModeIOS: true,
      shouldDuckAndroid: true,
      playThroughEarpieceAndroid: false,
    });
  } catch (error) {
    console.log('Error configuring audio session:', error);
  }
};
```

**Key Configuration Options:**
- `staysActiveInBackground: true` - Enables background audio playback
- `interruptionModeIOS: InterruptionModeIOS.DoNotMix` - Prevents iOS from mixing with other audio
- `playsInSilentModeIOS: true` - Allows playback even when device is in silent mode
- `shouldDuckAndroid: true` - Reduces volume of other apps on Android

### 2. Enhanced Screen Lock Handling

Implemented platform-specific recovery mechanisms:

```typescript
const handleScreenLock = () => {
  if (status === STATUS_PLAYING) {
    enableKeepAwake();
    
    if (Platform.OS === 'android') {
      // More aggressive recovery for Android
      Speech.stop();
      setTimeout(() => {
        if (status === STATUS_PLAYING && !isPausedRef.current) {
          speakCurrentSentence();
        }
      }, 200);
    } else {
      // Gentler approach for iOS
      if (currentSentenceIndex < sentencesRef.current.length && !isPausedRef.current) {
        setTimeout(() => {
          if (status === STATUS_PLAYING) {
            speakCurrentSentence();
          }
        }, 100);
      }
    }
  }
};
```

### 3. Continuous Speech Monitoring

Added periodic monitoring to detect and recover from speech interruptions:

```typescript
useEffect(() => {
  let monitoringInterval: number | null = null;

  if (status === STATUS_PLAYING && Platform.OS === 'android') {
    monitoringInterval = setInterval(async () => {
      if (status === STATUS_PLAYING && !isPausedRef.current) {
        try {
          const isSpeaking = await Speech.isSpeakingAsync();
          if (!isSpeaking && currentSentenceIndex < sentencesRef.current.length) {
            console.log('Android: Speech stopped unexpectedly, recovering...');
            speakCurrentSentence();
          }
        } catch (error) {
          console.log('Android: Error monitoring speech, attempting recovery:', error);
          if (currentSentenceIndex < sentencesRef.current.length) {
            speakCurrentSentence();
          }
        }
      }
    }, 2000); // Check every 2 seconds
  }

  return () => {
    if (monitoringInterval) {
      clearInterval(monitoringInterval);
    }
  };
}, [status, currentSentenceIndex]);
```

### 4. Improved App State Management

Enhanced the app state change handler to better manage background transitions:

```typescript
const handleAppStateChange = (nextAppState: AppStateStatus) => {
  if (nextAppState === 'background' || nextAppState === 'inactive') {
    wasPlayingBeforeBackgroundRef.current = status === STATUS_PLAYING;
    
    if (status === STATUS_PLAYING) {
      enableKeepAwake();
      handleScreenLock();
      // Start monitoring speech continuity for Android
      if (Platform.OS === 'android') {
        setTimeout(() => monitorSpeechContinuity(), 500);
      }
    }
  } else if (nextAppState === 'active') {
    // Resume speech if it was interrupted
    if (wasPlayingBeforeBackgroundRef.current && 
        status !== STATUS_PLAYING && 
        !isPausedRef.current) {
      setStatus(STATUS_PLAYING);
      if (currentSentenceIndex < sentencesRef.current.length) {
        speakCurrentSentence();
      }
    }
  }
};
```

## Key Features

### 1. Platform-Specific Optimizations
- **Android**: Aggressive recovery with speech restart and continuous monitoring
- **iOS**: Gentler approach leveraging iOS's better background audio support

### 2. Multi-Layer Recovery
- Audio session configuration for system-level support
- App state monitoring for background/foreground transitions
- Screen lock detection and handling
- Continuous speech monitoring for Android
- Automatic speech resumption

### 3. Keep-Awake Integration
- Maintains device wake state during audio playback
- Automatically manages wake state based on playback status
- Prevents system sleep during critical audio operations

## Dependencies

- `expo-av`: Audio session configuration
- `expo-speech`: Text-to-speech functionality
- `expo-keep-awake`: Device wake state management
- `react-native`: Platform detection and app state monitoring

## Testing

The implementation includes comprehensive test coverage:
- Unit tests for all speech functions
- Background audio integration tests
- Platform-specific behavior tests
- App state transition tests

## Usage

The enhanced background audio functionality is automatically enabled when using the `useSpeech` hook. No additional configuration is required from the consumer side.

```typescript
import { useSpeech } from '@/hooks/useSpeech';

const MyComponent = () => {
  const { speak, stop, pause, resume, status } = useSpeech();
  
  // Audio will automatically continue in background
  const handleSpeak = () => {
    speak('Your text content here', {
      language: 'en',
      pitch: 1.0,
      rate: 1.0
    });
  };
  
  return (
    // Your component JSX
  );
};
```

## Performance Considerations

- Monitoring intervals are optimized to balance responsiveness with battery usage
- Platform-specific implementations minimize unnecessary operations
- Automatic cleanup prevents memory leaks
- Efficient state management reduces re-renders

## Future Enhancements

- Integration with media session API for better system integration
- Support for audio focus management
- Enhanced error recovery mechanisms
- Customizable monitoring intervals
- Background task scheduling for long-form content