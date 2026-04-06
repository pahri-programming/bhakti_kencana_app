import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/peminjaman.dart';
import '../../services/peminjaman_service.dart';

class PeminjamanDetailScreen extends StatefulWidget {
  final int id;
  const PeminjamanDetailScreen({super.key, required this.id});

  @override
  State<PeminjamanDetailScreen> createState() => _PeminjamanDetailScreenState();
}

class _PeminjamanDetailScreenState extends State<PeminjamanDetailScreen> {
  final _service = PeminjamanService();
  Peminjaman? _data;
  bool _loading = true;
  bool _canceling = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final data = await _service.getDetail(widget.id);
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  Future<void> _cancel() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Batalkan Peminjaman'),
        content: const Text('Yakin ingin membatalkan peminjaman ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _canceling = true);
    final result = await _service.cancel(widget.id);
    setState(() => _canceling = false);

    if (result['success'] == true) {
      Get.back(result: true);
      Get.snackbar(
        'Berhasil',
        'Peminjaman berhasil dibatalkan',
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

  Color _statusColor(String status) {
    switch (status) {
      case 'disetujui':
        return const Color(0xFF16A34A);
      case 'menunggu':
        return const Color(0xFFF59E0B);
      case 'ditolak':
        return const Color(0xFFEF4444);
      case 'dipinjam':
        return const Color(0xFF3B82F6);
      case 'dikembalikan':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'disetujui':
        return 'Disetujui';
      case 'menunggu':
        return 'Menunggu Persetujuan';
      case 'ditolak':
        return 'Ditolak';
      case 'dipinjam':
        return 'Sedang Dipinjam';
      case 'dikembalikan':
        return 'Sudah Dikembalikan';
      default:
        return status;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'disetujui':
        return Icons.check_circle_rounded;
      case 'menunggu':
        return Icons.access_time_rounded;
      case 'ditolak':
        return Icons.cancel_rounded;
      case 'dipinjam':
        return Icons.inventory_2_rounded;
      case 'dikembalikan':
        return Icons.assignment_return_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _formatTanggal(String tanggal) {
    try {
      final dt = DateTime.parse(tanggal);
      return DateFormat('EEEE, dd MMMM yyyy', 'id').format(dt);
    } catch (_) {
      return tanggal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        title: const Text(
          'Detail Peminjaman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetch,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF97316)),
            )
          : _data == null
              ? _notFound()
              : RefreshIndicator(
                  color: const Color(0xFFF97316),
                  onRefresh: _fetch,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // ── Status Banner ──────────────────
                        _statusBanner(),
                        const SizedBox(height: 16),

                        // ── Info Peminjaman ────────────────
                        _infoCard(),
                        const SizedBox(height: 16),

                        // ── Daftar Barang ──────────────────
                        _barangCard(),
                        const SizedBox(height: 16),

                        // ── Keterangan ─────────────────────
                        if (_data!.keterangan != null &&
                            _data!.keterangan!.isNotEmpty)
                          _keteranganCard(),

                        // ── Alasan Tolak ───────────────────
                        if (_data!.status == 'ditolak' &&
                            _data!.alasanTolak != null)
                          _alasanTolakCard(),

                        const SizedBox(height: 16),

                        // ── Tombol Batalkan ────────────────
                        if (_data!.status == 'menunggu') _cancelButton(),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _statusBanner() {
    final color = _statusColor(_data!.status);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _statusIcon(_data!.status),
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusLabel(_data!.status),
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _data!.kode,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Peminjaman',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.calendar_today_rounded,
            'Tanggal Pinjam',
            _formatTanggal(_data!.tanggalPinjam),
          ),
          const Divider(height: 20),
          _infoRow(
            Icons.event_rounded,
            'Tanggal Kembali',
            _formatTanggal(_data!.tanggalKembali),
          ),
          const Divider(height: 20),
          _infoRow(
            Icons.access_time_rounded,
            'Durasi',
            '${_data!.durasiHari} hari',
          ),
          const Divider(height: 20),
          _infoRow(
            Icons.schedule_rounded,
            'Diajukan',
            _formatTanggal(_data!.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFFF97316), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _barangCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Daftar Barang',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_data!.barang.length} item',
                  style: const TextStyle(
                    color: Color(0xFFF97316),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._data!.barang.map(
            (b) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
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
                          b.namaBarang,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.meeting_room_rounded,
                                size: 11, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              b.namaRuangan,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${b.jumlah} unit',
                      style: const TextStyle(
                        color: Color(0xFFF97316),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  Widget _keteranganCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keterangan',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 10),
          Text(
            _data!.keterangan!,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _alasanTolakCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cancel_rounded, color: Color(0xFFEF4444), size: 18),
              SizedBox(width: 8),
              Text(
                'Alasan Penolakan',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _data!.alasanTolak!,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _canceling ? null : _cancel,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEF2F2),
          foregroundColor: const Color(0xFFEF4444),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFFECACA)),
          ),
        ),
        icon: _canceling
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Color(0xFFEF4444),
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.cancel_rounded),
        label: const Text(
          'Batalkan Peminjaman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _notFound() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, color: Colors.grey, size: 48),
          SizedBox(height: 12),
          Text(
            'Data tidak ditemukan',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
