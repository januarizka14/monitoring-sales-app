import 'package:flutter/material.dart';

import '../services/data_service.dart';

class TasksTab extends StatefulWidget {
  final String username;
  const TasksTab({super.key, required this.username});

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color accentRed = Color(0xFFDB1607);

  late Future<Map<String, dynamic>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _refreshTasks();
  }

  void _refreshTasks() {
    setState(() {
      _tasksFuture = DataService().ambilTasks(widget.username);
    });
  }

  Future<void> _selesaikanTask(String idTask) async {
    final result = await DataService().selesaikanTask(idTask);
    if (!mounted) return;

    final success = result['status'] == 'success';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Text(result['message'] ?? 'Tugas berhasil diselesaikan!'),
          ],
        ),
        backgroundColor: success ? primaryBlue : accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    _refreshTasks();
  }

  void _konfirmasiSelesai(BuildContext context, Map task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.task_alt, color: primaryBlue),
            SizedBox(width: 10),
            Text('Selesaikan Tugas?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Tandai "${task['nama_bengkel']}" sebagai selesai?\n\nTugas yang diselesaikan tidak dapat dibatalkan.',
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
              _selesaikanTask(task['id'].toString());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Ya, Selesai',
                style: TextStyle(color: Colors.white)),
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
          children: [
            // Judul inline compact
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
                      Text(
                        'Daftar Penugasan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Tugas yang perlu diselesaikan segera',
                        style: TextStyle(fontSize: 12, color: Colors.black45),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _refreshTasks,
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

            // Body
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _tasksFuture,
                builder: (context, snapshot) {
                  // Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: primaryBlue));
                  }

                  // Error jaringan
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: accentRed.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.wifi_off_rounded,
                                size: 48, color: accentRed),
                          ),
                          const SizedBox(height: 16),
                          const Text('Gagal terhubung ke server',
                              style: TextStyle(
                                  color: Colors.black54, fontSize: 15)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _refreshTasks,
                            icon: const Icon(Icons.refresh_rounded,
                                color: Colors.white),
                            label: const Text('Coba Lagi',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Tidak ada data
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(
                        child: Text('Tidak ada koneksi ke server'));
                  }

                  final data = snapshot.data!;

                  // Kosong / semua selesai
                  if (data['status'] == 'empty') {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00A86B).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.task_alt_rounded,
                                size: 52, color: Color(0xFF00A86B)),
                          ),
                          const SizedBox(height: 16),
                          const Text('Semua tugas sudah selesai!',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54)),
                          const SizedBox(height: 6),
                          const Text('Kerja bagus hari ini 🎉',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.black38)),
                        ],
                      ),
                    );
                  }

                  // Error dari server
                  if (data['status'] != 'success') {
                    return Center(
                        child: Text('Error: ${data['message']}',
                            style: const TextStyle(color: Colors.black45)));
                  }

                  // List tugas
                  final List tasks = data['data_tasks'];
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: tasks.length,
                    itemBuilder: (context, i) {
                      final task = tasks[i];
                      final hasDeadline = task['deadline'] != null &&
                          task['deadline'].toString().isNotEmpty;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon tugas
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryBlue,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.assignment_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['nama_bengkel'] ?? '-',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: Colors.black87),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      task['deskripsi_tugas'] ?? '-',
                                      style: const TextStyle(
                                          fontSize: 13, color: Colors.black54),
                                    ),
                                    if (hasDeadline) ...[
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: accentRed.withOpacity(0.08),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                                Icons.calendar_today_rounded,
                                                size: 11,
                                                color: accentRed),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Deadline: ${task['deadline']}',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: accentRed,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              // Tombol selesai
                              GestureDetector(
                                onTap: () => _konfirmasiSelesai(context, task),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: accentRed.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: accentRed,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
