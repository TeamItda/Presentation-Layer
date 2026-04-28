import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/government_model.dart';

class GovernmentService {
  List<GovernmentModel>? _cache;

  Future<List<GovernmentModel>> fetchGovernments() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString('assets/jongno_government.json');
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final rows = decoded['data'] as List<dynamic>;

    _cache = rows
        .whereType<Map<String, dynamic>>()
        .map((e) => GovernmentModel.fromLocal(e))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return _cache!;
  }
}
