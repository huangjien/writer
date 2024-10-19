import { Text, View, TextInput, Button, Alert } from "react-native"
import AsyncStorage from '@react-native-async-storage/async-storage'
import { useState } from 'react';
import { useForm, Controller } from "react-hook-form"

const {
  control,
  handleSubmit,
  formState: { errors },
} = useForm({
  defaultValues: {
    githubRepo: "",
    githubToken: "",
    contentFolder: "Content",
    analysisFoler: "Analysis"
  },
})
const onSubmit = (data) => console.log(data)

export default function Page() {
  const [settings, setSettings] = useState([]); 
  
  const setValues = async (values) => {
    await AsyncStorage.setItem("@Settings", values)
  }
  
  AsyncStorage.getItem('@Settings')
  return (
    <View>
      <Controller
        control={control}
        rules={{
          required: true,
        }}
        render={({ field: { onChange, onBlur, value } }) => (
          <TextInput
            placeholder="GitHub Repository URL"
            onBlur={onBlur}
            onChangeText={onChange}
            value={value}
          />
        )}
        name="githubRepo"
      />
      {errors.githubRepo && <Text>This is required.</Text>}

      <Controller
        control={control}
        rules={{
          maxLength: 100,
        }}
        render={({ field: { onChange, onBlur, value } }) => (
          <TextInput
            placeholder="Last name"
            onBlur={onBlur}
            onChangeText={onChange}
            value={value}
          />
        )}
        name="githubToken"
      />

      <Button title="Submit" onPress={handleSubmit(onSubmit)} />
    </View>
  )
}