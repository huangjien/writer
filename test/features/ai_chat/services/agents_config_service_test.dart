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

    test('updateMyVersion sends put and returns map', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn('{"id": 456}');
      when(
        () => mockClient.put(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await service.updateMyVersion('abc', {'config': 2});
      expect(result, isNotNull);
      expect(result!['id'], 456);
    });

    test('updateMyVersion returns null on error', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(500);
      when(
        () => mockClient.put(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await service.updateMyVersion('abc', {});
      expect(result, isNull);
    });

    test('resetToPublic returns true on <400 and false otherwise', () async {
      final okResponse = MockResponse();
      when(() => okResponse.statusCode).thenReturn(204);
      when(
        () => mockClient.delete(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => okResponse);
      final ok = await service.resetToPublic('abc');
      expect(ok, isTrue);

      final badResponse = MockResponse();
      when(() => badResponse.statusCode).thenReturn(404);
      when(
        () => mockClient.delete(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => badResponse);
      final bad = await service.resetToPublic('abc');
      expect(bad, isFalse);
    });

    test('list returns empty when body is not a list', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn('{"x":1}');
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => mockResponse);

      final result = await service.list('editor');
      expect(result, isEmpty);
    });

    test('getEffective returns null when body is not a map', () async {
      final mockResponse = MockResponse();
      when(() => mockResponse.statusCode).thenReturn(200);
      when(() => mockResponse.body).thenReturn('[1,2]');
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => mockResponse);

      final result = await service.getEffective('editor');
      expect(result, isNull);
    });
  });
}
