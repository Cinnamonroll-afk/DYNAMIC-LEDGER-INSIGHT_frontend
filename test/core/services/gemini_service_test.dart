import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/core/services/gemini_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    // Provide empty env so dotenv doesn't throw
    dotenv.loadFromString(envString: 'GEMINI_API_KEY=');
  });

  group('GeminiService.suggestCategories — guard conditions', () {
    test('returns empty list when note is empty string', () async {
      final result = await GeminiService.suggestCategories(
        note: '',
        isIncome: true,
      );
      expect(result, isEmpty);
    });

    test('returns empty list when note is only whitespace', () async {
      final result = await GeminiService.suggestCategories(
        note: '   ',
        isIncome: false,
      );
      expect(result, isEmpty);
    });

    test('returns empty list when note is only tabs/newlines', () async {
      final result = await GeminiService.suggestCategories(
        note: '\t\n',
        isIncome: true,
      );
      expect(result, isEmpty);
    });
  });

  group('GeminiService.generateBilingualInsight — guard conditions', () {
    test('returns null when facts string is empty', () async {
      expect(await GeminiService.generateBilingualInsight(''), isNull);
    });

    test('returns null when facts string is only whitespace', () async {
      expect(await GeminiService.generateBilingualInsight('   '), isNull);
    });

    test('returns null when facts string is only newlines', () async {
      expect(await GeminiService.generateBilingualInsight('\n\n'), isNull);
    });
  });

  group('GeminiService.parseBilingualInsight — response parsing', () {
    test('parses a valid JSON reply into Thai and English', () {
      final r = GeminiService.parseBilingualInsight(
        '{"th": "สัปดาห์นี้คุณใช้จ่ายน้อยลง", "en": "You spent less this week"}',
      );
      expect(r, isNotNull);
      expect(r!.th, 'สัปดาห์นี้คุณใช้จ่ายน้อยลง');
      expect(r.en, 'You spent less this week');
    });

    test('extracts JSON wrapped in extra text / code fences', () {
      final r = GeminiService.parseBilingualInsight(
        '```json\n{"th": "ดีมาก", "en": "Great job"}\n```',
      );
      expect(r?.en, 'Great job');
    });

    test('strips markdown bold and newlines', () {
      final r = GeminiService.parseBilingualInsight(
        '{"th": "**ดี**\\nมาก", "en": "**Good**\\njob"}',
      );
      expect(r?.en, 'Good job');
      expect(r?.th, 'ดี มาก');
    });

    test('returns null when one language is missing', () {
      expect(GeminiService.parseBilingualInsight('{"en": "Only English"}'), isNull);
    });

    test('returns null for non-JSON text', () {
      expect(GeminiService.parseBilingualInsight('Sorry, I cannot help.'), isNull);
    });

    test('returns null for malformed JSON', () {
      expect(GeminiService.parseBilingualInsight('{"th": "x", "en": }'), isNull);
    });
  });

  // ── Error-path tests (API key empty → call fails → safe fallback) ──────────
  // GeminiService catches all exceptions and returns empty list / null.
  // In tests, GEMINI_API_KEY is empty (set in setUpAll), so any live call
  // to GenerativeModel.generateContent() will fail → exercises the catch block.

  group('GeminiService.suggestCategories — error path (empty key → catch → [])', () {
    test('valid note with invalid API key returns empty list (does not throw)', () async {
      final result = await GeminiService.suggestCategories(
        note: 'coffee at starbucks',
        isIncome: false,
      );
      // With an empty API key the model call fails; catch block returns []
      expect(result, isA<List<String>>());
      expect(result, isEmpty);
    });

    test('income note with invalid API key returns empty list (does not throw)', () async {
      final result = await GeminiService.suggestCategories(
        note: 'monthly salary',
        isIncome: true,
      );
      expect(result, isA<List<String>>());
      expect(result, isEmpty);
    });
  });

  group('GeminiService.generateBilingualInsight — error path (empty key → catch → null)', () {
    test('valid facts with invalid API key returns null (does not throw)', () async {
      final result = await GeminiService.generateBilingualInsight(
        'Period: this week\nTotal income: \$5,000.00\nTotal expense: \$200.00',
      );
      expect(result, isNull);
    });
  });
}
