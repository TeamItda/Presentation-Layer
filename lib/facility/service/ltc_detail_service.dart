import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../../core/constants.dart';
import '../model/ltc_program_model.dart';
import '../model/ltc_staff_model.dart';

class LtcDetail {
  const LtcDetail({this.staff, this.programs = const [], this.acceptance});
  final LtcStaffStatus? staff;
  final List<LtcProgram> programs;
  final LtcAcceptance? acceptance;
}

class LtcDetailService {
  static const String _baseUrl =
      'http://apis.data.go.kr/B550928/getLtcInsttDetailInfoService02';

  final Map<String, LtcDetail> _cache = {};

  Future<LtcDetail> fetchDetail({
    required String longTermAdminSym,
    required String adminPttnCd,
  }) async {
    final cacheKey = '$longTermAdminSym|$adminPttnCd';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final results = await Future.wait([
      _fetchStaff(longTermAdminSym, adminPttnCd),
      _fetchPrograms(longTermAdminSym, adminPttnCd),
      _fetchAcceptance(longTermAdminSym, adminPttnCd),
    ]);

    final detail = LtcDetail(
      staff: results[0] as LtcStaffStatus?,
      programs: (results[1] as List<LtcProgram>?) ?? const [],
      acceptance: results[2] as LtcAcceptance?,
    );
    _cache[cacheKey] = detail;
    return detail;
  }

  Future<XmlDocument?> _call(String operation, Map<String, String> params) async {
    if (AppConstants.smallBizApiKey.isEmpty) return null;
    final uri = Uri.parse('$_baseUrl/$operation').replace(
      queryParameters: {
        'serviceKey': AppConstants.smallBizApiKey,
        ...params,
      },
    );
    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) return null;
      return XmlDocument.parse(res.body);
    } catch (_) {
      return null;
    }
  }

  Future<LtcStaffStatus?> _fetchStaff(String sym, String code) async {
    final doc = await _call('getStaffSttusDetailInfoItem02', {
      'longTermAdminSym': sym,
      'adminPttnCd': code,
    });
    if (doc == null) return null;
    final item = doc.findAllElements('item').firstOrNull;
    if (item == null) return null;

    int v(String tag) =>
        int.tryParse(item.getElement(tag)?.innerText.trim() ?? '') ?? 0;

    return LtcStaffStatus(
      chargeDoc: v('chargeDoc'),
      chrgDoc: v('chrgDoc'),
      cook: v('cook'),
      dent: v('dent'),
      equipLong: v('equipLong'),
      etcPer: v('etcPer'),
      hdOfce: v('hdOfce'),
      hygiPrsn: v('hygiPrsn'),
      mgmtPrsn: v('mgmtPrsn'),
      nur: v('nur'),
      nurArticle: v('nurArticle'),
      nut: v('nut'),
      ofceEmp: v('ofceEmp'),
      physicalMTret: v('physicalMTret'),
      recuProtDelay: v('recuProtDelay'),
      recuProt1: v('recuProt_1'),
      recuProt2: v('recuProt_2'),
      socWel: v('socWel'),
      suppPrsn: v('suppPrsn'),
      wrkMTret: v('wrkMTret'),
    );
  }

  Future<List<LtcProgram>> _fetchPrograms(String sym, String code) async {
    final doc = await _call('getProgramSttusDetailInfoList02', {
      'longTermAdminSym': sym,
      'adminPttnCd': code,
      'numOfRows': '50',
      'pageNo': '1',
    });
    if (doc == null) return const [];
    return doc.findAllElements('item').map((item) {
      String s(String tag) =>
          item.getElement(tag)?.innerText.trim() ?? '';
      int i(String tag) => int.tryParse(s(tag)) ?? 0;
      final loc = s('runPlc');
      return LtcProgram(
        name: s('pgmNm'),
        typeCode: s('pgmType'),
        location: loc.isEmpty ? null : loc,
        targetCount: i('tgtNop'),
        frequency: i('cyclTm'),
      );
    }).where((p) => p.name.isNotEmpty).toList();
  }

  Future<LtcAcceptance?> _fetchAcceptance(String sym, String code) async {
    final doc = await _call('getAceptncNmprDetailInfoItem02', {
      'longTermAdminSym': sym,
      'adminPttnCd': code,
    });
    if (doc == null) return null;
    final item = doc.findAllElements('item').firstOrNull;
    if (item == null) return null;

    int v(String tag) =>
        int.tryParse(item.getElement(tag)?.innerText.trim() ?? '') ?? 0;

    // 응답 sample이 아직 비어 있어 필드명은 추정 — 실데이터 들어오면 보정.
    return LtcAcceptance(
      currentMen: v('currentMen'),
      currentWomen: v('currentWomen'),
      capacityMen: v('capacityMen'),
      capacityWomen: v('capacityWomen'),
    );
  }
}
