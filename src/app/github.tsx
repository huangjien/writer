import React, { useEffect, useState } from 'react';
import { Text, View } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';
import { ScrollView } from 'react-native-gesture-handler';
import { useRouter } from 'expo-router';
import { components } from '@octokit/openapi-types';
import Toast from 'react-native-root-toast';
import { useIsFocused } from '@react-navigation/native';
import {
  ANALYSIS_KEY,
  CONTENT_KEY,
  getStoredSettings,
  SETTINGS_KEY,
} from '../components/global';

type RepoContent = components['schemas']['content-file'];

function elementWithNameExists(array: any[], nameToFind: string): boolean {
  return array.some((element) => element.name === nameToFind);
}

// Define a function named fileNameComparator that takes two parameters, a and b, of type any and returns a number
function fileNameComparator(a: any, b: any): number {
  // Extract the number from the name property of object a by splitting it at the underscore and parsing the first part as an integer
  const aNumber = parseFloat(a.name.split('_')[0]);
  // Extract the number from the name property of object b by splitting it at the underscore and parsing the first part as an integer
  const bNumber = parseFloat(b.name.split('_')[0]);

  // Compare the extracted numbers
  if (aNumber < bNumber) {
    // If aNumber is less than bNumber, return -1 to indicate that a should come before b in the sorted array
    return -1;
  } else if (aNumber > bNumber) {
    // If aNumber is greater than bNumber, return 1 to indicate that b should come before a in the sorted array
    return 1;
  } else {
    // If aNumber is equal to bNumber, return 0 to indicate that the order of a and b should remain unchanged in the sorted array
    return 0;
  }
}

export default function Page() {
  const [settings, setSettings] = useState({});
  const [content, setContent] = useState([]);
  const [analysis, setAnalysis] = useState([]);
  const router = useRouter();

  // const {isFocused} = useIsFocused()

  useEffect(() => {
    if (settings) {
      getFolderAndMdfiles(settings['analysisFolder']).then((data) => {
        if (!data) {
          return;
        }
        setAnalysis(data);
        saveToStorage(ANALYSIS_KEY, data);
      });

      getFolderAndMdfiles(settings['contentFolder']).then((data) => {
        if (!data) {
          return;
        }
        saveToStorage(CONTENT_KEY, data);
        // return data;
      });
    }
  }, [settings]);

  useEffect(() => {
    getStoredSettings
      .then((data) => {
        setSettings(data);
      })
      .catch((err) => {
        Toast.show(err.message, {
          position: Toast.positions.CENTER,
          shadow: true,
          animation: true,
          textColor: 'red',
          hideOnPress: true,
          delay: 100,
          duration: Toast.durations.LONG,
        });
        console.error(err.status, err.message);
      });
  }, []);

  const getFolderAndMdfiles = async (folder) => {
    try {
      if (!folder) {
        return;
      }
      if (!settings) {
        return;
      }

      return await fetch(
        'https://api.github.com/repos/' +
          settings['githubRepo'] +
          '/contents/' +
          folder,
        {
          method: 'GET',
          headers: {
            Accept: 'application/vnd.github.v3+json',
            'X-GitHub-Api-Version': '2022-11-28',
            Authorization: 'token ' + settings['githubToken'],
          },
        }
      ).then((response) => {
        return response.json();
      });
    } catch (error) {
      Toast.show(
        'network issue or folder not exist in the github \n' + error.message,
        {
          position: Toast.positions.CENTER,
          shadow: true,
          animation: true,
          hideOnPress: true,
          delay: 100,
          duration: Toast.durations.LONG,
        }
      );
      console.error(error);
    }
  };

  return (
    <>
      {!content && (
        <View className='flex-1'>
          <View className='py-12 md:py-24 lg:py-32 xl:py-48'>
            <View className='px-4 md:px-6'>
              <View className='flex flex-col items-center gap-4 text-center'>
                <Text
                  role='heading'
                  className='text-2xl text-center native:text-5xl font-bold tracking-tighter sm:text-4xl md:text-5xl lg:text-6xl'
                >
                  Please configure your settings first, we cannot retrieve any
                  content at the moment.
                </Text>
              </View>
            </View>
          </View>
        </View>
      )}
      {content && (
        <View className='flex-1'>
          <View className='px-4 md:px-6 flex-1 flex-shrink-0 bg-white dark:bg-black  inline-flex items-stretch w-full gap-4 overflow-hidden '>
            <ScrollView>
              {content.sort(fileNameComparator).map((item) => (
                <Text
                  key={item.sha}
                  className='m-1 p-1 text-black dark:text-white text-2xl items-stretch native:text-2xl w-11/12  sm:text-2xl md:text-3xl lg:text-4xl'
                  onPress={() => {
                    router.push({
                      pathname: '/read',
                      params: { post: CONTENT_KEY + item['name'] },
                    });
                  }}
                >
                  {item.name} &nbsp;&nbsp;
                  <Text className=' text-gray-400 ml-2'>{item.size}</Text>{' '}
                  {item.analysed && <Text className='text-green-500'>✓</Text>}
                </Text>
              ))}
            </ScrollView>
          </View>
        </View>
      )}
    </>
  );

  function saveToStorage(mark: string, items: any) {
    let simple_content: any[] = [];
    items.sort(fileNameComparator);
    const requests = items.map((item) => {
      AsyncStorage.getItem(mark + item.name)
        .then((data) => {
          if (!data || data['sha'] !== item['sha']) {
            axios
              .get<RepoContent>(item['download_url'], {
                method: 'GET',
                headers: {
                  Accept: 'application/vnd.github.v4+raw',
                  'X-GitHub-Api-Version': '2022-11-28',
                  Authorization: 'token ' + settings['githubToken'],
                },
              })
              .then((response) => {
                const content = {
                  sha: item['sha'],
                  content: response['data'],
                  size: response['data'].toString().length,
                };
                if (mark === CONTENT_KEY) {
                  // need to update size and analysed
                  item['size'] = content['size'];
                  if (elementWithNameExists(analysis, item['name'])) {
                    item['analysed'] = true;
                  } else {
                    item['analysed'] = false;
                  }
                  simple_content.push({
                    name: item['name'],
                    sha: item['sha'],
                    size: item['size'],
                    analysed: item['analysed'],
                  });
                  setContent(simple_content);
                  // console.log(simple_content)
                }
                AsyncStorage.setItem(mark + item.name, JSON.stringify(content));
              });
          }
        })
        .catch((err) => {
          console.error(err);
        });
      return items;
    });
  }
}
