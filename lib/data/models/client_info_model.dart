/// Model untuk informasi client yang hanya digunakan sementara
/// Tidak disimpan ke database terpisah, hanya sebagai bagian dari invoice
class ClientInfo {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? company;

  ClientInfo({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.company,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'company': company,
  };

  factory ClientInfo.fromJson(Map<String, dynamic> json) => ClientInfo(
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    address: json['address'] ?? '',
    company: json['company'],
  );

  // Helper method untuk validasi
  bool get isValid {
    return name.isNotEmpty && 
           email.isNotEmpty && 
           phone.isNotEmpty && 
           address.isNotEmpty;
  }
}
