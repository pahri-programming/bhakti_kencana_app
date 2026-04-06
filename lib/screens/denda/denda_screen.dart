import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/denda.dart';
import '../../services/denda_service.dart';
import 'denda_detail_screen.dart';

class DendaScreen extends StatefulWidget {
  const DendaScreen({super.key});

  @override
  State<DendaScreen> createState() => _DendaScreenState();
}

class _DendaScreenState extends State<DendaScreen> {
  final _service = DendaService();
  List<Denda> _list = [];
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

  IconData _statusIcon(String status) {
    switch (status) {
      case 'belum_bayar':
        return Icons.warning_amber_rounded;
      case 'menunggu_verifikasi':
        return Icons.access_time_rounded;
      case 'sudah_bayar':
        return Icons.check_circle_rounded;
      case 'dibebaskan':
        return Icons.do_not_disturb_on_rounded;
      default:
        return Icons.info_rounded;
    }
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

  // Total denda belum bayar
  double get _totalTagihan => _list
      .where((d) =>
          d.statusPembayaran == 'belum_bayar' ||
          d.statusPembayaran == 'menunggu_verifikasi')
      .fold(0, (sum, d) => sum + d.jumlahDenda);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        title: const Text(
          'Denda',
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
          : RefreshIndicator(
              color: const Color(0xFFF97316),
              onRefresh: _fetch,
              child: _list.isEmpty
                  ? _emptyState()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Summary tagihan
                        if (_totalTagihan > 0) _summaryCard(),
                        const SizedBox(height: 16),
                        ..._list.map((d) => _dendaCard(d)),
                      ],
                    ),
            ),
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Total Tagihan Aktif',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(
              locale: 'id',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(_totalTagihan),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_list.where((d) => d.statusPembayaran == 'belum_bayar' || d.statusPembayaran == 'menunggu_verifikasi').length} denda belum lunas',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dendaCard(Denda d) {
    final color = _statusColor(d.statusPembayaran);

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
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
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
                  Icon(_statusIcon(d.statusPembayaran), color: color, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      d.referensi['kode'] ?? '-',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      d.statusLabel,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Tipe denda
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: d.type == 'barang'
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              d.type == 'barang'
                                  ? Icons.inventory_2_rounded
                                  : Icons.meeting_room_rounded,
                              size: 12,
                              color: d.type == 'barang'
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              d.type == 'barang'
                                  ? 'Peminjaman Barang'
                                  : 'Booking Ruangan',
                              style: TextStyle(
                                fontSize: 11,
                                color: d.type == 'barang'
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFF16A34A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        d.jumlahDendaFormat,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Info tambahan
                  if (d.tindakanAdmin != null)
                    Row(
                      children: [
                        const Icon(Icons.admin_panel_settings_rounded,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            d.tindakanAdmin!,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  if (d.tanggalTindakan != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 13, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          _formatTanggal(d.tanggalTindakan),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],

                  // Tombol bayar kalau belum bayar
                  if (d.statusPembayaran == 'belum_bayar') ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Get.to(() => DendaDetailScreen(
                                type: d.type,
                                id: d.id,
                              ));
                          _fetch();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(Icons.upload_rounded, size: 16),
                        label: const Text(
                          'Upload Bukti Pembayaran',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
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
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF16A34A),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada denda',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kamu tidak memiliki tagihan denda',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
