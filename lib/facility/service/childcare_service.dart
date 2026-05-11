import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../model/childcare_model.dart';

class ChildcareService {
  static const String _jongnoSidoCd = '11';
  static const String _jongnoSggCd = '11110';

  List<ChildcareModel>? _cache;

  Future<List<ChildcareModel>> fetchChildcares() async {
    if (_cache != null) return _cache!;

    final api = await _fetchFromKindergartenApi();
    if (api.isNotEmpty) {
      _cache = api..sort((a, b) => a.name.compareTo(b.name));
      return _cache!;
    }

    return _loadLocal();
  }

  Future<List<ChildcareModel>> _fetchFromKindergartenApi() async {
    if (AppConstants.kindergartenApiKey.isEmpty) return const [];

    final uri = Uri.parse(
      '${AppConstants.kindergartenApiBaseUrl}/basicInfo.do',
    );

    try {
      final res = await http.post(
        uri,
        headers: const {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: {
          'key': AppConstants.kindergartenApiKey,
          'sidoList': _jongnoSidoCd,
          'sggList': _jongnoSggCd,
          'pageCnt': '500',
          'currentPage': '1',
        },
      );
      if (res.statusCode != 200) return const [];

      final decoded =
          jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      if (decoded['status'] != 'SUCCESS') return const [];

      final rows = decoded['kinderInfo'] as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(ChildcareModel.fromKindergartenApi)
          .where((c) => c.name.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<List<ChildcareModel>> _loadLocal() async {
    final jsonString =
        await rootBundle.loadString('assets/jongno_childcare.json');
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
