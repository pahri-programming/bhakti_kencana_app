class Denda {
  final int id;
  final String type; // 'barang' atau 'booking'
  final double jumlahDenda;
  final String jumlahDendaFormat;
  final String statusPembayaran;
  final String statusLabel;
  final String? tindakanAdmin;
  final String? keteranganDenda;
  final String? tanggalTindakan;
  final String? tanggalBayar;
  final String? buktiPembayaran;
  final String? keteranganPembayaran;
  final String? kondisi;
  final String createdAt;
  final Map<String, dynamic> referensi;

  Denda({
    required this.id,
    required this.type,
    required this.jumlahDenda,
    required this.jumlahDendaFormat,
    required this.statusPembayaran,
    required this.statusLabel,
    this.tindakanAdmin,
    this.keteranganDenda,
    this.tanggalTindakan,
    this.tanggalBayar,
    this.buktiPembayaran,
    this.keteranganPembayaran,
    this.kondisi,
    required this.createdAt,
    required this.referensi,
  });

  factory Denda.fromJson(Map<String, dynamic> json) {
    return Denda(
      id: int.tryParse(json['id'].toString()) ?? 0,
      type: json['type'] ?? 'barang',
      jumlahDenda: double.tryParse(json['jumlah_denda'].toString()) ?? 0,
      jumlahDendaFormat: json['jumlah_denda_format'] ?? 'Rp 0',
      statusPembayaran: json['status_pembayaran'] ?? '-',
      statusLabel: json['status_label'] ?? '-',
      tindakanAdmin: json['tindakan_admin'],
      keteranganDenda: json['keterangan_denda'],
      tanggalTindakan: json['tanggal_tindakan'],
      tanggalBayar: json['tanggal_bayar'],
      buktiPembayaran: json['bukti_pembayaran'],
      keteranganPembayaran: json['keterangan_pembayaran'],
      kondisi: json['kondisi_barang'] ?? json['kondisi_ruangan'],
      createdAt: json['created_at'] ?? '',
      referensi: Map<String, dynamic>.from(json['referensi'] ?? {}),
    );
  }
}
