import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/data_service.dart';

class BengkelTab extends StatefulWidget {
  final String usernameSales;
  const BengkelTab({super.key, required this.usernameSales});

  @override
  State<BengkelTab> createState() => BengkelTabState();
}

class BengkelTabState extends State<BengkelTab> {
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color accentRed = Color(0xFFDB1607);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _namaBengkelController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  String? _selectedStatus;
  final List<String> _statusList = ['Sukses', 'Follow-up', 'Tutup', 'Ditolak'];

  bool _isSaving = false;
  String _latitude = '-6.2088';
  String _longitude = '106.8456';

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _latitude = position.latitude.toStringAsFixed(6);
          _longitude = position.longitude.toStringAsFixed(6);
        });
      }
    } catch (_) {}
  }

  Future<void> _openGoogleMaps() async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate() || _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Lengkapi semua data terlebih dahulu!'),
            ],
          ),
          backgroundColor: accentRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final result = await DataService().simpanBengkel(
      namaSales: widget.usernameSales,
      namaBengkel: _namaBengkelController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      catatan: _catatanController.text.trim(),
      statusKunjungan: _selectedStatus!,
    );

    if (mounted) setState(() => _isSaving = false);

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
            Text(success
                ? 'Kunjungan berhasil disimpan!'
                : 'Gagal menyimpan data.'),
          ],
        ),
        backgroundColor: success ? primaryBlue : accentRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    if (success) {
      _namaBengkelController.clear();
      _catatanController.clear();
      setState(() => _selectedStatus = null);
    }
  }

  Color _chipColor(String status) {
    switch (status) {
      case 'Sukses':
        return const Color(0xFF00A86B);
      case 'Follow-up':
        return primaryBlue;
      case 'Tutup':
        return Colors.grey;
      case 'Ditolak':
        return accentRed;
      default:
        return primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul inline — compact, tidak makan ruang
                Row(
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
                          'Laporan Kunjungan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Catat kunjungan bengkel hari ini',
                          style: TextStyle(fontSize: 12, color: Colors.black45),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Kartu Informasi Bengkel
                _buildSectionCard(
                  title: 'Informasi Bengkel',
                  icon: Icons.storefront_rounded,
                  children: [
                    TextFormField(
                      controller: _namaBengkelController,
                      decoration:
                          _inputDecor('Nama Bengkel', Icons.storefront_rounded)
                              .copyWith(hintText: 'Masukkan nama bengkel'),
                      validator: (v) =>
                          v!.isEmpty ? 'Nama bengkel wajib diisi' : null,
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Status Kunjungan',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _statusList.map((status) {
                        final isSelected = _selectedStatus == status;
                        final color = _chipColor(status);
                        return ChoiceChip(
                          label: Text(
                            status,
                            style: TextStyle(
                              color: isSelected ? Colors.white : color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: color,
                          backgroundColor: color.withOpacity(0.12),
                          disabledColor: color.withOpacity(0.12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onSelected: (_) =>
                              setState(() => _selectedStatus = status),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Kartu Catatan & Lokasi
                _buildSectionCard(
                  title: 'Catatan & Lokasi',
                  icon: Icons.location_on_rounded,
                  children: [
                    TextFormField(
                      controller: _catatanController,
                      maxLines: 3,
                      decoration: _inputDecor(
                          'Catatan Tambahan (opsional)', Icons.notes_rounded),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: primaryBlue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: primaryBlue.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.my_location_rounded,
                              size: 16, color: primaryBlue),
                          const SizedBox(width: 8),
                          Text(
                            '$_latitude, $_longitude',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _openGoogleMaps,
                            child: const Text(
                              'Buka Maps',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: accentRed,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Tombol Simpan
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      disabledBackgroundColor: primaryBlue.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Simpan Kunjungan',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentRed, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    fontSize: 14),
              ),
            ],
          ),
          const Divider(height: 22),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Colors.black54),
        prefixIcon: Icon(icon, size: 20, color: primaryBlue),
        filled: true,
        fillColor: const Color(0xFFF4F8FF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentRed, width: 1.5),
        ),
      );
}
