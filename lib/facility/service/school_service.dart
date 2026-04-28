import 'dart:convert';

import 'package:flutter/services.dart';

import '../model/school_model.dart';

class SchoolService {
  List<SchoolModel>? _cache;
  Map<String, dynamic>? _coordinateCache;

  /// assets/jongno_schools.json에서 종로구 학교 목록을 불러온다.
  Future<List<SchoolModel>> fetchSchools() async {
    if (_cache != null) {
      return _cache!;
    }

    final jsonString = await rootBundle.loadString('assets/jongno_schools.json');
    final decoded = jsonDecode(jsonString);
    final rows = decoded is Map<String, dynamic> ? decoded['DATA'] : null;
    final coordinates = await _loadCoordinateMap();

    if (rows is! List) {
      _cache = const [];
      return _cache!;
    }

    final uniqueSchools = <String, SchoolModel>{};
    for (final row in rows) {
      if (row is! Map<String, dynamic>) {
        continue;
      }
      final school = SchoolModel.fromJson(_normalizeJson(row, coordinates));
      if (!school.isJongno) {
        continue;
      }
      uniqueSchools.putIfAbsent(school.code, () => school);
    }

    _cache = uniqueSchools.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return _cache!;
  }

  Future<List<SchoolModel>> filterByKind(String kind) async {
    final all = await fetchSchools();
    return all.where((school) => school.kind == kind).toList();
  }

  Future<List<SchoolModel>> search(String keyword) async {
    final all = await fetchSchools();
    return all
        .where(
          (school) =>
              school.name.contains(keyword) || school.addr.contains(keyword),
        )
        .toList();
  }

  Future<SchoolModel?> getByCode(String code) async {
    final all = await fetchSchools();
    try {
      return all.firstWhere((school) => school.code == code);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _loadCoordinateMap() async {
    if (_coordinateCache != null) {
      return _coordinateCache!;
    }

    final jsonString = await rootBundle.loadString(
      'assets/jongno_school_coordinates.json',
    );
    final decoded = jsonDecode(jsonString);
    if (decoded is Map<String, dynamic>) {
      _coordinateCache = decoded;
      return decoded;
    }

    _coordinateCache = const <String, dynamic>{};
    return _coordinateCache!;
  }

  Map<String, dynamic> _normalizeJson(
    Map<String, dynamic> row,
    Map<String, dynamic> coordinates,
  ) {
    final code = row['sd_schul_code'] ?? '';
    final coordinate = coordinates[code];
    return {
      'SD_SCHUL_CODE': code,
      'SCHUL_NM': row['schul_nm'] ?? '',
      'ENG_SCHUL_NM': row['eng_schul_nm'] ?? '',
      'SCHUL_KND_SC_NM': row['schul_knd_sc_nm'] ?? '',
      'FOND_SC_NM': row['fond_sc_nm'] ?? '',
      'ORG_RDNMA': row['org_rdnma'] ?? '',
      'ORG_RDNDA': row['org_rdnda'] ?? '',
      'ORG_TELNO': row['org_telno'] ?? '',
      'ORG_FAXNO': row['org_faxno'] ?? '',
      'HMPG_ADRES': row['hmpg_adres'] ?? '',
      'COEDU_SC_NM': row['coedu_sc_nm'] ?? '',
      'HS_SC_NM': row['hs_sc_nm'] ?? '',
      'DGHT_SC_NM': row['dght_sc_nm'] ?? '',
      'LAT': coordinate is Map<String, dynamic> ? coordinate['lat'] : null,
      'LNG': coordinate is Map<String, dynamic> ? coordinate['lng'] : null,
    };
  }
}
