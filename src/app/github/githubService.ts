import axios from 'axios';
import { handleError } from '@/components/global';
import {
  GitHubSettings,
  RepoContent,
  ContentItem,
  ContentFetchResult,
} from './types';

/**
 * Validate GitHub settings
 */
export const validateGitHubSettings = (
  settings: GitHubSettings | undefined
): boolean => {
  return !!(
    settings &&
    settings.githubToken &&
    settings.githubRepo &&
    settings.contentFolder &&
    settings.analysisFolder
  );
};

/**
 * Get folder and markdown files from GitHub repository
 */
export const getFolderAndMdfiles = async (
  settings: GitHubSettings,
  folder: string
): Promise<RepoContent[]> => {
  const url = `https://api.github.com/repos/${settings.githubRepo}/contents/${folder}`;
  const headers = {
    Authorization: `token ${settings.githubToken}`,
    Accept: 'application/vnd.github.v3+json',
  };

  try {
    const response = await axios.get(url, { headers });
    return response.data;
  } catch (error) {
    console.error('Error fetching folder contents:', error);
    throw error;
  }
};

/**
 * Fetch content from GitHub for a specific item
 */
export const fetchContentFromGitHub = async (
  item: ContentItem,
  settings: GitHubSettings
): Promise<ContentFetchResult> => {
  try {
    const response = await axios.get(item.download_url, {
      headers: {
        Authorization: `token ${settings.githubToken}`,
        Accept: 'application/vnd.github.v3+json',
      },
    });

    return {
      sha: item.sha,
      content: response.data,
      size: response.data.length,
    };
  } catch (error) {
    console.error('Error fetching content from GitHub:', error);
    throw error;
  }
};

/**
 * Fetch GitHub data for both content and analysis folders
 */
export const fetchGitHubData = async (
  settings: GitHubSettings
): Promise<{ content: RepoContent[]; analysis: RepoContent[] }> => {
  try {
    const [contentData, analysisData] = await Promise.all([
      getFolderAndMdfiles(settings, settings.contentFolder),
      getFolderAndMdfiles(settings, settings.analysisFolder),
    ]);

    return {
      content: contentData,
      analysis: analysisData,
    };
  } catch (error) {
    console.error('Error fetching GitHub data:', error);
    handleError(error);
    throw error;
  }
};

/**
 * Refresh data from GitHub and update storage
 */
export const refreshDataFromGitHub = async (
  settings: GitHubSettings,
  saveToStorage: (mark: string, items: any) => Promise<void>,
  setIsRefreshing: (refreshing: boolean) => void,
  CONTENT_KEY: string,
  ANALYSIS_KEY: string
): Promise<void> => {
  if (!validateGitHubSettings(settings)) {
    console.error('Invalid GitHub settings');
    return;
  }

  setIsRefreshing(true);

  try {
    const { content, analysis } = await fetchGitHubData(settings);

    // Save both content and analysis to storage
    await Promise.all([
      saveToStorage(CONTENT_KEY, content),
      saveToStorage(ANALYSIS_KEY, analysis),
    ]);
  } catch (error) {
    console.error('Error refreshing data from GitHub:', error);
    handleError(error);
  } finally {
    setIsRefreshing(false);
  }
};
