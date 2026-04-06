import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../services/auth_service.dart';
import '../../services/peminjaman_service.dart';

class PeminjamanCreateScreen extends StatefulWidget {
  const PeminjamanCreateScreen({super.key});

  @override
  State<PeminjamanCreateScreen> createState() => _PeminjamanCreateScreenState();
}

class _PeminjamanCreateScreenState extends State<PeminjamanCreateScreen> {
  final _service = PeminjamanService();
  final _keteranganController = TextEditingController();

  DateTime? _tanggalPinjam;
  DateTime? _tanggalKembali;
  bool _isLoading = false;
  bool _loadBarang = true;

  // List barang dari API
  List _barangList = [];

  // Barang yang dipilih: {barang_ruangan_id, nama, ruangan, qty_tersedia, jumlah_dipinjam}
  List<Map<String, dynamic>> _selectedBarang = [];

  @override
  void initState() {
    super.initState();
    _fetchBarang();
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _fetchBarang() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.barang),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _barangList = data['data'] ?? [];
          _loadBarang = false;
        });
      }
    } catch (_) {
      setState(() => _loadBarang = false);
    }
  }

  Future<void> _pickTanggal({required bool isPinjam}) async {
    final now = DateTime.now();
    final first = isPinjam ? now : (_tanggalPinjam ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: first,
      firstDate: first,
      lastDate: DateTime(now.year + 1),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF97316),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isPinjam) {
          _tanggalPinjam = picked;
          // Reset tanggal kembali kalau lebih awal
          if (_tanggalKembali != null && _tanggalKembali!.isBefore(picked)) {
            _tanggalKembali = null;
          }
        } else {
          _tanggalKembali = picked;
        }
      });
    }
  }

  // Tambah barang ke daftar pilihan
  void _showPilihBarang() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _barangPickerSheet(),
    );
  }

  Widget _barangPickerSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Pilih Barang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Divider(height: 1),

          _loadBarang
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFF97316)),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _barangList.length,
                    itemBuilder: (_, i) {
                      final barang = _barangList[i];
                      final tersediaDi = barang['tersedia_di'] as List? ?? [];

                      if (tersediaDi.isEmpty) return const SizedBox();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nama barang
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              barang['nama'] ?? '-',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ),

                          // Per ruangan
                          ...tersediaDi.map((t) {
                            final brId = int.tryParse(
                                    t['barang_ruangan_id'].toString()) ??
                                0;
                            final qty = int.tryParse(t['qty'].toString()) ?? 0;
                            final sudahDipilih = _selectedBarang
                                .any((s) => s['barang_ruangan_id'] == brId);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: sudahDipilih
                                    ? const Color(0xFFFFF7ED)
                                    : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: sudahDipilih
                                      ? const Color(0xFFF97316)
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.meeting_room_rounded,
                                      size: 16, color: Color(0xFFF97316)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t['nama_ruangan'] ?? '-',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'Tersedia: $qty unit',
                                          style: const TextStyle(
                                              fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  sudahDipilih
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedBarang.removeWhere((s) =>
                                                  s['barang_ruangan_id'] ==
                                                  brId);
                                            });
                                            Navigator.pop(context);
                                            _showPilihBarang();
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEF4444),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Hapus',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedBarang.add({
                                                'barang_ruangan_id': brId,
                                                'nama_barang': barang['nama'],
                                                'nama_ruangan':
                                                    t['nama_ruangan'],
                                                'qty_tersedia': qty,
                                                'jumlah': 1,
                                              });
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF97316),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              'Pilih',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            );
                          }),

                          const Divider(),
                        ],
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (_tanggalPinjam == null || _tanggalKembali == null) {
      Get.snackbar(
        'Peringatan',
        'Tanggal pinjam dan kembali harus diisi',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (_selectedBarang.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Pilih minimal 1 barang',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _service.store(
      tanggalPinjam: DateFormat('yyyy-MM-dd').format(_tanggalPinjam!),
      tanggalKembali: DateFormat('yyyy-MM-dd').format(_tanggalKembali!),
      barangRuanganIds:
          _selectedBarang.map((s) => s['barang_ruangan_id'] as int).toList(),
      jumlahList: _selectedBarang.map((s) => s['jumlah'] as int).toList(),
      keterangan: _keteranganController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      Get.back(result: true);
      Get.snackbar(
        'Berhasil',
        'Peminjaman berhasil diajukan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      Get.snackbar(
        'Gagal',
        result['message'] ?? 'Terjadi kesalahan',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  String _formatTanggal(DateTime dt) =>
      DateFormat('dd MMM yyyy', 'id').format(dt);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        title: const Text(
          'Ajukan Peminjaman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tanggal ───────────────────────────────────
            _sectionTitle('Periode Peminjaman'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _datePicker(
                    label: 'Tanggal Pinjam',
                    value: _tanggalPinjam != null
                        ? _formatTanggal(_tanggalPinjam!)
                        : null,
                    onTap: () => _pickTanggal(isPinjam: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _datePicker(
                    label: 'Tanggal Kembali',
                    value: _tanggalKembali != null
                        ? _formatTanggal(_tanggalKembali!)
                        : null,
                    onTap: _tanggalPinjam == null
                        ? null
                        : () => _pickTanggal(isPinjam: false),
                  ),
                ),
              ],
            ),

            // Durasi
            if (_tanggalPinjam != null && _tanggalKembali != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: Color(0xFFF97316)),
                    const SizedBox(width: 6),
                    Text(
                      'Durasi: ${_tanggalKembali!.difference(_tanggalPinjam!).inDays} hari',
                      style: const TextStyle(
                        color: Color(0xFFF97316),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Pilih Barang ──────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle('Barang yang Dipinjam'),
                GestureDetector(
                  onTap: _showPilihBarang,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Pilih Barang',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _selectedBarang.isEmpty
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.grey[200]!, style: BorderStyle.solid),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            color: Colors.grey, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada barang dipilih',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: _selectedBarang
                        .asMap()
                        .entries
                        .map((entry) =>
                            _selectedBarangCard(entry.key, entry.value))
                        .toList(),
                  ),

            const SizedBox(height: 24),

            // ── Keterangan ────────────────────────────────
            _sectionTitle('Keterangan (opsional)'),
            const SizedBox(height: 12),
            TextField(
              controller: _keteranganController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tulis keperluan peminjaman...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFF97316), width: 2),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Tombol Submit ─────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Ajukan Peminjaman',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _datePicker({
    required String label,
    String? value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: onTap == null ? const Color(0xFFF3F4F6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: onTap == null ? Colors.grey[400] : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: onTap == null
                      ? Colors.grey[400]
                      : const Color(0xFFF97316),
                ),
                const SizedBox(width: 6),
                Text(
                  value ?? 'Pilih tanggal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        value != null ? FontWeight.w600 : FontWeight.normal,
                    color:
                        value != null ? const Color(0xFF1A1A1A) : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectedBarangCard(int index, Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Color(0xFFF97316),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama_barang'] ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  item['nama_ruangan'] ?? '-',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),

          // Input jumlah
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (item['jumlah'] > 1) {
                    setState(() => _selectedBarang[index]['jumlah']--);
                  }
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.remove_rounded, size: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${item['jumlah']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (item['jumlah'] < item['qty_tersedia']) {
                    setState(() => _selectedBarang[index]['jumlah']++);
                  } else {
                    Get.snackbar(
                      'Peringatan',
                      'Stok tidak mencukupi',
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                    );
                  }
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF97316),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 8),

          // Hapus
          GestureDetector(
            onTap: () => setState(() => _selectedBarang.removeAt(index)),
            child: const Icon(
              Icons.close_rounded,
              size: 18,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
