import 'package:flutter/material.dart';

import '../services/data_service.dart';

class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color accentRed = Color(0xFFDB1607);

  late Future<Map<String, dynamic>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = DataService().ambilSemuaUsers();
    });
  }

  Future<void> _hapusUser(String id) async {
    final result = await DataService().hapusUser(id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Berhasil dihapus'),
        backgroundColor:
            result['status'] == 'success' ? primaryBlue : accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    _refreshUsers();
  }

  void _konfirmasiHapus(String id, String username) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.person_remove_rounded, color: accentRed),
            SizedBox(width: 10),
            Text('Hapus Akun?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Akun "$username" akan dihapus permanen beserta semua datanya. Lanjutkan?',
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.black45)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _hapusUser(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child:
                const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: accentRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Manajemen User',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87)),
                      Text('Daftar akun sales terdaftar',
                          style:
                              TextStyle(fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _refreshUsers,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.refresh_rounded,
                          color: primaryBlue, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: primaryBlue));
                  }

                  final data = snapshot.data;
                  if (data == null || data['status'] == 'empty') {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.people_rounded,
                                size: 48, color: primaryBlue),
                          ),
                          const SizedBox(height: 16),
                          const Text('Belum ada akun sales.',
                              style: TextStyle(
                                  color: Colors.black45, fontSize: 15)),
                        ],
                      ),
                    );
                  }

                  final List users = data['data_users'] ?? [];

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: users.length,
                    itemBuilder: (context, i) {
                      final user = users[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.person_rounded,
                                  color: primaryBlue, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['username'] ?? '-',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Colors.black87),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Daftar: ${user['waktu_daftar'] ?? '-'}',
                                    style: const TextStyle(
                                        fontSize: 11, color: Colors.black38),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _konfirmasiHapus(
                                  user['id'].toString(),
                                  user['username'] ?? ''),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: accentRed.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.person_remove_outlined,
                                    color: accentRed, size: 20),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
