import 'package:flutter/material.dart';

import '../services/data_service.dart';

class RiwayatTab extends StatefulWidget {
  final String usernameSales;
  const RiwayatTab({super.key, required this.usernameSales});

  @override
  State<RiwayatTab> createState() => RiwayatTabState();
}

class RiwayatTabState extends State<RiwayatTab> {
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color accentRed = Color(0xFFDB1607);

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final List<dynamic> _kunjungan = [];

  int _page = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  String _searchQuery = '';
  String _selectedStatus = '';
  DateTime? _dariTanggal;
  DateTime? _sampaiTanggal;

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

    final result = await DataService().ambilRiwayat(
      widget.usernameSales,
      page: 1,
      search: _searchQuery,
      status: _selectedStatus == 'Semua' ? '' : _selectedStatus,
      dari: _dariTanggal != null
          ? '${_dariTanggal!.year}-${_dariTanggal!.month.toString().padLeft(2, '0')}-${_dariTanggal!.day.toString().padLeft(2, '0')}'
          : '',
      sampai: _sampaiTanggal != null
          ? '${_sampaiTanggal!.year}-${_sampaiTanggal!.month.toString().padLeft(2, '0')}-${_sampaiTanggal!.day.toString().padLeft(2, '0')}'
          : '',
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

    final result = await DataService().ambilRiwayat(
      widget.usernameSales,
      page: _page,
      search: _searchQuery,
      status: _selectedStatus == 'Semua' ? '' : _selectedStatus,
      dari: _dariTanggal != null
          ? '${_dariTanggal!.year}-${_dariTanggal!.month.toString().padLeft(2, '0')}-${_dariTanggal!.day.toString().padLeft(2, '0')}'
          : '',
      sampai: _sampaiTanggal != null
          ? '${_sampaiTanggal!.year}-${_sampaiTanggal!.month.toString().padLeft(2, '0')}-${_sampaiTanggal!.day.toString().padLeft(2, '0')}'
          : '',
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

  // TIDAK DIUBAH — dipanggil dari MainNavigation via GlobalKey
  Future<void> refreshRiwayat() async {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedStatus = '';
      _dariTanggal = null;
      _sampaiTanggal = null;
    });
    await _loadData();
  }

  Future<void> _pilihTanggal(BuildContext context, bool isDari) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: primaryBlue,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isDari) {
          _dariTanggal = picked;
        } else {
          _sampaiTanggal = picked;
        }
      });
      _loadData();
    }
  }

  void _resetFilter() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedStatus = '';
      _dariTanggal = null;
      _sampaiTanggal = null;
    });
    _loadData();
  }

  bool get _adaFilter =>
      _searchQuery.isNotEmpty ||
      (_selectedStatus.isNotEmpty && _selectedStatus != 'Semua') ||
      _dariTanggal != null ||
      _sampaiTanggal != null;

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

  String _formatTanggal(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul
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
                      Text('Riwayat Kunjungan',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87)),
                      Text('Seluruh riwayat kunjungan bengkel',
                          style:
                              TextStyle(fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                ],
              ),
            ),

            // Kartu search + filter
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
                      blurRadius: 10,
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
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_searchQuery == val.trim()) _loadData();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari nama bengkel...',
                        hintStyle: const TextStyle(
                            fontSize: 13, color: Colors.black38),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: primaryBlue),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    color: Colors.black38, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                  _loadData();
                                },
                              )
                            : null,
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
                          borderSide:
                              const BorderSide(color: primaryBlue, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F8FF),
                              borderRadius: BorderRadius.circular(14),
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
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pilihTanggal(context, true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: _dariTanggal != null
                                    ? primaryBlue.withOpacity(0.08)
                                    : const Color(0xFFF5F8FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      size: 14,
                                      color: _dariTanggal != null
                                          ? primaryBlue
                                          : Colors.black38),
                                  const SizedBox(width: 6),
                                  Text(
                                    _dariTanggal != null
                                        ? _formatTanggal(_dariTanggal!)
                                        : 'Dari tanggal',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _dariTanggal != null
                                          ? primaryBlue
                                          : Colors.black38,
                                      fontWeight: _dariTanggal != null
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('—',
                            style: TextStyle(color: Colors.black38)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pilihTanggal(context, false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: _sampaiTanggal != null
                                    ? primaryBlue.withOpacity(0.08)
                                    : const Color(0xFFF5F8FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      size: 14,
                                      color: _sampaiTanggal != null
                                          ? primaryBlue
                                          : Colors.black38),
                                  const SizedBox(width: 6),
                                  Text(
                                    _sampaiTanggal != null
                                        ? _formatTanggal(_sampaiTanggal!)
                                        : 'Sampai tanggal',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _sampaiTanggal != null
                                          ? primaryBlue
                                          : Colors.black38,
                                      fontWeight: _sampaiTanggal != null
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryBlue))
                  : _kunjungan.isEmpty
                      ? Center(
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
                                      : Icons.history_rounded,
                                  size: 48,
                                  color: primaryBlue,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _adaFilter
                                    ? 'Tidak ada hasil yang cocok.'
                                    : 'Belum ada riwayat kunjungan.',
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
                          onRefresh: refreshRiwayat,
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
                                      height: 90,
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
                                            if (item['catatan'] != null &&
                                                item['catatan']
                                                    .toString()
                                                    .isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                'Catatan: ${item['catatan']}',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
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
