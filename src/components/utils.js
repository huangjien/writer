import { AysncStorage} from 'react-native'

export const saveDate = async (key, value) => {
    try{
        await AysncStorage.setItem(key, value);
    } catch (error) {
        console.error(error.message);
    }
}

export const readData = async (key) => {
    try {
        return await AysncStorage.getItem(key)
    } catch (error) {
        console.error(error.message);
    }
}