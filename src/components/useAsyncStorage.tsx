import { useState, useCallback, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

type StorageOperations = {
  getItem: (key: string) => Promise<string | null>;
  setItem: (key: string, value: string) => Promise<void>;
  removeItem: (key: string) => Promise<void>;
};

function useAsyncStorage(): [
  Record<string, string | null>,
  StorageOperations,
  boolean,
] {
  const [storage, setStorage] = useState<Record<string, string | null>>({});
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const loadInitialStorage = async () => {
      try {
        const keys = await AsyncStorage.getAllKeys();
        const result = await AsyncStorage.multiGet(keys);
        const initialStorage = Object.fromEntries(result);
        setStorage(initialStorage);
      } catch (error) {
        console.error('Error loading initial storage:', error);
      } finally {
        setIsLoading(false);
      }
    };

    loadInitialStorage();
  }, []);

  const getItem = useCallback(async (key: string): Promise<string | null> => {
    try {
      const value = await AsyncStorage.getItem(key);
      setStorage((prev) => ({ ...prev, [key]: value }));
      return value;
    } catch (error) {
      console.error('Error getting item:', error);
      return null;
    }
  }, []);

  const setItem = useCallback(
    async (key: string, value: string): Promise<void> => {
      try {
        await AsyncStorage.setItem(key, value);
        setStorage((prev) => ({ ...prev, [key]: value }));
      } catch (error) {
        console.error('Error setting item:', error);
      }
    },
    []
  );

  const removeItem = useCallback(async (key: string): Promise<void> => {
    try {
      await AsyncStorage.removeItem(key);
      setStorage((prev) => {
        const newStorage = { ...prev };
        delete newStorage[key];
        return newStorage;
      });
    } catch (error) {
      console.error('Error removing item:', error);
    }
  }, []);

  const operations: StorageOperations = {
    getItem,
    setItem,
    removeItem,
  };

  return [storage, operations, isLoading];
}

export default useAsyncStorage;
