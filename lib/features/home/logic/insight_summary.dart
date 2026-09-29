// AI Insight — period filtering & summary calculations (pure Dart, no Flutter).
//
// Design decisions (see FEEDBACK_NOTES.md, Feedback #1):
//  - Periods follow the calendar: today / this week (Monday start) / this month.
//  - All figures are computed here, never by the AI. The AI only writes advice
//    based on these figures, so the numbers on the card are always correct.
//  - A fingerprint of the period's data decides when a new insight is needed.

import 'dart:convert';

import 'package:fincontrol/features/transaction/data/models/transaction_model.dart';

enum InsightPeriod { day, week, month }

extension InsightPeriodX on InsightPeriod {
  String get key => name; // 'day' | 'week' | 'month'

  static InsightPeriod fromKey(String? key) {
    return InsightPeriod.values.firstWhere(
      (p) => p.name == key,
      orElse: () => InsightPeriod.week, // default period
    );
  }
}

/// Half-open date range: [start, end).
class InsightRange {
  final DateTime start;
  final DateTime end;
  const InsightRange(this.start, this.end);

  bool contains(DateTime d) => !d.isBefore(start) && d.isBefore(end);

  /// Last day included in the range (for display).
  DateTime get lastDay => end.subtract(const Duration(days: 1));

  @override
  bool operator ==(Object other) =>
      other is InsightRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'InsightRange($start → $end)';
}

class InsightRanges {
  /// Range of the current period containing [now].
  static InsightRange current(InsightPeriod period, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    switch (period) {
      case InsightPeriod.day:
        return InsightRange(today, DateTime(today.year, today.month, today.day + 1));
      case InsightPeriod.week:
        // DateTime.weekday: Monday = 1 ... Sunday = 7
        final monday = DateTime(today.year, today.month, today.day - (today.weekday - 1));
        return InsightRange(monday, DateTime(monday.year, monday.month, monday.day + 7));
      case InsightPeriod.month:
        return InsightRange(
          DateTime(today.year, today.month, 1),
          DateTime(today.year, today.month + 1, 1),
        );
    }
  }

  /// Range of the period right before the current one.
  static InsightRange previous(InsightPeriod period, DateTime now) {
    final cur = current(period, now);
    switch (period) {
      case InsightPeriod.day:
        return InsightRange(
          DateTime(cur.start.year, cur.start.month, cur.start.day - 1),
          cur.start,
        );
      case InsightPeriod.week:
        return InsightRange(
          DateTime(cur.start.year, cur.start.month, cur.start.day - 7),
          cur.start,
        );
      case InsightPeriod.month:
        return InsightRange(
          DateTime(cur.start.year, cur.start.month - 1, 1),
          cur.start,
        );
    }
  }
}

class CategoryAmount {
  final String category;
  final double amount;
  const CategoryAmount(this.category, this.amount);
}

class InsightSummary {
  final InsightPeriod period;
  final InsightRange range;
  final InsightRange previousRange;

  final int transactionCount;
  final double income;
  final double expense;

  final int previousTransactionCount;
  final double previousIncome;
  final double previousExpense;

  /// Expense categories in the current period, largest first.
  final List<CategoryAmount> topExpenseCategories;

  /// Category with the largest expense increase vs the previous period (if any).
  final CategoryAmount? biggestIncrease;

  /// Stable hash of everything the insight depends on.
  final String fingerprint;

  const InsightSummary({
    required this.period,
    required this.range,
    required this.previousRange,
    required this.transactionCount,
    required this.income,
    required this.expense,
    required this.previousTransactionCount,
    required this.previousIncome,
    required this.previousExpense,
    required this.topExpenseCategories,
    required this.biggestIncrease,
    required this.fingerprint,
  });

  bool get isEmpty => transactionCount == 0;
  double get net => income - expense;
  bool get hasPrevious => previousTransactionCount > 0;

  /// % change of expense vs previous period. Null when not comparable
  /// (no previous data, or previous expense was zero).
  double? get expenseChangePercent {
    if (!hasPrevious || previousExpense <= 0) return null;
    return (expense - previousExpense) / previousExpense * 100;
  }

