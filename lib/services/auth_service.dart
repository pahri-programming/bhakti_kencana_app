import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  // Simpan token ke SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Ambil token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Hapus token (logout)
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }

  // LOGIN
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['data']['access_token'];
        final user = data['data']['user'];

        await saveToken(token);

        // Simpan data user ke prefs
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', user['name']);
        await prefs.setString('user_email', user['email']);
        await prefs.setString('user_role', user['role'] ?? 'user');

        return {'success': true, 'user': User.fromJson(user)};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Login gagal',
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // REGISTER
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? instansi,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'instansi': instansi ?? '',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        final token = data['data']['access_token'];
        final user = data['data']['user'];

        await saveToken(token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_name', user['name']);
        await prefs.setString('user_email', user['email']);

        return {'success': true, 'user': User.fromJson(user)};
      }

      // Ambil pesan error validasi kalau ada
      String message = data['message'] ?? 'Registrasi gagal';
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        message = errors.values.first[0];
      }

      return {'success': false, 'message': message};
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      final token = await getToken();
      if (token != null) {
        await http.post(
          Uri.parse(ApiConfig.logout),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      }
    } catch (_) {}
    await removeToken();
  }
}
