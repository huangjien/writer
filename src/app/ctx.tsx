import {useState, useContext, createContext, PropsWithChildren, useEffect} from 'react'
import * as LocalAuthentication from 'expo-local-authentication';
import { Alert } from 'react-native';

const AuthContext = createContext(false)

export function useSession() {
    return  useContext(AuthContext);
}

export function SessionProvider(props: PropsWithChildren) {
    const [isBiometricSupported, setIsBiometricSupported] = useState(false);
    // Check if hardware supports biometrics
    useEffect(() => {
        (async () => {
        const compatible = await LocalAuthentication.hasHardwareAsync();
        setIsBiometricSupported(compatible);
        })();
    });
    const [isAuthenticated, setIsAuthenticated] = useState(false);

    const handleBiometricAuth = async () => {
        const savedBiometrics = await LocalAuthentication.isEnrolledAsync();
        if (!savedBiometrics)
          return Alert.alert(
            'No Biometrics Authentication',
            'Please verify your identity with your password',
            [{ text: 'OK', onPress: () => console.log('OK Pressed') }],
            { cancelable: false }
          );
        const biometricAuth = await LocalAuthentication.authenticateAsync({
          promptMessage: "You need to be this device's owner to use this app",
          disableDeviceFallback: false,
        });
        console.log(biometricAuth.success);
        setIsAuthenticated(biometricAuth.success);
        
      };

    const signIn = () => {
        handleBiometricAuth();
    };

    const signOut = () => {
        setIsAuthenticated(false);
    };
    return (
        <AuthContext.Provider
            value={isAuthenticated}
        >
            {props.children}
        </AuthContext.Provider>
    )
}
