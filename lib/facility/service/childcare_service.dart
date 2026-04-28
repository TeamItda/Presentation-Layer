import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/childcare_model.dart';

class ChildcareService {
  List<ChildcareModel>? _cache;

  Future<List<ChildcareModel>> fetchChildcares() async {
    if (_cache != null) return _cache!;

    final jsonString = await rootBundle.loadString('assets/jongno_childcare.json');
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final rows = decoded['data'] as List<dynamic>;

    _cache = rows
        .whereType<Map<String, dynamic>>()
        .map((e) => ChildcareModel.fromLocal(e))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return _cache!;
  }
}
