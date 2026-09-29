// Coverage: Activity period navigation (Feedback #10)
import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/features/home/logic/insight_summary.dart';
import 'package:fincontrol/features/transaction/logic/activity_period.dart';

void main() {
  final now = DateTime(2026, 9, 25, 10); // Thursday

  test('current month and previous month', () {
    expect(ActivityPeriods.range(ActivityPeriod.month, now, 0),
        InsightRange(DateTime(2026, 9, 1), DateTime(2026, 10, 1)));
    expect(ActivityPeriods.range(ActivityPeriod.month, now, -1),
        InsightRange(DateTime(2026, 8, 1), DateTime(2026, 9, 1)));
  });

  test('month offset crosses the year boundary', () {
    expect(ActivityPeriods.range(ActivityPeriod.month, now, -9),
        InsightRange(DateTime(2025, 12, 1), DateTime(2026, 1, 1)));
  });

  test('week is Monday to Sunday and steps by 7 days', () {
    expect(ActivityPeriods.range(ActivityPeriod.week, now, 0),
        InsightRange(DateTime(2026, 9, 21), DateTime(2026, 9, 28)));
    expect(ActivityPeriods.range(ActivityPeriod.week, now, -1),
        InsightRange(DateTime(2026, 9, 14), DateTime(2026, 9, 21)));
  });

  test('day and year', () {
    expect(ActivityPeriods.range(ActivityPeriod.day, now, -1),
        InsightRange(DateTime(2026, 9, 24), DateTime(2026, 9, 25)));
    expect(ActivityPeriods.range(ActivityPeriod.year, now, -1),
        InsightRange(DateTime(2025, 1, 1), DateTime(2026, 1, 1)));
  });

  group('ActivityPeriods.buckets (trend bars)', () {
    test('week → 7 days Monday..Sunday', () {
      final r = ActivityPeriods.range(ActivityPeriod.week, now, 0);
      final b = ActivityPeriods.buckets(ActivityPeriod.week, r);
      expect(b.length, 7);
      expect(b.first.start, DateTime(2026, 9, 21));
      expect(b.last.start, DateTime(2026, 9, 27));
    });

    test('September (30 days) → 1-7, 8-14, 15-21, 22-28, 29-30', () {
      final r = ActivityPeriods.range(ActivityPeriod.month, now, 0);
      final b = ActivityPeriods.buckets(ActivityPeriod.month, r);
      expect(b.length, 5);
      expect(b.last, InsightRange(DateTime(2026, 9, 29), DateTime(2026, 10, 1)));
    });

    test('February 2026 (28 days) → exactly 4 blocks', () {
      final r = ActivityPeriods.range(ActivityPeriod.month, DateTime(2026, 2, 10), 0);
      expect(ActivityPeriods.buckets(ActivityPeriod.month, r).length, 4);
    });

    test('year → 12 months; day → none', () {
      final r = ActivityPeriods.range(ActivityPeriod.year, now, 0);
      expect(ActivityPeriods.buckets(ActivityPeriod.year, r).length, 12);
      final d = ActivityPeriods.range(ActivityPeriod.day, now, 0);
      expect(ActivityPeriods.buckets(ActivityPeriod.day, d), isEmpty);
    });
  });
}
