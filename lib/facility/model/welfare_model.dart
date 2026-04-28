class WelfareModel {
  final String id;
  final String name;
  final String addr;
  final double? lat;
  final double? lng;
  final String type;     // 노인요양시설 / 주야간보호 / 방문요양 등
  final int capacity;    // 정원
  final int staffCount;  // 직원 수
  final String tel;
  final String? homepage;

  const WelfareModel({
    required this.id,
    required this.name,
    required this.addr,
    this.lat,
    this.lng,
    required this.type,
    required this.capacity,
    required this.staffCount,
    required this.tel,
    this.homepage,
  });

  // NHIS 장기요양기관 API 응답 파싱
  factory WelfareModel.fromApi(Map<String, dynamic> json) {
    return WelfareModel(
      id: (json['FACLT_CD'] ?? json['faclt_cd'] ?? json['FACLT_ID'] ?? '').toString(),
      name: (json['FACLT_NM'] ?? json['faclt_nm'] ?? '').toString(),
      addr: (json['FACLT_ADDR'] ?? json['faclt_addr'] ?? json['ADDR'] ?? '').toString(),
      lat: _toDouble(json['LA'] ?? json['la']),
      lng: _toDouble(json['LO'] ?? json['lo']),
      type: (json['FACLT_TYPE_NM'] ?? json['faclt_type_nm'] ?? json['FACLT_TYPE'] ?? '').toString(),
      capacity: _toInt(json['CPCT'] ?? json['cpct'] ?? json['TOT_CPCT']),
      staffCount: _toInt(json['WRKR_CNT'] ?? json['wrkr_cnt'] ?? json['WRKR_TOT_CNT']),
      tel: (json['FACLT_TEL'] ?? json['faclt_tel'] ?? json['TEL_NO'] ?? '').toString(),
      homepage: (json['HMPG_ADDR'] ?? json['hmpg_addr'])?.toString(),
    );
  }

  factory WelfareModel.fromLocal(Map<String, dynamic> data) {
    return WelfareModel(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      addr: data['addr']?.toString() ?? '',
      lat: _toDouble(data['lat']),
      lng: _toDouble(data['lng']),
      type: data['type']?.toString() ?? '',
      capacity: _toInt(data['capacity']),
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
