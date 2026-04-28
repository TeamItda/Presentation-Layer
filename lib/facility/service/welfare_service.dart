import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/welfare_model.dart';

class WelfareService {
  List<WelfareModel>? _cache;

  Future<List<WelfareModel>> fetchWelfares() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString('assets/jongno_welfare.json');
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final rows = decoded['data'] as List<dynamic>;

    _cache = rows
        .whereType<Map<String, dynamic>>()
        .map((e) => WelfareModel.fromLocal(e))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return _cache!;
  }
}
