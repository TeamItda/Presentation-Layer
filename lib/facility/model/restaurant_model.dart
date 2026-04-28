class RestaurantModel {
  final String id;
  final String name;
  final String addr;
  final double? lat;
  final double? lng;
  final String category; // 업종 (한식/중식/카페/분식 등)
  final double rating;   // 평점 0.0~5.0
  final String tel;
  final String? homepage;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.addr,
    this.lat,
    this.lng,
    required this.category,
    required this.rating,
    required this.tel,
    this.homepage,
  });

  // 소상공인상가정보 API 응답 파싱
  factory RestaurantModel.fromSmallBizApi(Map<String, dynamic> json) {
    return RestaurantModel(
      id: (json['BIZRNO'] ?? json['bizrno'] ?? json['BIZPLC_CD'] ?? '').toString(),
      name: (json['BIZPLC_NM'] ?? json['bizplc_nm'] ?? '').toString(),
      addr: (json['RDNWHLADDR'] ?? json['rdnwhladdr'] ?? json['LOTADDR'] ?? '').toString(),
      lat: _toDouble(json['Y_DNTS_CORS'] ?? json['LA']),
      lng: _toDouble(json['X_DNTS_CORS'] ?? json['LO']),
      category: (json['INDUTY_NM'] ?? json['induty_nm'] ?? json['INDUTYPE_NM'] ?? '').toString(),
      rating: _toDouble(json['RATING'] ?? json['rating']) ?? 0.0,
      tel: (json['TELNO'] ?? json['telno'] ?? '').toString(),
      homepage: (json['HMPG_ADDR'] ?? json['hmpg_addr'])?.toString(),
    );
  }

  factory RestaurantModel.fromLocal(Map<String, dynamic> data) {
    return RestaurantModel(
      id: data['id']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      addr: data['addr']?.toString() ?? '',
      lat: _toDouble(data['lat']),
      lng: _toDouble(data['lng']),
      category: data['category']?.toString() ?? data['type']?.toString() ?? '',
      rating: _toDouble(data['rating']) ?? 0.0,
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
