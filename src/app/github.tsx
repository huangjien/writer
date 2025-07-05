import React, { useEffect, useState } from 'react';
import { Text, View, TouchableOpacity } from 'react-native';
// Removed useSafeAreaInsets import due to navigation context issues
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

// Helper function to load settings from storage
const loadSettingsFromStorage = async (
  getItem,
  setSettings,
  setIsLoadingContent
) => {
  try {
    const res = await getItem(SETTINGS_KEY);
    if (!res) {
      console.log('no data returned for settings');
      setIsLoadingContent(false);
      return null;
    }

    const data = JSON.parse(res);
    setSettings(data);
    return data;
  } catch (err) {
    console.error('Error loading settings from storage:', err);
    handleError(err);
    setIsLoadingContent(false);
    return null;
  }
};

// Helper function to load existing content from storage
const loadExistingContentFromStorage = async (getItem, setContent) => {
  try {
    const existingContent = await getItem(CONTENT_KEY);
    if (existingContent) {
      try {
        const parsedContent = JSON.parse(existingContent);
        if (Array.isArray(parsedContent) && parsedContent.length > 0) {
          setContent(parsedContent);
        }
      } catch (parseError) {
        console.error('Error parsing existing content:', parseError);
      }
    }
  } catch (error) {
    console.error('Error loading existing content:', error);
  }
};

// Helper function to load existing analysis from storage
const loadExistingAnalysisFromStorage = async (getItem, setAnalysis) => {
  try {
    const existingAnalysis = await getItem(ANALYSIS_KEY);
    if (existingAnalysis) {
      try {
        const parsedAnalysis = JSON.parse(existingAnalysis);
        if (Array.isArray(parsedAnalysis)) {
          setAnalysis(parsedAnalysis);
        }
      } catch (parseError) {
        console.error('Error parsing existing analysis:', parseError);
      }
    }
  } catch (error) {
    console.error('Error loading existing analysis:', error);
  }
};

