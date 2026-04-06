import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../screens/home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _instansiController = TextEditingController();
  final _passwordController = TextEditingController();
  final _konfirmasiController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureKonfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _instansiController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final instansi = _instansiController.text.trim();
    final password = _passwordController.text.trim();
    final konfirmasi = _konfirmasiController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Nama, email, dan password harus diisi',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (password != konfirmasi) {
      Get.snackbar(
        'Peringatan',
        'Password dan konfirmasi password tidak sama',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (password.length < 8) {
      Get.snackbar(
        'Peringatan',
        'Password minimal 8 karakter',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
      instansi: instansi,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      Get.offAll(() => const HomeScreen());
    } else {
      Get.snackbar(
        'Registrasi Gagal',
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFD000), Color(0xFFF97316), Color(0xFFEA580C)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Logo
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/ubk2.png',
                        width: 80,
                        height: 80,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.school,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Universitas Bhakti Kencana',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Bergabunglah dan nikmati kemudahan booking',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Card register
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Daftar Akun Baru',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Isi data diri kamu untuk membuat akun',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 24),

                        // Nama
                        _buildLabel('Nama Lengkap'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _nameController,
                          hint: 'Masukkan nama lengkap',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),

                        // Email
                        _buildLabel('Alamat Email'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _emailController,
                          hint: 'nama@email.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Instansi
                        _buildLabel('Instansi / Fakultas'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _instansiController,
                          hint: 'Contoh: Fakultas Farmasi, PT. ABC',
                          icon: Icons.business_outlined,
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _buildLabel('Password'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _passwordController,
                          hint: 'Minimal 8 karakter',
                          icon: Icons.lock_outline,
                          obscure: _obscurePass,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePass
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Konfirmasi password
                        _buildLabel('Konfirmasi Password'),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _konfirmasiController,
                          hint: 'Ulangi password',
                          icon: Icons.lock_outline,
                          obscure: _obscureKonfirm,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureKonfirm
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => _obscureKonfirm = !_obscureKonfirm),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Tombol daftar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF97316),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Daftar Sekarang',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Link ke login
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Sudah punya akun? ',
                                style: TextStyle(color: Colors.grey),
                              ),
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: const Text(
                                  'Masuk di sini',
                                  style: TextStyle(
                                    color: Color(0xFFF97316),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
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
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
      ),
    );
  }
}
