class CultureModel {
  final String id;
  final String name;
  final String addr;
  final double? lat;
  final double? lng;
  final String type;     // 미술관 / 공연장 / 박물관 / 도서관 등
  final String tel;
  final String? homepage;

  const CultureModel({
    required this.id,
    required this.name,
    required this.addr,
    this.lat,
    this.lng,
    required this.type,
    required this.tel,
    this.homepage,
  });

  // 문화체육관광부 문화시설 API 응답 파싱
  factory CultureModel.fromApi(Map<String, dynamic> json) {
    return CultureModel(
      id: (json['PRFPLCCD'] ?? json['prfplccd'] ?? json['FCLTY_CD'] ?? '').toString(),
      name: (json['PRFPLCNM'] ?? json['prfplcnm'] ?? json['FCLTY_NM'] ?? '').toString(),
      addr: (json['PRFPLCADRES'] ?? json['prfplcadres'] ?? json['ADDR'] ?? '').toString(),
      lat: _toDouble(json['LA'] ?? json['la'] ?? json['PRFPLCLA']),
      lng: _toDouble(json['LO'] ?? json['lo'] ?? json['PRFPLCLO']),
      type: (json['PRFPLCFCLTYNM'] ?? json['prfplcfcltynm'] ?? json['FCLTY_TYPE'] ?? '').toString(),
      tel: (json['TELNO'] ?? json['telno'] ?? json['PRFPLCTEL'] ?? '').toString(),
      homepage: (json['HMPGADDR'] ?? json['hmpgaddr'] ?? json['HMPG_ADDR'])?.toString(),
    );
  }

  factory CultureModel.fromLocal(Map<String, dynamic> data) {
    return CultureModel(
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
