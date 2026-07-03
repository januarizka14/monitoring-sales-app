import 'package:flutter/material.dart';

import '../services/data_service.dart';

class AdminDashboardTab extends StatefulWidget {
  final String usernameAdmin;
  const AdminDashboardTab({super.key, required this.usernameAdmin});

  @override
  State<AdminDashboardTab> createState() => AdminDashboardTabState();
}

class AdminDashboardTabState extends State<AdminDashboardTab> {
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color accentRed = Color(0xFFDB1607);

  late Future<Map<String, dynamic>> _dashboardData;

  @override
  void initState() {
    super.initState();
    _dashboardData = DataService().ambilDashboardAdmin();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 19) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 11) return '🌤️';
    if (hour < 15) return '☀️';
    if (hour < 19) return '🌇';
    return '🌙';
  }

// Ganti fungsi _refresh() yang lama dengan ini
  Future<void> _refresh() async {
    final newData = await DataService().ambilDashboardAdmin();
    if (mounted) {
      setState(() {
        _dashboardData = Future.value(newData);
      });
    }
  }

  // Method public — dipanggil dari AdminNavigation via GlobalKey
  Future<void> refreshDashboard() async {
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: primaryBlue,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: primaryBlue));
            }
            final data = snapshot.data ?? {};
            final perSales = data['per_sales'] as List? ?? [];

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                        24, MediaQuery.of(context).padding.top + 18, 24, 24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF003A8F), Color(0xFF004AAD)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()} ${_getGreetingEmoji()}',
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.usernameAdmin,
                          style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Pantau seluruh aktivitas sales di sini.',
                          style: TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _buildStatCard(
                                'Total Sales',
                                data['total_sales']?.toString() ?? '0',
                                Icons.people_rounded),
                            const SizedBox(width: 12),
                            _buildStatCard(
                                'Kunjungan Hari Ini',
                                data['total_hari_ini']?.toString() ?? '0',
                                Icons.today_rounded),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildStatCard(
                                'Total Kunjungan',
                                data['total_kunjungan']?.toString() ?? '0',
                                Icons.analytics_rounded),
                            const SizedBox(width: 12),
                            _buildStatCard(
                                'Tugas Pending',
                                data['total_pending']?.toString() ?? '0',
                                Icons.assignment_late_rounded),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Ringkasan per Sales'),
                        const SizedBox(height: 12),
                        if (perSales.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text('Belum ada data sales.',
                                  style: TextStyle(color: Colors.black38)),
                            ),
                          )
                        else
                          ...perSales.map((s) => Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border:
                                      Border.all(color: Colors.grey.shade100),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: primaryBlue.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.person_rounded,
                                          color: primaryBlue, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        s['username'] ?? '-',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Colors.black87),
                                      ),
                                    ),
                                    _buildMiniBadge(
                                        '${s['total_kunjungan_sales'] ?? 0} visit',
                                        primaryBlue),
                                    const SizedBox(width: 6),
                                    _buildMiniBadge(
                                        '${s['total_tugas_sales'] ?? 0} tugas',
                                        accentRed),
                                  ],
                                ),
                              )),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: accentRed,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(title,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
        ],
      );

  Widget _buildMiniBadge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w600)),
      );

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0052C7), Color(0xFF004AAD)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800)),
            Text(label,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
