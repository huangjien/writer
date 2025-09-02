import React from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  ActivityIndicator,
  FlatList,
} from 'react-native';
import { router } from 'expo-router';
import { ContentItem } from './types';

/**
 * Component for rendering loading state
 */
export const LoadingComponent: React.FC = () => (
  <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
    <ActivityIndicator size='large' />
    <Text style={{ marginTop: 10 }}>Loading...</Text>
  </View>
);

/**
 * Component for rendering settings required state
 */
interface SettingsRequiredComponentProps {
  onRefresh: () => void;
  onGoToSettings: () => void;
}

export const SettingsRequiredComponent: React.FC<
  SettingsRequiredComponentProps
> = ({ onRefresh, onGoToSettings }) => (
  <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
    <Text style={{ fontSize: 18, marginBottom: 20 }}>Settings Required</Text>
    <Text style={{ textAlign: 'center', marginHorizontal: 20 }}>
      Please configure your GitHub settings to access content.
    </Text>
    <TouchableOpacity
      style={{
        backgroundColor: '#007AFF',
        padding: 15,
        borderRadius: 8,
        marginTop: 20,
      }}
      onPress={onGoToSettings}
    >
      <Text style={{ color: 'white', fontSize: 16 }}>Go to Settings</Text>
    </TouchableOpacity>
  </View>
);

/**
 * Component for rendering no content state
 */
interface NoContentComponentProps {
  onRefresh: () => void;
  onGoToSettings: () => void;
  isRefreshing: boolean;
}

export const NoContentComponent: React.FC<NoContentComponentProps> = ({
  onRefresh,
  onGoToSettings,
  isRefreshing,
}) => (
  <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
    <Text style={{ fontSize: 18, marginBottom: 20 }}>No Content Found</Text>
    <Text style={{ textAlign: 'center', marginHorizontal: 20 }}>
      {isRefreshing
        ? 'Checking for content in your repository...'
        : 'No markdown files were found in the configured content folder.'}
    </Text>
    {!isRefreshing && (
      <TouchableOpacity
        style={{
          borderWidth: 1,
          borderColor: '#D1D5DB',
          padding: 15,
          borderRadius: 8,
          marginTop: 20,
          marginBottom: 10,
        }}
        onPress={onRefresh}
      >
        <Text style={{ color: '#374151', fontSize: 16, textAlign: 'center' }}>
          Refresh
        </Text>
      </TouchableOpacity>
    )}
    <TouchableOpacity
      style={{
        backgroundColor: '#007AFF',
        padding: 15,
        borderRadius: 8,
        marginTop: 10,
      }}
      onPress={onGoToSettings}
    >
      <Text style={{ color: 'white', fontSize: 16 }}>Check Settings</Text>
    </TouchableOpacity>
  </View>
);

/**
 * Props for ContentListItem component
 */
interface ContentListItemProps {
  item: ContentItem;
  index: number;
  onPress: () => void;
}

/**
 * Individual content list item component
 */
export const ContentListItem: React.FC<ContentListItemProps> = ({
  item,
  index,
  onPress,
}) => (
  <TouchableOpacity
    key={index}
    style={{
      padding: 15,
      borderBottomWidth: 1,
      borderBottomColor: '#e0e0e0',
      backgroundColor: 'white',
    }}
    onPress={onPress}
  >
    <View
      style={{
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
      }}
    >
      <View style={{ flex: 1 }}>
        <Text style={{ fontSize: 16, fontWeight: 'bold', marginBottom: 5 }}>
          {item.name.replace('.md', '')}
        </Text>
        <Text style={{ fontSize: 12, color: '#666' }}>
          Size: {item.size} bytes
        </Text>
      </View>
      {item.analysed && (
        <View
          style={{
            backgroundColor: '#4CAF50',
            paddingHorizontal: 8,
            paddingVertical: 4,
            borderRadius: 12,
          }}
        >
          <Text style={{ color: 'white', fontSize: 10, fontWeight: 'bold' }}>
            ANALYSED
          </Text>
        </View>
      )}
    </View>
  </TouchableOpacity>
);

/**
 * Props for ContentList component
 */
interface ContentListProps {
  content: ContentItem[];
  onItemPress: (item: ContentItem) => void;
}

/**
 * Component for rendering content list
 */
export const ContentList: React.FC<ContentListProps> = ({
  content,
  onItemPress,
}) => (
  <FlatList
    data={content}
    keyExtractor={(item, index) => `${item.name}-${index}`}
    renderItem={({ item, index }) => (
      <ContentListItem
        item={item}
        index={index}
        onPress={() => onItemPress(item)}
      />
    )}
    style={{ flex: 1 }}
  />
);

/**
 * Props for SyncingIndicator component
 */
interface SyncingIndicatorProps {
  isRefreshing: boolean;
}

/**
 * Syncing indicator component
 */
export const SyncingIndicator: React.FC<SyncingIndicatorProps> = ({
  isRefreshing,
}) => {
  if (!isRefreshing) return null;

  return (
    <View
      style={{
        position: 'absolute',
        top: 50,
        left: 0,
        right: 0,
        backgroundColor: 'rgba(0, 0, 0, 0.8)',
        padding: 10,
        alignItems: 'center',
        zIndex: 1000,
      }}
    >
      <Text style={{ color: 'white', fontSize: 16 }}>Syncing...</Text>
    </View>
  );
};
