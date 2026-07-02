import 'package:flutter/material.dart';

import '../services/data_service.dart';

class DashboardTab extends StatefulWidget {
  final String usernameSales;
  final VoidCallback? onNavigateToTugas;
  const DashboardTab({
    super.key,
    required this.usernameSales,
    this.onNavigateToTugas,
  });

  @override
  State<DashboardTab> createState() => DashboardTabState();
}

class DashboardTabState extends State<DashboardTab> {
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color accentRed = Color(0xFFDB1607);

  late Future<Map<String, dynamic>> _dashboardData;
  late Future<Map<String, dynamic>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _dashboardData = DataService().ambilDataDashboard(widget.usernameSales);
    _tasksFuture = DataService().ambilTasks(widget.usernameSales);
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

  // TIDAK DIUBAH — dipanggil dari MainNavigation via GlobalKey
  Future<void> refreshDashboard() async {
    final newData =
        await DataService().ambilDataDashboard(widget.usernameSales);
    if (mounted) {
      setState(() {
        _dashboardData = Future.value(newData);
        _tasksFuture = DataService().ambilTasks(widget.usernameSales);
      });
    }
  }

  Color _statusColor(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'sukses':
        return const Color(0xFF00A86B);
      case 'follow-up':
        return primaryBlue;
      case 'tutup':
        return Colors.grey;
      case 'ditolak':
        return accentRed;
      default:
        return primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: RefreshIndicator(
        onRefresh: refreshDashboard,
        color: primaryBlue,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: primaryBlue));
            }
            final data = snapshot.data ?? {};

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                        24, MediaQuery.of(context).padding.top + 16, 24, 24),
                    decoration: const BoxDecoration(
                      color: primaryBlue,
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
                          widget.usernameSales,
                          style: const TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Pantau target kunjungan harianmu di sini.',
                          style: TextStyle(fontSize: 12, color: Colors.white54),
                        ),
                        const SizedBox(height: 20),

                        // Stat cards
                        Row(
                          children: [
                            _buildStatCard(
                              'Hari Ini',
                              data['total_kunjungan']?.toString() ?? '0',
                              Icons.today_rounded,
                              Colors.white,
                              Colors.white.withOpacity(0.15),
                            ),
                            const SizedBox(width: 12),
                            _buildStatCard(
                              'Total Visit',
                              data['total_keseluruhan']?.toString() ?? '0',
                              Icons.analytics_rounded,
                              Colors.white,
                              Colors.white.withOpacity(0.15),
                            ),
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
                        // Kunjungan Terakhir
                        _buildSectionTitle('Kunjungan Terakhir'),
                        const SizedBox(height: 12),
                        _buildLastVisitCard(data),

                        const SizedBox(height: 24),

                        // Ringkasan Tugas — dinamis
                        _buildSectionTitle('Status Tugas Hari Ini'),
                        const SizedBox(height: 12),
                        FutureBuilder<Map<String, dynamic>>(
                          future: _tasksFuture,
                          builder: (context, taskSnapshot) {
                            final taskData = taskSnapshot.data;
                            final semuaSelesai = taskData != null &&
                                taskData['status'] == 'empty';

                            const green = Color(0xFF00A86B);

                            return GestureDetector(
                              onTap: widget.onNavigateToTugas,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: semuaSelesai
                                      ? green.withOpacity(0.06)
                                      : accentRed.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: semuaSelesai
                                        ? green.withOpacity(0.2)
                                        : accentRed.withOpacity(0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: semuaSelesai
                                            ? green.withOpacity(0.1)
                                            : accentRed.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        semuaSelesai
                                            ? Icons.task_alt_rounded
                                            : Icons.assignment_late_rounded,
                                        color: semuaSelesai ? green : accentRed,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        semuaSelesai
                                            ? 'Semua tugas sudah selesai! Kerja bagus hari ini 🎉'
                                            : 'Cek tab Tugas untuk melihat tugas yang perlu diselesaikan.',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color:
                                              semuaSelesai ? green : accentRed,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: semuaSelesai ? green : accentRed,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
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
          Text(
            title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87),
          ),
        ],
      );

  Widget _buildLastVisitCard(Map<String, dynamic> data) {
    final status = data['status_terakhir'] as String?;
    final statusColor = _statusColor(status);
    final bengkel = data['bengkel_terakhir'] as String?;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: bengkel == null || bengkel.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'Belum ada kunjungan hari ini.',
                  style: TextStyle(color: Colors.black38, fontSize: 13),
                ),
              ),
            )
          : Row(
              children: [
                Container(
                  width: 4,
                  height: 80,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: primaryBlue, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bengkel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        if (status != null && status.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          data['waktu_terakhir'] ?? '-',
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black38),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bgColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  color: color, fontSize: 26, fontWeight: FontWeight.w800),
            ),
            Text(
              label,
              style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
