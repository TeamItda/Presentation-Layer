class GovernmentModel {
  final String id;
  final String name;
  final String addr;
  final double? lat;
  final double? lng;
  final String type;  // 구청 / 경찰서 / 소방서 / 보건소 / 주민센터 등
  final String tel;
  final String? homepage;

  const GovernmentModel({
    required this.id,
    required this.name,
    required this.addr,
    this.lat,
    this.lng,
    required this.type,
    required this.tel,
    this.homepage,
  });

  // Firestore 문서 파싱
  factory GovernmentModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return GovernmentModel(
      id: docId,
      name: data['name']?.toString() ?? '',
      addr: data['addr']?.toString() ?? data['address']?.toString() ?? '',
      lat: _toDouble(data['lat']),
      lng: _toDouble(data['lng']),
      type: data['type']?.toString() ?? '',
      tel: data['tel']?.toString() ?? data['phone']?.toString() ?? '',
      homepage: data['homepage']?.toString(),
    );
  }

  factory GovernmentModel.fromLocal(Map<String, dynamic> data) {
    return GovernmentModel(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      addr: data['addr']?.toString() ?? '',
      lat: _toDouble(data['lat']),
      lng: _toDouble(data['lng']),
      type: data['type']?.toString() ?? '',
      tel: data['tel']?.toString() ?? '',
      homepage: data['homepage']?.toString(),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String && v.trim().isNotEmpty) return double.tryParse(v.trim());
    return null;
  }
}
