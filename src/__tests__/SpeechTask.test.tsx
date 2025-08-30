// TypeScript global declarations
declare global {
  namespace NodeJS {
    interface Global {
      capturedTaskFunction: any;
      mockDefineTaskCalls: any[];
    }
  }
}

// Make global available in this context
declare const global: NodeJS.Global & typeof globalThis;

import * as TaskManager from 'expo-task-manager';
// Import the entire module to ensure the task is registered
import '../components/SpeechTask';
import { SPEECH_TASK, speechService } from '../components/SpeechTask';
import { speechService as importedSpeechService } from '../services/speechService';

// Mock TaskManager with spy to track calls
let taskFunction:
  | ((params: { data?: any; error?: any }) => Promise<void>)
  | null = null;

const mockDefineTask = jest.fn();

jest.mock('expo-task-manager', () => {
  return {
    defineTask: jest.fn((taskName: string, taskFn: any) => {
      // Store in global scope for test access
      (global as any).capturedTaskFunction = taskFn;
      (global as any).mockDefineTaskCalls =
        (global as any).mockDefineTaskCalls || [];
      (global as any).mockDefineTaskCalls.push([taskName, taskFn]);
    }),
  };
});

// Mock speechService
jest.mock('../services/speechService', () => ({
  speechService: {
    speak: jest.fn(),
    stop: jest.fn(),
    pause: jest.fn(),
    resume: jest.fn(),
    isSpeaking: jest.fn(),
    getNext: jest.fn(),
  },
}));

const mockSpeechService = importedSpeechService as jest.Mocked<
  typeof importedSpeechService
>;

// Mock console methods to avoid noise in tests
const originalConsoleLog = console.log;
const originalConsoleError = console.error;
beforeAll(() => {
  console.log = jest.fn();
  console.error = jest.fn();
});

afterAll(() => {
  console.log = originalConsoleLog;
  console.error = originalConsoleError;
});

describe('SpeechTask', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    // Reset all mock implementations
    mockSpeechService.speak.mockResolvedValue(undefined);
    mockSpeechService.stop.mockReturnValue(undefined);
    // Update local reference to captured function
    taskFunction = (global as any).capturedTaskFunction;
  });

  describe('SPEECH_TASK constant', () => {
    it('should have correct task name', () => {
      expect(SPEECH_TASK).toBe('background-speech-task');
    });
  });

  describe('speechService export', () => {
    it('should export speechService from the module', () => {
      expect(speechService).toBeDefined();
      expect(speechService).toBe(importedSpeechService);
    });

    it('should have all required speechService methods', () => {
      expect(speechService).toHaveProperty('speak');
      expect(speechService).toHaveProperty('stop');
      expect(speechService).toHaveProperty('pause');
      expect(speechService).toHaveProperty('resume');
      expect(speechService).toHaveProperty('isSpeaking');
      expect(speechService).toHaveProperty('getNext');
    });
  });

  describe('TaskManager integration', () => {
    it('should register task with TaskManager', () => {
      const calls = (global as any).mockDefineTaskCalls || [];
      expect(calls.length).toBeGreaterThan(0);
      expect(calls[0][0]).toBe('background-speech-task');
      expect(typeof calls[0][1]).toBe('function');
    });

    it('should register task function that can be called', () => {
      expect(taskFunction).toBeDefined();
      expect(typeof taskFunction).toBe('function');
    });
  });

  describe('task function execution', () => {
    it('should handle error parameter and log error', async () => {
      if (!taskFunction) {
        throw new Error('Task function not defined');
      }

      const error = new Error('Test error');
      await taskFunction({ error });

      expect(console.error).toHaveBeenCalledWith('Task Manager Error:', error);
      expect(mockSpeechService.speak).not.toHaveBeenCalled();
      expect(mockSpeechService.stop).not.toHaveBeenCalled();
    });

    it('should stop speech when no data is provided', async () => {
      if (!taskFunction) {
        throw new Error('Task function not defined');
      }

      await taskFunction({});

      expect(console.log).toHaveBeenCalledWith(
        'No data provided, stopping speech'
      );
      expect(mockSpeechService.stop).toHaveBeenCalled();
      expect(mockSpeechService.speak).not.toHaveBeenCalled();
    });

    it('should call speechService.speak with valid data', async () => {
      if (!taskFunction) {
        throw new Error('Task function not defined');
      }

      const data = {
        current: 'chapter1.md',
        progress: 50,
      };

      await taskFunction({ data });

      expect(console.log).toHaveBeenCalledWith(
        'Data provided, calling speak with:',
        'chapter1.md',
        50
      );
      expect(mockSpeechService.speak).toHaveBeenCalledWith('chapter1.md', 50, {
        language: 'zh',
        voice: 'zh',
      });
      expect(mockSpeechService.stop).not.toHaveBeenCalled();
    });

    it('should call speechService.speak with partial data', async () => {
      if (!taskFunction) {
        throw new Error('Task function not defined');
      }

      const data = {
        current: 'chapter2.md',
        progress: undefined,
      };

      await taskFunction({ data });

      expect(console.log).toHaveBeenCalledWith(
        'Invalid data provided, ignoring task execution:',
        data
      );
      expect(mockSpeechService.speak).not.toHaveBeenCalled();
    });

    it('should handle speechService.speak throwing an error', async () => {
      if (!taskFunction) {
        throw new Error('Task function not defined');
      }

      const data = {
        current: 'chapter1.md',
        progress: 0,
      };

      mockSpeechService.speak.mockRejectedValue(new Error('Speech error'));

      // The task function doesn't handle errors, so it should throw
      await expect(taskFunction({ data })).rejects.toThrow('Speech error');

      expect(mockSpeechService.speak).toHaveBeenCalledWith('chapter1.md', 0, {
        language: 'zh',
        voice: 'zh',
      });
    });

    it('should log task execution details', async () => {
      if (!taskFunction) {
        throw new Error('Task function not defined');
      }

      const data = { current: 'test.md' };
      const error = null;

      await taskFunction({ data, error });

      expect(console.log).toHaveBeenCalledWith(
        'TaskManager.defineTask called with:',
        { data, error }
      );
    });

    it('should handle empty data object', async () => {
      if (!taskFunction) {
        throw new Error('Task function not defined');
      }

      const data = {};

      await taskFunction({ data });

      expect(console.log).toHaveBeenCalledWith(
        'Invalid data provided, ignoring task execution:',
        data
      );
      expect(mockSpeechService.speak).not.toHaveBeenCalled();
    });
  });
});
