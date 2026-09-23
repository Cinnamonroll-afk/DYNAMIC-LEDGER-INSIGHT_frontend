import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fincontrol/features/wealth/data/models/portfolio_model.dart';

class PortfolioRepository {
  String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://192.168.88.84:8000';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Stream<List<PortfolioModel>> getPortfolios(String userId) async* {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/portfolios'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      yield data.map((item) => PortfolioModel.fromMap(item, item['id'])).toList();
    } else {
      throw Exception('Failed to load portfolios');
    }
  }

  Future<String> addPortfolio(PortfolioModel portfolio) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/portfolios'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(portfolio.toMap()..remove('id')), // Remove empty ID
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add portfolio');
    }
    final data = jsonDecode(response.body);
    return data['id'] as String;
  }

  Future<void> updatePortfolio(PortfolioModel portfolio) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/portfolios/${portfolio.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode(portfolio.toMap()..remove('id')),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update portfolio');
    }
  }

  Future<void> deletePortfolio(String id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/portfolios/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete portfolio');
    }
  }
}
