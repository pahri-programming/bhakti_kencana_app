import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/booking.dart';
import '../../services/booking_service.dart';

class BookingDetailScreen extends StatefulWidget {
  final int id;
  const BookingDetailScreen({super.key, required this.id});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final _service = BookingService();
  Booking? _data;
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
        title: const Text('Batalkan Booking'),
        content: const Text('Yakin ingin membatalkan booking ini?'),
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
        'Booking berhasil dibatalkan',
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
      case 'Diterima':
        return const Color(0xFF16A34A);
      case 'Pending':
        return const Color(0xFFF59E0B);
      case 'Ditolak':
        return const Color(0xFFEF4444);
      case 'Selesai':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Diterima':
        return Icons.check_circle_rounded;
      case 'Pending':
        return Icons.access_time_rounded;
      case 'Ditolak':
        return Icons.cancel_rounded;
      case 'Selesai':
        return Icons.task_alt_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'Diterima':
        return 'Booking Diterima';
      case 'Pending':
        return 'Menunggu Persetujuan';
      case 'Ditolak':
        return 'Booking Ditolak';
      case 'Selesai':
        return 'Booking Selesai';
      default:
        return status;
    }
  }

  String _formatTanggal(String tanggal) {
    try {
      final dt = DateTime.parse(tanggal.split('T')[0]);
      return DateFormat('EEEE, dd MMMM yyyy', 'id').format(dt);
    } catch (_) {
      return tanggal;
    }
  }

  String _formatWaktu(String waktu) {
    try {
      return waktu.substring(0, 5);
    } catch (_) {
      return waktu;
    }
  }

  String _formatCreatedAt(String dt) {
    try {
      final d = DateTime.parse(dt).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm', 'id').format(d);
    } catch (_) {
      return dt;
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
          'Detail Booking',
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
              child: CircularProgressIndicator(color: Color(0xFFF97316)))
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
                        _statusBanner(),
                        const SizedBox(height: 16),
                        _ruanganCard(),
                        const SizedBox(height: 16),
                        _infoCard(),
                        const SizedBox(height: 16),
                        if (_data!.keterangan != null &&
                            _data!.keterangan!.isNotEmpty)
                          _keteranganCard(),
                        if (_data!.status == 'Ditolak' &&
                            _data!.keterangan != null)
                          _alasanTolakCard(),
                        const SizedBox(height: 16),
                        if (_data!.status == 'Pending') _cancelButton(),
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
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
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

  Widget _ruanganCard() {
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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.meeting_room_rounded,
              color: Color(0xFFF97316),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _data!.ruangan['nama_ruangan'] ?? '-',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_data!.ruangan['lokasi'] != null)
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        _data!.ruangan['lokasi'],
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                if (_data!.ruangan['kapasitas'] != null)
                  Row(
                    children: [
                      const Icon(Icons.people_outline,
                          size: 13, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${_data!.ruangan['kapasitas']} orang',
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
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
            'Informasi Booking',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.calendar_today_rounded,
            'Tanggal',
            _formatTanggal(_data!.tanggal),
          ),
          const Divider(height: 20),
          _infoRow(
            Icons.access_time_rounded,
            'Waktu Mulai',
            _formatWaktu(_data!.waktuMulai),
          ),
          const Divider(height: 20),
          _infoRow(
            Icons.access_time_filled_rounded,
            'Waktu Selesai',
            _formatWaktu(_data!.waktuSelesai),
          ),
          const Divider(height: 20),
          _infoRow(
            Icons.timelapse_rounded,
            'Durasi',
            () {
              try {
                final mulai = _data!.waktuMulai.split(':');
                final selesai = _data!.waktuSelesai.split(':');
                final mulaiMenit =
                    int.parse(mulai[0]) * 60 + int.parse(mulai[1]);
                final selesaiMenit =
                    int.parse(selesai[0]) * 60 + int.parse(selesai[1]);
                final durasi = selesaiMenit - mulaiMenit;
                if (durasi >= 60) {
                  final jam = durasi ~/ 60;
                  final mnt = durasi % 60;
                  return mnt > 0 ? '$jam jam $mnt menit' : '$jam jam';
                }
                return '$durasi menit';
              } catch (_) {
                return '-';
              }
            }(),
          ),
          const Divider(height: 20),
          _infoRow(
            Icons.schedule_rounded,
            'Diajukan',
            _formatCreatedAt(_data!.createdAt),
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
            _data!.keterangan!,
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
          'Batalkan Booking',
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
