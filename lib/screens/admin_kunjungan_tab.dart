import 'dart:async';

import 'package:flutter/material.dart';

import '../services/data_service.dart';

class AdminKunjunganTab extends StatefulWidget {
  const AdminKunjunganTab({super.key});

  @override
  State<AdminKunjunganTab> createState() => _AdminKunjunganTabState();
}

class _AdminKunjunganTabState extends State<AdminKunjunganTab> {
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color accentRed = Color(0xFFDB1607);

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final List<dynamic> _kunjungan = [];

  Timer? _autoRefreshTimer;

  int _page = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _isLoadingSales = false;
  String _searchQuery = '';
  String _selectedStatus = '';
  String _selectedSales = '';
  List<String> _salesList = ['Semua'];

  final List<String> _statusList = [
    'Semua',
    'Sukses',
    'Follow-up',
    'Tutup',
    'Ditolak'
  ];

  @override
  void initState() {
    super.initState();
    _loadSales();
    _loadData();
    _scrollController.addListener(_onScroll);
    // Auto-refresh tiap 30 detik, tanpa perlu tombol manual
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadData(),
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _kunjungan.clear();
      _page = 1;
      _hasMore = true;
    });

    final result = await DataService().ambilSemuaKunjungan(
      page: 1,
      search: _searchQuery,
      status: _selectedStatus == 'Semua' ? '' : _selectedStatus,
      sales: _selectedSales == 'Semua' ? '' : _selectedSales,
    );
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['status'] == 'success') {
        _kunjungan.addAll(result['data_kunjungan'] ?? []);
        _hasMore = result['has_more'] ?? false;
        _page = 2;
      }
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    final result = await DataService().ambilSemuaKunjungan(
      page: _page,
      search: _searchQuery,
      status: _selectedStatus == 'Semua' ? '' : _selectedStatus,
      sales: _selectedSales == 'Semua' ? '' : _selectedSales,
    );
    if (!mounted) return;

    setState(() {
      _isLoadingMore = false;
      if (result['status'] == 'success') {
        _kunjungan.addAll(result['data_kunjungan'] ?? []);
        _hasMore = result['has_more'] ?? false;
        _page++;
      }
    });
  }

  bool get _adaFilter =>
      _searchQuery.isNotEmpty ||
      _selectedStatus.isNotEmpty ||
      _selectedSales.isNotEmpty;

  void _resetFilter() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedStatus = '';
      _selectedSales = '';
    });
    _loadData();
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

  Future<void> _loadSales() async {
    if (_isLoadingSales) return;
    setState(() => _isLoadingSales = true);

    final result = await DataService().ambilSemuaSales();
    if (!mounted) return;

    setState(() {
      _isLoadingSales = false;
      if (result['status'] == 'success') {
        final data = result['data_users'] as List<dynamic>? ?? [];
        final names = data
            .map((item) => item['username']?.toString().trim() ?? '')
            .where((username) => username.isNotEmpty)
            .toSet()
            .toList();
        _salesList = ['Semua', ...names];
      }
    });
  }

  IconData _statusIcon(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'sukses':
        return Icons.check_circle_rounded;
      case 'follow-up':
        return Icons.schedule_rounded;
      case 'tutup':
        return Icons.cancel_rounded;
      case 'ditolak':
        return Icons.block_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
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
                  child: const Icon(Icons.map_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Monitoring Kunjungan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Seluruh kunjungan semua sales.',
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
                      width: double.infinity,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() => _searchQuery = val.trim());
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                if (_searchQuery == val.trim()) _loadData();
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
                                      value: _selectedStatus.isEmpty
                                          ? 'Semua'
                                          : _selectedStatus,
                                      isExpanded: true,
                                      items: _statusList.map((s) {
                                        final color = s == 'Semua'
                                            ? Colors.black
                                            : _statusColor(s.toLowerCase());
                                        return DropdownMenuItem<String>(
                                          value: s,
                                          child: Text(
                                            s,
                                            style: TextStyle(color: color),
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val == null) return;
                                        setState(() => _selectedStatus =
                                            val == 'Semua' ? '' : val);
                                        _loadData();
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
                                              _loadData();
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
                    child: _isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: primaryBlue))
                        : _kunjungan.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: primaryBlue.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _adaFilter
                                            ? Icons.search_off_rounded
                                            : Icons.map_rounded,
                                        size: 48,
                                        color: primaryBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _adaFilter
                                          ? 'Tidak ada hasil yang cocok.'
                                          : 'Tidak ada data kunjungan.',
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
                              )
                            : RefreshIndicator(
                                onRefresh: _loadData,
                                color: primaryBlue,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 4, 20, 24),
                                  itemCount:
                                      _kunjungan.length + (_hasMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == _kunjungan.length) {
                                      return const Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 16),
                                        child: Center(
                                          child: CircularProgressIndicator(
                                              color: primaryBlue,
                                              strokeWidth: 2),
                                        ),
                                      );
                                    }

                                    final item = _kunjungan[index];
                                    final status =
                                        item['status_kunjungan'] as String?;
                                    final statusColor = _statusColor(status);

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: Colors.grey.shade100),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.black.withOpacity(0.04),
                                            blurRadius: 10,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: statusColor
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(_statusIcon(status),
                                                    color: statusColor,
                                                    size: 20),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  item['nama_bengkel'] ?? '-',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 14,
                                                      color: Colors.black87),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: statusColor
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  status ?? '-',
                                                  style: TextStyle(
                                                    color: statusColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 8,
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
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                        Icons.person_rounded,
                                                        size: 14,
                                                        color: primaryBlue),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      item['nama_sales'] ?? '-',
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: primaryBlue,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ],
                                                ),
                                              ),
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
                                                      item['waktu_input'] ??
                                                          '-',
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
                                        ],
                                      ),
                                    );
                                  },
                                ),
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
