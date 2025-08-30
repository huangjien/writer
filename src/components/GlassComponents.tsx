import React from 'react';
import { View, ViewProps, ViewStyle } from 'react-native';
import { useColorScheme } from 'nativewind';

interface GlassViewProps extends ViewProps {
  variant?: 'ultraLight' | 'light' | 'medium' | 'strong';
  children?: React.ReactNode;
  style?: ViewStyle;
  className?: string;
}

interface GlassCardProps extends ViewProps {
  children?: React.ReactNode;
  style?: ViewStyle;
  elevated?: boolean;
  className?: string;
}

interface GlassModalProps extends ViewProps {
  children?: React.ReactNode;
  style?: ViewStyle;
  backdrop?: boolean;
  className?: string;
}

/**
 * GlassView - Basic glass effect container
 * Provides translucent background with blur effect
 */
export function GlassView({
  variant = 'light',
  children,
  style,
  className = '',
  ...props
}: GlassViewProps) {
  const { colorScheme } = useColorScheme();
  const isDark = colorScheme === 'dark';

  const getVariantClass = () => {
    const baseClass = 'border border-glass-border';

    switch (variant) {
      case 'ultraLight':
        return `${baseClass} ${isDark ? 'bg-glass-ultraLightDark' : 'bg-glass-ultraLight'}`;
      case 'light':
        return `${baseClass} ${isDark ? 'bg-glass-lightDark' : 'bg-glass-light'}`;
      case 'medium':
        return `${baseClass} ${isDark ? 'bg-glass-mediumDark' : 'bg-glass-medium'}`;
      case 'strong':
        return `${baseClass} ${isDark ? 'bg-glass-strongDark' : 'bg-glass-strong'}`;
      default:
        return `${baseClass} ${isDark ? 'bg-glass-lightDark' : 'bg-glass-light'}`;
    }
  };

  return (
    <View
      className={`glass-effect rounded-glass ${getVariantClass()} ${className}`}
      style={[
        {
          shadowColor: isDark ? '#000000' : '#1f2687',
          shadowOffset: { width: 0, height: 8 },
          shadowOpacity: isDark ? 0.25 : 0.37,
          shadowRadius: 32,
          elevation: 8,
        },
        style,
      ]}
      {...props}
    >
      {children}
    </View>
  );
}

/**
 * GlassCard - Enhanced glass container for content cards
 * Provides elevated glass effect with enhanced blur and shadows
 */
export function GlassCard({
  children,
  style,
  className = '',
  elevated = true,
  ...props
}: GlassCardProps) {
  const { colorScheme } = useColorScheme();
  const isDark = colorScheme === 'dark';

  return (
    <View
      className={`glass-card rounded-glass-lg ${isDark ? 'border-glass-borderDark' : 'border-glass-border'} ${className}`}
      style={[
        {
          shadowColor: isDark ? '#000000' : '#1f2687',
          shadowOffset: { width: 0, height: elevated ? 12 : 8 },
          shadowOpacity: isDark ? 0.3 : 0.4,
          shadowRadius: elevated ? 40 : 32,
          elevation: elevated ? 12 : 8,
        },
        style,
      ]}
      {...props}
    >
      {children}
    </View>
  );
}

/**
 * GlassModal - Glass effect for modal overlays
 * Provides strong glass effect with backdrop blur
 */
export function GlassModal({
  children,
  style,
  className = '',
  backdrop = true,
  ...props
}: GlassModalProps) {
  const { colorScheme } = useColorScheme();
  const isDark = colorScheme === 'dark';

  return (
    <View
      className={`glass-modal rounded-glass-xl ${isDark ? 'border-glass-borderDark' : 'border-glass-border'} ${className}`}
      style={[
        {
          shadowColor: isDark ? '#000000' : '#1f2687',
          shadowOffset: { width: 0, height: 25 },
          shadowOpacity: isDark ? 0.35 : 0.25,
          shadowRadius: 50,
          elevation: 16,
        },
        backdrop && {
          backgroundColor: isDark
            ? 'rgba(15, 23, 42, 0.85)'
            : 'rgba(248, 250, 252, 0.85)',
        },
        style,
      ]}
      {...props}
    >
      {children}
    </View>
  );
}

/**
 * GlassBackground - Full-screen glass background overlay
 * Used for app backgrounds with subtle glass effect
 */
interface GlassBackgroundProps extends ViewProps {
  children?: React.ReactNode;
  style?: ViewStyle;
  className?: string;
}

export function GlassBackground({
  children,
  style,
  className = '',
  ...props
}: GlassBackgroundProps) {
  const { colorScheme } = useColorScheme();
  const isDark = colorScheme === 'dark';

  return (
    <View
      className={`flex-1 ${className}`}
      style={[
        {
          backgroundColor: isDark
            ? 'rgba(15, 23, 42, 0.95)'
            : 'rgba(248, 250, 252, 0.95)',
        },
        style,
      ]}
      {...props}
    >
      {children}
    </View>
  );
}

/**
 * GlassButton - Glass effect button component
 * Provides interactive glass surface for buttons
 */
interface GlassButtonProps extends ViewProps {
  children?: React.ReactNode;
  style?: ViewStyle;
  className?: string;
}

export function GlassButton({
  children,
  style,
  className = '',
  ...props
}: GlassButtonProps) {
  const { colorScheme } = useColorScheme();
  const isDark = colorScheme === 'dark';

  return (
    <View
      className={`glass-effect rounded-glass px-6 py-3 ${isDark ? 'border-glass-borderDark' : 'border-glass-border'} ${className}`}
      style={[
        {
          shadowColor: isDark ? '#000000' : '#1f2687',
          shadowOffset: { width: 0, height: 4 },
          shadowOpacity: isDark ? 0.2 : 0.3,
          shadowRadius: 16,
          elevation: 4,
        },
        style,
      ]}
      {...props}
    >
      {children}
    </View>
  );
}

/**
 * GlassHeader - Glass effect header component
 * Provides translucent header with blur effect
 */
interface GlassHeaderProps extends ViewProps {
  children?: React.ReactNode;
  style?: ViewStyle;
  className?: string;
}

export function GlassHeader({
  children,
  style,
  className = '',
  ...props
}: GlassHeaderProps) {
  const { colorScheme } = useColorScheme();
  const isDark = colorScheme === 'dark';

  return (
    <View
      className={`glass-effect ${isDark ? 'bg-glass-mediumDark border-glass-borderDark' : 'bg-glass-medium border-glass-border'} ${className}`}
      style={[
        {
          shadowColor: isDark ? '#000000' : '#1f2687',
          shadowOffset: { width: 0, height: 2 },
          shadowOpacity: isDark ? 0.15 : 0.2,
          shadowRadius: 8,
          elevation: 2,
        },
        style,
      ]}
      {...props}
    >
      {children}
    </View>
  );
}

export default {
  GlassView,
  GlassCard,
  GlassModal,
  GlassBackground,
  GlassButton,
  GlassHeader,
};
