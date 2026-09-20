import 'package:flutter_test/flutter_test.dart';
import 'package:fincontrol/core/services/gemini_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    // Provide empty env so dotenv doesn't throw
    dotenv.testLoad(fileInput: 'GEMINI_API_KEY=');
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

  group('GeminiService.generateFinancialInsight — guard conditions', () {
    test('returns null when transactions string is empty', () async {
      final result = await GeminiService.generateFinancialInsight('', 'en');
      expect(result, isNull);
    });

    test('returns null when transactions string is only whitespace', () async {
      final result = await GeminiService.generateFinancialInsight('   ', 'th');
      expect(result, isNull);
    });

    test('returns null when transactions string is only newlines', () async {
      final result = await GeminiService.generateFinancialInsight('\n\n', 'en');
      expect(result, isNull);
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

  group('GeminiService.generateFinancialInsight — error path (empty key → catch → null)', () {
    test('valid transactions string with invalid API key returns null (does not throw)', () async {
      final result = await GeminiService.generateFinancialInsight(
        'income: 5000 THB salary\nexpense: 200 THB coffee',
        'en',
      );
      // With empty API key the model call fails; catch block returns null
      expect(result, isNull);
    });

    test('Thai language request with invalid API key returns null (does not throw)', () async {
      final result = await GeminiService.generateFinancialInsight(
        'income: 5000 salary\nexpense: 100 food',
        'th',
      );
      expect(result, isNull);
    });
  });
}
