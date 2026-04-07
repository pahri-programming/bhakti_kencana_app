class ApiConfig {
  static const String baseUrl = 'http://10.227.124.123:8000/api';

  // Auth
  static const String login    = '$baseUrl/auth/login';
  static const String logout   = '$baseUrl/auth/logout';
  static const String me       = '$baseUrl/auth/me';
  static const String register = '$baseUrl/auth/register';

  // Barang
  static const String barang   = '$baseUrl/barang';

  // Peminjaman
  static const String peminjaman = '$baseUrl/peminjaman';

  // Booking
  static const String booking         = '$baseUrl/booking';
  static const String ruanganTersedia = '$baseUrl/booking/ruangan-tersedia';

  // Denda
  static const String denda = '$baseUrl/denda';

  // Helper — url dinamis
  static String barangDetail(int id)             => '$baseUrl/barang/$id';
  static String peminjamanDetail(int id)         => '$baseUrl/peminjaman/$id';
  static String bookingDetail(int id)            => '$baseUrl/booking/$id';
  static String dendaDetail(String type, int id) => '$baseUrl/denda/$type/$id';
  static String uploadBukti(String type, int id) => '$baseUrl/denda/$type/$id/upload-bukti';
}