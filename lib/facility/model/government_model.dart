class GovernmentModel {
  final String id;
  final String name;
  final String addr;
  final double? lat;
  final double? lng;
  final String type;  // 구청 / 경찰서 / 소방서 / 보건소 / 주민센터 등
  final String tel;
  final String? homepage;
  final String? operatingHours; // 운영시간 (예: 평일 09:00~18:00, 24시간 등)

  const GovernmentModel({
    required this.id,
    required this.name,
    required this.addr,
    this.lat,
    this.lng,
    required this.type,
    required this.tel,
    this.homepage,
    this.operatingHours,
  });

  // 시설 유형별 기본 운영시간 (데이터에 명시 없을 때 fallback)
  String get displayOperatingHours {
    final v = operatingHours?.trim();
    if (v != null && v.isNotEmpty) return v;
    switch (type) {
      case '경찰서':
      case '소방서':
        return '24시간';
      case '구청':
      case '주민센터':
      case '보건소':
      case '세무서':
      case '행정기관':
      case '교육기관':
      case '복지기관':
      case '우체국':
        return '평일 09:00~18:00';
      default:
        return '';
    }
  }

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
      operatingHours: data['operatingHours']?.toString(),
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
      operatingHours: data['operatingHours']?.toString(),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String && v.trim().isNotEmpty) return double.tryParse(v.trim());
    return null;
  }
}
