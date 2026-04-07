import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/denda.dart';
import '../../services/denda_service.dart';

class DendaDetailScreen extends StatefulWidget {
  final String type;
  final int id;
  const DendaDetailScreen({
    super.key,
    required this.type,
    required this.id,
  });

  @override
  State<DendaDetailScreen> createState() => _DendaDetailScreenState();
}

class _DendaDetailScreenState extends State<DendaDetailScreen> {
  final _service = DendaService();
  final _keteranganController = TextEditingController();

  Denda? _data;
  bool _loading = true;
  bool _uploading = false;
  File? _buktiFile;
  DateTime? _tanggalBayar;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final data = await _service.getDetail(widget.type, widget.id);
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Bukti Pembayaran',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final img = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 80,
                      );
                      Navigator.pop(context, img);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFED7AA)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.camera_alt_rounded,
                              color: Color(0xFFF97316), size: 32),
                          SizedBox(height: 8),
                          Text(
                            'Kamera',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF97316),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final img = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      Navigator.pop(context, img);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.photo_library_rounded,
                              color: Color(0xFF3B82F6), size: 32),
                          SizedBox(height: 8),
                          Text(
                            'Galeri',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (picked != null) {
      setState(() => _buktiFile = File(picked.path));
    }
  }

  Future<void> _pickTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
      locale: const Locale('id', 'ID'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFFF97316)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggalBayar = picked);
  }

  Future<void> _upload() async {
    if (_buktiFile == null) {
      Get.snackbar(
        'Peringatan',
        'Pilih foto bukti pembayaran terlebih dahulu',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (_tanggalBayar == null) {
      Get.snackbar(
        'Peringatan',
        'Pilih tanggal pembayaran terlebih dahulu',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => _uploading = true);

    final result = await _service.uploadBukti(
      type: widget.type,
      id: widget.id,
      file: _buktiFile!,
      tanggalBayar: DateFormat('yyyy-MM-dd').format(_tanggalBayar!),
      keterangan: _keteranganController.text.trim(),
    );

    setState(() => _uploading = false);

    if (result['success'] == true) {
      Get.snackbar(
        'Berhasil',
        'Bukti pembayaran berhasil diupload. Menunggu verifikasi admin.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      _fetch();
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
      return DateFormat('dd MMMM yyyy', 'id').format(dt);
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
          'Detail Denda',
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
                        _infoCard(),
                        const SizedBox(height: 16),
                        if (_data!.tindakanAdmin != null) _tindakanCard(),
                        // Upload form kalau belum bayar
                        if (_data!.statusPembayaran == 'belum_bayar') ...[
                          const SizedBox(height: 16),
                          _uploadCard(),
                        ],
                        // Bukti yang sudah diupload
                        if (_data!.buktiPembayaran != null &&
                            _data!.statusPembayaran != 'belum_bayar') ...[
                          const SizedBox(height: 16),
                          _buktiCard(),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _statusBanner() {
    final color = _statusColor(_data!.statusPembayaran);
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(_statusIcon(_data!.statusPembayaran),
                color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _data!.statusLabel,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _data!.jumlahDendaFormat,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  _data!.referensi['label'] ?? '-',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
            'Informasi Denda',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          _infoRow(
            Icons.receipt_long_rounded,
            'Referensi',
            _data!.referensi['kode'] ?? '-',
          ),
          const Divider(height: 20),
          _infoRow(
            _data!.type == 'barang'
                ? Icons.inventory_2_rounded
                : Icons.meeting_room_rounded,
            'Jenis',
            _data!.type == 'barang' ? 'Peminjaman Barang' : 'Booking Ruangan',
          ),
          if (_data!.kondisi != null) ...[
            const Divider(height: 20),
            _infoRow(
              Icons.info_outline_rounded,
              'Kondisi',
              _data!.kondisi!,
            ),
          ],
          const Divider(height: 20),
          _infoRow(
            Icons.calendar_today_rounded,
            'Tanggal Ditetapkan',
            _formatTanggal(_data!.tanggalTindakan),
          ),
          if (_data!.tanggalBayar != null) ...[
            const Divider(height: 20),
            _infoRow(
              Icons.payment_rounded,
              'Tanggal Bayar',
              _formatTanggal(_data!.tanggalBayar),
            ),
          ],
          if (_data!.keteranganDenda != null) ...[
            const Divider(height: 20),
            _infoRow(
              Icons.notes_rounded,
              'Keterangan Denda',
              _data!.keteranganDenda!,
            ),
          ],
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
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tindakanCard() {
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
          const Row(
            children: [
              Icon(Icons.admin_panel_settings_rounded,
                  color: Color(0xFFF97316), size: 18),
              SizedBox(width: 8),
              Text(
                'Tindakan Admin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _data!.tindakanAdmin!,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _uploadCard() {
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
          const Row(
            children: [
              Icon(Icons.upload_rounded, color: Color(0xFFF97316), size: 18),
              SizedBox(width: 8),
              Text(
                'Upload Bukti Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Upload screenshot bukti transfer bank atau e-wallet',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Preview foto
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _buktiFile != null
                      ? const Color(0xFFF97316)
                      : const Color(0xFFE5E7EB),
                  width: _buktiFile != null ? 2 : 1,
                ),
              ),
              child: _buktiFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.file(
                        _buktiFile!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_rounded,
                            color: Colors.grey, size: 40),
                        SizedBox(height: 8),
                        Text(
                          'Tap untuk pilih foto',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          'JPG, JPEG, PNG • Maks 2MB',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
            ),
          ),

          if (_buktiFile != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Ganti foto'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF97316),
                padding: EdgeInsets.zero,
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Tanggal bayar
          const Text(
            'Tanggal Pembayaran',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickTanggal,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _tanggalBayar != null
                      ? const Color(0xFFF97316)
                      : const Color(0xFFE5E7EB),
                  width: _tanggalBayar != null ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: _tanggalBayar != null
                        ? const Color(0xFFF97316)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _tanggalBayar != null
                        ? DateFormat('dd MMMM yyyy', 'id')
                            .format(_tanggalBayar!)
                        : 'Pilih tanggal pembayaran',
                    style: TextStyle(
                      fontSize: 13,
                      color: _tanggalBayar != null
                          ? const Color(0xFF1A1A1A)
                          : Colors.grey,
                      fontWeight: _tanggalBayar != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Keterangan
          const Text(
            'Keterangan (opsional)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _keteranganController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Contoh: Transfer BCA atas nama ...',
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
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

          const SizedBox(height: 20),

          // Tombol upload
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _uploading ? null : _upload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: _uploading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_rounded),
              label: Text(
                _uploading ? 'Mengupload...' : 'Upload Bukti',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buktiCard() {
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
          const Row(
            children: [
              Icon(Icons.receipt_rounded, color: Color(0xFFF97316), size: 18),
              SizedBox(width: 8),
              Text(
                'Bukti Pembayaran',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              _data!.buktiPembayaran!,
              fit: BoxFit.cover,
              width: double.infinity,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child:
                            CircularProgressIndicator(color: Color(0xFFF97316)),
                      ),
                    ),
              errorBuilder: (_, __, ___) => Container(
                height: 100,
                color: const Color(0xFFF3F4F6),
                child: const Center(
                  child: Icon(Icons.broken_image_rounded,
                      color: Colors.grey, size: 36),
                ),
              ),
            ),
          ),
          if (_data!.keteranganPembayaran != null) ...[
            const SizedBox(height: 10),
            Text(
              _data!.keteranganPembayaran!,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ],
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
          Text('Data tidak ditemukan', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
