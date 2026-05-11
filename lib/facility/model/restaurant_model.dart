class RestaurantModel {
  final String id;
  final String name;
  final String addr;
  final double? lat;
  final double? lng;
  final String category; // 업종 (한식/중식/카페/분식 등)
  final String? cuisine; // 한식/일식/중식 등 세부 분류 (있을 때만)
  final double rating;   // 평점 0.0~5.0
  final int? userRatingsTotal; // Google Places 기준 총 리뷰 수
  final String tel;
  final String? homepage;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.addr,
    this.lat,
    this.lng,
    required this.category,
    this.cuisine,
    required this.rating,
    this.userRatingsTotal,
    required this.tel,
    this.homepage,
  });

  // 소상공인시장진흥공단 상가(상권)정보 API (sdsc2) 응답 파싱
  factory RestaurantModel.fromSmallBizApi(Map<String, dynamic> json) {
    return RestaurantModel(
      id: (json['bizesId'] ?? '').toString(),
      name: (json['bizesNm'] ?? '').toString(),
      addr: (json['rdnmAdr'] ?? json['lnoAdr'] ?? '').toString(),
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lon']),
      category:
          (json['indsSclsNm'] ?? json['indsMclsNm'] ?? json['indsLclsNm'] ?? '')
              .toString(),
      rating: 0.0,
      tel: '',
      homepage: null,
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
      cuisine: (data['cuisine'] as String?)?.trim().isNotEmpty == true
          ? data['cuisine'].toString()
          : null,
      rating: _toDouble(data['rating']) ?? 0.0,
      userRatingsTotal: _toInt(data['userRatingsTotal']),
      tel: data['tel']?.toString() ?? '',
      homepage: data['homepage']?.toString(),
    );
  }

  static const Map<String, String> _categoryLabels = {
    'restaurant': '식당',
    'cafe': '카페',
    'bakery': '베이커리',
    'bar': '술집',
    'meal_takeaway': '포장 식당',
    'meal_delivery': '배달 식당',
    'food': '음식',
  };

  static String displayCategory(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return '';
    return _categoryLabels[v] ?? v;
  }

  // 우선 cuisine(한식/일식 등)을 표시, 없으면 category 번역값으로 fallback.
  String get displayCategoryLabel {
    final c = cuisine;
    if (c != null && c.isNotEmpty) return c;
    return displayCategory(category);
  }

  static double? _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String && v.trim().isNotEmpty) return double.tryParse(v.trim());
    return null;
  }

  static int? _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String && v.trim().isNotEmpty) return int.tryParse(v.trim());
    return null;
  }
}
