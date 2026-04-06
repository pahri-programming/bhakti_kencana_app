import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/booking.dart';
import 'auth_service.dart';

class BookingService {
  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET semua booking user
  Future<List<Booking>> getAll() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.booking),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List).map((b) => Booking.fromJson(b)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // GET detail booking
  Future<Booking?> getDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.bookingDetail(id)),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Booking.fromJson(data['data']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // GET ruangan tersedia
  Future<List<Map<String, dynamic>>> getRuangan() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.ruanganTersedia),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // POST buat booking baru
  Future<Map<String, dynamic>> store({
    required int ruangId,
    required String tanggal,
    required String waktuMulai,
    required String waktuSelesai,
    String? keterangan,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.booking),
        headers: await _headers(),
        body: jsonEncode({
          'ruang_id': ruangId,
          'tanggal': tanggal,
          'waktu_mulai': waktuMulai,
          'waktu_selesai': waktuSelesai,
          'keterangan': keterangan ?? '',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'data': Booking.fromJson(data['data']),
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal mengajukan booking',
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // DELETE batalkan booking
  Future<Map<String, dynamic>> cancel(int id) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConfig.bookingDetail(id)),
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
 