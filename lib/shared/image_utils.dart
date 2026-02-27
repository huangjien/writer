import 'package:flutter/material.dart';

class ImageUtils {
  static bool isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);

      // Check if it's a valid URL
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return false;
      }

      // Check if it's an image file (common image extensions)
      final path = uri.path.toLowerCase();
      final imageExtensions = [
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.webp',
        '.svg',
      ];
      final hasImageExtension = imageExtensions.any(path.endsWith);

      // Allow Unsplash URLs and other common image hosts without extensions
      final isKnownImageHost =
          uri.host.contains('unsplash.com') ||
          uri.host.contains('picsum.photos') ||
          uri.host.contains('images.unsplash.com');

      return hasImageExtension || isKnownImageHost;
    } catch (e) {
      return false;
    }
  }

  static String? getValidImageUrl(String? url) {
    return isValidImageUrl(url) ? url : null;
  }

  static String? getFilteredCoverUrl(String? coverUrl) {
    if (coverUrl == null || coverUrl.isEmpty) return null;

    // Check for known problematic URLs
    final problematicUrls = [
      'https://images.unsplash.com/photo-1519681393784-7f06f0eb4756?w=800&q=80',
    ];

    if (problematicUrls.contains(coverUrl)) {
      return null;
    }

    return getValidImageUrl(coverUrl);
  }

  static String getFallbackCoverUrl() {
    // Use a reliable placeholder image service
    return 'https://picsum.photos/seed/writer-cover/400/600.jpg';
  }

  static Widget buildFallbackImage({
    required double width,
    required double height,
    BorderRadius? borderRadius,
    IconData? icon,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Icon(
          icon ?? Icons.menu_book,
          size: width * 0.3,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
