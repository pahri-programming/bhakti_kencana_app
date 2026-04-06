class Booking {
  final int id;
  final String kode;
  final String status;
  final String? keterangan;
  final String tanggal;
  final String waktuMulai;
  final String waktuSelesai;
  final String createdAt;
  final Map<String, dynamic> ruangan;

  Booking({
    required this.id,
    required this.kode,
    required this.status,
    this.keterangan,
    required this.tanggal,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.createdAt,
    required this.ruangan,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: int.tryParse(json['id'].toString()) ?? 0,
      kode: json['kode'] ?? '-',
      status: json['status'] ?? '-',
      keterangan: json['keterangan'],
      tanggal: json['tanggal'] ?? '',
      waktuMulai: json['waktu_mulai'] ?? '',
      waktuSelesai: json['waktu_selesai'] ?? '',
      createdAt: json['created_at'] ?? '',
      ruangan: json['ruangan'] != null
          ? Map<String, dynamic>.from(json['ruangan'])
          : {},
    );
  }
}
