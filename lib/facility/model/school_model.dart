class SchoolModel {
  final String code;
  final String name;
  final String engName;
  final String kind;
  final String fondType;
  final String addr;
  final String addrDetail;
  final String tel;
  final String fax;
  final String homepage;
  final String coedu;
  final String hsType;
  final String dayNight;
  final double? lat;
  final double? lng;

  SchoolModel({
    required this.code,
    required this.name,
    required this.engName,
    required this.kind,
    required this.fondType,
    required this.addr,
    required this.addrDetail,
    required this.tel,
    required this.fax,
    required this.homepage,
    required this.coedu,
    required this.hsType,
    required this.dayNight,
    this.lat,
    this.lng,
  });

  factory SchoolModel.fromJson(Map<String, dynamic> json) {
    return SchoolModel(
      code: json['SD_SCHUL_CODE'] ?? '',
      name: json['SCHUL_NM'] ?? '',
      engName: json['ENG_SCHUL_NM'] ?? '',
      kind: json['SCHUL_KND_SC_NM'] ?? '',
      fondType: json['FOND_SC_NM'] ?? '',
      addr: json['ORG_RDNMA'] ?? '',
      addrDetail: json['ORG_RDNDA'] ?? '',
      tel: json['ORG_TELNO'] ?? '',
      fax: json['ORG_FAXNO'] ?? '',
      homepage: json['HMPG_ADRES'] ?? '',
      coedu: json['COEDU_SC_NM'] ?? '',
      hsType: (json['HS_SC_NM'] ?? '').toString().trim(),
      dayNight: json['DGHT_SC_NM'] ?? '',
      lat: _toDouble(json['LAT']),
      lng: _toDouble(json['LNG']),
    );
  }

  String get geocodingAddress => addr.trim();

  String get displayAddress {
    final base = addr.trim();
    final detail = addrDetail.trim();
    if (detail.isEmpty) {
      return base;
    }
    if (detail.startsWith('(')) {
      return '$base $detail';
    }
    return base;
  }

  bool get isJongno => addr.contains('\uC885\uB85C\uAD6C');

  static double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String && value.trim().isNotEmpty) {
      return double.tryParse(value);
    }
    return null;
  }
}
