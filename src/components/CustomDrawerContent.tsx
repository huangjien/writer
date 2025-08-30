import { Image } from '@/components/image';
import { Feather } from '@expo/vector-icons';
import { DrawerItem } from '@react-navigation/drawer';
import { useRouter } from 'expo-router';
import { ReactElement } from 'react';
import { ScrollView, View, TouchableOpacity } from 'react-native';
import { useThemeConfig } from '@/hooks/use-theme-config';
import { images } from '@/app/images';
import { Text } from 'react-native';
import packageJson from '@/../package.json';
import { useAsyncStorage } from '@/hooks/useAsyncStorage';
import { TIMEOUT } from './global';
import { useColorScheme } from 'nativewind';
import { GlassView, GlassCard } from './GlassComponents';

export const CustomDrawerContent = (): ReactElement => {
  const router = useRouter();
  const [storage, { setItem }, isLoading, hasChanged] = useAsyncStorage();
  const { theme, themeName, setSelectedTheme } = useThemeConfig();
  const { colorScheme } = useColorScheme();
  const isDark = colorScheme === 'dark';

  return (
    <GlassView
      className='flex-1'
      style={{
        backgroundColor: isDark
          ? 'rgba(15, 23, 42, 0.95)'
          : 'rgba(248, 250, 252, 0.95)',
      }}
    >
      <View
        className={`mx-4 mt-4 px-6 py-8 border-b ${
          isDark ? 'border-glass-borderDark' : 'border-glass-border'
        }`}
      >
        <Image
          source={images.logo}
          className='flex w-12 h-12 m-2 rounded-full'
          style={{
            shadowColor: isDark ? '#000000' : '#1f2687',
            shadowOffset: { width: 0, height: 4 },
            shadowOpacity: isDark ? 0.3 : 0.4,
            shadowRadius: 12,
          }}
        />
        <Text
          className={`text-xl font-bold mb-2 ${
            isDark ? 'text-slate-100' : 'text-slate-800'
          }`}
          style={{
            textShadowColor: isDark
              ? 'rgba(0, 0, 0, 0.3)'
              : 'rgba(255, 255, 255, 0.8)',
            textShadowOffset: { width: 0, height: 1 },
            textShadowRadius: 2,
          }}
        >
          {packageJson.name}
        </Text>
        <Text
          className={`text-sm ${isDark ? 'text-slate-300' : 'text-slate-600'}`}
          style={{
            opacity: 0.8,
            textShadowColor: isDark
              ? 'rgba(0, 0, 0, 0.2)'
              : 'rgba(255, 255, 255, 0.6)',
            textShadowOffset: { width: 0, height: 1 },
            textShadowRadius: 1,
          }}
        >
          {packageJson.slogan}
        </Text>
      </View>

      <ScrollView className='flex-1 px-4 py-6'>
        <TouchableOpacity onPress={() => router.push('/')}>
          <GlassCard
            className={`flex-row items-center px-4 py-3 mb-3 rounded-glass ${
              isDark ? 'border-glass-borderDark' : 'border-glass-border'
            }`}
            style={{
              shadowColor: isDark ? '#000000' : '#1f2687',
              shadowOffset: { width: 0, height: 3 },
              shadowOpacity: isDark ? 0.2 : 0.25,
              shadowRadius: 12,
              elevation: 3,
            }}
          >
            <Feather
              name='home'
              size={24}
              color={isDark ? '#cbd5e1' : '#475569'}
              style={{
                marginRight: 16,
                textShadowColor: isDark
                  ? 'rgba(0, 0, 0, 0.3)'
                  : 'rgba(255, 255, 255, 0.8)',
                textShadowOffset: { width: 0, height: 1 },
                textShadowRadius: 2,
              }}
            />
            <Text
              className={`text-base font-medium ${
                isDark ? 'text-slate-200' : 'text-slate-700'
              }`}
              style={{
                textShadowColor: isDark
                  ? 'rgba(0, 0, 0, 0.3)'
                  : 'rgba(255, 255, 255, 0.8)',
                textShadowOffset: { width: 0, height: 1 },
                textShadowRadius: 2,
              }}
            >
              Home
            </Text>
          </GlassCard>
        </TouchableOpacity>

        <TouchableOpacity onPress={() => router.push('/github')}>
          <GlassCard
            className={`flex-row items-center px-4 py-3 mb-3 rounded-glass ${
              isDark ? 'border-glass-borderDark' : 'border-glass-border'
            }`}
            style={{
              shadowColor: isDark ? '#000000' : '#1f2687',
              shadowOffset: { width: 0, height: 3 },
              shadowOpacity: isDark ? 0.2 : 0.25,
              shadowRadius: 12,
              elevation: 3,
            }}
          >
            <Feather
              name='code'
              size={24}
              color={isDark ? '#cbd5e1' : '#475569'}
              style={{
                marginRight: 16,
                textShadowColor: isDark
                  ? 'rgba(0, 0, 0, 0.3)'
                  : 'rgba(255, 255, 255, 0.8)',
                textShadowOffset: { width: 0, height: 1 },
                textShadowRadius: 2,
              }}
            />
            <Text
              className={`text-base font-medium ${
                isDark ? 'text-slate-200' : 'text-slate-700'
              }`}
              style={{
                textShadowColor: isDark
                  ? 'rgba(0, 0, 0, 0.3)'
                  : 'rgba(255, 255, 255, 0.8)',
                textShadowOffset: { width: 0, height: 1 },
                textShadowRadius: 2,
              }}
            >
              Index
            </Text>
          </GlassCard>
        </TouchableOpacity>

        <TouchableOpacity onPress={() => router.push('/read')}>
          <GlassCard
            className={`flex-row items-center px-4 py-3 mb-3 rounded-glass ${
              isDark ? 'border-glass-borderDark' : 'border-glass-border'
            }`}
            style={{
              shadowColor: isDark ? '#000000' : '#1f2687',
              shadowOffset: { width: 0, height: 3 },
              shadowOpacity: isDark ? 0.2 : 0.25,
              shadowRadius: 12,
              elevation: 3,
            }}
          >
            <Feather
              name='play'
              size={24}
              color={isDark ? '#cbd5e1' : '#475569'}
              style={{
                marginRight: 16,
                textShadowColor: isDark
                  ? 'rgba(0, 0, 0, 0.3)'
                  : 'rgba(255, 255, 255, 0.8)',
                textShadowOffset: { width: 0, height: 1 },
                textShadowRadius: 2,
              }}
            />
            <Text
              className={`text-base font-medium ${
                isDark ? 'text-slate-200' : 'text-slate-700'
              }`}
              style={{
                textShadowColor: isDark
                  ? 'rgba(0, 0, 0, 0.3)'
                  : 'rgba(255, 255, 255, 0.8)',
                textShadowOffset: { width: 0, height: 1 },
                textShadowRadius: 2,
              }}
            >
              Read
            </Text>
          </GlassCard>
        </TouchableOpacity>

        <TouchableOpacity onPress={() => router.push('/setting')}>
          <GlassCard
            className={`flex-row items-center px-4 py-3 mb-3 rounded-glass ${
              isDark ? 'border-glass-borderDark' : 'border-glass-border'
            }`}
            style={{
              shadowColor: isDark ? '#000000' : '#1f2687',
              shadowOffset: { width: 0, height: 3 },
              shadowOpacity: isDark ? 0.2 : 0.25,
              shadowRadius: 12,
              elevation: 3,
            }}
          >
            <Feather
              name='settings'
              size={24}
              color={isDark ? '#cbd5e1' : '#475569'}
              style={{
                marginRight: 16,
                textShadowColor: isDark
                  ? 'rgba(0, 0, 0, 0.3)'
                  : 'rgba(255, 255, 255, 0.8)',
                textShadowOffset: { width: 0, height: 1 },
                textShadowRadius: 2,
              }}
            />
            <Text
              className={`text-base font-medium ${
                isDark ? 'text-slate-200' : 'text-slate-700'
              }`}
              style={{
                textShadowColor: isDark
                  ? 'rgba(0, 0, 0, 0.3)'
                  : 'rgba(255, 255, 255, 0.8)',
                textShadowOffset: { width: 0, height: 1 },
                textShadowRadius: 2,
              }}
            >
              Settings
            </Text>
          </GlassCard>
        </TouchableOpacity>

        <View className='h-4' />

        <TouchableOpacity
          onPress={() => {
            if (themeName === 'dark') {
              setSelectedTheme('light');
            } else {
              setSelectedTheme('dark');
            }
          }}
        >
          <GlassCard
            className={`flex-row items-center px-4 py-3 mb-3 rounded-glass border-primary-400`}
            style={{
              shadowColor: isDark ? '#000000' : '#1f2687',
              shadowOffset: { width: 0, height: 6 },
              shadowOpacity: isDark ? 0.3 : 0.4,
              shadowRadius: 20,
              elevation: 6,
              backgroundColor: isDark
                ? 'rgba(34, 197, 94, 0.15)'
                : 'rgba(34, 197, 94, 0.1)',
            }}
          >
            <Feather
              name={themeName === 'dark' ? 'moon' : 'sun'}
              size={24}
              color={isDark ? '#4ade80' : '#16a34a'}
              style={{
                marginRight: 16,
                textShadowColor: isDark
                  ? 'rgba(0, 0, 0, 0.3)'
                  : 'rgba(255, 255, 255, 0.8)',
                textShadowOffset: { width: 0, height: 1 },
                textShadowRadius: 2,
              }}
            />
            <Text
              className={`text-base font-medium ${
                isDark ? 'text-green-300' : 'text-green-600'
              }`}
              style={{
                textShadowColor: isDark
                  ? 'rgba(0, 0, 0, 0.3)'
                  : 'rgba(255, 255, 255, 0.8)',
                textShadowOffset: { width: 0, height: 1 },
                textShadowRadius: 2,
              }}
            >
              Theme
            </Text>
          </GlassCard>
        </TouchableOpacity>

        <TouchableOpacity
          onPress={() => {
            setItem('expiry', (Date.now() - TIMEOUT).toString());
          }}
        >
          <GlassCard
            className={`flex-row items-center px-4 py-3 mb-3 rounded-glass border-red-400`}
            style={{
              shadowColor: isDark ? '#000000' : '#dc2626',
              shadowOffset: { width: 0, height: 6 },
              shadowOpacity: isDark ? 0.3 : 0.4,
              shadowRadius: 20,
              elevation: 6,
              backgroundColor: isDark
                ? 'rgba(239, 68, 68, 0.15)'
                : 'rgba(239, 68, 68, 0.1)',
            }}
          >
            <Feather
              name='log-out'
              size={24}
              color={isDark ? '#f87171' : '#dc2626'}
              style={{
                marginRight: 16,
                textShadowColor: isDark
                  ? 'rgba(0, 0, 0, 0.3)'
                  : 'rgba(255, 255, 255, 0.8)',
                textShadowOffset: { width: 0, height: 1 },
                textShadowRadius: 2,
              }}
            />
            <Text
              className={`text-base font-medium ${
                isDark ? 'text-red-300' : 'text-red-600'
              }`}
              style={{
                textShadowColor: isDark
                  ? 'rgba(0, 0, 0, 0.3)'
                  : 'rgba(255, 255, 255, 0.8)',
                textShadowOffset: { width: 0, height: 1 },
                textShadowRadius: 2,
              }}
            >
              Log out
            </Text>
          </GlassCard>
        </TouchableOpacity>
      </ScrollView>
    </GlassView>
  );
};
