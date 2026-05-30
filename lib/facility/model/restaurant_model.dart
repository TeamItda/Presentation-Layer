import '../data/food_facility_code.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String addr;
  final double? lat;
  final double? lng;
  final String category; // 업종 (한식/중식/카페/분식 등) - 영문/한국어 모두 가능
  final String? cuisine; // 한식/일식/중식 등 세부 분류 (있을 때만)
  final double rating; // 평점 0.0~5.0
  final int? userRatingsTotal; // Google Places 기준 총 리뷰 수
  final String tel;
  final String? homepage;
  // 영업시간 요약(예: "월~금 10:00-22:00 / 토 11:00-21:00"). 데이터에 있을 때만.
  final String? openingHours;
  // 상가(상권)정보 업종소분류 코드 (예: 'I20303'). sdsc2 API 응답에 들어옴.
  // 있으면 food_facility_code.dart 의 csv 매핑으로 정식 라벨을 우선 표시.
  final String? indsSclsCd;

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
    this.openingHours,
    this.indsSclsCd,
  });

  // 소상공인시장진흥공단 상가(상권)정보 API (sdsc2) 응답 파싱
  factory RestaurantModel.fromSmallBizApi(Map<String, dynamic> json) {
    final code = (json['indsSclsCd'] as String?)?.trim();
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
      indsSclsCd: (code != null && code.isNotEmpty) ? code : null,
    );
  }

  factory RestaurantModel.fromLocal(Map<String, dynamic> data) {
    final indsCd = (data['indsSclsCd'] as String?)?.trim();
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
      openingHours: (data['openingHours'] as String?)?.trim().isNotEmpty == true
          ? data['openingHours'].toString()
          : null,
      indsSclsCd: (indsCd != null && indsCd.isNotEmpty) ? indsCd : null,
    );
  }

  /// 표시용 카테고리 라벨. 우선순위:
  ///   1. `indsSclsCd` 가 있으면 food_facility_code.csv 의 소분류명
  ///      (예: 'I20303' → '일식 면 요리')
  ///   2. `cuisine` (한국어) 을 표준 코드로 추정해 csv 소분류명
  ///      (예: '한식' → I20199 → '기타 한식 음식점')
  ///   3. `category` 영문(restaurant/cafe/bar/…) 을 추정해 csv 소분류명
  ///      (예: 'cafe' → I21201 → '카페')
  ///   4. 매핑이 없으면 cuisine/category 원문 그대로
  String get displayCategoryLabel {
    // 1. 코드가 직접 있으면 csv 매핑
    final code = indsSclsCd;
    if (code != null && code.isNotEmpty) {
      final name = lookupFoodSclsName(code);
      if (name != null) return name;
    }

    // 2. cuisine → 추정 코드 → 소분류명
    final c = cuisine?.trim();
    if (c != null && c.isNotEmpty) {
      final guessed = cuisineToFoodCode[c];
      if (guessed != null) {
        final name = lookupFoodSclsName(guessed);
        if (name != null) return name;
      }
      // 매핑 없는 cuisine 은 원문 그대로 (예: '치즈', '특수요리' 등)
      return c;
    }

    // 3. category 영문/한국어 → 추정 코드 → 소분류명
    final cat = category.trim();
    if (cat.isEmpty) return '';
    final guessedCat = categoryToFoodCode[cat];
    if (guessedCat != null) {
      final name = lookupFoodSclsName(guessedCat);
      if (name != null) return name;
    }
    // 한국어가 이미 sdsc2 표준 라벨이면 그대로 (sdsc2 API fromSmallBizApi 경로)
    return cat;
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
