import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fincontrol/features/transaction/data/models/transaction_model.dart';

class TransactionRepository {
  String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://192.168.88.84:8000';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Stream<List<TransactionModel>> getTransactions(String userId) async* {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/transactions'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      final list = data.map((item) => TransactionModel.fromMap(item, item['id'])).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      yield list;
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/transactions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(transaction.toMap()..remove('id')),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add transaction');
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    if (transaction.id.isEmpty) return;
    
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/transactions/${transaction.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(transaction.toMap()..remove('id')),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update transaction');
    }
  }

  Future<void> deleteTransaction(String id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/transactions/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete transaction');
    }
  }
}
