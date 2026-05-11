import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../model/restaurant_model.dart';

class RestaurantService {
  static const String _baseUrl =
      'https://apis.data.go.kr/B553077/api/open/sdsc2';
  static const String _jongnoSignguCd = '11110';
  static const int _pageSize = 1000;
  static const int _maxPages = 7;
  static const String _ratedAssetPath =
      'assets/jongno_rated_restaurants.json';
  static const String _localAssetPath = 'assets/jongno_restaurants.json';

  List<RestaurantModel>? _cache;

  Future<List<RestaurantModel>> fetchRestaurants() async {
    if (_cache != null) return _cache!;

    final rated = await _loadRatedAsset();
    if (rated.isNotEmpty) {
      _cache = rated;
      return _cache!;
    }

    final apiResults = await _fetchFromApi();
    if (apiResults.isNotEmpty) {
      _cache = apiResults;
      return _cache!;
    }

    return _loadLocal();
  }

  Future<List<RestaurantModel>> _loadRatedAsset() async {
    try {
      final jsonString = await rootBundle.loadString(_ratedAssetPath);
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final rows = decoded['data'] as List<dynamic>? ?? const [];
      final list = rows
          .whereType<Map<String, dynamic>>()
          .map(RestaurantModel.fromLocal)
          .where((r) => r.lat != null && r.lng != null)
          .toList()
        ..sort((a, b) =>
            (b.userRatingsTotal ?? 0).compareTo(a.userRatingsTotal ?? 0));
      return list;
    } catch (_) {
      return const [];
    }
  }

  Future<List<RestaurantModel>> _fetchFromApi() async {
    if (AppConstants.smallBizApiKey.isEmpty) return const [];

    final pages = await Future.wait(
      List.generate(_maxPages, (i) => _fetchPage(i + 1)),
    );

    final results = <RestaurantModel>[];
    for (final page in pages) {
      results.addAll(page);
    }
    return results;
  }

  Future<List<RestaurantModel>> _fetchPage(int page) async {
    final uri = Uri.parse('$_baseUrl/storeListInDong').replace(
      queryParameters: {
        'serviceKey': AppConstants.smallBizApiKey,
        'pageNo': '$page',
        'numOfRows': '$_pageSize',
        'divId': 'signguCd',
        'key': _jongnoSignguCd,
        'indsLclsCd': 'I2',
        'type': 'json',
      },
    );

    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) return const [];

      final decoded =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final header = decoded['header'];
      if (header is Map<String, dynamic> && header['resultCode'] != '00') {
        return const [];
      }

      final body = decoded['body'];
      if (body is! Map<String, dynamic>) return const [];
      final items = body['items'];
      if (items is! List) return const [];

      final out = <RestaurantModel>[];
      for (final raw in items) {
        if (raw is Map<String, dynamic>) {
          final r = RestaurantModel.fromSmallBizApi(raw);
          if (r.lat != null && r.lng != null && r.name.isNotEmpty) {
            out.add(r);
          }
        }
      }
      return out;
    } catch (_) {
      return const [];
    }
  }

  Future<List<RestaurantModel>> _loadLocal() async {
    final jsonString = await rootBundle.loadString(_localAssetPath);
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final rows = decoded['data'] as List<dynamic>;

    _cache = rows
        .whereType<Map<String, dynamic>>()
        .map((e) => RestaurantModel.fromLocal(e))
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return _cache!;
  }
}
