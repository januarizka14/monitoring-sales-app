import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class DataService {
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost/api_sales';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2/api_sales';
    } else {
      return 'http://localhost/api_sales';
    }
  }

  // --- Fungsi Kunjungan Bengkel ---
  Future<Map<String, dynamic>> simpanBengkel({
    required String namaSales,
    required String namaBengkel,
    required String latitude,
    required String longitude,
    required String catatan,
    required String statusKunjungan,
  }) async {
    final Uri url = Uri.parse('$_baseUrl/simpan_bengkel.php');
    final response = await http.post(url, body: {
      'nama_sales': namaSales,
      'nama_bengkel': namaBengkel,
      'latitude': latitude,
      'longitude': longitude,
      'catatan': catatan,
      'status_kunjungan': statusKunjungan,
    }).timeout(const Duration(seconds: 15));

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> ambilRiwayat(
    String username, {
    int page = 1,
    String search = '',
    String status = '',
    String dari = '',
    String sampai = '',
  }) async {
    final Uri url = Uri.parse(
      '$_baseUrl/ambil_riwayat.php?username=$username&page=$page'
      '&search=${Uri.encodeComponent(search)}'
      '&status=${Uri.encodeComponent(status)}'
      '&dari=$dari'
      '&sampai=$sampai',
    );
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> ambilDataDashboard(String username) async {
    final Uri url =
        Uri.parse('$_baseUrl/ambil_dashboard.php?username=$username');
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> ambilTasks(String username) async {
    final Uri url = Uri.parse('$_baseUrl/ambil_tasks.php?username=$username');
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> selesaikanTask(String idTask) async {
    final Uri url = Uri.parse('$_baseUrl/selesaikan_task.php');
    final response = await http.post(url, body: {
      'id': idTask,
    }).timeout(const Duration(seconds: 15));

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // === ADMIN ===

  Future<Map<String, dynamic>> ambilDashboardAdmin() async {
    final Uri url = Uri.parse('$_baseUrl/ambil_dashboard_admin.php');
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> ambilSemuaTugas({
    String status = '',
    String username = '',
    String search = '',
  }) async {
    final Uri url = Uri.parse(
        '$_baseUrl/ambil_semua_tugas.php?status=${Uri.encodeComponent(status)}&username=${Uri.encodeComponent(username)}&search=${Uri.encodeComponent(search)}');
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> buatTugas({
    required String username,
    required String namaBengkel,
    required String deskripsi,
    String deadline = '',
  }) async {
    final Uri url = Uri.parse('$_baseUrl/buat_tugas.php');
    final response = await http.post(url, body: {
      'username': username,
      'nama_bengkel': namaBengkel,
      'deskripsi_tugas': deskripsi,
      'deadline': deadline,
    }).timeout(const Duration(seconds: 15));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> hapusTugas(String id) async {
    final Uri url = Uri.parse('$_baseUrl/hapus_tugas.php');
    final response = await http
        .post(url, body: {'id': id}).timeout(const Duration(seconds: 15));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> ambilSemuaKunjungan({
    int page = 1,
    String search = '',
    String status = '',
    String sales = '',
    String dari = '',
    String sampai = '',
  }) async {
    final Uri url = Uri.parse(
      '$_baseUrl/ambil_semua_kunjungan.php?page=$page'
      '&search=${Uri.encodeComponent(search)}'
      '&status=${Uri.encodeComponent(status)}'
      '&sales=${Uri.encodeComponent(sales)}'
      '&dari=$dari&sampai=$sampai',
    );
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> ambilSemuaUsers() async {
    final Uri url = Uri.parse('$_baseUrl/ambil_semua_users.php');
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> hapusUser(String id) async {
    final Uri url = Uri.parse('$_baseUrl/hapus_user.php');
    final response = await http
        .post(url, body: {'id': id}).timeout(const Duration(seconds: 15));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> ambilSemuaSales() async {
    final Uri url = Uri.parse('$_baseUrl/ambil_semua_users.php');
    final response = await http.get(url).timeout(const Duration(seconds: 15));
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
