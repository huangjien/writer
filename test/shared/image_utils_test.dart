import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:writer/shared/image_utils.dart';

void main() {
  group('ImageUtils', () {
    group('isValidImageUrl', () {
      test('returns false for null or empty url', () {
        expect(ImageUtils.isValidImageUrl(null), isFalse);
        expect(ImageUtils.isValidImageUrl(''), isFalse);
      });

      test('returns false for invalid URI', () {
        expect(ImageUtils.isValidImageUrl('not a url'), isFalse);
        expect(ImageUtils.isValidImageUrl('http://'), isFalse);
      });

      test('returns false for non-http/https schemes', () {
        expect(
          ImageUtils.isValidImageUrl('ftp://example.com/image.jpg'),
          isFalse,
        );
        expect(ImageUtils.isValidImageUrl('file:///image.jpg'), isFalse);
      });

      test('returns true for valid image extensions', () {
        expect(
          ImageUtils.isValidImageUrl('https://example.com/image.jpg'),
          isTrue,
        );
        expect(
          ImageUtils.isValidImageUrl('https://example.com/image.jpeg'),
          isTrue,
        );
        expect(
          ImageUtils.isValidImageUrl('https://example.com/image.png'),
          isTrue,
        );
        expect(
          ImageUtils.isValidImageUrl('https://example.com/image.gif'),
          isTrue,
        );
        expect(
          ImageUtils.isValidImageUrl('https://example.com/image.webp'),
          isTrue,
        );
        expect(
          ImageUtils.isValidImageUrl('https://example.com/image.svg'),
          isTrue,
        );
      });

      test('returns true for known image hosts without extensions', () {
        expect(
          ImageUtils.isValidImageUrl('https://unsplash.com/photos/123'),
          isTrue,
        );
        expect(
          ImageUtils.isValidImageUrl('https://images.unsplash.com/photo-123'),
          isTrue,
        );
        expect(
          ImageUtils.isValidImageUrl('https://picsum.photos/200/300'),
          isTrue,
        );
      });

      test('returns false for unknown hosts without extensions', () {
        expect(
          ImageUtils.isValidImageUrl('https://example.com/not-an-image'),
          isFalse,
        );
      });

      test('handles query parameters correctly', () {
        expect(
          ImageUtils.isValidImageUrl('https://example.com/image.jpg?v=1'),
          isTrue,
        );
      });
    });

    group('getValidImageUrl', () {
      test('returns url if valid', () {
        const url = 'https://example.com/image.jpg';
        expect(ImageUtils.getValidImageUrl(url), url);
      });

      test('returns null if invalid', () {
        expect(ImageUtils.getValidImageUrl('invalid'), isNull);
      });
    });

    group('getFilteredCoverUrl', () {
      test('returns null for null or empty url', () {
        expect(ImageUtils.getFilteredCoverUrl(null), isNull);
        expect(ImageUtils.getFilteredCoverUrl(''), isNull);
      });

      test('returns null for problematic URLs', () {
        const badUrl =
            'https://images.unsplash.com/photo-1519681393784-7f06f0eb4756?w=800&q=80';
        expect(ImageUtils.getFilteredCoverUrl(badUrl), isNull);
      });

      test('returns valid url', () {
        const url = 'https://example.com/image.jpg';
        expect(ImageUtils.getFilteredCoverUrl(url), url);
      });
    });

    group('getFallbackCoverUrl', () {
      test('returns a valid url string', () {
        final url = ImageUtils.getFallbackCoverUrl();
        expect(url, isNotEmpty);
        expect(url, startsWith('https://'));
      });
    });

    group('buildFallbackImage', () {
      testWidgets('renders container with icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageUtils.buildFallbackImage(width: 100, height: 150),
            ),
          ),
        );

        expect(find.byType(Container), findsOneWidget);
        expect(find.byIcon(Icons.menu_book), findsOneWidget);
      });

      testWidgets('renders with custom icon', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ImageUtils.buildFallbackImage(
                width: 100,
                height: 150,
                icon: Icons.image,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.image), findsOneWidget);
      });
    });
  });
}