export default function Page() {
  const [settings, setSettings] = useState(undefined);
  const [content, setContent] = useState([]);
  const [analysis, setAnalysis] = useState([]);
  const [isLoadingContent, setIsLoadingContent] = useState(true);
  const [isRefreshing, setIsRefreshing] = useState(false);

  // Handle navigation hooks with fallbacks for context issues
  let router;
  let isFocused = true;

  try {
    router = useRouter();
  } catch (error) {
    // Silently handle navigation context not being available
    router = { push: () => {} };
  }

  try {
    isFocused = useIsFocused();
  } catch (error) {
    // Silently handle navigation context not being available
    isFocused = true;
  }

  const [storage, { setItem, getItem, removeItem }, isLoading, hasChanged] =
    useAsyncStorage();

  // Load existing data immediately on mount
  useEffect(() => {
    loadExistingData();
  }, []);

  // Load settings and refresh data when needed
  useEffect(() => {
    if (!settings) {
      loadSettingsFromStorage(getItem, setSettings, setIsLoadingContent);
    }
    if (settings) {
      refreshDataFromGitHub();
    }
  }, [settings]);

  const loadExistingData = async () => {
    try {
      await Promise.all([
        loadExistingContentFromStorage(getItem, setContent),
        loadExistingAnalysisFromStorage(getItem, setAnalysis),
      ]);
    } catch (error) {
      showErrorToast('Error loading existing data from storage.');
    }
  };

  // Helper function to validate settings for GitHub operations
  const validateGitHubSettings = (settings) => {
    return settings && settings.githubToken && settings.githubRepo;
  };

  // Helper component for loading state
  const renderLoadingState = () => (
    <View className='flex-1 justify-center items-center'>
      <View className='w-8 h-8 border-2 border-blue-500 border-t-transparent rounded-full animate-spin mb-4' />
      <Text className='text-gray-500 dark:text-gray-400'>
        Loading content...
      </Text>
    </View>
  );

  // Helper component for settings required state
  const renderSettingsRequired = () => (
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
  );

  // Helper component for no content state
  const renderNoContent = () => (
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
  );

  // Helper component for content list
  const renderContentList = () => {
    return (
      <ScrollView className='flex-1 px-4'>
        {content.sort(fileNameComparator).map((item, index) => (
          <TouchableOpacity
            key={item.sha}
            className='mb-3 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700'
            onPress={() => {
              try {
                router?.push({
                  pathname: '/read',
                  params: { post: CONTENT_KEY + item.name },
                });
              } catch (error) {
                console.warn('Navigation failed:', error);
              }
            }}
          >
            <View className='flex-row items-center justify-between'>
              <View className='flex-1'>
                <Text className='text-lg font-semibold text-gray-900 dark:text-white mb-1'>
                  {item.name.replace('_', '').replace('.md', '')}
                </Text>
                <View className='flex-row items-center gap-2'>
                  <Text className='text-sm text-gray-600 dark:text-gray-400'>
                    {item.size} characters
                  </Text>
                  {item.analysed && (
                    <View className='flex-row items-center gap-1'>
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
      </ScrollView>
    );
  };

  // Main content renderer
  const renderMainContent = () => {
    console.log('renderMainContent called:', {
      isLoadingContent,
      hasSettings: !!settings,
      contentLength: content.length,
    });

    if (isLoadingContent) {
      console.log('Rendering loading state');
      return renderLoadingState();
    }

    if (!settings) {
      console.log('Rendering settings required');
      return renderSettingsRequired();
    }

    if (content.length === 0) {
      console.log('Rendering no content');
      return renderNoContent();
    }

    console.log('Rendering content list');
    return renderContentList();
  };

  // Helper function to fetch GitHub data
  const fetchGitHubData = async (settings) => {
    return await getFolderAndMdfiles(settings.contentFolder);
  };

  // Helper function to clean up orphan items from storage
  const cleanupOrphanItems = async (currentItems: any[], keyPrefix: string) => {
    try {
      // Get all storage keys
      const allKeys = Object.keys(storage);
      const prefixKeys = allKeys.filter((key) => key.startsWith(keyPrefix));
      const currentFileKeys = currentItems.map((item) => keyPrefix + item.name);
      const orphanKeys = prefixKeys.filter(
        (key) =>
          key !== keyPrefix && // Keep the main list key
          !currentFileKeys.includes(key)
      );

      // Remove orphan items
      if (orphanKeys.length > 0) {
        await Promise.all(orphanKeys.map((key) => removeItem(key)));
        console.log(
          `Cleaned up ${orphanKeys.length} orphan items for ${keyPrefix}`
        );
      }
    } catch (error) {
      console.error('Error cleaning orphan items:', error);
    }
  };

  const refreshDataFromGitHub = async () => {
    if (!validateGitHubSettings(settings)) {
      console.log('Settings not available for refresh');
      setIsLoadingContent(false);
      return;
    }

    setIsRefreshing(true);
    try {
      // Refresh analysis data
      const analysisData = await getFolderAndMdfiles(
        settings['analysisFolder']
      );
      if (analysisData) {
        setAnalysis(analysisData);
        saveToStorage(ANALYSIS_KEY, analysisData);
        // Clean up orphan analysis items
        await cleanupOrphanItems(analysisData, ANALYSIS_KEY);
      }

      // Refresh content data
      const contentData = await getFolderAndMdfiles(settings['contentFolder']);
      if (contentData) {
        saveToStorage(CONTENT_KEY, contentData);
        // Clean up orphan content items
        await cleanupOrphanItems(contentData, CONTENT_KEY);
      }
    } catch (err) {
      handleError(err);
    } finally {
      setIsRefreshing(false);
      setIsLoadingContent(false);
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

  // Helper function to validate items for storage
  const validateItemsForStorage = (items: any) => {
    if (!items || items.length <= 0) {
      console.log('no items to save');
      return { isValid: false, error: null };
    }

    if (!Array.isArray(items)) {
      let errorMessage = 'Unexpected data format received from GitHub API.';

      if (items && typeof items === 'object' && items.message) {
        if (items.status === '401') {
          errorMessage =
            'Authentication failed. Please check your GitHub token in settings.';
        } else {
          errorMessage = `GitHub API error: ${items.message}`;
        }
      }

      return { isValid: false, error: errorMessage };
    }

    return { isValid: true, error: null };
  };

  // Helper function to update item metadata
  const updateItemMetadata = (item: any, contentSize: number, mark: string) => {
    if (mark === CONTENT_KEY && item['name'].endsWith('.md')) {
      item['size'] = contentSize;
      item['analysed'] = elementWithNameExists(analysis, item['name']);
    }
  };

  // Helper function to fetch content from GitHub
  const fetchContentFromGitHub = async (item: any) => {
    const response = await axios.get<RepoContent>(item['download_url'], {
      method: 'GET',
      headers: {
        Accept: 'application/vnd.github.v4+raw',
        'X-GitHub-Api-Version': '2022-11-28',
        Authorization: 'token ' + settings['githubToken'],
      },
    });

    return {
      sha: item['sha'],
      content: response['data'],
      size: response['data'].toString().length,
    };
  };

  // Helper function to finalize storage update
  const finalizeStorageUpdate = (items: any[], mark: string, index: number) => {
    if (index >= items.length - 1) {
      const filteredItems = items.filter((item) => item.name.endsWith('.md'));
      setItem(mark, JSON.stringify(filteredItems));
      setContent(filteredItems);
    }
  };

  // Helper function to process individual item
  const processStorageItem = async (
    item: any,
    index: number,
    mark: string,
    items: any[]
  ) => {
    try {
      const existingData = await getItem(mark + item.name);
      let data = null;

      if (existingData) {
        try {
          data = JSON.parse(existingData);
        } catch (parseError) {
          console.error(
            'Error parsing existing data for item:',
            item.name,
            parseError
          );
          data = null;
        }
      }

      if (!data || data['sha'] !== item['sha']) {
        // Need to update - fetch new content
        const content = await fetchContentFromGitHub(item);
        updateItemMetadata(item, content.size, mark);
        await setItem(mark + item.name, JSON.stringify(content));
      } else {
        // Content is up to date - just update metadata
        updateItemMetadata(item, data['size'], mark);
      }

      finalizeStorageUpdate(items, mark, index);
    } catch (err) {
      handleError(err);
    }
  };

  function saveToStorage(mark: string, items: any) {
    // Load existing content to show immediately
    if (mark === CONTENT_KEY) {
      getItem(mark)
        .then((res) => {
          if (res) {
            try {
              setContent(JSON.parse(res));
            } catch (parseError) {
              console.error(
                'Error parsing content for immediate display:',
                parseError
              );
            }
          }
        })
        .catch((error) => {
          console.error('Error loading content for immediate display:', error);
        });
    }

    // Validate items
    const validation = validateItemsForStorage(items);
    if (!validation.isValid) {
      if (validation.error) {
        showErrorToast(validation.error);
      }
      return;
    }

    // Sort items and process each one
    items.sort(fileNameComparator);
    items.forEach((item, index) => {
      processStorageItem(item, index, mark, items);
    });

    // Save the items list
    setItem(mark, JSON.stringify(items));
  }

  return (
    <View className='flex-1 bg-white dark:bg-black' style={{ paddingTop: 100 }}>
      {isRefreshing && (
        <View className='absolute top-20 right-4 z-10 flex flex-row items-center gap-2 bg-white dark:bg-black px-3 py-2 rounded-lg shadow'>
          <Text className='text-sm text-gray-500 dark:text-gray-400'>
            Syncing...
          </Text>
          <View className='w-4 h-4 border-2 border-blue-500 border-t-transparent rounded-full animate-spin' />
        </View>
      )}
      {renderMainContent()}
    </View>
  );
}
