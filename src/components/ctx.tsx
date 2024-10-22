import {
  useState,
  useContext,
  createContext,
  PropsWithChildren,
  useEffect,
} from 'react';
import * as LocalAuthentication from 'expo-local-authentication';
import { Alert } from 'react-native';

const AuthContext = createContext(false);

export function useSession() {
  return useContext(AuthContext);
}

export function SessionProvider(props: PropsWithChildren) {
  const [isAuthenticated, setAuthenticated] = useState(false);
  return (
    <AuthContext.Provider value={isAuthenticated}>
      {props.children}
    </AuthContext.Provider>
  );
}
