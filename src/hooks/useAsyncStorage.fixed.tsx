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

// Types
type StorageOperations = {
  getItem: (key: string) => Promise<string | null>;
  setItem: (key: string, value: string) => Promise<void>;
  removeItem: (key: string) => Promise<void>;
};

type StorageState = [
  Record<string, string | null>,
  StorageOperations,
  boolean,
  number,
];

// Storage interface for dependency injection
interface IAsyncStorage {
  getAllKeys(): Promise<readonly string[]>;
  multiGet(
    keys: readonly string[]
  ): Promise<readonly [string, string | null][]>;
  getItem(key: string): Promise<string | null>;
  setItem(key: string, value: string): Promise<void>;
  removeItem(key: string): Promise<void>;
}

// Context
const StorageContext = createContext<StorageState | null>(null);

// Provider props
interface AsyncStorageProviderProps {
  children: ReactNode;
  asyncStorage?: IAsyncStorage;
}

export function AsyncStorageProvider({
  children,
  asyncStorage = AsyncStorage,
}: AsyncStorageProviderProps) {
  const [storage, setStorage] = useState<Record<string, string | null>>({});
  const [isLoading, setIsLoading] = useState(true);
  const [hasChanged, setHasChanged] = useState(0);

  // Initialize storage
  useEffect(() => {
    const loadInitialStorage = async () => {
      setIsLoading(true);
      try {
        const keys = await asyncStorage.getAllKeys();
        const result = await asyncStorage.multiGet(keys);
        const initialStorage = Object.fromEntries(result);
        setStorage(initialStorage);
      } catch (error) {
        console.error('Error loading initial storage:', error);
        setStorage({});
      } finally {
        setIsLoading(false);
      }
    };

    loadInitialStorage();
  }, [asyncStorage]);

  const getItem = useCallback(
    async (key: string): Promise<string | null> => {
      setIsLoading(true);
      try {
        const value = await asyncStorage.getItem(key);
        setStorage((prev) => ({ ...prev, [key]: value }));
        return value;
      } catch (error) {
        console.error('Error getting item:', error);
        return null;
      } finally {
        setIsLoading(false);
      }
    },
    [asyncStorage]
  );

  const setItem = useCallback(
    async (key: string, value: string): Promise<void> => {
      setIsLoading(true);
      try {
        await asyncStorage.setItem(key, value);
        setStorage((prev) => ({ ...prev, [key]: value }));
        setHasChanged((prev) => prev + 1);
      } catch (error) {
        console.error('Error setting item:', error);
        throw error;
      } finally {
        setIsLoading(false);
      }
    },
    [asyncStorage]
  );

  const removeItem = useCallback(
    async (key: string): Promise<void> => {
      setIsLoading(true);
      try {
        await asyncStorage.removeItem(key);
        setStorage((prev) => {
          const newStorage = { ...prev };
          delete newStorage[key];
          return newStorage;
        });
        setHasChanged((prev) => prev + 1);
      } catch (error) {
        console.error('Error removing item:', error);
        throw error;
      } finally {
        setIsLoading(false);
      }
    },
    [asyncStorage]
  );

  const operations: StorageOperations = useMemo(
    () => ({
      getItem,
      setItem,
      removeItem,
    }),
    [getItem, setItem, removeItem]
  );

  const value: StorageState = useMemo(
    () => [storage, operations, isLoading, hasChanged],
    [storage, operations, isLoading, hasChanged]
  );

  return (
    <StorageContext.Provider value={value}>{children}</StorageContext.Provider>
  );
}

export function useAsyncStorage(): StorageState {
  const context = useContext(StorageContext);
  if (context === null) {
    throw new Error(
      'useAsyncStorage must be used within an AsyncStorageProvider'
    );
  }
  return context;
}

// Export for testing
export { type IAsyncStorage };
