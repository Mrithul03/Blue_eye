import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8000/api'; // Update this for production

  Future<bool> loginUser({
    required String phone,
    required String password,
    required String userType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
          'user_type': userType,
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

      if (response.statusCode == 200 && data.containsKey('token')) {
        final token = data['token'];

        // Save token in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('device_token', token);

        print('Login success. Token saved.');
        return true;
      } else {
        print('Login failed. Server response: $data');
      }
    } catch (e) {
      print('Login error: $e');
    }

    return false;
  }

  // Optional: get token later if needed
  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('device_token');
  }
}
