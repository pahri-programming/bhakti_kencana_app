import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/peminjaman.dart';
import 'auth_service.dart';

class PeminjamanService {
  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET semua peminjaman user
  Future<List<Peminjaman>> getAll() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.peminjaman),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((p) => Peminjaman.fromJson(p))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // GET detail peminjaman
  Future<Peminjaman?> getDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.peminjamanDetail(id)),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Peminjaman.fromJson(data['data']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST buat peminjaman baru
  Future<Map<String, dynamic>> store({
    required String tanggalPinjam,
    required String tanggalKembali,
    required List<int> barangRuanganIds,
    required List<int> jumlahList,
    String? keterangan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.peminjaman),
        headers: await _headers(),
        body: jsonEncode({
          'tanggal_pinjam': tanggalPinjam,
          'tanggal_kembali': tanggalKembali,
          'barang_ruangan_id': barangRuanganIds,
          'jumlah': jumlahList,
          'keterangan': keterangan ?? '',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'data': Peminjaman.fromJson(data['data']),
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengajukan peminjaman',
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // DELETE batalkan peminjaman
  Future<Map<String, dynamic>> cancel(int id) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.peminjamanDetail(id)),
        headers: await _headers(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal membatalkan',
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }
}
