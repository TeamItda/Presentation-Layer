class ChildcareModel {
  final String id;
  final String name;
  final String addr;
  final double? lat;
  final double? lng;
  final String typeCode; // 1:국공립 2:사회복지법인 3:법인단체 4:민간 5:가정 6:부모협동 7:직장
  final int capacity;    // 정원
  final int currentCount; // 현원
  final bool hasCctv;
  final int staffCount;  // 교직원 수
  final String tel;
  final String? homepage;

  const ChildcareModel({
    required this.id,
    required this.name,
    required this.addr,
    this.lat,
    this.lng,
    required this.typeCode,
    required this.capacity,
    required this.currentCount,
    required this.hasCctv,
    required this.staffCount,
    required this.tel,
    this.homepage,
  });

  String get typeLabel {
    switch (typeCode) {
      case '1': return '국공립';
      case '2': return '사회복지법인';
      case '3': return '법인·단체';
      case '4': return '민간';
      case '5': return '가정';
      case '6': return '부모협동';
      case '7': return '직장';
      default:  return typeCode.isNotEmpty ? typeCode : '어린이집';
    }
  }

  double get occupancyRate => capacity > 0 ? (currentCount / capacity).clamp(0.0, 1.0) : 0.0;

  // 사회보장정보원 어린이집 API 응답 파싱
  factory ChildcareModel.fromApi(Map<String, dynamic> json) {
    final cctvCount = _toInt(json['CCTVINSTLCNT'] ?? json['cctvinstlcnt']);
    return ChildcareModel(
      id: (json['CCRNO'] ?? json['ccrno'] ?? '').toString(),
      name: (json['CCRNAME'] ?? json['ccrname'] ?? '').toString(),
      addr: (json['RDNMADR'] ?? json['rdnmadr'] ?? json['LOTADDR'] ?? '').toString(),
      lat: _toDouble(json['LA'] ?? json['la']),
      lng: _toDouble(json['LO'] ?? json['lo']),
      typeCode: (json['CRTYPE'] ?? json['crtype'] ?? '').toString(),
      capacity: _toInt(json['CRCAPAT'] ?? json['crcapat']),
      currentCount: _toInt(json['CURRINST'] ?? json['currinst']),
      hasCctv: cctvCount > 0,
      staffCount: _toInt(json['TCHER_CNT'] ?? json['tcher_cnt'] ?? json['FDRCAR_CNT'] ?? json['fdrcar_cnt']),
      tel: (json['CCRTEL'] ?? json['ccrtel'] ?? '').toString(),
      homepage: (json['HMPG'] ?? json['hmpg'])?.toString(),
    );
  }

  // 교육부 유치원알리미 API 응답 파싱
  factory ChildcareModel.fromKindergartenApi(Map<String, dynamic> json) {
    return ChildcareModel(
      id: 'kg_${(json['KINDERCD'] ?? json['kindercd'] ?? '').toString()}',
      name: (json['KINDERNM'] ?? json['kindernm'] ?? '').toString(),
      addr: (json['ADDR'] ?? json['addr'] ?? '').toString(),
      lat: _toDouble(json['LA'] ?? json['la']),
      lng: _toDouble(json['LO'] ?? json['lo']),
      typeCode: (json['ESTABLISH'] ?? json['establish'] ?? '4').toString(),
      capacity: _toInt(json['PPCNT'] ?? json['ppcnt']),
      currentCount: _toInt(json['CLSCNT'] ?? json['clscnt']),
      hasCctv: (json['CCTV'] ?? json['cctv'] ?? 'N').toString().toUpperCase() == 'Y',
      staffCount: _toInt(json['TCHCNT'] ?? json['tchcnt']),
      tel: (json['TELNO'] ?? json['telno'] ?? '').toString(),
      homepage: (json['HPADDR'] ?? json['hpaddr'])?.toString(),
    );
  }

  factory ChildcareModel.fromLocal(Map<String, dynamic> data) {
    return ChildcareModel(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      addr: data['addr']?.toString() ?? '',
      lat: _toDouble(data['lat']),
      lng: _toDouble(data['lng']),
      typeCode: data['typeCode']?.toString() ?? '4',
      capacity: _toInt(data['capacity']),
      currentCount: _toInt(data['currentCount']),
      hasCctv: data['hasCctv'] as bool? ?? false,
      staffCount: _toInt(data['staffCount']),
      tel: data['tel']?.toString() ?? '',
      homepage: data['homepage']?.toString(),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  static double? _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String && v.trim().isNotEmpty) return double.tryParse(v.trim());
    return null;
  }
}
