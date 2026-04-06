class DetailPeminjaman {
  final int id;
  final int barangRuanganId;
  final String namaBarang;
  final String namaRuangan;
  final int jumlah;

  DetailPeminjaman({
    required this.id,
    required this.barangRuanganId,
    required this.namaBarang,
    required this.namaRuangan,
    required this.jumlah,
  });

  factory DetailPeminjaman.fromJson(Map<String, dynamic> json) {
    return DetailPeminjaman(
      id: int.tryParse(json['detail_id'].toString()) ?? 0,
      barangRuanganId: int.tryParse(json['barang_ruangan_id'].toString()) ?? 0,
      namaBarang: json['nama_barang'] ?? '-',
      namaRuangan: json['nama_ruangan'] ?? '-',
      jumlah: int.tryParse(json['jumlah'].toString()) ?? 0,
    );
  }
}

class Peminjaman {
  final int id;
  final String kode;
  final String status;
  final String? alasanTolak;
  final String tanggalPinjam;
  final String tanggalKembali;
  final int durasiHari;
  final String? keterangan;
  final String createdAt;
  final List<DetailPeminjaman> barang;

  Peminjaman({
    required this.id,
    required this.kode,
    required this.status,
    this.alasanTolak,
    required this.tanggalPinjam,
    required this.tanggalKembali,
    required this.durasiHari,
    this.keterangan,
    required this.createdAt,
    required this.barang,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      id: int.tryParse(json['id'].toString()) ?? 0,
      kode: json['kode'] ?? '-',
      status: json['status'] ?? '-',
      alasanTolak: json['alasan_tolak'],
      tanggalPinjam: json['tanggal_pinjam'] ?? '',
      tanggalKembali: json['tanggal_kembali'] ?? '',
      durasiHari: int.tryParse(json['durasi_hari'].toString()) ?? 0,
      keterangan: json['keterangan'],
      createdAt: json['created_at'] ?? '',
      barang: (json['barang'] as List? ?? [])
          .map((b) => DetailPeminjaman.fromJson(b))
          .toList(),
    );
  }
}
