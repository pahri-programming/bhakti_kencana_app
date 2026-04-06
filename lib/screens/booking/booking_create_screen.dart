import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../services/booking_service.dart';

class BookingCreateScreen extends StatefulWidget {
  const BookingCreateScreen({super.key});

  @override
  State<BookingCreateScreen> createState() => _BookingCreateScreenState();
}

class _BookingCreateScreenState extends State<BookingCreateScreen> {
  final _service = BookingService();
  final _keteranganController = TextEditingController();

  List<Map<String, dynamic>> _ruanganList = [];
  Map<String, dynamic>? _selectedRuangan;
  DateTime? _tanggal;
  TimeOfDay? _waktuMulai;
  TimeOfDay? _waktuSelesai;
  bool _isLoading = false;
  bool _loadRuangan = true;

  @override
  void initState() {
    super.initState();
    _fetchRuangan();
  }

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _fetchRuangan() async {
    final data = await _service.getRuangan();
    setState(() {
      _ruanganList = data;
      _loadRuangan = false;
    });
  }

  Future<void> _pickTanggal() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      locale: const Locale('id', 'ID'),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFF97316),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _tanggal = picked;
        _waktuMulai = null;
        _waktuSelesai = null;
      });
    }
  }

  Future<void> _pickWaktu({required bool isMulai}) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: isMulai ? now : (_waktuMulai ?? now),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFF97316),
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      // Validasi waktu sudah lewat untuk hari ini
      if (_tanggal != null) {
        final now = DateTime.now();
        final isToday = _tanggal!.year == now.year &&
            _tanggal!.month == now.month &&
            _tanggal!.day == now.day;

        if (isToday) {
          final pickedDt = DateTime(
            _tanggal!.year,
            _tanggal!.month,
            _tanggal!.day,
            picked.hour,
            picked.minute,
          );
          if (pickedDt.isBefore(now)) {
            Get.snackbar(
              'Peringatan',
              'Waktu sudah lewat, pilih waktu yang akan datang',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
            return;
          }
        }
      }

      // Validasi waktu selesai harus setelah waktu mulai
      if (!isMulai && _waktuMulai != null) {
        final mulaiMenit = _waktuMulai!.hour * 60 + _waktuMulai!.minute;
        final selesaiMenit = picked.hour * 60 + picked.minute;
        if (selesaiMenit <= mulaiMenit) {
          Get.snackbar(
            'Peringatan',
            'Waktu selesai harus lebih dari waktu mulai',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }
      }

      setState(() {
        if (isMulai) {
          _waktuMulai = picked;
          _waktuSelesai = null;
        } else {
          _waktuSelesai = picked;
        }
      });
    }
  }

  String _formatWaktu(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatTanggal(DateTime dt) =>
      DateFormat('dd MMM yyyy', 'id').format(dt);

  Future<void> _submit() async {
    if (_selectedRuangan == null) {
      Get.snackbar('Peringatan', 'Pilih ruangan terlebih dahulu',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }
    if (_tanggal == null) {
      Get.snackbar('Peringatan', 'Pilih tanggal terlebih dahulu',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }
    if (_waktuMulai == null || _waktuSelesai == null) {
      Get.snackbar('Peringatan', 'Pilih waktu mulai dan selesai',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }

    setState(() => _isLoading = true);

    final result = await _service.store(
      ruangId: int.tryParse(_selectedRuangan!['id'].toString()) ?? 0,
      tanggal: DateFormat('yyyy-MM-dd').format(_tanggal!),
      waktuMulai: _formatWaktu(_waktuMulai!),
      waktuSelesai: _formatWaktu(_waktuSelesai!),
      keterangan: _keteranganController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      Get.back(result: true);
      Get.snackbar(
        'Berhasil',
        'Booking berhasil diajukan, menunggu persetujuan admin',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF97316),
        foregroundColor: Colors.white,
        title: const Text(
          'Ajukan Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Pilih Ruangan ─────────────────────────────
            _sectionTitle('Pilih Ruangan'),
            const SizedBox(height: 12),
            _loadRuangan
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFF97316)))
                : _ruanganList.isEmpty
                    ? _emptyRuangan()
                    : Column(
                        children:
                            _ruanganList.map((r) => _ruanganOption(r)).toList(),
                      ),

            const SizedBox(height: 24),

            // ── Tanggal ───────────────────────────────────
            _sectionTitle('Tanggal Booking'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickTanggal,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _tanggal != null
                        ? const Color(0xFFF97316)
                        : const Color(0xFFE5E7EB),
                    width: _tanggal != null ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      color: _tanggal != null
                          ? const Color(0xFFF97316)
                          : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _tanggal != null
                          ? _formatTanggal(_tanggal!)
                          : 'Pilih tanggal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _tanggal != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: _tanggal != null
                            ? const Color(0xFF1A1A1A)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Waktu ─────────────────────────────────────
            _sectionTitle('Waktu Booking'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _waktuPicker(
                    label: 'Waktu Mulai',
                    value:
                        _waktuMulai != null ? _formatWaktu(_waktuMulai!) : null,
                    onTap: _tanggal == null
                        ? null
                        : () => _pickWaktu(isMulai: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _waktuPicker(
                    label: 'Waktu Selesai',
                    value: _waktuSelesai != null
                        ? _formatWaktu(_waktuSelesai!)
                        : null,
                    onTap: _waktuMulai == null
                        ? null
                        : () => _pickWaktu(isMulai: false),
                  ),
                ),
              ],
            ),

            // Durasi
            if (_waktuMulai != null && _waktuSelesai != null) ...[
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
                      'Durasi: ${(_waktuSelesai!.hour * 60 + _waktuSelesai!.minute) - (_waktuMulai!.hour * 60 + _waktuMulai!.minute)} menit',
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

            // ── Keterangan ────────────────────────────────
            _sectionTitle('Keterangan (opsional)'),
            const SizedBox(height: 12),
            TextField(
              controller: _keteranganController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tulis keperluan booking ruangan...',
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
                        'Ajukan Booking',
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

  Widget _ruanganOption(Map<String, dynamic> ruangan) {
    final isSelected = _selectedRuangan?['id'] == ruangan['id'];

    return GestureDetector(
      onTap: () => setState(() => _selectedRuangan = ruangan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFF97316) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFF97316)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.meeting_room_rounded,
                color: isSelected ? Colors.white : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ruangan['nama_ruangan'] ?? '-',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected
                          ? const Color(0xFFF97316)
                          : const Color(0xFF1A1A1A),
                    ),
                  ),
                  if (ruangan['lokasi'] != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          ruangan['lokasi'],
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  if (ruangan['kapasitas'] != null)
                    Row(
                      children: [
                        const Icon(Icons.people_outline,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${ruangan['kapasitas']} orang',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFFF97316), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _waktuPicker({
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
          border: Border.all(
            color: value != null
                ? const Color(0xFFF97316)
                : const Color(0xFFE5E7EB),
            width: value != null ? 2 : 1,
          ),
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
                  Icons.access_time_rounded,
                  size: 14,
                  color: value != null
                      ? const Color(0xFFF97316)
                      : (onTap == null ? Colors.grey[400] : Colors.grey),
                ),
                const SizedBox(width: 6),
                Text(
                  value ?? 'Pilih waktu',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        value != null ? FontWeight.w600 : FontWeight.normal,
                    color: value != null
                        ? const Color(0xFF1A1A1A)
                        : (onTap == null ? Colors.grey[400] : Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyRuangan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.meeting_room_outlined, color: Colors.grey, size: 36),
          SizedBox(height: 8),
          Text(
            'Tidak ada ruangan tersedia',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
