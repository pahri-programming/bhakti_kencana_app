import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/peminjaman.dart';
import '../../services/peminjaman_service.dart';
import 'peminjaman_detail_screen.dart';
import 'peminjaman_create_screen.dart';

class PeminjamanScreen extends StatefulWidget {
  const PeminjamanScreen({super.key});

  @override
  State<PeminjamanScreen> createState() => _PeminjamanScreenState();
}

class _PeminjamanScreenState extends State<PeminjamanScreen> {
  final _service = PeminjamanService();
  List<Peminjaman> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final data = await _service.getAll();
    setState(() {
      _list = data;
      _loading = false;
    });
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
        return 'Menunggu';
      case 'ditolak':
        return 'Ditolak';
      case 'dipinjam':
        return 'Dipinjam';
      case 'dikembalikan':
        return 'Dikembalikan';
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
      // Ambil tanggal saja, buang waktu dan timezone
      final dateOnly = tanggal.split('T')[0]; // → "2026-03-27"
      final dt = DateTime.parse(dateOnly);
      return DateFormat('dd MMM yyyy', 'id').format(dt);
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
          'Peminjaman Barang',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
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
          : RefreshIndicator(
              color: const Color(0xFFF97316),
              onRefresh: _fetch,
              child: _list.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _list.length,
                      itemBuilder: (_, i) => _peminjamanCard(_list[i]),
                    ),
            ),

      // Tombol ajukan peminjaman
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.to(() => const PeminjamanCreateScreen());
          if (result == true) _fetch();
        },
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Ajukan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _peminjamanCard(Peminjaman p) {
    final color = _statusColor(p.status);

    return GestureDetector(
      onTap: () async {
        final result = await Get.to(
          () => PeminjamanDetailScreen(id: p.id),
        );
        if (result == true) _fetch();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(_statusIcon(p.status), color: color, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    p.kode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel(p.status),
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Tanggal
                  // Tanggal
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${_formatTanggal(p.tanggalPinjam)} → ${_formatTanggal(p.tanggalKembali)}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${p.durasiHari} hari',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),

                  // List barang
                  ...p.barang.take(2).map(
                        (b) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF7ED),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.inventory_2_rounded,
                                  color: Color(0xFFF97316),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.namaBarang,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      b.namaRuangan,
                                      style: const TextStyle(
                                          fontSize: 11, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${b.jumlah} unit',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF97316),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                  // Kalau barang lebih dari 2
                  if (p.barang.length > 2)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '+${p.barang.length - 2} barang lainnya',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF97316),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  // Alasan tolak
                  if (p.status == 'ditolak' && p.alasanTolak != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              size: 14, color: Color(0xFFEF4444)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              p.alasanTolak!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Color(0xFFF97316),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada peminjaman',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajukan peminjaman barang\ndengan menekan tombol di bawah',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
