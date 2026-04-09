import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = ProfileService();

  Map<String, dynamic>? _profile;
  bool _loading = true;

  final _nameController = TextEditingController();
  final _instansiController = TextEditingController();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  bool _editMode = false;
  bool _savingProfile = false;
  bool _savingPass = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureKonfirm = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instansiController.dispose();
    _oldPassController.dispose();
    _newPassController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    final result = await _service.getProfile();
    if (result['success'] == true) {
      final data = result['data'];
      setState(() {
        _profile = data;
        _nameController.text = data['name'] ?? '';
        _instansiController.text = data['instansi'] ?? '';
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar('Peringatan', 'Nama tidak boleh kosong',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }

    setState(() => _savingProfile = true);
    final result = await _service.updateProfile(
      name: _nameController.text.trim(),
      instansi: _instansiController.text.trim(),
    );
    setState(() => _savingProfile = false);

    if (result['success'] == true) {
      setState(() {
        _profile!['name'] = _nameController.text.trim();
        _profile!['instansi'] = _instansiController.text.trim();
        _editMode = false;
      });
      Get.snackbar('Berhasil', 'Profil berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    } else {
      Get.snackbar('Gagal', result['message'] ?? 'Terjadi kesalahan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> _savePassword() async {
    if (_oldPassController.text.isEmpty ||
        _newPassController.text.isEmpty ||
        _konfirmasiController.text.isEmpty) {
      Get.snackbar('Peringatan', 'Semua field password harus diisi',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }

    if (_newPassController.text != _konfirmasiController.text) {
      Get.snackbar('Peringatan', 'Password baru dan konfirmasi tidak cocok',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }

    setState(() => _savingPass = true);
    final result = await _service.updatePassword(
      passwordLama: _oldPassController.text,
      passwordBaru: _newPassController.text,
      konfirmasi: _konfirmasiController.text,
    );
    setState(() => _savingPass = false);

    if (result['success'] == true) {
      _oldPassController.clear();
      _newPassController.clear();
      _konfirmasiController.clear();
      Get.snackbar('Berhasil', 'Password berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    } else {
      Get.snackbar('Gagal', result['message'] ?? 'Terjadi kesalahan',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    }
  }

  Future<void> _logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService().logout();
      Get.offAll(() => const LoginScreen());
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
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          if (!_loading)
            IconButton(
              icon: Icon(_editMode ? Icons.close_rounded : Icons.edit_rounded),
              onPressed: () => setState(() => _editMode = !_editMode),
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFF97316)))
          : RefreshIndicator(
              color: const Color(0xFFF97316),
              onRefresh: _fetch,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _headerCard(),
                    const SizedBox(height: 16),
                    _statsCard(),
                    const SizedBox(height: 16),
                    _editMode ? _editProfileCard() : _infoCard(),
                    const SizedBox(height: 16),
                    _passwordCard(),
                    const SizedBox(height: 16),
                    _logoutButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEA580C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(36),
            ),
            child: Center(
              child: Text(
                (_profile?['name'] ?? 'U').substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF97316),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _profile?['name'] ?? '-',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _profile?['email'] ?? '-',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _profile?['role'] == 'admin' ? 'Admin' : 'User',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsCard() {
    final stats = _profile?['stats'] ?? {};
    return Container(
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
            'Statistik',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statItem(
                Icons.inventory_2_rounded,
                '${stats['total_peminjaman_barang'] ?? 0}',
                'Peminjaman',
                const Color(0xFF3B82F6),
              ),
              _statItem(
                Icons.meeting_room_rounded,
                '${stats['total_booking_ruangan'] ?? 0}',
                'Booking',
                const Color(0xFFF97316),
              ),
              _statItem(
                Icons.assignment_return_rounded,
                '${stats['total_kembali'] ?? 0}',
                'Dikembalikan',
                const Color(0xFF16A34A),
              ),
              _statItem(
                Icons.pending_rounded,
                '${stats['belum_kembali'] ?? 0}',
                'Belum Kembali',
                const Color(0xFFEF4444),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
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
            'Informasi Akun',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.person_rounded, 'Nama', _profile?['name'] ?? '-'),
          const Divider(height: 20),
          _infoRow(Icons.email_rounded, 'Email', _profile?['email'] ?? '-'),
          const Divider(height: 20),
          _infoRow(
            Icons.business_rounded,
            'Instansi',
            _profile?['instansi'] ?? '-',
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

  Widget _editProfileCard() {
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
            'Edit Profil',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          _buildLabel('Nama Lengkap'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nameController,
            hint: 'Masukkan nama lengkap',
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 16),
          _buildLabel('Instansi / Fakultas'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _instansiController,
            hint: 'Masukkan instansi',
            icon: Icons.business_rounded,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _savingProfile ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _savingProfile
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan Perubahan',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordCard() {
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
              Icon(Icons.lock_rounded, color: Color(0xFFF97316), size: 18),
              SizedBox(width: 8),
              Text(
                'Ganti Password',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLabel('Password Lama'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _oldPassController,
            hint: 'Masukkan password lama',
            icon: Icons.lock_outline_rounded,
            obscure: _obscureOld,
            suffixIcon: IconButton(
              icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureOld = !_obscureOld),
            ),
          ),
          const SizedBox(height: 12),
          _buildLabel('Password Baru'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _newPassController,
            hint: 'Minimal 8 karakter',
            icon: Icons.lock_rounded,
            obscure: _obscureNew,
            suffixIcon: IconButton(
              icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureNew = !_obscureNew),
            ),
          ),
          const SizedBox(height: 12),
          _buildLabel('Konfirmasi Password Baru'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _konfirmasiController,
            hint: 'Ulangi password baru',
            icon: Icons.lock_rounded,
            obscure: _obscureKonfirm,
            suffixIcon: IconButton(
              icon: Icon(
                  _obscureKonfirm ? Icons.visibility_off : Icons.visibility),
              onPressed: () =>
                  setState(() => _obscureKonfirm = !_obscureKonfirm),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _savingPass ? null : _savePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _savingPass
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Ganti Password',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFEF2F2),
          foregroundColor: const Color(0xFFEF4444),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFFFECACA)),
          ),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          'Keluar dari Akun',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
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
          borderSide: const BorderSide(color: Color(0xFFF97316), width: 2),
        ),
      ),
    );
  }
}
