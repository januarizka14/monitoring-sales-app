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

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw const FormatException('Respons server bukan JSON objek');
    } catch (e) {
      throw Exception('Respons server tidak valid: ${e.toString()}');
    }
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

    if (response.statusCode != 200) {
      throw Exception('Server error: ${response.statusCode}');
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      throw const FormatException('Respons server bukan JSON objek');
    } catch (e) {
      throw Exception('Respons server tidak valid: ${e.toString()}');
    }
  }
}
