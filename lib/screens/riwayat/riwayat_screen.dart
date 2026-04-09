import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/riwayat_service.dart';
import '../../services/denda_service.dart';
import '../../models/denda.dart';
import '../peminjaman/peminjaman_detail_screen.dart';
import '../booking/booking_detail_screen.dart';
import '../denda/denda_detail_screen.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen>
    with SingleTickerProviderStateMixin {
  final _riwayatService = RiwayatService();
  final _dendaService = DendaService();

  late TabController _tabController;

  List _peminjaman = [];
  List _booking = [];
  List<Denda> _denda = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetch();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final riwayat = await _riwayatService.getAll();
    final denda = await _dendaService.getAll();
    setState(() {
      _peminjaman = riwayat['peminjaman'] ?? [];
      _booking = riwayat['booking'] ?? [];
      _denda = denda;
      _loading = false;
    });
  }

  String _formatTanggal(String? tanggal) {
    if (tanggal == null) return '-';
    try {
      final dt = DateTime.parse(tanggal.split('T')[0]);
      return DateFormat('dd MMM yyyy', 'id').format(dt);
    } catch (_) {
      return tanggal;
    }
  }

  Color _statusColorPeminjaman(String status) {
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

  Color _statusColorBooking(String status) {
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

  Color _statusColorDenda(String status) {
    switch (status) {
      case 'belum_bayar':
        return const Color(0xFFEF4444);
      case 'menunggu_verifikasi':
        return const Color(0xFFF59E0B);
      case 'sudah_bayar':
        return const Color(0xFF16A34A);
      case 'dibebaskan':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
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
          'Riwayat Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetch,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: 'Pinjam (${_peminjaman.length})'),
            Tab(text: 'Booking (${_booking.length})'),
            Tab(text: 'Denda (${_denda.length})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF97316)))
          : RefreshIndicator(
              color: const Color(0xFFF97316),
              onRefresh: _fetch,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _peminjamanTab(),
                  _bookingTab(),
                  _dendaTab(),
                ],
              ),
            ),
    );
  }

  // ── TAB PEMINJAMAN ────────────────────────────────────────
  Widget _peminjamanTab() {
    if (_peminjaman.isEmpty) return _emptyState('Belum ada riwayat peminjaman');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _peminjaman.length,
      itemBuilder: (_, i) {
        final p = _peminjaman[i];
        final color = _statusColorPeminjaman(p['status'] ?? '');
        final id = int.tryParse(p['id'].toString()) ?? 0;

        return GestureDetector(
          onTap: () => Get.to(() => PeminjamanDetailScreen(id: id)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
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
              children: [
                // Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          p['kode'] ?? '-',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          p['status'] ?? '-',
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                // Body
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${_formatTanggal(p['tanggal_pinjam'])} → ${_formatTanggal(p['tanggal_kembali'])}',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Barang
                      ...((p['barang'] as List? ?? []).take(2).map(
                            (b) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.inventory_2_rounded,
                                      size: 13, color: Color(0xFFF97316)),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${b['nama_barang']} - ${b['nama_ruangan']}',
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${b['jumlah']} unit',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFF97316),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      if ((p['barang'] as List? ?? []).length > 2)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '+${(p['barang'] as List).length - 2} lainnya',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFFF97316)),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── TAB BOOKING ───────────────────────────────────────────
  Widget _bookingTab() {
    if (_booking.isEmpty) return _emptyState('Belum ada riwayat booking');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _booking.length,
      itemBuilder: (_, i) {
        final b = _booking[i];
        final color = _statusColorBooking(b['status'] ?? '');
        final id = int.tryParse(b['id'].toString()) ?? 0;

        return GestureDetector(
          onTap: () => Get.to(() => BookingDetailScreen(id: id)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
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
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          b['kode'] ?? '-',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          b['status'] ?? '-',
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.meeting_room_rounded,
                              size: 13, color: Color(0xFFF97316)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              b['ruangan']?['nama_ruangan'] ?? '-',
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            _formatTanggal(b['tanggal']),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const Spacer(),
                          const Icon(Icons.access_time_rounded,
                              size: 13, color: Color(0xFFF97316)),
                          const SizedBox(width: 4),
                          Text(
                            '${(b['waktu_mulai'] ?? '').toString().substring(0, 5)} - ${(b['waktu_selesai'] ?? '').toString().substring(0, 5)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF97316),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── TAB DENDA ─────────────────────────────────────────────
  Widget _dendaTab() {
    if (_denda.isEmpty) return _emptyState('Tidak ada riwayat denda');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _denda.length,
      itemBuilder: (_, i) {
        final d = _denda[i];
        final color = _statusColorDenda(d.statusPembayaran);

        return GestureDetector(
          onTap: () async {
            await Get.to(() => DendaDetailScreen(
                  type: d.type,
                  id: d.id,
                ));
            _fetch();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
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
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          d.referensi['kode'] ?? '-',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          d.statusLabel,
                          style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: d.type == 'barang'
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          d.type == 'barang' ? 'Peminjaman' : 'Booking',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: d.type == 'barang'
                                ? const Color(0xFF3B82F6)
                                : const Color(0xFF16A34A),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        d.jumlahDendaFormat,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _emptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_rounded, color: Colors.grey, size: 48),
          const SizedBox(height: 12),
          Text(msg, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
