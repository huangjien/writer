import {
  useState,
  useContext,
  createContext,
  PropsWithChildren,
  useEffect,
} from 'react';
import * as LocalAuthentication from 'expo-local-authentication';
import { Alert } from 'react-native';

const AuthContext = createContext({isAuthenticated:false, expiry: Date.now()+1000*60*60*8});

export function useSession() {
  return useContext(AuthContext);
}

export function SessionProvider(props: PropsWithChildren) {
  const [isAuthenticated, setAuthenticated] = useState(false);
  const [expiry, setExpiry] = useState(Date.now()+1000*60*60*8);
  return (
    <AuthContext.Provider value={{isAuthenticated, expiry}}>
      {props.children}
    </AuthContext.Provider>
  );
}
