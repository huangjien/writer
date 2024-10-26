import AsyncStorage from '@react-native-async-storage/async-storage';

// components/global.tsx
export const SETTINGS_KEY = '@Settings';
export const CONTENT_KEY = '@Content:';
export const ANALYSIS_KEY = '@Analysis:';
export const STATUS_PLAYING = 'playing';
export const STATUS_PAUSED = 'paused';
export const STATUS_STOPPED = 'stopped';

export const getStoredSettings = AsyncStorage.getItem(SETTINGS_KEY).then(
  (data) => {
    if (data) {
      const parsedData = JSON.parse(data);
      return parsedData;
    }
    return undefined;
  }
);

// Define a function named fileNameComparator that takes two parameters, a and b, of type any and returns a number
export function fileNameComparator(a: any, b: any): number {
  // Extract the number from the name property of object a by splitting it at the underscore and parsing the first part as an integer
  const aNumber = parseFloat(a.name.split('_')[0]);
  // Extract the number from the name property of object b by splitting it at the underscore and parsing the first part as an integer
  const bNumber = parseFloat(b.name.split('_')[0]);

  // Compare the extracted numbers
  if (aNumber < bNumber) {
    // If aNumber is less than bNumber, return -1 to indicate that a should come before b in the sorted array
    return -1;
  } else if (aNumber > bNumber) {
    // If aNumber is greater than bNumber, return 1 to indicate that b should come before a in the sorted array
    return 1;
  } else {
    // If aNumber is equal to bNumber, return 0 to indicate that the order of a and b should remain unchanged in the sorted array
    return 0;
  }
}
