// GitHub-related TypeScript type definitions

/**
 * GitHub API response structure for repository content
 */
export type RepoContent = {
  name: string;
  path: string;
  sha: string;
  size: number;
  url: string;
  html_url: string;
  git_url: string;
  download_url: string;
  type: 'file' | 'dir';
  content?: string;
  encoding?: string;
  _links: {
    self: string;
    git: string;
    html: string;
  };
};

/**
 * Extended content item with additional metadata
 */
export interface ContentItem extends RepoContent {
  analysed?: boolean;
}

/**
 * GitHub settings configuration
 */
export interface GitHubSettings {
  githubToken: string;
  githubRepo: string;
  contentFolder: string;
  analysisFolder: string;
}

/**
 * Storage validation result
 */
export interface StorageValidationResult {
  isValid: boolean;
  error: string | null;
}

/**
 * Content fetch result from GitHub API
 */
export interface ContentFetchResult {
  sha: string;
  content: string;
  size: number;
}

/**
 * Storage operation parameters
 */
export interface StorageOperationParams {
  getItem: (key: string) => Promise<string | null>;
  setItem: (key: string, value: string) => Promise<void>;
  removeItem: (key: string) => Promise<void>;
}

/**
 * Component state interface
 */
export interface GitHubPageState {
  settings: GitHubSettings | undefined;
  content: ContentItem[];
  analysis: ContentItem[];
  isLoadingContent: boolean;
  isRefreshing: boolean;
}
