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

// Storage manager class for better testability
class StorageManager {
  private storage: Record<string, string | null> = {};
  private isLoading = false;
  private hasChanged = 0;
  private asyncStorage: IAsyncStorage;

  constructor(asyncStorage: IAsyncStorage = AsyncStorage) {
    this.asyncStorage = asyncStorage;
  }

  async initialize(): Promise<Record<string, string | null>> {
    try {
      const keys = await this.asyncStorage.getAllKeys();
      const result = await this.asyncStorage.multiGet(keys);
      this.storage = Object.fromEntries(result);
      return this.storage;
    } catch (error) {
      console.error('Error loading initial storage:', error);
      return {};
    }
  }

  async getItem(key: string): Promise<string | null> {
    try {
      const value = await this.asyncStorage.getItem(key);
      this.storage = { ...this.storage, [key]: value };
      return value;
    } catch (error) {
      console.error('Error getting item:', error);
      return null;
    }
  }

  async setItem(key: string, value: string): Promise<void> {
    try {
      await this.asyncStorage.setItem(key, value);
      this.storage = { ...this.storage, [key]: value };
      this.hasChanged += 1;
    } catch (error) {
      console.error('Error setting item:', error);
      throw error;
    }
  }

  async removeItem(key: string): Promise<void> {
    try {
      await this.asyncStorage.removeItem(key);
      const newStorage = { ...this.storage };
      delete newStorage[key];
      this.storage = newStorage;
      this.hasChanged += 1;
    } catch (error) {
      console.error('Error removing item:', error);
      throw error;
    }
  }

  getStorage(): Record<string, string | null> {
    return this.storage;
  }

  getHasChanged(): number {
    return this.hasChanged;
  }

  setStorage(storage: Record<string, string | null>): void {
    this.storage = storage;
  }

  setHasChanged(count: number): void {
    this.hasChanged = count;
  }
}

// Context
const StorageContext = createContext<StorageState | null>(null);

// Provider props
interface AsyncStorageProviderProps {
  children: ReactNode;
  asyncStorage?: IAsyncStorage;
  storageManager?: StorageManager;
}

export function AsyncStorageProvider({
  children,
  asyncStorage,
  storageManager: injectedStorageManager,
}: AsyncStorageProviderProps) {
  const [storage, setStorage] = useState<Record<string, string | null>>({});
  const [isLoading, setIsLoading] = useState(true);
  const [hasChanged, setHasChanged] = useState(0);

  // Use injected storage manager or create a new one
  const storageManager = useMemo(
    () => injectedStorageManager || new StorageManager(asyncStorage),
    [asyncStorage, injectedStorageManager]
  );

  useEffect(() => {
    const loadInitialStorage = async () => {
      setIsLoading(true);
      try {
        const initialStorage = await storageManager.initialize();
        setStorage(initialStorage);
        setHasChanged(storageManager.getHasChanged());
      } finally {
        setIsLoading(false);
      }
    };

    loadInitialStorage();
  }, [storageManager]);

  const getItem = useCallback(
    async (key: string): Promise<string | null> => {
      setIsLoading(true);
      try {
        const value = await storageManager.getItem(key);
        setStorage(storageManager.getStorage());
        return value;
      } finally {
        setIsLoading(false);
      }
    },
    [storageManager]
  );

  const setItem = useCallback(
    async (key: string, value: string): Promise<void> => {
      setIsLoading(true);
      try {
        await storageManager.setItem(key, value);
        setStorage(storageManager.getStorage());
        setHasChanged(storageManager.getHasChanged());
      } finally {
        setIsLoading(false);
      }
    },
    [storageManager]
  );

  const removeItem = useCallback(
    async (key: string): Promise<void> => {
      setIsLoading(true);
      try {
        await storageManager.removeItem(key);
        setStorage(storageManager.getStorage());
        setHasChanged(storageManager.getHasChanged());
      } finally {
        setIsLoading(false);
      }
    },
    [storageManager]
  );

  const operations: StorageOperations = useMemo(
    () => ({
      getItem,
      setItem,
      removeItem,
    }),
    [getItem, setItem, removeItem]
  );

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

// Export for testing
export { StorageManager, type IAsyncStorage };
