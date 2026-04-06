class User {
  final int id;
  final String name;
  final String email;
  final String? instansi;
  final String? role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.instansi,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // Paksa convert ke int, handle kalau String atau int
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      instansi: json['instansi'],
      role: json['role'],
    );
  }
}
