import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants.dart';

/// 카카오 로컬 keyword search 응답에서 뽑은 한 곳의 메타데이터.
///
/// 카카오 로컬 API 는 영업시간을 제공하지 않습니다 — placeUrl 의 카카오플레이스
/// 페이지를 열어야 영업시간을 확인할 수 있습니다.
class KakaoLocalPlace {
  /// 카카오플레이스 고유 id (`id` 필드).
  final String id;
  final String placeName;
  final String categoryName; // 예: "음식점 > 한식 > 국밥"
  final String phone;
  final String addressName;
  final String roadAddressName;
  final String placeUrl;
  final double? lat;
  final double? lng;

  const KakaoLocalPlace({
    required this.id,
    required this.placeName,
    required this.categoryName,
    required this.phone,
    required this.addressName,
    required this.roadAddressName,
    required this.placeUrl,
    this.lat,
    this.lng,
  });

  factory KakaoLocalPlace.fromJson(Map<String, dynamic> json) {
    return KakaoLocalPlace(
      id: (json['id'] ?? '').toString(),
      placeName: (json['place_name'] ?? '').toString(),
      categoryName: (json['category_name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      addressName: (json['address_name'] ?? '').toString(),
      roadAddressName: (json['road_address_name'] ?? '').toString(),
      placeUrl: (json['place_url'] ?? '').toString(),
      lat: double.tryParse((json['y'] ?? '').toString()),
      lng: double.tryParse((json['x'] ?? '').toString()),
    );
  }
}

/// 카카오 로컬 keyword search 클라이언트.
///
/// 같은 (query + center) 호출은 메모리 캐시하여 중복 호출을 피합니다.
class KakaoLocalService {
  static const String _endpoint =
      'https://dapi.kakao.com/v2/local/search/keyword.json';

  // 결과를 (query + center) 키로 캐시
  final Map<String, KakaoLocalPlace?> _cache = {};

  bool get isConfigured => AppConstants.kakaoRestApiKey.isNotEmpty;

  /// [query] (가게명 등) 으로 카카오 로컬 keyword search 호출 후 첫 결과 반환.
  /// 좌표 힌트 [lat], [lng] 가 주어지면 그 좌표 기준 가장 가까운 결과를 선택.
  /// key 미설정 / 네트워크 실패 / 결과 없음일 때 null.
  Future<KakaoLocalPlace?> lookup({
    required String query,
    double? lat,
    double? lng,
  }) async {
    if (!isConfigured || query.trim().isEmpty) return null;

    final cacheKey = '${query.trim()}|${lat ?? ''}|${lng ?? ''}';
    if (_cache.containsKey(cacheKey)) return _cache[cacheKey];

    final params = <String, String>{'query': query.trim(), 'size': '5'};
    if (lat != null && lng != null) {
      params['x'] = lng.toString();
      params['y'] = lat.toString();
      params['radius'] = '500'; // 좌표 ±500m 우선 검색
      params['sort'] = 'distance';
    }
    final uri = Uri.parse(_endpoint).replace(queryParameters: params);

    try {
      final res = await http.get(
        uri,
        headers: {
          'Authorization': 'KakaoAK ${AppConstants.kakaoRestApiKey}',
        },
      );
      if (res.statusCode != 200) {
        _cache[cacheKey] = null;
        return null;
      }
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        _cache[cacheKey] = null;
        return null;
      }
      final docs = decoded['documents'];
      if (docs is! List || docs.isEmpty) {
        _cache[cacheKey] = null;
        return null;
      }
      final first = docs.first;
      if (first is! Map<String, dynamic>) {
        _cache[cacheKey] = null;
        return null;
      }
      final place = KakaoLocalPlace.fromJson(first);
      _cache[cacheKey] = place;
      return place;
    } catch (_) {
      _cache[cacheKey] = null;
      return null;
    }
  }
}
