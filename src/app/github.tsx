import React, { useEffect, useState } from 'react';
import { View } from 'react-native';
import { useRouter } from 'expo-router';
import { useIsFocused } from '@react-navigation/native';
import {
  ANALYSIS_KEY,
  CONTENT_KEY,
  SETTINGS_KEY,
  showErrorToast,
  handleError,
} from '@/components/global';
import { useAsyncStorage } from '@/hooks/useAsyncStorage';

// Import extracted modules
import { GitHubSettings, ContentItem } from './github/types';
import {
  loadSettingsFromStorage,
  loadExistingContentFromStorage,
  loadExistingAnalysisFromStorage,
} from './github/storageUtils';
import { refreshDataFromGitHub } from './github/githubService';
import {
  LoadingComponent,
  SettingsRequiredComponent,
  NoContentComponent,
  ContentList,
  SyncingIndicator,
} from './github/components';

export default function Page() {
  const [settings, setSettings] = useState<GitHubSettings | undefined>(
    undefined
  );
  const [content, setContent] = useState<ContentItem[]>([]);
  const [analysis, setAnalysis] = useState<ContentItem[]>([]);
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
      handleRefreshData();
    }
  }, [settings]);

  const loadExistingData = async () => {
    try {
      await Promise.all([
        loadExistingContentFromStorage(getItem, setContent),
        loadExistingAnalysisFromStorage(getItem, setAnalysis),
      ]);
    } catch (error) {
      handleError(error);
    }
  };

  const handleRefreshData = async () => {
    if (!settings) {
      setIsLoadingContent(false);
      return;
    }

    setIsRefreshing(true);
    try {
      await refreshDataFromGitHub(
        settings,
        setItem,
        setIsRefreshing,
        CONTENT_KEY,
        ANALYSIS_KEY
      );
    } catch (error) {
      handleError(error);
    } finally {
      setIsRefreshing(false);
      setIsLoadingContent(false);
    }
  };

  const handleItemPress = (item: ContentItem) => {
    try {
      router?.push({
        pathname: '/read',
        params: {
          name: item.name,
          path: item.path,
          sha: item.sha,
          size: item.size.toString(),
          url: item.url,
          html_url: item.html_url,
          git_url: item.git_url,
          download_url: item.download_url,
          type: item.type,
          analysed: item.analysed ? 'true' : 'false',
        },
      });
    } catch (error) {
      handleError(error);
    }
  };

  // Main content renderer
  const renderMainContent = () => {
    if (isLoadingContent) {
      return <LoadingComponent />;
    }

    if (!settings) {
      return (
        <SettingsRequiredComponent
          onRefresh={handleRefreshData}
          onGoToSettings={() => router?.push('/settings')}
        />
      );
    }

    if (content.length === 0) {
      return (
        <NoContentComponent
          onRefresh={handleRefreshData}
          onGoToSettings={() => router?.push('/settings')}
          isRefreshing={isRefreshing}
        />
      );
    }

    return <ContentList content={content} onItemPress={handleItemPress} />;
  };

  return (
    <View style={{ flex: 1 }}>
      {isRefreshing && <SyncingIndicator isRefreshing={isRefreshing} />}
      {renderMainContent()}
    </View>
  );
}
