import 'dart:async';

import 'package:flutter/material.dart';

import '../services/data_service.dart';

class AdminTugasTab extends StatefulWidget {
  final String usernameAdmin;
  const AdminTugasTab({super.key, required this.usernameAdmin});

  @override
  State<AdminTugasTab> createState() => _AdminTugasTabState();
}

class _AdminTugasTabState extends State<AdminTugasTab> {
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color accentRed = Color(0xFFDB1607);

  late Future<Map<String, dynamic>> _tasksFuture;
  Timer? _autoRefreshTimer;
  bool _isLoadingSales = false;
  String _filterStatus = '';
  String _selectedSales = '';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<String> _salesList = ['Semua'];

  final List<String> _statusFilters = ['Semua', 'pending', 'done'];

  @override
  void initState() {
    super.initState();
    _loadSales();
    _refreshTasks();
    // Auto-refresh tiap 30 detik, tanpa perlu tombol manual
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _refreshTasks(),
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSales() async {
    if (_isLoadingSales) return;
    setState(() => _isLoadingSales = true);

    final result = await DataService().ambilSemuaSales();
    if (!mounted) return;

    setState(() {
      _isLoadingSales = false;
      if (result['status'] == 'success') {
        final users = result['data_users'] as List<dynamic>? ?? [];
        final names = users
            .map((item) => item['username']?.toString().trim() ?? '')
            .where((username) => username.isNotEmpty)
            .toSet()
            .toList();
        _salesList = ['Semua', ...names];
      }
    });
  }

  void _refreshTasks() {
    setState(() {
      _tasksFuture = DataService().ambilSemuaTugas(
        status: _filterStatus,
        username: _selectedSales == 'Semua' ? '' : _selectedSales,
        search: _searchQuery,
      );
    });
  }

  bool get _adaFilter =>
      _searchQuery.isNotEmpty ||
      _filterStatus.isNotEmpty ||
      _selectedSales.isNotEmpty;

  void _resetFilter() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filterStatus = '';
      _selectedSales = '';
    });
    _refreshTasks();
  }

  Future<void> _hapusTugas(String id) async {
    final result = await DataService().hapusTugas(id);
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
    _refreshTasks();
  }

  void _konfirmasiHapus(String id, String namaBengkel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.delete_rounded, color: accentRed),
            SizedBox(width: 10),
            Text('Hapus Tugas?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Tugas untuk "$namaBengkel" akan dihapus permanen. Lanjutkan?',
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
              _hapusTugas(id);
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

  void _showFormTambahTugas() {
    final namaBengkelController = TextEditingController();
    final deskripsiController = TextEditingController();
    String? selectedUsername;
    DateTime? deadline;
    bool isSaving = false;
    bool isLoadingUsers = true;
    List<dynamic> salesList = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          if (isLoadingUsers) {
            DataService().ambilSemuaUsers().then((result) {
              if (!ctx.mounted) return;
              setModalState(() {
                salesList = result['status'] == 'success'
                    ? result['data_users'] ?? []
                    : [];
                isLoadingUsers = false;
              });
            });
            isLoadingUsers = false;
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const Text('Buat Tugas Baru',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87)),
                    const SizedBox(height: 6),
                    const Text(
                      'Tambahkan tugas baru untuk sales dan pastikan semua informasi lengkap.',
                      style: TextStyle(
                          fontSize: 13, color: Colors.black54, height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    const Text('Sales',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F8FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: isLoadingUsers
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            )
                          : salesList.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Text('Tidak ada data sales',
                                      style: TextStyle(
                                          color: Colors.black38, fontSize: 13)),
                                )
                              : DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedUsername,
                                    isExpanded: true,
                                    hint: const Row(
                                      children: [
                                        Icon(Icons.person_rounded,
                                            color: primaryBlue, size: 20),
                                        SizedBox(width: 10),
                                        Text('Pilih Sales',
                                            style: TextStyle(
                                                color: Colors.black38,
                                                fontSize: 14)),
                                      ],
                                    ),
                                    items: salesList
                                        .map<DropdownMenuItem<String>>((s) {
                                      return DropdownMenuItem<String>(
                                        value: s['username'],
                                        child: Row(
                                          children: [
                                            const Icon(Icons.person_rounded,
                                                color: primaryBlue, size: 18),
                                            const SizedBox(width: 10),
                                            Text(s['username'] ?? '-'),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setModalState(
                                          () => selectedUsername = val);
                                    },
                                  ),
                                ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: namaBengkelController,
                      decoration: InputDecoration(
                        labelText: 'Nama Bengkel',
                        prefixIcon: const Icon(Icons.storefront_rounded,
                            color: primaryBlue),
                        filled: true,
                        fillColor: const Color(0xFFF5F8FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: deskripsiController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Tugas',
                        prefixIcon:
                            const Icon(Icons.notes_rounded, color: primaryBlue),
                        filled: true,
                        fillColor: const Color(0xFFF5F8FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setModalState(() => deadline = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F8FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 18, color: primaryBlue),
                            const SizedBox(width: 10),
                            Text(
                              deadline != null
                                  ? '${deadline!.day}/${deadline!.month}/${deadline!.year}'
                                  : 'Pilih Deadline (opsional)',
                              style: TextStyle(
                                color: deadline != null
                                    ? Colors.black87
                                    : Colors.black38,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (selectedUsername == null ||
                                    namaBengkelController.text.trim().isEmpty ||
                                    deskripsiController.text.trim().isEmpty) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Lengkapi semua field!'),
                                      backgroundColor: accentRed,
                                    ),
                                  );
                                  return;
                                }

                                setModalState(() => isSaving = true);

                                final result = await DataService().buatTugas(
                                  username: selectedUsername!,
                                  namaBengkel:
                                      namaBengkelController.text.trim(),
                                  deskripsi: deskripsiController.text.trim(),
                                  deadline: deadline != null
                                      ? '${deadline!.year}-${deadline!.month.toString().padLeft(2, '0')}-${deadline!.day.toString().padLeft(2, '0')}'
                                      : '',
                                );

                                if (!ctx.mounted) return;
                                Navigator.pop(ctx);
                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result['message'] ??
                                        'Tugas berhasil dibuat'),
                                    backgroundColor:
                                        result['status'] == 'success'
                                            ? primaryBlue
                                            : accentRed,
                                  ),
                                );
                                _refreshTasks();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text('Buat Tugas',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(String status) =>
      status == 'done' ? const Color(0xFF00A86B) : accentRed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showFormTambahTugas,
        backgroundColor: primaryBlue,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Buat Tugas', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header full-width, menempel di atas, flat, solid color
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 12, 20, 16),
            color: primaryBlue,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.assignment_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Manajemen Tugas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Kelola tugas seluruh sales.',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() => _searchQuery = val.trim());
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                if (_searchQuery == val.trim()) {
                                  _refreshTasks();
                                }
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Cari nama bengkel...',
                              hintStyle: const TextStyle(
                                  fontSize: 13, color: Colors.black38),
                              prefixIcon: const Icon(Icons.search_rounded,
                                  color: primaryBlue),
                              filled: true,
                              fillColor: const Color(0xFFEFF4FF),
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                    color: primaryBlue, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F8FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _filterStatus.isEmpty
                                          ? 'Semua'
                                          : _filterStatus,
                                      isExpanded: true,
                                      items: _statusFilters.map((s) {
                                        return DropdownMenuItem<String>(
                                          value: s,
                                          child: Text(
                                            s == 'pending'
                                                ? 'Pending'
                                                : s == 'done'
                                                    ? 'Selesai'
                                                    : 'Semua',
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val == null) return;
                                        setState(() => _filterStatus =
                                            val == 'Semua' ? '' : val);
                                        _refreshTasks();
                                      },
                                      icon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: primaryBlue),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F8FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: _isLoadingSales
                                      ? const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Center(
                                            child: SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            ),
                                          ),
                                        )
                                      : DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _selectedSales.isEmpty
                                                ? 'Semua'
                                                : _selectedSales,
                                            isExpanded: true,
                                            items: _salesList.map((s) {
                                              return DropdownMenuItem<String>(
                                                value: s,
                                                child: Text(s),
                                              );
                                            }).toList(),
                                            onChanged: (val) {
                                              if (val == null) return;
                                              setState(() => _selectedSales =
                                                  val == 'Semua' ? '' : val);
                                              _refreshTasks();
                                            },
                                            icon: const Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                color: primaryBlue),
                                          ),
                                        ),
                                ),
                              ),
                              if (_adaFilter) ...[
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: _resetFilter,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: accentRed.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(
                                      Icons.filter_alt_off_rounded,
                                      size: 18,
                                      color: accentRed,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: FutureBuilder<Map<String, dynamic>>(
                      future: _tasksFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: primaryBlue));
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
                                  child: Icon(
                                    _adaFilter
                                        ? Icons.search_off_rounded
                                        : Icons.assignment_rounded,
                                    size: 48,
                                    color: primaryBlue,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _adaFilter
                                      ? 'Tidak ada hasil yang cocok.'
                                      : 'Belum ada tugas.',
                                  style: const TextStyle(
                                      color: Colors.black45, fontSize: 15),
                                ),
                                if (_adaFilter) ...[
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: _resetFilter,
                                    child: const Text(
                                      'Reset filter',
                                      style: TextStyle(
                                          color: accentRed,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }

                        final List tasks = data['data_tasks'] ?? [];

                        return ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
                          itemCount: tasks.length,
                          itemBuilder: (context, i) {
                            final task = tasks[i];
                            final status = task['status'] ?? 'pending';
                            final statusColor = _statusColor(status);
                            final waktuInput =
                                task['waktu_input']?.toString().trim() ?? '';
                            final showWaktuInput = waktuInput.isNotEmpty;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          status == 'done'
                                              ? Icons.check_circle_rounded
                                              : Icons.assignment_rounded,
                                          color: statusColor,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              task['nama_bengkel'] ?? '-',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: Colors.black87),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              task['deskripsi_tugas'] ?? '-',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                  height: 1.3),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () => _konfirmasiHapus(
                                            task['id'].toString(),
                                            task['nama_bengkel'] ?? ''),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: accentRed.withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          child: const Icon(
                                            Icons.delete_outline_rounded,
                                            color: accentRed,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          spacing: 8,
                                          runSpacing: 6,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: primaryBlue
                                                    .withOpacity(0.08),
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                      Icons.person_rounded,
                                                      size: 14,
                                                      color: primaryBlue),
                                                  const SizedBox(width: 6),
                                                  Text(task['username'] ?? '-',
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: primaryBlue,
                                                          fontWeight:
                                                              FontWeight.w600)),
                                                ],
                                              ),
                                            ),
                                            if (task['deadline'] != null &&
                                                task['deadline']
                                                    .toString()
                                                    .isNotEmpty)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: accentRed
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .calendar_today_rounded,
                                                        size: 14,
                                                        color: accentRed),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      task['deadline'] ?? '-',
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: accentRed,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            if (showWaktuInput)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade100,
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .access_time_rounded,
                                                        size: 14,
                                                        color: Colors.black45),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      waktuInput,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black54,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          status == 'done'
                                              ? 'Selesai'
                                              : 'Pending',
                                          style: TextStyle(
                                              color: statusColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ],
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
          ),
        ],
      ),
    );
  }
}
