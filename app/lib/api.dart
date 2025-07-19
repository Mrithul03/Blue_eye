import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 🔐 Login and store device_token (DRF token) in SharedPreferences
Future<String> login({required String phone, required String password}) async {
  try {
    final response = await http.post(
      // Uri.parse('http://192.168.1.17:8000/api/login/'),
      // Uri.parse('http://127.0.0.1:8000/api/login/'),
      Uri.parse('https://mdgroup.pythonanywhere.com/api/login/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

    if (response.statusCode == 200 && data.containsKey('device_token')) {
      final token = data['device_token'];
      final userId = data['user_id'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('device_token', token);
      await prefs.setInt('user_id', userId); 

      return token;
    }
  } catch (e) {
    print('❗ Exception during login: $e');
  }

  return '';
}

/// 📦 Retrieve saved DRF token from SharedPreferences
Future<String?> getSavedToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('device_token');
}

/// 📄 Customer model
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

/// 👤 User model
class UserModel {
  final int id;
  final String name;
  final String phone;
  final String userType;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.userType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      userType: json['user_type'] ?? '',
    );
  }
}

/// 📡 API service
class ApiService {
  // final String baseUrl = 'http://192.168.1.17:8000/api';
  // final String baseUrl = 'http://127.0.0.1:8000/api';
  final String baseUrl = 'https://mdgroup.pythonanywhere.com/api/';
  

  /// 📥 Fetch customers (requires auth)
  Future<List<Customer>> fetchCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('device_token');

      if (token == null || token.isEmpty) {
        print('❌ No token found. User not authenticated.');
        return [];
      }

      final response = await http.get(
        Uri.parse('$baseUrl/customers/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
        return jsonData.map((item) => Customer.fromJson(item)).toList();
      } else {
        print('❌ Server error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❗ Exception while fetching customers: $e');
    }

    return [];
  }

  /// 🙋‍♂️ Fetch current user based on token
  Future<UserModel?> fetchUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('device_token');
      final userId = prefs.getInt('user_id');

      if (token == null || userId == null) {
        print('❌ Token or user_id not found');
        return null;
      }

      final response = await http.get(
        // Uri.parse('http://192.168.1.17:8000/api/users/'),
        // Uri.parse('http://127.0.0.1:8000/api/users/'),
        Uri.parse('https://mdgroup.pythonanywhere.com/api/users/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        for (var userJson in jsonList) {
          if (userJson['id'] == userId) {
            return UserModel.fromJson(userJson);
          }
        }
        print('❌ User with ID $userId not found in response');
      } else {
        print(
          '❌ Failed to fetch users: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❗ Exception in fetchUser(): $e');
    }

    return null;
  }

  Future<void> updateCustomerStatus(
    int customerId,
    String status,
    String driver,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('device_token'); // From login

    final url = Uri.parse('$baseUrl/customer/$customerId/update/');

    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode({
        'status': status.toLowerCase(), // Make sure it's lowercase
        'driver': driver, // Name as string
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update status: ${response.body}');
    }
  }
}
