import '../data/food_facility_code.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String addr;
  final double? lat;
  final double? lng;
  final String category;
  final String? cuisine;
  final double rating;
  final int? userRatingsTotal;
  final String tel;
  final String? homepage;
  final String? openingHours;
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

  /// 기존 한국어 카테고리 라벨 (하위 호환용)
  String get displayCategoryLabel => _resolveLabel('ko');

  /// 현지화된 카테고리 라벨
  String displayCategoryLabelLocalized(String lang) => _resolveLabel(lang);

  String _resolveLabel(String lang) {
    // 1. 코드가 직접 있으면 현지화 매핑
    final code = indsSclsCd;
    if (code != null && code.isNotEmpty) {
      final name = lookupFoodSclsNameLocalized(code, lang);
      if (name != null) return name;
    }

    // 2. cuisine → 추정 코드 → 현지화 소분류명
    final c = cuisine?.trim();
    if (c != null && c.isNotEmpty) {
      final guessed = cuisineToFoodCode[c];
      if (guessed != null) {
        final name = lookupFoodSclsNameLocalized(guessed, lang);
        if (name != null) return name;
      }
      return c; // 매핑 없으면 원문
    }

    // 3. category → 추정 코드 → 현지화 소분류명
    final cat = category.trim();
    if (cat.isEmpty) return '';
    final guessedCat = categoryToFoodCode[cat];
    if (guessedCat != null) {
      final name = lookupFoodSclsNameLocalized(guessedCat, lang);
      if (name != null) return name;
    }
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