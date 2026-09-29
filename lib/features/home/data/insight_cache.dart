// Local cache for AI Insight, kept per account and per period so the advice
// stays the same across app restarts until the underlying data changes.

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fincontrol/features/home/logic/insight_summary.dart';

class CachedInsight {
  final String fingerprint;
  final String th;
  final String en;
  final DateTime generatedAt;

  const CachedInsight({
    required this.fingerprint,
    required this.th,
    required this.en,
    required this.generatedAt,
  });

  String forLanguage(String languageCode) => languageCode == 'th' ? th : en;

  Map<String, dynamic> toJson() => {
        'fp': fingerprint,
        'th': th,
        'en': en,
        'at': generatedAt.toIso8601String(),
      };

  static CachedInsight? fromJson(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final th = (m['th'] as String?) ?? '';
      final en = (m['en'] as String?) ?? '';
      if (th.isEmpty || en.isEmpty) return null;
      return CachedInsight(
        fingerprint: (m['fp'] as String?) ?? '',
        th: th,
        en: en,
        generatedAt: DateTime.tryParse((m['at'] as String?) ?? '') ?? DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }
}

class InsightCache {
  static const _prefix = 'ai_insight_';

  static String _insightKey(String userId, InsightPeriod p) => '${_prefix}v2_${userId}_${p.key}';
  static String _periodKey(String userId) => '${_prefix}period_$userId';

  static Future<CachedInsight?> read(String userId, InsightPeriod period) async {
    final prefs = await SharedPreferences.getInstance();
    return CachedInsight.fromJson(prefs.getString(_insightKey(userId, period)));
  }

  static Future<void> write(String userId, InsightPeriod period, CachedInsight insight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_insightKey(userId, period), jsonEncode(insight.toJson()));
  }

  static Future<InsightPeriod> readSelectedPeriod(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return InsightPeriodX.fromKey(prefs.getString(_periodKey(userId)));
  }

  static Future<void> saveSelectedPeriod(String userId, InsightPeriod period) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_periodKey(userId), period.key);
  }

  /// Removes every cached insight and period choice (called on logout).
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}
