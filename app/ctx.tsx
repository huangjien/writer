import {useState, useContext, createContext, PropsWithChildren} from 'react'
import * as LocalAuthentication from 'expo-local-authentication';

const AuthContext = createContext(false)

export function useSession() {
    return  useContext(AuthContext);
}

export function SessionProvider(props: PropsWithChildren) {
    const [isAuthenticated, setIsAuthenticated] = useState(false);

    const signIn = () => {
        setIsAuthenticated(true);
    };

    const signOut = () => {
        setIsAuthenticated(false);
    };
    return (
        <AuthContext.Provider
            value={{
                signIn,signOut,
                isAuthenticated
            }}
        >
            {props.children}
        </AuthContext.Provider>
    )
}