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
  }

  @override
  void dispose() {
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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
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
                      Text('Monitoring Kunjungan',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87)),
                      Text('Seluruh kunjungan semua sales',
                          style:
                              TextStyle(fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim());
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchQuery == val.trim()) _loadData();
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Cari nama bengkel...',
                  hintStyle:
                      const TextStyle(fontSize: 13, color: Colors.black38),
                  prefixIcon:
                      const Icon(Icons.search_rounded, color: primaryBlue),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Filter status
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _statusList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final s = _statusList[i];
                  final isSelected = _selectedStatus == s ||
                      (s == 'Semua' && _selectedStatus.isEmpty);
                  final color = s == 'Semua'
                      ? primaryBlue
                      : _statusColor(s.toLowerCase());

                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedStatus = s == 'Semua' ? '' : s);
                      _loadData();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? color : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : color.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          color: isSelected ? Colors.white : color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Filter Sales',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: _isLoadingSales
                  ? const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _salesList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final s = _salesList[i];
                        final isSelected = _selectedSales == s ||
                            (s == 'Semua' && _selectedSales.isEmpty);
                        final color =
                            isSelected ? primaryBlue : Colors.grey.shade300;

                        return GestureDetector(
                          onTap: () {
                            setState(
                                () => _selectedSales = s == 'Semua' ? '' : s);
                            _loadData();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryBlue : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? primaryBlue
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryBlue))
                  : _kunjungan.isEmpty
                      ? const Center(
                          child: Text('Tidak ada data kunjungan.',
                              style: TextStyle(
                                  color: Colors.black45, fontSize: 15)),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: primaryBlue,
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                            itemCount: _kunjungan.length + (_hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _kunjungan.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                        color: primaryBlue, strokeWidth: 2),
                                  ),
                                );
                              }

                              final item = _kunjungan[index];
                              final status =
                                  item['status_kunjungan'] as String?;
                              final statusColor = _statusColor(status);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: Colors.grey.shade100),
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
                                      width: 4,
                                      height: 95,
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
                                        color: statusColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(_statusIcon(status),
                                          color: statusColor, size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['nama_bengkel'] ?? '-',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                  color: Colors.black87),
                                            ),
                                            const SizedBox(height: 3),
                                            Row(
                                              children: [
                                                const Icon(Icons.person_rounded,
                                                    size: 11,
                                                    color: primaryBlue),
                                                const SizedBox(width: 3),
                                                Text(
                                                  item['nama_sales'] ?? '-',
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      color: primaryBlue,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: statusColor
                                                    .withOpacity(0.1),
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
                                            const SizedBox(height: 4),
                                            Text(
                                              item['waktu_input'] ?? '-',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.black38),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
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
    );
  }
}
