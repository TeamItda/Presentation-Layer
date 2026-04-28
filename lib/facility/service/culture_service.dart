import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/culture_model.dart';

class CultureService {
  List<CultureModel>? _cache;

  Future<List<CultureModel>> fetchCultures() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString('assets/jongno_culture.json');
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final rows = decoded['data'] as List<dynamic>;

    _cache = rows
        .whereType<Map<String, dynamic>>()
        .map((e) => CultureModel.fromLocal(e))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return _cache!;
  }
}