  static InsightSummary compute({
    required List<TransactionModel> transactions,
    required InsightPeriod period,
    required DateTime now,
    String currencyTag = '',
  }) {
    final range = InsightRanges.current(period, now);
    final prevRange = InsightRanges.previous(period, now);

    final cur = transactions.where((t) => range.contains(t.date)).toList();
    final prev = transactions.where((t) => prevRange.contains(t.date)).toList();

    double sumOf(List<TransactionModel> list, String type) => list
        .where((t) => t.type.toLowerCase() == type)
        .fold(0.0, (s, t) => s + t.amount.abs());

    Map<String, double> byCategory(List<TransactionModel> list) {
      final map = <String, double>{};
      for (final t in list) {
        if (t.type.toLowerCase() != 'expense') continue;
        final c = t.category.trim().isEmpty ? 'Other' : t.category.trim();
        map[c] = (map[c] ?? 0) + t.amount.abs();
      }
      return map;
    }

    final curCats = byCategory(cur);
    final prevCats = byCategory(prev);

    final top = curCats.entries
        .map((e) => CategoryAmount(e.key, e.value))
        .toList()
      ..sort((a, b) {
        final c = b.amount.compareTo(a.amount);
        return c != 0 ? c : a.category.compareTo(b.category);
      });

    CategoryAmount? biggest;
    if (prev.isNotEmpty) {
      for (final e in curCats.entries) {
        final diff = e.value - (prevCats[e.key] ?? 0);
        if (diff > 0 && (biggest == null || diff > biggest.amount)) {
          biggest = CategoryAmount(e.key, diff);
        }
      }
    }

    // Fingerprint: current-period transactions (sorted, order-independent)
    // + previous-period totals + currency. Any add/edit/delete changes it.
    final curSorted = List<TransactionModel>.from(cur)
      ..sort((a, b) {
        final c = a.date.compareTo(b.date);
        return c != 0 ? c : a.id.compareTo(b.id);
      });
    final buf = StringBuffer()
      ..write('${period.key}|${range.start.toIso8601String()}|$currencyTag|');
    for (final t in curSorted) {
      buf.write('${t.id};${t.type};${t.amount};${t.category};${t.note};${t.date.toIso8601String()}|');
    }
    buf.write('prev:${prev.length};${sumOf(prev, 'income')};${sumOf(prev, 'expense')}');
    final fingerprint = _fnv1a(buf.toString());

    return InsightSummary(
      period: period,
      range: range,
      previousRange: prevRange,
      transactionCount: cur.length,
      income: sumOf(cur, 'income'),
      expense: sumOf(cur, 'expense'),
      previousTransactionCount: prev.length,
      previousIncome: sumOf(prev, 'income'),
      previousExpense: sumOf(prev, 'expense'),
      topExpenseCategories: top.take(3).toList(),
      biggestIncrease: biggest,
      fingerprint: fingerprint,
    );
  }

  /// Plain-text fact sheet sent to the AI. [fmt] formats money in the
  /// user's currency. Contains only pre-computed, verified figures.
  String toPromptFacts(String Function(double) fmt) {
    String periodName;
    String prevName;
    switch (period) {
      case InsightPeriod.day:
        periodName = 'today';
        prevName = 'yesterday';
        break;
      case InsightPeriod.week:
        periodName = 'this week (Monday to Sunday)';
        prevName = 'last week';
        break;
      case InsightPeriod.month:
        periodName = 'this month';
        prevName = 'last month';
        break;
    }
    String d(DateTime x) => x.toIso8601String().substring(0, 10);

    final lines = <String>[
      'Period: $periodName, ${d(range.start)} to ${d(range.lastDay)}',
      'Number of transactions: $transactionCount',
      'Total income: ${fmt(income)}',
      'Total expense: ${fmt(expense)}',
      'Net (income - expense): ${net < 0 ? '-' : ''}${fmt(net.abs())}',
    ];
    if (topExpenseCategories.isNotEmpty) {
      lines.add('Top expense categories: ${topExpenseCategories.map((c) => '${c.category} ${fmt(c.amount)}').join(', ')}');
    }
    if (hasPrevious) {
      lines.add('Previous period ($prevName): income ${fmt(previousIncome)}, expense ${fmt(previousExpense)}');
      final pct = expenseChangePercent;
      if (pct != null) {
        lines.add('Expense change vs $prevName: ${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(0)}%');
      }
      if (biggestIncrease != null) {
        lines.add('Category with the biggest spending increase vs $prevName: ${biggestIncrease!.category} (+${fmt(biggestIncrease!.amount)})');
      }
    } else {
      lines.add('Previous period ($prevName): no data, do not compare');
    }
    return lines.join('\n');
  }
}

/// Stable hash (FNV-1a 32-bit, two seeds) as hex — unlike [Object.hashCode],
/// the result is identical across app restarts, so it can be stored.
String _fnv1a(String input) {
  final bytes = utf8.encode(input);
  int h1 = 0x811c9dc5;
  int h2 = 0x050c5d1f;
  for (final b in bytes) {
    h1 = ((h1 ^ b) * 0x01000193) & 0xFFFFFFFF;
    h2 = ((h2 ^ b) * 0x01000193) & 0xFFFFFFFF;
  }
  return '${h1.toRadixString(16)}${h2.toRadixString(16)}-${bytes.length}';
}
