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

  static Future<String?> generateFinancialInsight(String last10Transactions, String languageCode) async {
    if (last10Transactions.trim().isEmpty) return null;

    final languageInstruction = languageCode == 'th' 
        ? 'IMPORTANT: You MUST reply entirely in Thai language.' 
        : 'IMPORTANT: You MUST reply entirely in English language.';

    final prompt = 'Here are my recent transactions:\n$last10Transactions\nGive me one short financial insight in 1-2 sentences. Make it encouraging and helpful. DO NOT wrap it in quotes. DO NOT output bold markdown text, just keep it plain simple string. $languageInstruction';
    
    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text?.replaceAll('\n', ' ').trim();
    } catch (e) {
      debugPrint('[Gemini error]: $e');
      return null;
    }
  }
}
