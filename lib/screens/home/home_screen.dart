import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';
import '../auth/login_screen.dart';
import '../peminjaman/peminjaman_screen.dart';
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
      body: RefreshIndicator(
        color: const Color(0xFFF97316),
        onRefresh: () async {
          await _fetchRuangan();
          await _fetchBarang();
        },
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFFF97316),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFF97316),
                        Color(0xFFEA580C),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              // Logo lebih besar & background putih bulat
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: Image.asset(
                                  'assets/images/ubk2.png',
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.school,
                                    color: Color(0xFFF97316),
                                    size: 36,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bhakti Kencana',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
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
                              IconButton(
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  color: Colors.white,
                                ),
                                onPressed: _logout,
                                tooltip: 'Keluar',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Selamat datang, $_userName 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            'Kelola booking ruangan dan peminjaman fasilitas',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Menu cepat ──────────────────────────
                    Row(
                      children: [
                        _menuCard(Icons.meeting_room_rounded,
                            'Booking\nRuangan', const Color(0xFFF97316)),
                        const SizedBox(width: 10),
                        _menuCard(Icons.inventory_2_rounded, 'Peminjaman\nBarang',
                            const Color(0xFF3B82F6)),
                        const SizedBox(width: 10),
                        _menuCard(Icons.receipt_long_rounded, 'Riwayat\nTransaksi',
                            const Color(0xFF10B981)),
                        const SizedBox(width: 10),
                        _menuCard(Icons.warning_amber_rounded, 'Denda\nTransaksi',
                            const Color(0xFFEF4444)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Ruangan Tersedia ─────────────────────
                    _sectionHeader(
                      'Ruangan Tersedia',
                      '${_ruangan.length} Ruangan',
                      Icons.meeting_room_rounded,
                    ),
                    const SizedBox(height: 12),
                    _loadRuangan
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                color: Color(0xFFF97316),
                              ),
                            ),
                          )
                        : _ruangan.isEmpty
                            ? _emptyCard('Tidak ada ruangan tersedia')
                            : SizedBox(
                                height: 140,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _ruangan.length,
                                  itemBuilder: (_, i) =>
                                      _ruanganCard(_ruangan[i]),
                                ),
                              ),

                    const SizedBox(height: 24),

                    // ── Daftar Barang ────────────────────────
                    _sectionHeader(
                      'Daftar Barang',
                      '${_barang.length} Barang',
                      Icons.inventory_2_rounded,
                    ),
                    const SizedBox(height: 12),
                    _loadBarang
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(
                                color: Color(0xFFF97316),
                              ),
                            ),
                          )
                        : _barang.isEmpty
                            ? _emptyCard('Tidak ada barang tersedia')
                            : Column(
                                children:
                                    _barang.map((b) => _barangCard(b)).toList(),
                              ),

                    const SizedBox(height: 80),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedNav,
          onTap: (i) {
            setState(() => _selectedNav = i);
            if (i == 1) Get.to(() => const PeminjamanScreen());
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFF97316),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
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
              label: 'profil',
            ),
          ],
        ),
      ),
    );
  }

  // ── WIDGETS ──────────────────────────────────────────────

  Widget _menuCard(IconData icon, String label, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFFF97316),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFED7AA)),
          ),
          child: Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFFF97316),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _ruanganCard(Map ruangan) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.meeting_room_rounded,
                  color: Color(0xFFF97316),
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
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (ruangan['kapasitas'] != null)
            Row(
              children: [
                const Icon(Icons.people_outline, size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${ruangan['kapasitas']} Orang',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          if (ruangan['lokasi'] != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 12, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    ruangan['lokasi'],
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
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
    );
  }

  Widget _barangCard(Map barang) {
    final tersediaDi = barang['tersedia_di'] as List? ?? [];
    final totalQty = tersediaDi.fold<int>(
      0,
      (sum, item) => sum + (item['qty'] as int? ?? 0),
    );
    final namaRuangan =
        tersediaDi.isNotEmpty ? tersediaDi[0]['nama_ruangan'] ?? '-' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Color(0xFFF97316),
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
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  barang['kategori'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 11, color: Colors.grey),
                    const SizedBox(width: 2),
                    Text(
                      namaRuangan,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                  fontSize: 13,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
    );
  }

  Widget _emptyCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_rounded, color: Colors.grey, size: 36),
          const SizedBox(height: 8),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
