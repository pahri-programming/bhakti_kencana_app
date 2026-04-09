import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class ProfileService {
  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    return {
      'Content-Type':  'application/json',
      'Accept':        'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.profile),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': 'Gagal memuat profil'};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? instansi,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.profile),
        headers: await _headers(),
        body: jsonEncode({'name': name, 'instansi': instansi ?? ''}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        // Update nama di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', name);
        return {'success': true, 'data': data['data']};
      }
      String message = data['message'] ?? 'Gagal update profil';
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        message = errors.values.first[0];
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  Future<Map<String, dynamic>> updatePassword({
    required String passwordLama,
    required String passwordBaru,
    required String konfirmasi,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.profilePassword),
        headers: await _headers(),
        body: jsonEncode({
          'password_lama': passwordLama,
          'password_baru': passwordBaru,
          'konfirmasi':    konfirmasi,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      }
      String message = data['message'] ?? 'Gagal update password';
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        message = errors.values.first[0];
      }
      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }
}