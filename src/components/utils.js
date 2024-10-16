import { AysncStorage, Platform } from 'react-native';

export const saveDate = async (key, value) => {
  try {
    if (Platform.OS === 'web') {
      if (value) {
        localStorage.setItem(key, value);
      } else {
        localStorage.removeItem(key);
      }
    } else {
      if (value) {
        await AysncStorage.setItem(key, value);
      } else {
        await AysncStorage.removeItem(key);
      }
    }
  } catch (error) {
    console.error(error.message);
  }
};

export const readData = async (key) => {
  try {
    if (Platform.OS === 'web') {
      return localStorage.getItem(key);
    }
    return await AysncStorage.getItem(key);
  } catch (error) {
    console.error(error.message);
  }
};
