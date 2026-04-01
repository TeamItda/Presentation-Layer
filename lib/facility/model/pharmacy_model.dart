class PharmacyModel {
  final String id;
  final String name;
  final String addr;
  final String tel;
  final double lat;
  final double lng;

  PharmacyModel({
    required this.id,
    required this.name,
    required this.addr,
    required this.tel,
    required this.lat,
    required this.lng,
  });

  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    return PharmacyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      addr: json['addr'] ?? '',
      tel: json['tel'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
    );
  }
}
