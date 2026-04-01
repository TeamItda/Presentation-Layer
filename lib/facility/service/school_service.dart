import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/school_model.dart';

class SchoolService {
  static const String _baseUrl = 'https://open.neis.go.kr/hub/schoolInfo';
  static const String _key = '41c941d6400949c8a9b8a2e6178196ea';

  List<SchoolModel>? _cache;

  /// NEIS API로 종로구 학교 실시간 조회
  Future<List<SchoolModel>> fetchSchools() async {
    if (_cache != null) return _cache!;

    final List<SchoolModel> allSchools = [];
    int page = 1;
    const int pageSize = 1000;

    // 서울 전체 조회 후 종로구 필터링
    while (true) {
      final uri = Uri.parse(
        '$_baseUrl?KEY=$_key&Type=json&ATPT_OFCDC_SC_CODE=B10&pIndex=$page&pSize=$pageSize',
      );

      final response = await http.get(uri);
      if (response.statusCode != 200) break;

      final data = jsonDecode(response.body);

      // 에러 체크
      if (data['RESULT'] != null) break;

      final schoolInfo = data['schoolInfo'];
      if (schoolInfo == null || schoolInfo.length < 2) break;

      final rows = schoolInfo[1]['row'] as List<dynamic>;
      if (rows.isEmpty) break;

      for (final row in rows) {
        if (row is Map<String, dynamic> && row.isNotEmpty) {
          final school = SchoolModel.fromJson(row);
          if (school.isJongno) {
            allSchools.add(school);
          }
        }
      }

      // 전체 건수 확인
      final totalCount = schoolInfo[0]['head']?[0]?['list_total_count'] ?? 0;
      if (page * pageSize >= totalCount) break;
      page++;
    }

    _cache = allSchools;
    return _cache!;
  }

  /// 학교급(초/중/고)으로 필터
  Future<List<SchoolModel>> filterByKind(String kind) async {
    final all = await fetchSchools();
    return all.where((s) => s.kind == kind).toList();
  }

  /// 이름으로 검색
  Future<List<SchoolModel>> search(String keyword) async {
    final all = await fetchSchools();
    return all.where((s) => s.name.contains(keyword) || s.addr.contains(keyword)).toList();
  }

  /// 코드로 상세 조회
  Future<SchoolModel?> getByCode(String code) async {
    final all = await fetchSchools();
    try {
      return all.firstWhere((s) => s.code == code);
    } catch (_) {
      return null;
    }
  }
}