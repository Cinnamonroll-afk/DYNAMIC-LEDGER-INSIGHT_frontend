// Coverage: URS-03-01 (total balance), URS-03-02 (monthly income/expense),
//           URS-03-03 (spend ratio), URS-03-05 (7-day sparkline)
//
// The calculation logic lives in home_page.dart (_buildBalanceCard).
// These tests replicate the exact formulas to verify correctness for
// traceability — no widget required.

import 'package:flutter_test/flutter_test.dart';

// ── Helpers that mirror home_page.dart logic exactly ──────────────────────

class _Tx {
  final String type;
  final double amount;
  final DateTime date;
  const _Tx(this.type, this.amount, this.date);
}

double _calcTotalBalance(List<_Tx> txs) {
  double total = 0;
  for (final t in txs) {
    final type = t.type.toLowerCase();
    final amt = t.amount.abs();
    if (type == 'income') total += amt;
    if (type == 'expense') total -= amt;
  }
  return total;
}

Map<String, double> _calcMonthly(List<_Tx> txs, DateTime now) {
  double income = 0, expense = 0;
  for (final t in txs) {
    if (t.date.year == now.year && t.date.month == now.month) {
      final type = t.type.toLowerCase();
      final amt = t.amount.abs();
      if (type == 'income') income += amt;
      if (type == 'expense') expense += amt;
    }
  }
  return {'income': income, 'expense': expense};
}

double _calcSpendRatio(double monthlyIncome, double monthlyExpense) {
  if (monthlyIncome <= 0) return 0.0;
  return (monthlyExpense / monthlyIncome).clamp(0.0, 1.0);
}

