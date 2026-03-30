import 'dart:convert';
import 'package:flutter/services.dart';
import '../model/hospital_model.dart';

class HospitalService {
  List<HospitalModel>? _cache;

  /// assets/jongno_hospitals.json 로컬 로딩
  Future<List<HospitalModel>> fetchHospitals() async {
    if (_cache != null) return _cache!;

    final jsonStr = await rootBundle.loadString('assets/jongno_hospitals.json');
    final List<dynamic> jsonList = jsonDecode(jsonStr);
    _cache = jsonList.map((e) => HospitalModel.fromJson(e)).toList();
    return _cache!;
  }

  /// 이름으로 검색
  Future<List<HospitalModel>> search(String keyword) async {
    final all = await fetchHospitals();
    return all.where((h) => h.name.contains(keyword) || h.addr.contains(keyword)).toList();
  }

  /// 종별(의원, 병원, 상급종합 등) 필터
  Future<List<HospitalModel>> filterByType(String type) async {
    final all = await fetchHospitals();
    return all.where((h) => h.type == type).toList();
  }

  /// 진료과목으로 필터
  Future<List<HospitalModel>> filterByDepartment(String dept) async {
    final all = await fetchHospitals();
    return all.where((h) => h.departments.contains(dept)).toList();
  }

  /// ID로 상세 조회
  Future<HospitalModel?> getById(String id) async {
    final all = await fetchHospitals();
    try {
      return all.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }
}