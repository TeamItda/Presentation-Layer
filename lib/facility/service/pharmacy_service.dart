import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/pharmacy_model.dart';

class PharmacyService {
  List<PharmacyModel>? _cache;

  /// assets/jongno_pharmacies.json 로컬 로딩
  Future<List<PharmacyModel>> fetchPharmacies() async {
    if (_cache != null) return _cache!;

    final jsonStr = await rootBundle.loadString('assets/jongno_pharmacies.json');
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    _cache = jsonList.map((e) => PharmacyModel.fromJson(e)).toList();
    return _cache!;
  }

  /// 이름으로 검색
  Future<List<PharmacyModel>> search(String keyword) async {
    final all = await fetchPharmacies();
    return all.where((p) => p.name.contains(keyword) || p.addr.contains(keyword)).toList();
  }

  /// ID로 상세 조회
  Future<PharmacyModel?> getById(String id) async {
    final all = await fetchPharmacies();
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}