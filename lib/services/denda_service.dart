import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/denda.dart';
import 'auth_service.dart';

class DendaService {
  Future<Map<String, String>> _headers() async {
    final token = await AuthService().getToken();
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET semua denda user
  Future<List<Denda>> getAll() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.denda),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List).map((d) => Denda.fromJson(d)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // GET detail denda
  Future<Denda?> getDetail(String type, int id) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.dendaDetail(type, id)),
        headers: await _headers(),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Denda.fromJson(data['data']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // POST upload bukti pembayaran
  Future<Map<String, dynamic>> uploadBukti({
    required String type,
    required int id,
    required File file,
    required String tanggalBayar,
    String? keterangan,
  }) async {
    try {
      final token = await AuthService().getToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.uploadBukti(type, id)),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(await http.MultipartFile.fromPath(
        'bukti_pembayaran',
        file.path,
      ));

      request.fields['tanggal_bayar'] = tanggalBayar;
      request.fields['keterangan_pembayaran'] = keterangan ?? '';

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': Denda.fromJson(data['data'])};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Gagal upload bukti',
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi gagal: $e'};
    }
  }
}
