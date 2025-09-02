/**
 * TypeScript interfaces and types for speech functionality
 */

export interface SpeechOptions {
  language?: string;
  pitch?: number;
  rate?: number;
  onDone?: () => void;
}

export interface SpeechState {
  status: string;
  progress: number;
  currentSentenceIndex: number;
}

export interface SpeechRefs {
  sentences: string[];
  totalContentLength: number;
  completedContentLength: number;
  isPaused: boolean;
  wasPlayingBeforeBackground: boolean;
  wasPlayingBeforeInterruption: boolean;
  audioInterruptionListener: any;
  speechOptions: SpeechOptions;
}

export interface AudioSessionConfig {
  allowsRecordingIOS: boolean;
  staysActiveInBackground: boolean;
  playsInSilentModeIOS: boolean;
  shouldDuckAndroid?: boolean;
  playThroughEarpieceAndroid: boolean;
  interruptionModeIOS?: any;
}

export interface MediaSessionOptions {
  waitForBuffer: boolean;
  autoHandleInterruptions: boolean;
}

export interface SpeechHookReturn {
  status: string;
  progress: number;
  currentSentenceIndex: number;
  speak: (content: string, options?: SpeechOptions) => void;
  stop: () => void;
  pause: () => void;
  resume: () => void;
}

export interface SentenceProcessingResult {
  sentences: string[];
  totalSentences: number;
  totalCharacters: number;
  averageSentenceLength: number;
  isValid: boolean;
}

export interface ProgressUpdate {
  sentenceProgress: number;
  characterProgress: number;
  currentSentence: number;
  totalSentences: number;
  isComplete: boolean;
}
