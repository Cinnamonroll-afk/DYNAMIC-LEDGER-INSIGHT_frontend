import 'dart:convert';
import 'package:http/http.dart' as http;

class MarketApiRepository {
  final String _baseUrl = 'https://query1.finance.yahoo.com/v8/finance/chart';
  final http.Client _client;

  MarketApiRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<double> getPrice(String tickerSymbol) async {
    if (tickerSymbol.isEmpty) return 0.0;
    
    final url = Uri.parse('$_baseUrl/$tickerSymbol');
    try {
      final response = await _client.get(
        url,
        headers: {'User-Agent': 'Mozilla/5.0'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['chart']?['result'];
        if (result != null && result.isNotEmpty) {
          final meta = result[0]['meta'];
          if (meta != null && meta['regularMarketPrice'] != null) {
            return (meta['regularMarketPrice'] as num).toDouble();
          }
        }
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<double> getStockPrice(String tickerSymbol) => getPrice(tickerSymbol);
  
  Future<double> getCryptoPrice(String tickerSymbol) => getPrice(tickerSymbol);

  Future<Map<String, dynamic>> getAssetStats(String tickerSymbol) async {
    if (tickerSymbol.isEmpty) return {};
    
    final url = Uri.parse('$_baseUrl/$tickerSymbol?interval=1d&range=1d');
    try {
      final response = await _client.get(
        url,
        headers: {'User-Agent': 'Mozilla/5.0'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['chart']?['result'];
        if (result != null && result.isNotEmpty) {
          final meta = result[0]['meta'];
          final indicators = result[0]['indicators'];
          
          num? open, high, low, volume;
          if (indicators != null && indicators['quote'] != null && indicators['quote'].isNotEmpty) {
            final quote = indicators['quote'][0];
            if (quote['open'] != null && quote['open'].isNotEmpty) open = quote['open'][0];
            if (quote['high'] != null && quote['high'].isNotEmpty) high = quote['high'][0];
            if (quote['low'] != null && quote['low'].isNotEmpty) low = quote['low'][0];
            if (quote['volume'] != null && quote['volume'].isNotEmpty) volume = quote['volume'][0];
          }

          return {
            'regularMarketPrice': meta?['regularMarketPrice'],
            'regularMarketChange': meta?['regularMarketPrice'] != null && meta?['previousClose'] != null 
                ? meta['regularMarketPrice'] - meta['previousClose'] 
                : null,
            'regularMarketChangePercent': meta?['regularMarketPrice'] != null && meta?['previousClose'] != null && meta['previousClose'] > 0
                ? ((meta['regularMarketPrice'] - meta['previousClose']) / meta['previousClose']) * 100 
                : null,
            'regularMarketOpen': open,
            'regularMarketDayHigh': high,
            'regularMarketDayLow': low,
            'regularMarketPreviousClose': meta?['previousClose'],
            'regularMarketVolume': volume,
            'marketCap': null,
            'currency': meta?['currency'],
            'exchange': meta?['exchangeName'],
            'quoteType': meta?['instrumentType'],
            'marketState': 'REGULAR',
          };
        }
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<List<double>> getChartData(String tickerSymbol, {String interval = '15m', String range = '1d'}) async {
    if (tickerSymbol.isEmpty) return [];
    
    final url = Uri.parse('$_baseUrl/$tickerSymbol?interval=$interval&range=$range');
    try {
      final response = await _client.get(
        url,
        headers: {'User-Agent': 'Mozilla/5.0'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['chart']?['result'];
        if (result != null && result.isNotEmpty) {
          final indicators = result[0]['indicators'];
          if (indicators != null && indicators['quote'] != null && indicators['quote'].isNotEmpty) {
            final closePrices = indicators['quote'][0]['close'];
            if (closePrices is List) {
              return closePrices.where((e) => e != null).map((e) => (e as num).toDouble()).toList();
            }
          }
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
