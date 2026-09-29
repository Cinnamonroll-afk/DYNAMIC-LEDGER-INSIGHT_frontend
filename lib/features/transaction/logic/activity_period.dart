// Activity period navigation (Feedback #10): calendar periods that can be
// stepped back/forward. Weeks start on Monday, like AI Insight.

import 'package:fincontrol/features/home/logic/insight_summary.dart';

enum ActivityPeriod { day, week, month, year }

class ActivityPeriods {
  /// Range of [period] shifted by [offset] steps from the one containing [now]
  /// (0 = current, -1 = previous, …).
  static InsightRange range(ActivityPeriod period, DateTime now, int offset) {
    final today = DateTime(now.year, now.month, now.day);
    switch (period) {
      case ActivityPeriod.day:
        return InsightRanges.current(InsightPeriod.day, DateTime(today.year, today.month, today.day + offset));
      case ActivityPeriod.week:
        return InsightRanges.current(InsightPeriod.week, DateTime(today.year, today.month, today.day + 7 * offset));
      case ActivityPeriod.month:
        return InsightRanges.current(InsightPeriod.month, DateTime(today.year, today.month + offset, 1));
      case ActivityPeriod.year:
        return InsightRange(DateTime(today.year + offset, 1, 1), DateTime(today.year + offset + 1, 1, 1));
    }
  }

  /// Sub-periods for the trend bar chart: 7 days for a week, 7-day blocks
  /// (1–7, 8–14, 15–21, 22–28, 29–end) for a month, 12 months for a year.
  /// A single day has no trend → empty list.
  static List<InsightRange> buckets(ActivityPeriod period, InsightRange r) {
    final s = r.start;
    switch (period) {
      case ActivityPeriod.day:
        return const [];
      case ActivityPeriod.week:
        return [
          for (int i = 0; i < 7; i++)
            InsightRange(DateTime(s.year, s.month, s.day + i), DateTime(s.year, s.month, s.day + i + 1)),
        ];
      case ActivityPeriod.month:
        final out = <InsightRange>[];
        for (int d = 1; ; d += 7) {
          final start = DateTime(s.year, s.month, d);
          if (!start.isBefore(r.end)) break;
          var end = DateTime(s.year, s.month, d + 7);
          if (end.isAfter(r.end)) end = r.end;
          out.add(InsightRange(start, end));
        }
        return out;
      case ActivityPeriod.year:
        return [
          for (int m = 1; m <= 12; m++) InsightRange(DateTime(s.year, m, 1), DateTime(s.year, m + 1, 1)),
        ];
    }
  }
}
