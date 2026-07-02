import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class AuthService {
  // Gunakan getter dinamis agar tidak error "Invalid constant value"
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost/api_sales';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2/api_sales'; // IP khusus untuk emulator Android
    } else {
      return 'http://localhost/api_sales';
    }
  }

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/login.php');
    final response = await http.post(url, body: {
      'username': username,
      'password': password,
    }).timeout(const Duration(seconds: 15));

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/daftar.php');
    final response = await http.post(url, body: {
      'username': username,
      'password': password,
    }).timeout(const Duration(seconds: 15));

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
