import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:writer/features/ai_chat/services/agents_config_service.dart';

class MockClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

void main() {
  late MockClient mockClient;
  late AgentsConfigService service;

  setUp(() {
    mockClient = MockClient();
    service = AgentsConfigService('http://test.com', client: mockClient);
    registerFallbackValue(Uri());
  });

  group('AgentsConfigService', () {
    test('getEffective returns map on success', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn('{"key": "value"}');
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => mockResponse);

      final result = await service.getEffective('editor');
      expect(result, isNotNull);
      expect(result!['key'], 'value');
    });

    test('getEffective returns null on error', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(404);
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => mockResponse);

      final result = await service.getEffective('editor');
      expect(result, isNull);
    });

    test('list returns list on success', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn('[{"id": 1}]');
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => mockResponse);

      final result = await service.list('editor');
      expect(result, hasLength(1));
      expect(result.first['id'], 1);
    });

    test('list returns empty on error', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(500);
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => mockResponse);

      final result = await service.list('editor');
      expect(result, isEmpty);
    });

    test('saveMyVersion sends post and returns map', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn('{"id": 123}');
      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await service.saveMyVersion('editor', {'config': 1});
      expect(result, isNotNull);
      expect(result!['id'], 123);
    });

    test('saveMyVersion returns null on error', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(400);
      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await service.saveMyVersion('editor', {});
      expect(result, isNull);
    });
  });
}
