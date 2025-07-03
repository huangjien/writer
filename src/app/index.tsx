import { Image } from '@/components/image';
import { Text, View, TouchableOpacity } from 'react-native';
import { images } from './images';
import { useRouter } from 'expo-router';
import { Feather } from '@expo/vector-icons';
import { ScrollView } from 'react-native-gesture-handler';

export default function Page() {
  const router = useRouter();

  const features = [
    {
      icon: 'book-open',
      title: 'Smart Reading',
      description:
        'Access your content from GitHub repositories with intelligent text processing',
    },
    {
      icon: 'volume-2',
      title: 'Text-to-Speech',
      description:
        'Natural voice synthesis with adjustable speed and progress tracking',
    },
    {
      icon: 'settings',
      title: 'Customizable',
      description:
        'Configure GitHub integration, voice settings, and reading preferences',
    },
    {
      icon: 'smartphone',
      title: 'Cross-Platform',
      description: 'Works seamlessly on mobile and web with responsive design',
    },
  ];

  return (
    <ScrollView className='flex-1 bg-white dark:bg-black'>
      {/* Hero Section */}
      <View className='py-12 md:py-24 lg:py-32'>
        <View className='px-4 md:px-6'>
          <View className='flex flex-col items-center gap-6 text-center'>
            <View className='flex justify-center items-center mb-6'>
              <Image
                source={images.logo}
                className='w-24 h-24 rounded-full shadow-lg mb-4'
              />
            </View>
            <Text
              role='heading'
              className='text-3xl text-center native:text-5xl font-bold tracking-tighter sm:text-4xl md:text-5xl lg:text-6xl text-black dark:text-white'
            >
              Writer
            </Text>
            <Text className='mx-auto max-w-[700px] text-gray-500 md:text-xl dark:text-gray-400 text-center'>
              A powerful text-to-speech app that reads your content aloud with
              natural voice synthesis and GitHub integration.
            </Text>

            {/* Action Buttons */}
            <View className='flex flex-row gap-4 mt-6'>
              <TouchableOpacity
                className='bg-blue-600 px-6 py-3 rounded-lg flex flex-row items-center gap-2'
                onPress={() => router.push('/github')}
              >
                <Feather name='book-open' size={20} color='white' />
                <Text className='text-white font-semibold'>Browse Content</Text>
              </TouchableOpacity>

              <TouchableOpacity
                className='border border-gray-300 dark:border-gray-600 px-6 py-3 rounded-lg flex flex-row items-center gap-2'
                onPress={() => router.push('/setting')}
              >
                <Feather name='settings' size={20} color='gray' />
                <Text className='text-gray-700 dark:text-gray-300 font-semibold'>
                  Settings
                </Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </View>

      {/* Features Section */}
      <View className='py-12 px-4 md:px-6 bg-gray-50 dark:bg-gray-900'>
        <Text className='text-2xl font-bold text-center mb-8 text-black dark:text-white'>
          Key Features
        </Text>
        <View className='flex flex-col gap-6'>
          {features.map((feature, index) => (
            <View
              key={index}
              className='flex flex-row items-start gap-4 p-4 bg-white dark:bg-gray-800 rounded-lg shadow-sm'
            >
              <View className='bg-blue-100 dark:bg-blue-900 p-3 rounded-full'>
                <Feather name={feature.icon as any} size={24} color='#3B82F6' />
              </View>
              <View className='flex-1'>
                <Text className='text-lg font-semibold mb-2 text-black dark:text-white'>
                  {feature.title}
                </Text>
                <Text className='text-gray-600 dark:text-gray-400'>
                  {feature.description}
                </Text>
              </View>
            </View>
          ))}
        </View>
      </View>

      {/* Multi-language Welcome */}
      <View className='py-12 px-4 md:px-6'>
        <Text className='text-xl font-semibold text-center mb-6 text-black dark:text-white'>
          Welcome in Multiple Languages
        </Text>
        <View className='flex flex-col gap-3 items-center'>
          <Text className='text-lg text-gray-600 dark:text-gray-300'>
            🇨🇳 欢迎使用 Writer - 您的智能阅读助手
          </Text>
          <Text className='text-lg text-gray-600 dark:text-gray-300'>
            🇪🇸 Bienvenido a Writer - Tu asistente de lectura inteligente
          </Text>
          <Text className='text-lg text-gray-600 dark:text-gray-300'>
            🇫🇷 Bienvenue dans Writer - Votre assistant de lecture intelligent
          </Text>
          <Text className='text-lg text-gray-600 dark:text-gray-300'>
            🇩🇪 Willkommen bei Writer - Ihr intelligenter Leseassistent
          </Text>
        </View>
      </View>
    </ScrollView>
  );
}
