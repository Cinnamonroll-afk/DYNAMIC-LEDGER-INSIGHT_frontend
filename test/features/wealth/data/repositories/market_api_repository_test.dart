import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:fincontrol/features/wealth/data/repositories/market_api_repository.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockClient;
  late MarketApiRepository repository;

  setUp(() {
    mockClient = MockHttpClient();
    repository = MarketApiRepository(client: mockClient);
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  // Helper: valid Yahoo Finance chart response
  http.Response _yahooResponse(double price) {
    final body = jsonEncode({
      'chart': {
        'result': [
          {
            'meta': {
              'regularMarketPrice': price,
              'previousClose': price - 1.0,
              'currency': 'USD',
              'exchangeName': 'NASDAQ',
              'instrumentType': 'EQUITY',
            },
            'indicators': {
              'quote': [
                {
                  'open': [price - 2],
                  'high': [price + 1],
                  'low': [price - 3],
                  'volume': [1000000],
                  'close': [price],
                }
              ]
            }
          }
        ]
      }
    });
    return http.Response(body, 200);
  }

  group('getPrice', () {
    test('returns 0.0 immediately when ticker is empty', () async {
      final result = await repository.getPrice('');
      expect(result, 0.0);
      verifyNever(() => mockClient.get(any(), headers: any(named: 'headers')));
    });

    test('returns price from successful response', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => _yahooResponse(150.0));
      final result = await repository.getPrice('AAPL');
      expect(result, 150.0);
    });

    test('returns 0.0 when status code is not 200', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{}', 404));
      final result = await repository.getPrice('AAPL');
      expect(result, 0.0);
    });

    test('returns 0.0 when response has no result', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode({'chart': {'result': null}}), 200));
      final result = await repository.getPrice('AAPL');
      expect(result, 0.0);
    });

    test('returns 0.0 when result array is empty', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode({'chart': {'result': []}}), 200));
      final result = await repository.getPrice('AAPL');
      expect(result, 0.0);
    });

    test('returns 0.0 on network exception', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('network error'));
      final result = await repository.getPrice('AAPL');
      expect(result, 0.0);
    });

    test('returns 0.0 on malformed JSON', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('not-json', 200));
      final result = await repository.getPrice('AAPL');
      expect(result, 0.0);
    });
  });

  group('getStockPrice', () {
    test('delegates to getPrice and returns value', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => _yahooResponse(200.0));
      final result = await repository.getStockPrice('TSLA');
      expect(result, 200.0);
    });

    test('returns 0.0 for empty ticker', () async {
      final result = await repository.getStockPrice('');
      expect(result, 0.0);
    });
  });

  group('getCryptoPrice', () {
    test('delegates to getPrice and returns value', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => _yahooResponse(30000.0));
      final result = await repository.getCryptoPrice('BTC-USD');
      expect(result, 30000.0);
    });

    test('returns 0.0 for empty ticker', () async {
      final result = await repository.getCryptoPrice('');
      expect(result, 0.0);
    });
  });

  group('getAssetStats', () {
    test('returns empty map immediately when ticker is empty', () async {
      final result = await repository.getAssetStats('');
      expect(result, isEmpty);
      verifyNever(() => mockClient.get(any(), headers: any(named: 'headers')));
    });

    test('returns stats map on success', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => _yahooResponse(150.0));
      final result = await repository.getAssetStats('AAPL');
      expect(result, isNotEmpty);
      expect(result.containsKey('regularMarketPrice'), isTrue);
    });

    test('returns empty map on non-200 response', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{}', 500));
      final result = await repository.getAssetStats('AAPL');
      expect(result, isEmpty);
    });

    test('returns empty map on exception', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('error'));
      final result = await repository.getAssetStats('AAPL');
      expect(result, isEmpty);
    });
  });

  group('getChartData', () {
    test('returns empty list immediately when ticker is empty', () async {
      final result = await repository.getChartData('');
      expect(result, isEmpty);
      verifyNever(() => mockClient.get(any(), headers: any(named: 'headers')));
    });

    test('returns list of close prices on success', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => _yahooResponse(150.0));
      final result = await repository.getChartData('AAPL');
      expect(result, isNotEmpty);
      expect(result, everyElement(isA<double>()));
    });

    test('returns empty list on non-200 response', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('{}', 404));
      final result = await repository.getChartData('AAPL');
      expect(result, isEmpty);
    });

    test('returns empty list on exception', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenThrow(Exception('connection timeout'));
      final result = await repository.getChartData('AAPL');
      expect(result, isEmpty);
    });

    test('filters out null close prices', () async {
      final body = jsonEncode({
        'chart': {
          'result': [
            {
              'meta': {'regularMarketPrice': 100.0},
              'indicators': {
                'quote': [
                  {'close': [100.0, null, 102.0, null, 104.0]}
                ]
              }
            }
          ]
        }
      });
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(body, 200));
      final result = await repository.getChartData('AAPL');
      expect(result.length, 3);
      expect(result, [100.0, 102.0, 104.0]);
    });
  });
}
