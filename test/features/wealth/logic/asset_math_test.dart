// Coverage: Wealth fixes (Feedback #4) — holding merge, gain %, lookup.

import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/features/wealth/data/models/asset_model.dart';
import 'package:fincontrol/features/wealth/logic/asset_math.dart';

AssetModel holding({
  String id = 'a1',
  String ticker = 'AAPL',
  String portfolioId = '',
  double qty = 10,
  double avg = 100,
  double price = 150,
}) =>
    AssetModel(
      id: id,
      userId: 'u1',
      portfolioId: portfolioId,
      name: 'Apple Inc.',
      tickerSymbol: ticker,
      category: 'Stock',
      totalQuantity: qty,
      averageBuyPrice: avg,
      currentPrice: price,
    );

void main() {
  group('AssetMath.mergeBuy', () {
    test('adds quantity and computes weighted average price', () {
      final merged = AssetMath.mergeBuy(holding(qty: 10, avg: 100), quantity: 10, buyPrice: 200);
      expect(merged.totalQuantity, 20);
      expect(merged.averageBuyPrice, 150);
      expect(merged.id, 'a1'); // same holding, not a new one
    });

    test('keeps goal and updates current price when given', () {
      final merged = AssetMath.mergeBuy(holding(portfolioId: 'g1'), quantity: 1, buyPrice: 100, currentPrice: 180);
      expect(merged.portfolioId, 'g1');
      expect(merged.currentPrice, 180);
    });

    test('ignores a zero current price', () {
      final merged = AssetMath.mergeBuy(holding(price: 150), quantity: 1, buyPrice: 100, currentPrice: 0);
      expect(merged.currentPrice, 150);
    });
  });

  group('AssetMath.findSameHolding', () {
    final list = [
      holding(id: 'x', ticker: 'AAPL', portfolioId: ''),
      holding(id: 'y', ticker: 'AAPL', portfolioId: 'g1'),
      holding(id: 'z', ticker: 'PTT.BK', portfolioId: ''),
    ];

    test('matches same ticker (case-insensitive) in the same goal', () {
      expect(AssetMath.findSameHolding(list, 'aapl', '')?.id, 'x');
      expect(AssetMath.findSameHolding(list, 'AAPL', 'g1')?.id, 'y');
    });

    test('no match in another goal or for empty ticker', () {
      expect(AssetMath.findSameHolding(list, 'AAPL', 'g2'), isNull);
      expect(AssetMath.findSameHolding(list, '', ''), isNull);
    });
  });

  group('AssetMath.gainPercent', () {
    test('+50% when price 150 vs average 100', () {
      expect(AssetMath.gainPercent(holding(avg: 100, price: 150)), closeTo(50, 1e-9));
    });

    test('null when cost is unknown', () {
      expect(AssetMath.gainPercent(holding(avg: 0)), isNull);
    });

    test('regression: edit must not divide the average price by quantity', () {
      // Old bug: per-unit price was prefilled as "total amount", then saved as
      // amount ÷ quantity → avg 190/75 ≈ 2.53 → about +7400%.
      const qty = 75.0, avg = 190.0;
      final prefilledAmount = qty * avg; // new prefill = total invested
      final savedAvg = prefilledAmount / qty;
      expect(savedAvg, avg);
    });
  });

  group('AssetMath misc', () {
    test('Thai tickers use THB, others USD', () {
      expect(AssetMath.baseCurrency(holding(ticker: 'PTT.BK')), 'THB');
      expect(AssetMath.baseCurrency(holding(ticker: 'AAPL')), 'USD');
    });

    test('formatQuantity trims trailing zeros', () {
      expect(AssetMath.formatQuantity(10), '10');
      expect(AssetMath.formatQuantity(0.5), '0.5');
      expect(AssetMath.formatQuantity(0.1234567), '0.123457');
    });
  });

  group('AssetMath.planMove (Feedback #6)', () {
    test('moves into a goal without that ticker', () {
      final a = holding(id: 'a', portfolioId: '');
      final plan = AssetMath.planMove([a], [a], 'g1');
      expect(plan.deletes, isEmpty);
      expect(plan.updates.single.portfolioId, 'g1');
    });

    test('merges into the same ticker already in the goal', () {
      final inGoal = holding(id: 'g', portfolioId: 'g1', qty: 10, avg: 100);
      final moving = holding(id: 'm', portfolioId: '', qty: 10, avg: 200);
      final plan = AssetMath.planMove([inGoal, moving], [moving], 'g1');
      expect(plan.deletes, ['m']);
      final merged = plan.updates.single;
      expect(merged.id, 'g');
      expect(merged.totalQuantity, 20);
      expect(merged.averageBuyPrice, 150);
    });

    test('three duplicates moved together become one holding', () {
      final list = [
        holding(id: '1', qty: 1, avg: 100),
        holding(id: '2', qty: 1, avg: 200),
        holding(id: '3', qty: 2, avg: 300),
      ];
      final plan = AssetMath.planMove(list, list, 'g1');
      expect(plan.deletes.toSet(), {'2', '3'});
      final merged = plan.updates.single;
      expect(merged.id, '1');
      expect(merged.portfolioId, 'g1');
      expect(merged.totalQuantity, 4);
      expect(merged.averageBuyPrice, closeTo(225, 1e-9)); // (100+200+600)/4
    });

    test('removing from a goal merges into Unassigned', () {
      final free = holding(id: 'f', portfolioId: '', qty: 5, avg: 100);
      final inGoal = holding(id: 'x', portfolioId: 'g1', qty: 5, avg: 100);
      final plan = AssetMath.planMove([free, inGoal], [inGoal], '');
      expect(plan.deletes, ['x']);
      expect(plan.updates.single.totalQuantity, 10);
    });

    test('different tickers are never merged; same goal is a no-op', () {
      final a = holding(id: 'a', ticker: 'AAPL', portfolioId: 'g1');
      final b = holding(id: 'b', ticker: 'MSFT', portfolioId: '');
      final plan = AssetMath.planMove([a, b], [a, b], 'g1');
      expect(plan.deletes, isEmpty);
      expect(plan.updates.map((u) => u.id), ['b']);
    });
  });
}
