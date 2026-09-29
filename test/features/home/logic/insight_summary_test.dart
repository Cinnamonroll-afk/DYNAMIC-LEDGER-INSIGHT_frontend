// Coverage: AI Insight period filter (Feedback #1 after Progress 2)
//  - calendar ranges for day / week (Monday start) / month
//  - figures computed by the app (income, expense, categories, change %)
//  - fingerprint changes only when the period's data changes

import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/features/home/logic/insight_summary.dart';
import 'package:fincontrol/features/transaction/data/models/transaction_model.dart';

TransactionModel tx(String id, String type, double amount, DateTime date,
        {String category = 'Food & Dining', String note = ''}) =>
    TransactionModel(
      id: id,
      userId: 'u1',
      type: type,
      amount: amount,
      category: category,
      note: note,
      date: date,
    );

void main() {
  // Thursday 25 Sep 2026, 15:30
  final now = DateTime(2026, 9, 25, 15, 30);

  group('InsightRanges', () {
    test('day = today 00:00 → tomorrow 00:00', () {
      final r = InsightRanges.current(InsightPeriod.day, now);
      expect(r.start, DateTime(2026, 9, 25));
      expect(r.end, DateTime(2026, 9, 26));
    });

    test('week starts on Monday', () {
      final r = InsightRanges.current(InsightPeriod.week, now);
      expect(r.start, DateTime(2026, 9, 21)); // Monday
      expect(r.end, DateTime(2026, 9, 28));
      expect(r.lastDay, DateTime(2026, 9, 27)); // Sunday
    });

    test('week when today is Sunday still starts on the previous Monday', () {
      final r = InsightRanges.current(InsightPeriod.week, DateTime(2026, 9, 27, 23));
      expect(r.start, DateTime(2026, 9, 21));
    });

    test('week when today is Monday starts today', () {
      final r = InsightRanges.current(InsightPeriod.week, DateTime(2026, 9, 21, 0, 5));
      expect(r.start, DateTime(2026, 9, 21));
    });

    test('month = 1st of month → 1st of next month', () {
      final r = InsightRanges.current(InsightPeriod.month, now);
      expect(r.start, DateTime(2026, 9, 1));
      expect(r.end, DateTime(2026, 10, 1));
    });

    test('previous ranges: yesterday / last week / last month', () {
      expect(InsightRanges.previous(InsightPeriod.day, now),
          InsightRange(DateTime(2026, 9, 24), DateTime(2026, 9, 25)));
      expect(InsightRanges.previous(InsightPeriod.week, now),
          InsightRange(DateTime(2026, 9, 14), DateTime(2026, 9, 21)));
      expect(InsightRanges.previous(InsightPeriod.month, now),
          InsightRange(DateTime(2026, 8, 1), DateTime(2026, 9, 1)));
    });

    test('previous month across year boundary (January → December)', () {
      final r = InsightRanges.previous(InsightPeriod.month, DateTime(2027, 1, 10));
      expect(r.start, DateTime(2026, 12, 1));
      expect(r.end, DateTime(2027, 1, 1));
    });

    test('default period for unknown/empty saved value is week', () {
      expect(InsightPeriodX.fromKey(null), InsightPeriod.week);
      expect(InsightPeriodX.fromKey('bogus'), InsightPeriod.week);
      expect(InsightPeriodX.fromKey('month'), InsightPeriod.month);
    });
  });

  group('InsightSummary.compute', () {
    final txs = [
      // this week (Mon 21 – Sun 27 Sep)
      tx('1', 'Expense', 100, DateTime(2026, 9, 21, 9), category: 'Food & Dining'),
      tx('2', 'Expense', 300, DateTime(2026, 9, 25, 12), category: 'Shopping'),
      tx('3', 'Income', 1000, DateTime(2026, 9, 25, 8), category: 'Salary'),
      tx('4', 'Expense', 50, DateTime(2026, 9, 25, 13), category: 'Food & Dining'),
      // last week
      tx('5', 'Expense', 200, DateTime(2026, 9, 15), category: 'Food & Dining'),
      // last month
      tx('6', 'Expense', 999, DateTime(2026, 8, 20), category: 'Travel'),
    ];

    test('week totals only include this week', () {
      final s = InsightSummary.compute(transactions: txs, period: InsightPeriod.week, now: now);
      expect(s.transactionCount, 4);
      expect(s.income, 1000);
      expect(s.expense, 450);
      expect(s.net, 550);
    });

    test('day totals only include today', () {
      final s = InsightSummary.compute(transactions: txs, period: InsightPeriod.day, now: now);
      expect(s.transactionCount, 3);
      expect(s.expense, 350);
      expect(s.income, 1000);
    });

    test('month totals include the whole month', () {
      final s = InsightSummary.compute(transactions: txs, period: InsightPeriod.month, now: now);
      expect(s.transactionCount, 5);
      expect(s.expense, 650);
      expect(s.previousExpense, 999);
    });

    test('type comparison is case-insensitive and negative amounts use abs()', () {
      final s = InsightSummary.compute(
        transactions: [tx('a', 'expense', -80, now), tx('b', 'INCOME', 20, now)],
        period: InsightPeriod.day,
        now: now,
      );
      expect(s.expense, 80);
      expect(s.income, 20);
    });

    test('top expense categories sorted largest first', () {
      final s = InsightSummary.compute(transactions: txs, period: InsightPeriod.week, now: now);
      expect(s.topExpenseCategories.first.category, 'Shopping');
      expect(s.topExpenseCategories.first.amount, 300);
      expect(s.topExpenseCategories[1].category, 'Food & Dining');
      expect(s.topExpenseCategories[1].amount, 150);
    });

    test('expense change vs last week: 450 vs 200 = +125%', () {
      final s = InsightSummary.compute(transactions: txs, period: InsightPeriod.week, now: now);
      expect(s.hasPrevious, isTrue);
      expect(s.expenseChangePercent, closeTo(125, 0.001));
      expect(s.biggestIncrease?.category, 'Shopping');
      expect(s.biggestIncrease?.amount, 300);
    });

    test('no previous data → no comparison (new account)', () {
      final s = InsightSummary.compute(
        transactions: [tx('1', 'Expense', 100, now)],
        period: InsightPeriod.week,
        now: now,
      );
      expect(s.hasPrevious, isFalse);
      expect(s.expenseChangePercent, isNull);
      expect(s.biggestIncrease, isNull);
      expect(s.toPromptFacts((v) => '$v'), contains('no data, do not compare'));
    });

    test('empty period → isEmpty', () {
      final s = InsightSummary.compute(transactions: const [], period: InsightPeriod.day, now: now);
      expect(s.isEmpty, isTrue);
    });
  });

  group('InsightSummary.fingerprint', () {
    final base = [
      tx('1', 'Expense', 100, DateTime(2026, 9, 22)),
      tx('2', 'Income', 500, DateTime(2026, 9, 23)),
    ];
    String fp(List<TransactionModel> list, {InsightPeriod p = InsightPeriod.week, String cur = 'THB'}) =>
        InsightSummary.compute(transactions: list, period: p, now: now, currencyTag: cur).fingerprint;

    test('same data → same fingerprint (order does not matter)', () {
      expect(fp(base), fp(base.reversed.toList()));
    });

    test('adding a transaction in the period changes it', () {
      expect(fp([...base, tx('3', 'Expense', 10, now)]), isNot(fp(base)));
    });

    test('editing a transaction (same count) changes it', () {
      final edited = [tx('1', 'Expense', 120, DateTime(2026, 9, 22)), base[1]];
      expect(fp(edited), isNot(fp(base)));
    });

    test('adding a transaction outside both periods does not change it', () {
      expect(fp([...base, tx('9', 'Expense', 10, DateTime(2025, 1, 1))]), fp(base));
    });

    test('currency change → new fingerprint', () {
      expect(fp(base, cur: 'USD'), isNot(fp(base, cur: 'THB')));
    });

    test('different periods have different fingerprints', () {
      expect(fp(base, p: InsightPeriod.month), isNot(fp(base, p: InsightPeriod.week)));
    });
  });

  group('InsightSummary.toPromptFacts', () {
    test('contains only pre-computed figures and the period', () {
      final s = InsightSummary.compute(
        transactions: [
          tx('1', 'Expense', 100, now, category: 'Shopping'),
          tx('2', 'Expense', 50, DateTime(2026, 9, 15)),
        ],
        period: InsightPeriod.week,
        now: now,
      );
      final facts = s.toPromptFacts((v) => '฿${v.toStringAsFixed(0)}');
      expect(facts, contains('this week'));
      expect(facts, contains('2026-09-21 to 2026-09-27'));
      expect(facts, contains('Total expense: ฿100'));
      expect(facts, contains('Expense change vs last week: +100%'));
    });
  });
}
