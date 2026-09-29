import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:fincontrol/core/constants/app_categories.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? ''; 

  static final _model = GenerativeModel(
    model: 'gemini-3.5-flash-lite',
    apiKey: _apiKey,
  );

  static Future<List<String>> suggestCategories({
    required String note,
    required bool isIncome,
  }) async {
    if (note.trim().isEmpty) return [];

    final categoryList = isIncome
        ? AppCategories.incomeLabels
        : AppCategories.expenseLabels;

    final prompt = '''
You are a personal finance categorizer.
Given a transaction note, return the top 3 most relevant categories from the list below.
Reply with ONLY a JSON array of strings. No explanation. Use exact strings from the list.

Note: "$note"
Type: ${isIncome ? 'Income' : 'Expense'}
Categories: ${categoryList.join(', ')}

Example output: ["Food & Dining", "Grocery", "Other Expense"]
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text ?? '';

      final match = RegExp(r'\[.*?\]', dotAll: true).firstMatch(text);
      if (match == null) return [];

      final raw = match.group(0)!
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '')
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .take(4)
          .toList();

      return raw.where((r) =>
        categoryList.any((c) => c.toLowerCase() == r.toLowerCase())
      ).map((r) =>
        categoryList.firstWhere((c) => c.toLowerCase() == r.toLowerCase())
      ).toList();

    } catch (e) {
      debugPrint('[Gemini error]: $e');
      return [];
    }
  }

  // Separate model for insights: low temperature + JSON output so the advice
  // is consistent and grounded in the figures we send.
  static final _insightModel = GenerativeModel(
    model: 'gemini-3.5-flash-lite',
    apiKey: _apiKey,
    generationConfig: GenerationConfig(
      temperature: 0.2,
      responseMimeType: 'application/json',
    ),
  );

  /// Generates one short financial insight in BOTH Thai and English in a
  /// single call, so switching language shows the same advice.
  ///
  /// [facts] is a pre-computed summary (see InsightSummary.toPromptFacts).
  /// Returns null when [facts] is empty or the call/parse fails.
  static Future<({String th, String en})?> generateBilingualInsight(String facts) async {
    if (facts.trim().isEmpty) return null;

    final prompt = '''
You are a friendly personal finance assistant inside a budgeting app.
Below is a verified summary of the user's finances for one period. All numbers were calculated by the app and are correct.

$facts

Write ONE short, encouraging and practical insight (1-2 sentences) about this period.
Rules:
- Use ONLY the facts above. Never invent, estimate or recalculate numbers.
- If you mention an amount or percentage, copy it exactly as written above.
- Do not compare with the previous period if the summary says there is no previous data.
- Plain text only: no markdown, no quotes, no emojis.
- The Thai and English versions must say the same thing.

Reply with ONLY this JSON object:
{"th": "<insight in Thai>", "en": "<insight in English>"}
''';

    try {
      final response = await _insightModel.generateContent([Content.text(prompt)]);
      return parseBilingualInsight(response.text ?? '');
    } catch (e) {
      debugPrint('[Gemini error]: $e');
      return null;
    }
  }

  /// Parses the model's JSON reply. Public for unit testing.
  static ({String th, String en})? parseBilingualInsight(String text) {
    final match = RegExp(r'\{.*\}', dotAll: true).firstMatch(text);
    if (match == null) return null;
    try {
      final map = jsonDecode(match.group(0)!) as Map<String, dynamic>;
      String clean(Object? v) => (v is String ? v : '')
          .replaceAll('\n', ' ')
          .replaceAll('**', '')
          .replaceAll(RegExp(r'^["\u201C]+|["\u201D]+$'), '')
          .trim();
      final th = clean(map['th']);
      final en = clean(map['en']);
      if (th.isEmpty || en.isEmpty) return null;
      return (th: th, en: en);
    } catch (_) {
      return null;
    }
  }
}
