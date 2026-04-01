class SchoolModel {
  final String code;
  final String name;
  final String engName;
  final String kind;       // 초등학교, 중학교, 고등학교
  final String fondType;   // 공립, 사립
  final String addr;
  final String addrDetail;
  final String tel;
  final String fax;
  final String homepage;
  final String coedu;      // 남여공학, 남, 여
  final String hsType;     // 일반고, 특성화고, 자율고
  final String dayNight;   // 주간, 야간

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
    );
  }

  bool get isJongno => addr.contains('종로구');
}