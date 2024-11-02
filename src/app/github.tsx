import React, { useEffect, useState } from 'react';
import { Text, View } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';
import { ScrollView } from 'react-native-gesture-handler';
import { useRouter } from 'expo-router';
import { components } from '@octokit/openapi-types';
import { useIsFocused } from '@react-navigation/native';
import {
  ANALYSIS_KEY,
  CONTENT_KEY,
  fileNameComparator,
  getStoredSettings,
  handleError,
} from '@/components/global';

type RepoContent = components['schemas']['content-file'];

function elementWithNameExists(array: any[], nameToFind: string): boolean {
  return array.some((element) => element.name === nameToFind);
}

export default function Page() {
  const [settings, setSettings] = useState(undefined);
  const [content, setContent] = useState([]);
  const [analysis, setAnalysis] = useState([]);
  const router = useRouter();

  const isFocused = useIsFocused();

  useEffect(() => {
    if (!settings) {
      getStoredSettings
        .then((data) => {
          if (!data) {
            console.log('no data returned for settings');
            return;
          } else {
            setSettings(data);
          }
        })
        .catch((err) => {
          handleError(err);
        });
    }
    if (settings) {
      console.log(settings);
      getFolderAndMdfiles(settings['analysisFolder'])
        .then((data) => {
          // console.log(data)
          if (!data) {
            console.log('no data returned for analysis');
            return;
          }
          setAnalysis(data);
          saveToStorage(ANALYSIS_KEY, data);
        })
        .then(() => {
          getFolderAndMdfiles(settings['contentFolder']).then((data) => {
            if (!data) {
              console.log('no data returned for content');
              return;
            }
            saveToStorage(CONTENT_KEY, data);
            // return data;
          });
        });
    }
  }, [settings, isFocused]);

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
      handleError(error);
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
                  {item.name.replace('_', '').replace('.md', '')} &nbsp;&nbsp;
                  {item.analysed && <Text className='text-green-500'>✓</Text>}
                  <Text className='text-xs leading-8 text-gray-400 ml-2'>
                    {item.size}
                  </Text>{' '}
                </Text>
              ))}
            </ScrollView>
          </View>
        </View>
      )}
    </>
  );

  function saveToStorage(mark: string, items: any) {
    // load existed to show, then update them
    if (mark === CONTENT_KEY) {
      AsyncStorage.getItem(mark).then((res) => setContent(JSON.parse(res)));
    }
    // console.log('saveToStorage', mark, items)
    if (!items || items.length <= 0) {
      console.log('no items to save');
      return;
    }
    items.sort(fileNameComparator);

    items.map((item, index) => {
      // console.log('saveToStorage', mark+item.name)
      AsyncStorage.getItem(mark + item.name)
        .then((res) => {
          // if not equals, that means need to update
          const data = JSON.parse(res);
          if (!data || data['sha'] !== item['sha']) {
            //  console.log(mark+item.name, 'need to update')
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
                if (mark === CONTENT_KEY && item['name'].endsWith('.md')) {
                  // console.log('index', index, 'name', item['name']);
                  // need to update size and analysed
                  item['size'] = content['size'];
                  if (elementWithNameExists(analysis, item['name'])) {
                    item['analysed'] = true;
                  } else {
                    item['analysed'] = false;
                  }
                }
                if (index >= items.length - 1) {
                  // console.log("last item", index, items.length);
                  items = items.filter((item) => item.name.endsWith('.md'));
                  AsyncStorage.setItem(mark, JSON.stringify(items));
                  setContent(items);
                }

                AsyncStorage.setItem(mark + item.name, JSON.stringify(content));
              });
          } else {
            if (mark === CONTENT_KEY && item['name'].endsWith('.md')) {
              // console.log('index', index, 'name', item['name']);
              // need to update size and analysed
              item['size'] = data['size'];
              if (elementWithNameExists(analysis, item['name'])) {
                item['analysed'] = true;
              } else {
                item['analysed'] = false;
              }
            }
            if (index >= items.length - 1) {
              // console.log("last item", index, items.length);
              items = items.filter((item) => item.name.endsWith('.md'));
              AsyncStorage.setItem(mark, JSON.stringify(items));
              setContent(items);
            }
          }
        })
        .catch((err) => {
          handleError(err);
        });
    });
  }
}
