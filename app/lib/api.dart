import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<String> login({
  required String name,
  required String phone,
  required String password,
  required String userType,
}) async {
  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/login/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'password': password,
        'user_type': userType,
      }),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

    if (response.statusCode == 200 && data.containsKey('device_token')) {
      final token = data['device_token'];

      // Save device_token in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('device_token', token);

      print('🔐 API returned token: $token');
      print('📦 Stored token in SharedPreferences: ${prefs.getString('device_token')}');

      return token;
    } else {
      print('Server Error: $data');
    }
  } catch (e) {
    print('Login exception: $e');
  }

  return '';
}

// Optional: get token later if needed
Future<String?> getSavedToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('device_token');
}


class Customer {
  final int id;
  final String name;
  final String mobile;
  final String destination;
  final int members;
  final String dateFrom;
  final String dateUpto;
  final String packageName;
  final String suggestion;
  final String status;

  Customer({
    required this.id,
    required this.name,
    required this.mobile,
    required this.destination,
    required this.members,
    required this.dateFrom,
    required this.dateUpto,
    required this.packageName,
    required this.suggestion,
    required this.status,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mobile: json['mobile'] ?? '',
      destination: json['destination'] ?? '',
      members: json['members'] ?? 0,
      dateFrom: json['date_from'] ?? '',
      dateUpto: json['date_upto'] ?? '',
      packageName: json['package'] ?? '',
      suggestion: json['suggestion'] ?? '',
      status: json['status'] ?? '', 
    );
  }
}


class ApiService {
  // final String baseUrl = 'http://192.168.1.17:8000/api'; 
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<Customer>> fetchCustomers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/customers/'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        return jsonData.map((item) => Customer.fromJson(item)).toList();
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Exception while fetching customers: $e');
    }

    return [];
  }
}