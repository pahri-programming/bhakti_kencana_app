import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class RiwayatService {
  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> getAll() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.riwayat),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'peminjaman': data['peminjaman'] ?? [],
          'booking': data['booking'] ?? [],
        };
      }
      return {'success': false, 'peminjaman': [], 'booking': []};
    } catch (_) {
      return {'success': false, 'peminjaman': [], 'booking': []};
    }
  }
}