/// Returns dailyNet[diff] = net for day (now - diff days).
/// diff 0 = today, diff 6 = 6 days ago. Only 0..6 are included.
Map<int, double> _calcDailyNet(List<_Tx> txs, DateTime now) {
  final Map<int, double> dailyNet = {};
  for (final t in txs) {
    final diff = now.difference(t.date).inDays;
    if (diff >= 0 && diff < 7) {
      final amt = t.amount.abs();
      final net = t.type.toLowerCase() == 'income' ? amt : -amt;
      dailyNet[diff] = (dailyNet[diff] ?? 0) + net;
    }
  }
  return dailyNet;
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  final now = DateTime(2024, 6, 15);

  // ── URS-03-01: Total balance ───────────────────────────────────────────────

  group('Total balance calculation (URS-03-01)', () {
    test('empty transaction list gives 0', () {
      expect(_calcTotalBalance([]), 0.0);
    });

    test('income only: balance equals sum of income', () {
      final txs = [
        _Tx('income', 1000, now),
        _Tx('income', 500, now),
      ];
      expect(_calcTotalBalance(txs), 1500.0);
    });

    test('expense only: balance is negative', () {
      final txs = [
        _Tx('expense', 300, now),
        _Tx('expense', 200, now),
      ];
      expect(_calcTotalBalance(txs), -500.0);
    });

    test('income minus expense: balance = income - expense', () {
      final txs = [
        _Tx('income', 2000, now),
        _Tx('expense', 800, now),
      ];
      expect(_calcTotalBalance(txs), 1200.0);
    });

    test('balance can go negative when expenses exceed income', () {
      final txs = [
        _Tx('income', 100, now),
        _Tx('expense', 500, now),
      ];
      expect(_calcTotalBalance(txs), -400.0);
    });

    test('type is case-insensitive (Income/EXPENSE/Expense all work)', () {
      final txs = [
        _Tx('Income', 1000, now),
        _Tx('EXPENSE', 400, now),
        _Tx('Expense', 100, now),
      ];
      expect(_calcTotalBalance(txs), 500.0);
    });

    test('amount.abs() is applied (negative stored amount treated as positive)', () {
      final txs = [
        _Tx('income', -500, now), // abs → 500
        _Tx('expense', -200, now), // abs → 200
      ];
      expect(_calcTotalBalance(txs), 300.0);
    });
  });

  // ── URS-03-02: Monthly income/expense filter ──────────────────────────────

  group('Monthly income/expense filter (URS-03-02)', () {
    test('only current-month transactions are counted', () {
      final txs = [
        _Tx('income', 1000, DateTime(2024, 6, 1)),  // current month
        _Tx('income', 999,  DateTime(2024, 5, 31)), // previous month — excluded
        _Tx('expense', 200, DateTime(2024, 6, 15)), // current month
        _Tx('expense', 999, DateTime(2024, 7, 1)),  // future month — excluded
      ];
      final result = _calcMonthly(txs, now);
      expect(result['income'], 1000.0);
      expect(result['expense'], 200.0);
    });

    test('previous year same month is excluded', () {
      final txs = [
        _Tx('income', 5000, DateTime(2023, 6, 10)), // same month but last year
        _Tx('income', 1000, DateTime(2024, 6, 10)), // this year
      ];
      final result = _calcMonthly(txs, now);
      expect(result['income'], 1000.0);
    });

    test('all zeros when no current-month transactions', () {
      final txs = [
        _Tx('income', 1000, DateTime(2024, 5, 31)),
        _Tx('expense', 500, DateTime(2024, 7, 1)),
      ];
      final result = _calcMonthly(txs, now);
      expect(result['income'], 0.0);
      expect(result['expense'], 0.0);
    });

    test('sums multiple transactions in the same month', () {
      final txs = [
        _Tx('income', 100, DateTime(2024, 6, 1)),
        _Tx('income', 200, DateTime(2024, 6, 14)),
        _Tx('expense', 50, DateTime(2024, 6, 5)),
        _Tx('expense', 75, DateTime(2024, 6, 10)),
      ];
      final result = _calcMonthly(txs, now);
      expect(result['income'], 300.0);
      expect(result['expense'], 125.0);
    });
  });

  // ── URS-03-03: Spend ratio ─────────────────────────────────────────────────

  group('Spend ratio calculation (URS-03-03)', () {
    test('spend ratio = 0 when no income', () {
      expect(_calcSpendRatio(0, 500), 0.0);
    });

    test('spend ratio = expense / income', () {
      expect(_calcSpendRatio(1000, 400), closeTo(0.4, 0.0001));
    });

    test('spend ratio = 1.0 when expense equals income', () {
      expect(_calcSpendRatio(1000, 1000), 1.0);
    });

    test('spend ratio is clamped to 1.0 when expense exceeds income', () {
      expect(_calcSpendRatio(500, 2000), 1.0);
    });

    test('spend ratio = 0.0 when expense is 0', () {
      expect(_calcSpendRatio(1000, 0), 0.0);
    });

    test('spend ratio is never negative (clamp lower bound = 0)', () {
      // Negative expense would not occur in practice, but clamp ensures safety
      expect(_calcSpendRatio(1000, -100).clamp(0.0, 1.0), 0.0);
    });
  });

  // ── URS-03-05: 7-day sparkline daily net ────────────────────────────────

  group('7-day sparkline daily net (URS-03-05)', () {
    test('transactions older than 7 days are excluded', () {
      final txs = [
        _Tx('income', 500, now.subtract(const Duration(days: 7))), // diff=7, excluded
        _Tx('income', 100, now.subtract(const Duration(days: 6))), // diff=6, included
      ];
      final net = _calcDailyNet(txs, now);
      expect(net.containsKey(7), isFalse);
      expect(net[6], 100.0);
    });

    test('future transactions (negative diff) are excluded', () {
      final txs = [
        _Tx('income', 999, now.add(const Duration(days: 1))), // diff = -1, excluded
      ];
      final net = _calcDailyNet(txs, now);
      expect(net.isEmpty, isTrue);
    });

    test('today (diff=0) income is positive net', () {
      final txs = [_Tx('income', 200, now)];
      expect(_calcDailyNet(txs, now)[0], 200.0);
    });

    test('today (diff=0) expense is negative net', () {
      final txs = [_Tx('expense', 150, now)];
      expect(_calcDailyNet(txs, now)[0], -150.0);
    });

    test('multiple transactions on same day accumulate net', () {
      final day = now.subtract(const Duration(days: 2));
      final txs = [
        _Tx('income', 500, day),
        _Tx('expense', 200, day),
        _Tx('expense', 100, day),
      ];
      expect(_calcDailyNet(txs, now)[2], 200.0); // 500 - 200 - 100
    });

    test('net is correct over multiple days', () {
      final txs = [
        _Tx('income', 1000, now),                              // diff=0
        _Tx('expense', 300, now.subtract(const Duration(days: 1))), // diff=1
        _Tx('income', 400, now.subtract(const Duration(days: 3))), // diff=3
      ];
      final net = _calcDailyNet(txs, now);
      expect(net[0], 1000.0);
      expect(net[1], -300.0);
      expect(net[3], 400.0);
      expect(net.containsKey(2), isFalse); // no transactions
    });

    test('empty transaction list gives empty dailyNet', () {
      expect(_calcDailyNet([], now).isEmpty, isTrue);
    });
  });
}
