import { Link } from 'expo-router';
import React, { useEffect, useState } from 'react';
import { Alert, Pressable, Text, View } from 'react-native';
import { Feather } from '@expo/vector-icons';
import * as LocalAuthentication from 'expo-local-authentication';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';
import { ScrollView } from 'react-native-gesture-handler';

export default function Page() {
  const [settings, setSettings] = useState({});
  const [content, setContent] = useState([]);
  const [analysis, setAnalysis] = useState([]);

  useEffect(() => {
    AsyncStorage.getItem('@Settings').then((data) => {
      if (data) {
        const parsedData = JSON.parse(data);
        setSettings(parsedData);
        return parsedData;
      }
    }).then(data => {
      console.log(data)
      const contentFolder = getFolderAndMdfiles(data['contentFolder'])
      contentFolder.then(data => {
      setContent(data);
      return data
      });
    }).then(data => {
      const analysisFolder = getFolderAndMdfiles(data['analysisFolder'])
      analysisFolder.then(data => {
      setAnalysis(data);
      return data
      });
    });
  },[]);

  const getFolderAndMdfiles = async (folder) => {
    try{
      console.log('https://api.github.com/repos/' + settings['githubRepo'] + '/contents/'+ folder)
      return await fetch('https://api.github.com/repos/' + settings['githubRepo'] + '/contents/'+ folder, {
        method: 'GET',
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'X-GitHub-Api-Version': '2022-11-28',
          'Authorization': 'token ' + settings['githubToken'],
        }
      }).then(response => {return response.json()})
    } catch(error) {
      console.error(error);
    }
  }

  return (
    <>
      {(!settings['githubRepo'] ||
        !settings['githubToken'] ||
        !settings['contentFolder'] ||
        !settings['analysisFolder']) && (
        <View className='flex-1'>
          <View className='py-12 md:py-24 lg:py-32 xl:py-48'>
            <View className='px-4 md:px-6'>
              <View className='flex flex-col items-center gap-4 text-center'>
                <Text
                  role='heading'
                  className='text-2xl text-center native:text-5xl font-bold tracking-tighter sm:text-4xl md:text-5xl lg:text-6xl'
                >
                  Welcome to Project writer
                </Text>
              </View>
            </View>
          </View>
        </View>
      )}
      {settings['githubRepo'] &&
        settings['githubToken'] &&
        settings['contentFolder'] &&
        settings['analysisFolder'] && (
          <View className='flex-1'>
            <View className='py-12 md:py-24 lg:py-32 xl:py-48'>
              <View className='px-4 md:px-6 flex flex-col items-center gap-4 text-center text-2xl native:text-5xl font-bold tracking-tighter sm:text-4xl md:text-5xl lg:text-6xl'>
                <ScrollView >
                  <Text
                    role='heading'
                    
                  >
                    {JSON.stringify(content, null , 2)}
                  </Text>
                </ScrollView>
              </View>
            </View>
          </View>
        )}
    </>
  );
}
