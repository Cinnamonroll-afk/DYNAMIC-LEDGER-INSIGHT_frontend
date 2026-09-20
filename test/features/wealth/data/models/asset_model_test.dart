import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';

void main() {
  final validMap = <String, dynamic>{
    'user_id': 'user1',
    'portfolio_id': 'port1',
    'name': 'Apple',
    'ticker_symbol': 'AAPL',
    'category': 'Stocks',
    'quantity': 10.0,
    'average_buy_price': 150.0,
    'current_price': 175.0,
  };

  group('AssetModel.fromMap — happy path', () {
    test('maps all fields correctly', () {
      final m = AssetModel.fromMap(validMap, 'asset1');
      expect(m.id, 'asset1');
      expect(m.userId, 'user1');
      expect(m.portfolioId, 'port1');
      expect(m.name, 'Apple');
      expect(m.tickerSymbol, 'AAPL');
      expect(m.category, 'Stocks');
      expect(m.totalQuantity, 10.0);
      expect(m.averageBuyPrice, 150.0);
      expect(m.currentPrice, 175.0);
    });

    test('parses integer quantity as double', () {
      final m = AssetModel.fromMap({...validMap, 'quantity': 5}, 'a1');
      expect(m.totalQuantity, 5.0);
      expect(m.totalQuantity, isA<double>());
    });

    test('parses integer prices as double', () {
      final m = AssetModel.fromMap({...validMap, 'average_buy_price': 100, 'current_price': 120}, 'a1');
      expect(m.averageBuyPrice, 100.0);
      expect(m.currentPrice, 120.0);
    });
  });

  group('AssetModel.fromMap — null / missing fields', () {
    test('null user_id defaults to empty string', () {
      expect(AssetModel.fromMap({...validMap, 'user_id': null}, 'a1').userId, '');
    });

    test('null portfolio_id defaults to empty string', () {
      expect(AssetModel.fromMap({...validMap, 'portfolio_id': null}, 'a1').portfolioId, '');
    });

    test('null name defaults to empty string', () {
      expect(AssetModel.fromMap({...validMap, 'name': null}, 'a1').name, '');
    });

    test('null ticker_symbol defaults to empty string', () {
      expect(AssetModel.fromMap({...validMap, 'ticker_symbol': null}, 'a1').tickerSymbol, '');
    });

    test('null quantity defaults to 0.0', () {
      expect(AssetModel.fromMap({...validMap, 'quantity': null}, 'a1').totalQuantity, 0.0);
    });

    test('null average_buy_price defaults to 0.0', () {
      expect(AssetModel.fromMap({...validMap, 'average_buy_price': null}, 'a1').averageBuyPrice, 0.0);
    });

    test('null current_price defaults to 0.0', () {
      expect(AssetModel.fromMap({...validMap, 'current_price': null}, 'a1').currentPrice, 0.0);
    });

    test('empty map creates model with all defaults', () {
      final m = AssetModel.fromMap({}, 'asset_empty');
      expect(m.id, 'asset_empty');
      expect(m.userId, '');
      expect(m.portfolioId, '');
      expect(m.name, '');
      expect(m.tickerSymbol, '');
      expect(m.totalQuantity, 0.0);
    });
  });

  group('AssetModel.toMap', () {
    final model = AssetModel.fromMap(validMap, 'asset1');

    test('contains user_id', () => expect(model.toMap()['user_id'], 'user1'));
    test('contains portfolio_id', () => expect(model.toMap()['portfolio_id'], 'port1'));
    test('contains name', () => expect(model.toMap()['name'], 'Apple'));
    test('contains ticker_symbol', () => expect(model.toMap()['ticker_symbol'], 'AAPL'));
    test('contains category', () => expect(model.toMap()['category'], 'Stocks'));
    test('quantity key is "quantity"', () => expect(model.toMap().containsKey('quantity'), isTrue));
    test('does NOT contain id key', () => expect(model.toMap().containsKey('id'), isFalse));

    test('roundtrip fromMap → toMap preserves numeric fields', () {
      final m2 = AssetModel.fromMap(model.toMap(), model.id);
      expect(m2.totalQuantity, model.totalQuantity);
      expect(m2.averageBuyPrice, model.averageBuyPrice);
      expect(m2.currentPrice, model.currentPrice);
    });
  });

  group('AssetModel.copyWith', () {
    final original = AssetModel.fromMap(validMap, 'asset1');

    test('updates currentPrice only', () {
      final updated = original.copyWith(currentPrice: 200.0);
      expect(updated.currentPrice, 200.0);
      expect(updated.id, 'asset1');
      expect(updated.name, 'Apple');
      expect(updated.totalQuantity, 10.0);
    });

    test('updates totalQuantity only', () {
      final updated = original.copyWith(totalQuantity: 20.0);
      expect(updated.totalQuantity, 20.0);
      expect(updated.currentPrice, 175.0);
    });

    test('updates tickerSymbol only', () {
      final updated = original.copyWith(tickerSymbol: 'MSFT');
      expect(updated.tickerSymbol, 'MSFT');
      expect(updated.name, 'Apple');
    });

    test('no args returns equivalent model', () {
      final copy = original.copyWith();
      expect(copy.id, original.id);
      expect(copy.userId, original.userId);
      expect(copy.currentPrice, original.currentPrice);
    });
  });
}
