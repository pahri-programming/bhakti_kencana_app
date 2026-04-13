import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';
import '../auth/login_screen.dart';
import '../peminjaman/peminjaman_screen.dart';
import '../booking/booking_screen.dart';
import '../denda/denda_screen.dart';
import '../profile/profile_screen.dart';
import '../riwayat/riwayat_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  List _ruangan = [];
  List _barang = [];
  bool _loadRuangan = true;
  bool _loadBarang = true;
  int _selectedNav = 0;

  static const _orange = Color(0xFFF97316);
  static const _orangeDark = Color(0xFFEA580C);
  static const _orangeLight = Color(0xFFFFF7ED);
  static const _orangeBorder = Color(0xFFFED7AA);

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchRuangan();
    _fetchBarang();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userName = prefs.getString('user_name') ?? 'User');
  }

  Future<void> _fetchRuangan() async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse(ApiConfig.ruanganTersedia),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _ruangan = data['data'] ?? [];
          _loadRuangan = false;
        });
      } else {
        setState(() => _loadRuangan = false);
      }
    } catch (e) {
      debugPrint('ERROR RUANGAN: $e');
      setState(() => _loadRuangan = false);
    }
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
          _barang = (data['data'] ?? []).take(5).toList();
          _loadBarang = false;
        });
      } else {
        setState(() => _loadBarang = false);
      }
    } catch (e) {
      debugPrint('ERROR BARANG: $e');
      setState(() => _loadBarang = false);
    }
  }

  Future<void> _logout() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Keluar',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child:
                const Text('Keluar', style: TextStyle(color: Colors.white)),
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
      body: RefreshIndicator(
        color: _orange,
        onRefresh: () async {
          await _fetchRuangan();
          await _fetchBarang();
        },
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: _orange,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        top: -40,
                        right: -40,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -20,
                        left: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top row: logo + nama + logout
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              Colors.black.withOpacity(0.15),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: Image.asset(
                                      'assets/images/ubk2.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.school,
                                        color: _orange,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Bhakti Kencana',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        Text(
                                          'Universitas Bhakti Kencana',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _logout,
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.logout_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              // Welcome text
                              Text(
                                'Selamat datang, $_userName! 👋',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Kelola booking ruangan & peminjaman fasilitas',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Menu Cepat ──────────────────────────
                    _sectionLabel('Menu Cepat'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _menuCard(
                          Icons.meeting_room_rounded,
                          'Booking\nRuangan',
                          _orange,
                          onTap: () {
                            setState(() => _selectedNav = 2);
                            Get.to(() => const BookingScreen());
                          },
                        ),
                        const SizedBox(width: 10),
                        _menuCard(
                          Icons.inventory_2_rounded,
                          'Peminjaman\nBarang',
                          const Color(0xFF3B82F6),
                          onTap: () {
                            setState(() => _selectedNav = 1);
                            Get.to(() => const PeminjamanScreen());
                          },
                        ),
                        const SizedBox(width: 10),
                        _menuCard(
                          Icons.receipt_long_rounded,
                          'Riwayat\nTransaksi',
                          const Color(0xFF10B981),
                          onTap: () => Get.to(() => const RiwayatScreen()),
                        ),
                        const SizedBox(width: 10),
                        _menuCard(
                          Icons.warning_amber_rounded,
                          'Denda\nTransaksi',
                          const Color(0xFFEF4444),
                          onTap: () => Get.to(() => const DendaScreen()),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ── Ruangan Tersedia ─────────────────────
                    _sectionHeader(
                      'Ruangan Tersedia',
                      '${_ruangan.length} Ruangan',
                      _orange,
                    ),
                    const SizedBox(height: 12),
                    _loadRuangan
                        ? _loadingWidget()
                        : _ruangan.isEmpty
                            ? _emptyCard('Tidak ada ruangan tersedia')
                            : SizedBox(
                                height: 150,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _ruangan.length,
                                  itemBuilder: (_, i) =>
                                      _ruanganCard(_ruangan[i]),
                                ),
                              ),

                    const SizedBox(height: 28),

                    // ── Daftar Barang ────────────────────────
                    _sectionHeader(
                      'Daftar Barang',
                      '${_barang.length} Barang',
                      const Color(0xFF3B82F6),
                    ),
                    const SizedBox(height: 12),
                    _loadBarang
                        ? _loadingWidget()
                        : _barang.isEmpty
                            ? _emptyCard('Tidak ada barang tersedia')
                            : Column(
                                children: _barang
                                    .map((b) => _barangCard(b))
                                    .toList(),
                              ),

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Nav ────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _selectedNav,
            onTap: (i) {
              setState(() => _selectedNav = i);
              if (i == 1) Get.to(() => const PeminjamanScreen());
              if (i == 2) Get.to(() => const BookingScreen());
              if (i == 3) Get.to(() => const ProfileScreen());
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: _orange,
            unselectedItemColor: const Color(0xFF9CA3AF),
            backgroundColor: Colors.white,
            selectedFontSize: 11,
            unselectedFontSize: 11,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2_rounded),
                label: 'Peminjaman',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.meeting_room_outlined),
                activeIcon: Icon(Icons.meeting_room_rounded),
                label: 'Booking',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── WIDGETS ──────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
        letterSpacing: 0.1,
      ),
    );
  }

  Widget _sectionHeader(String title, String badge, Color badgeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: badgeColor.withOpacity(0.3)),
          ),
          child: Text(
            badge,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuCard(IconData icon, String label, Color color,
      {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ruanganCard(Map ruangan) {
    return GestureDetector(
      onTap: () => Get.to(() => const BookingScreen()),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.meeting_room_rounded,
                    color: _orange,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ruangan['nama_ruangan'] ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (ruangan['kapasitas'] != null)
              _ruanganInfo(
                  Icons.people_outline, '${ruangan['kapasitas']} Orang'),
            if (ruangan['lokasi'] != null) ...[
              const SizedBox(height: 4),
              _ruanganInfo(
                  Icons.location_on_outlined, ruangan['lokasi'].toString()),
            ],
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 12, color: Color(0xFF16A34A)),
                  SizedBox(width: 4),
                  Text(
                    'Tersedia',
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ruanganInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _barangCard(Map barang) {
    final tersediaDi = barang['tersedia_di'] as List? ?? [];
    final totalQty = tersediaDi.fold<int>(
        0, (sum, item) => sum + (item['qty'] as int? ?? 0));
    final namaRuangan = tersediaDi.isNotEmpty
        ? tersediaDi[0]['nama_ruangan'] ?? '-'
        : '-';

    return GestureDetector(
      onTap: () => Get.to(() => const PeminjamanScreen()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.inventory_2_rounded,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barang['nama'] ?? '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    barang['kategori'] ?? '',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 11, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 2),
                      Text(
                        namaRuangan,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$totalQty Unit',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Tersedia',
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: CircularProgressIndicator(color: _orange),
      ),
    );
  }

  Widget _emptyCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, color: Color(0xFFD1D5DB), size: 40),
          const SizedBox(height: 8),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
        ],
      ),
    );
  }
}