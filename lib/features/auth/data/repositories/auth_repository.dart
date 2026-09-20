import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  // Use 10.0.2.2 for localhost access from Android Emulator
  final String baseUrl = 'http://192.168.88.84:8000';

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  Future<void> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Auto-login after register
      await login(email, password);
    } else {
      throw Exception('Registration failed: ${response.body}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Future<Map<String, dynamic>?> getUser() async {
    final token = await getToken();
    if (token == null) return null;
    
    final response = await http.get(
      Uri.parse('$baseUrl/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<void> uploadAvatar(String imagePath) async {
    final token = await getToken();
    if (token == null) return;
    
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/users/me/avatar'));
    request.headers.addAll({'Authorization': 'Bearer $token'});
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    
    var streamedResponse = await request.send();
    if (streamedResponse.statusCode != 200) {
      final respStr = await streamedResponse.stream.bytesToString();
      throw Exception('Failed to upload avatar: $respStr');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final token = await getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body['detail'] ?? 'Failed to change password');
    }
  }
}
