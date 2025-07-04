import React, { useEffect, useState } from 'react';
import { Text, View, TouchableOpacity } from 'react-native';
import { useHeaderHeight } from '@react-navigation/elements';
import axios from 'axios';
import { ScrollView } from 'react-native-gesture-handler';
import { useRouter } from 'expo-router';
import { components } from '@octokit/openapi-types';
import { useIsFocused } from '@react-navigation/native';
import {
  ANALYSIS_KEY,
  CONTENT_KEY,
  fileNameComparator,
  handleError,
  showErrorToast,
  SETTINGS_KEY,
} from '@/components/global';
import { useAsyncStorage } from '@/hooks/useAsyncStorage';

type RepoContent = components['schemas']['content-file'];

function elementWithNameExists(array: any[], nameToFind: string): boolean {
  return array.some((element) => element.name === nameToFind);
}

export default function Page() {
  const headerHeight = useHeaderHeight();
  const [settings, setSettings] = useState(undefined);
  const [content, setContent] = useState([]);
  const [analysis, setAnalysis] = useState([]);
  const [isLoadingContent, setIsLoadingContent] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);
  const router = useRouter();
  const isFocused = useIsFocused();
  const [storage, { setItem, getItem }, isLoading, hasChanged] =
    useAsyncStorage();

  // Load existing data immediately on mount
  useEffect(() => {
    loadExistingData();
  }, []);

  // Load settings and refresh data when needed
  useEffect(() => {
    if (!settings) {
      getItem(SETTINGS_KEY)
        .then((res) => {
          return JSON.parse(res);
        })
        .then((data) => {
          if (!data) {
            console.log('no data returned for settings');
            setIsLoadingContent(false);
            return;
          } else {
            setSettings(data);
          }
        })
        .catch((err) => {
          handleError(err);
          setIsLoadingContent(false);
        });
    }
    if (settings) {
      refreshDataFromGitHub();
    }
  }, [settings]);

  const loadExistingData = async () => {
    try {
      // Load existing content from storage
      const existingContent = await getItem(CONTENT_KEY);
      if (existingContent) {
        const parsedContent = JSON.parse(existingContent);
        if (Array.isArray(parsedContent) && parsedContent.length > 0) {
          setContent(parsedContent);
        }
      }

      // Load existing analysis from storage
      const existingAnalysis = await getItem(ANALYSIS_KEY);
      if (existingAnalysis) {
        const parsedAnalysis = JSON.parse(existingAnalysis);
        if (Array.isArray(parsedAnalysis)) {
          setAnalysis(parsedAnalysis);
        }
      }
    } catch (error) {
      showErrorToast('Error loading existing data from storage.');
    } finally {
      setIsLoadingContent(false);
    }
  };

  const refreshDataFromGitHub = async () => {
    if (!settings) return;

    setIsRefreshing(true);
    try {
      // Refresh analysis data
      const analysisData = await getFolderAndMdfiles(
        settings['analysisFolder']
      );
      if (analysisData) {
        setAnalysis(analysisData);
        saveToStorage(ANALYSIS_KEY, analysisData);
      }

      // Refresh content data
      const contentData = await getFolderAndMdfiles(settings['contentFolder']);
      if (contentData) {
        saveToStorage(CONTENT_KEY, contentData);
      }
    } catch (err) {
      handleError(err);
    } finally {
      setIsRefreshing(false);
    }
  };

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
    <View
      style={{ paddingTop: headerHeight }}
      className='flex-1 bg-white dark:bg-black'
    >
      {/* Header with refresh indicator */}
      <View className='px-4 py-3 border-b border-gray-200 dark:border-gray-700'>
        <View className='flex flex-row items-center justify-between'>
          {isRefreshing && (
            <View className='flex flex-row items-center gap-2'>
              <Text className='text-sm text-gray-500 dark:text-gray-400'>
                Syncing...
              </Text>
              <View className='w-4 h-4 border-2 border-blue-500 border-t-transparent rounded-full animate-spin' />
            </View>
          )}
        </View>
      </View>

      {/* Loading state */}
      {isLoadingContent && (
        <View className='flex-1 justify-center items-center'>
          <View className='w-8 h-8 border-2 border-blue-500 border-t-transparent rounded-full animate-spin mb-4' />
          <Text className='text-gray-500 dark:text-gray-400'>
            Loading content...
          </Text>
        </View>
      )}

      {/* No settings configured */}
      {!isLoadingContent && !settings && (
        <View className='flex-1 justify-center items-center px-4'>
          <View className='text-center max-w-md'>
            <Text className='text-6xl mb-4'>⚙️</Text>
            <Text className='text-xl font-semibold mb-2 text-black dark:text-white'>
              Settings Required
            </Text>
            <Text className='text-gray-500 dark:text-gray-400 mb-6 text-center'>
              Please configure your GitHub repository settings to access your
              content.
            </Text>
            <TouchableOpacity
              className='bg-blue-600 px-6 py-3 rounded-lg'
              onPress={() => router.push('/setting')}
            >
              <Text className='text-white font-semibold text-center'>
                Go to Settings
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      )}

      {/* No content available */}
      {!isLoadingContent && settings && content.length === 0 && (
        <View className='flex-1 justify-center items-center px-4'>
          <View className='text-center max-w-md'>
            <Text className='text-6xl mb-4'>📚</Text>
            <Text className='text-xl font-semibold mb-2 text-black dark:text-white'>
              No Content Found
            </Text>
            <Text className='text-gray-500 dark:text-gray-400 mb-6 text-center'>
              {isRefreshing
                ? 'Checking for content in your repository...'
                : 'No markdown files found in your configured content folder. Make sure your GitHub repository contains .md files in the specified directory.'}
            </Text>
            {!isRefreshing && (
              <TouchableOpacity
                className='border border-gray-300 dark:border-gray-600 px-6 py-3 rounded-lg mb-3'
                onPress={refreshDataFromGitHub}
              >
                <Text className='text-gray-700 dark:text-gray-300 font-semibold text-center'>
                  Refresh
                </Text>
              </TouchableOpacity>
            )}
            <TouchableOpacity
              className='bg-blue-600 px-6 py-3 rounded-lg'
              onPress={() => router.push('/setting')}
            >
              <Text className='text-white font-semibold text-center'>
                Check Settings
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      )}

      {/* Content list */}
      {!isLoadingContent && content.length > 0 && (
        <View className='flex-1'>
          <View className='px-4 md:px-6 flex-1'>
            <ScrollView className='flex-1'>
              <View className='py-4'>
                {content.sort(fileNameComparator).map((item) => (
                  <TouchableOpacity
                    key={item.sha}
                    className='mb-3 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700'
                    onPress={() => {
                      router.push({
                        pathname: '/read',
                        params: { post: CONTENT_KEY + item['name'] },
                      });
                    }}
                  >
                    <View className='flex flex-row items-center justify-between'>
                      <View className='flex-1'>
                        <Text className='text-lg font-semibold text-black dark:text-white mb-1'>
                          {item.name.replace('_', '').replace('.md', '')}
                        </Text>
                        <View className='flex flex-row items-center gap-2'>
                          <Text className='text-sm text-gray-500 dark:text-gray-400'>
                            {item.size} characters
                          </Text>
                          {item.analysed && (
                            <View className='flex flex-row items-center gap-1'>
                              <Text className='text-green-500'>✓</Text>
                              <Text className='text-xs text-green-600 dark:text-green-400'>
                                Analyzed
                              </Text>
                            </View>
                          )}
                        </View>
                      </View>
                      <Text className='text-gray-400 text-lg'>›</Text>
                    </View>
                  </TouchableOpacity>
                ))}
              </View>
            </ScrollView>
          </View>
        </View>
      )}
    </View>
  );

  function saveToStorage(mark: string, items: any) {
    // load existed to show, then update them
    if (mark === CONTENT_KEY) {
      getItem(mark).then((res) => setContent(JSON.parse(res)));
    }
    // console.log('saveToStorage', mark, items)
    if (!items || items.length <= 0) {
      console.log('no items to save');
      return;
    }
    if (!Array.isArray(items)) {
      // Handle GitHub API error responses
      if (items && typeof items === 'object' && items.message) {
        if (items.status === '401') {
          showErrorToast(
            'Authentication failed. Please check your GitHub token in settings.'
          );
        } else {
          showErrorToast(`GitHub API error: ${items.message}`);
        }
      } else {
        showErrorToast('Unexpected data format received from GitHub API.');
      }
      return;
    }
    items.sort(fileNameComparator);

    items.map((item, index) => {
      // console.log('saveToStorage', mark+item.name)
      getItem(mark + item.name)
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
                  setItem(mark, JSON.stringify(items));
                  setContent(items);
                }

                setItem(mark + item.name, JSON.stringify(content));
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
              setItem(mark, JSON.stringify(items));
              setContent(items);
            }
          }
        })
        .catch((err) => {
          handleError(err);
        });
    });
    setItem(mark, JSON.stringify(items));
  }
}
