import {
  useState,
  useCallback,
  useEffect,
  useMemo,
  createContext,
  ReactNode,
  useContext,
} from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

type StorageOperations = {
  getItem: (key: string) => Promise<string>;
  setItem: (key: string, value: string) => Promise<void>;
  removeItem: (key: string) => Promise<void>;
};

type StorageState = [
  Record<string, string>,
  StorageOperations,
  boolean,
  number,
];

const StorageContext = createContext<StorageState | null>(null);

export function AsyncStorageProvider({ children }: { children: ReactNode }) {
  const [storage, setStorage] = useState<Record<string, string>>({});
  const [isLoading, setIsLoading] = useState(true);
  const [hasChanged, setHasChanged] = useState(0);

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

  const getItem = useCallback(async (key: string): Promise<string> => {
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
        setHasChanged((prev) => prev + 1);
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

  const value = useMemo<StorageState>(
    () => [storage, operations, isLoading, hasChanged],
    [storage, operations, isLoading, hasChanged]
  );

  return (
    <StorageContext.Provider value={value}>{children}</StorageContext.Provider>
  );
}

export function useAsyncStorage(): StorageState {
  const context = useContext(StorageContext);
  if (!context) {
    throw new Error(
      'useAsyncStorage must be used within an AsyncStorageProvider'
    );
  }
  return context;
}
