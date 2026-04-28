import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/restaurant_model.dart';

class RestaurantService {
  List<RestaurantModel>? _cache;

  Future<List<RestaurantModel>> fetchRestaurants() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString('assets/jongno_restaurants.json');
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final rows = decoded['data'] as List<dynamic>;

    _cache = rows
        .whereType<Map<String, dynamic>>()
        .map((e) => RestaurantModel.fromLocal(e))
        .toList()
      ..sort((a, b) => b.rating.compareTo(a.rating)); // 평점 높은 순
    return _cache!;
  }
}
