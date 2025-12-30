import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:writer/services/vector_service.dart';

import 'vector_service_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  group('VectorService interface', () {
    test('RemoteVectorService implements VectorService', () {
      final service = RemoteVectorService(baseUrl: 'http://test.com');
      expect(service, isA<VectorService>());
    });
  });

  group('RemoteVectorService', () {
    late MockClient mockClient;
    late RemoteVectorService service;
    const baseUrl = 'https://api.example.com';

    setUp(() {
      mockClient = MockClient();
      service = RemoteVectorService(baseUrl: baseUrl, client: mockClient);
    });

    group('getCharacterTemplateEmbedding', () {
      test('returns embedding on successful response', () async {
        const templateId = 'test-template-id';
        const embedding = 'test-embedding-vector';
        final response = http.Response.bytes(
          '{"embedding": "$embedding"}'.codeUnits,
          200,
        );

        when(mockClient.get(any)).thenAnswer((_) async => response);

        final result = await service.getCharacterTemplateEmbedding(templateId);

        expect(result, equals(embedding));
        verify(
          mockClient.get(
            Uri.parse('$baseUrl/templates/character/$templateId/embedding'),
          ),
        ).called(1);
      });

      test('returns null on non-200 response', () async {
        const templateId = 'test-template-id';
        final response = http.Response('Not Found', 404);

        when(mockClient.get(any)).thenAnswer((_) async => response);

        final result = await service.getCharacterTemplateEmbedding(templateId);

        expect(result, isNull);
        verify(
          mockClient.get(
            Uri.parse('$baseUrl/templates/character/$templateId/embedding'),
          ),
        ).called(1);
      });

      test('returns null on network error', () async {
        const templateId = 'test-template-id';

        when(mockClient.get(any)).thenThrow(Exception('Network error'));

        final result = await service.getCharacterTemplateEmbedding(templateId);

        expect(result, isNull);
        verify(
          mockClient.get(
            Uri.parse('$baseUrl/templates/character/$templateId/embedding'),
          ),
        ).called(1);
      });

      test('returns null when embedding field is missing', () async {
        const templateId = 'test-template-id';
        final response = http.Response.bytes(
          '{"other_field": "value"}'.codeUnits,
          200,
        );

        when(mockClient.get(any)).thenAnswer((_) async => response);

        final result = await service.getCharacterTemplateEmbedding(templateId);

        expect(result, isNull);
      });

      test('returns null on invalid JSON', () async {
        const templateId = 'test-template-id';
        final response = http.Response.bytes('invalid json'.codeUnits, 200);

        when(mockClient.get(any)).thenAnswer((_) async => response);

        final result = await service.getCharacterTemplateEmbedding(templateId);

        expect(result, isNull);
      });
    });

    group('getSceneTemplateEmbedding', () {
      test('returns embedding on successful response', () async {
        const templateId = 'scene-template-id';
        const embedding = 'scene-embedding-vector';
        final response = http.Response.bytes(
          '{"embedding": "$embedding"}'.codeUnits,
          200,
        );

        when(mockClient.get(any)).thenAnswer((_) async => response);

        final result = await service.getSceneTemplateEmbedding(templateId);

        expect(result, equals(embedding));
        verify(
          mockClient.get(
            Uri.parse('$baseUrl/templates/scene/$templateId/embedding'),
          ),
        ).called(1);
      });

      test('returns null on non-200 response', () async {
        const templateId = 'scene-template-id';
        final response = http.Response('Server Error', 500);

        when(mockClient.get(any)).thenAnswer((_) async => response);

        final result = await service.getSceneTemplateEmbedding(templateId);

        expect(result, isNull);
        verify(
          mockClient.get(
            Uri.parse('$baseUrl/templates/scene/$templateId/embedding'),
          ),
        ).called(1);
      });

      test('returns null on network error', () async {
        const templateId = 'scene-template-id';

        when(mockClient.get(any)).thenThrow(Exception('Network error'));

        final result = await service.getSceneTemplateEmbedding(templateId);

        expect(result, isNull);
        verify(
          mockClient.get(
            Uri.parse('$baseUrl/templates/scene/$templateId/embedding'),
          ),
        ).called(1);
      });

      test('returns null when embedding field is missing', () async {
        const templateId = 'scene-template-id';
        final response = http.Response.bytes(
          '{"template_id": "$templateId"}'.codeUnits,
          200,
        );

        when(mockClient.get(any)).thenAnswer((_) async => response);

        final result = await service.getSceneTemplateEmbedding(templateId);

        expect(result, isNull);
      });
    });

    group('refreshChapterEmbedding', () {
      test('makes POST request successfully', () async {
        const chapterId = 'chapter-123';
        final response = http.Response('Embedding refreshed', 200);

        when(mockClient.post(any)).thenAnswer((_) async => response);

        await service.refreshChapterEmbedding(chapterId);

        verify(
          mockClient.post(
            Uri.parse('$baseUrl/chapters/$chapterId/refresh_embedding'),
          ),
        ).called(1);
      });

      test('handles 404 response gracefully', () async {
        const chapterId = 'nonexistent-chapter';
        final response = http.Response('Chapter not found', 404);

        when(mockClient.post(any)).thenAnswer((_) async => response);

        await service.refreshChapterEmbedding(chapterId);

        verify(
          mockClient.post(
            Uri.parse('$baseUrl/chapters/$chapterId/refresh_embedding'),
          ),
        ).called(1);
      });

      test('handles network error gracefully', () async {
        const chapterId = 'chapter-456';

        when(mockClient.post(any)).thenThrow(Exception('Connection failed'));

        await service.refreshChapterEmbedding(chapterId);

        verify(
          mockClient.post(
            Uri.parse('$baseUrl/chapters/$chapterId/refresh_embedding'),
          ),
        ).called(1);
      });

      test('handles server error gracefully', () async {
        const chapterId = 'chapter-789';
        final response = http.Response('Internal Server Error', 500);

        when(mockClient.post(any)).thenAnswer((_) async => response);

        await service.refreshChapterEmbedding(chapterId);

        verify(
          mockClient.post(
            Uri.parse('$baseUrl/chapters/$chapterId/refresh_embedding'),
          ),
        ).called(1);
      });
    });

    group('URL construction', () {
      test('handles baseUrl with trailing slash', () {
        const baseUrlWithSlash = 'https://api.example.com/';
        final serviceWithSlash = RemoteVectorService(
          baseUrl: baseUrlWithSlash,
          client: mockClient,
        );

        when(
          mockClient.post(any),
        ).thenAnswer((_) async => http.Response('', 200));

        serviceWithSlash.refreshChapterEmbedding('test-id');

        verify(
          mockClient.post(
            Uri.parse('$baseUrlWithSlash/chapters/test-id/refresh_embedding'),
          ),
        ).called(1);
      });

      test('handles baseUrl without trailing slash', () {
        const baseUrlWithoutSlash = 'https://api.example.com';
        final serviceWithoutSlash = RemoteVectorService(
          baseUrl: baseUrlWithoutSlash,
          client: mockClient,
        );

        when(
          mockClient.post(any),
        ).thenAnswer((_) async => http.Response('', 200));

        serviceWithoutSlash.refreshChapterEmbedding('test-id');

        verify(
          mockClient.post(
            Uri.parse(
              '$baseUrlWithoutSlash/chapters/test-id/refresh_embedding',
            ),
          ),
        ).called(1);
      });
    });
  });
}
