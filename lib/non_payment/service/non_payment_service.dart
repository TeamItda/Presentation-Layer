import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NonPaymentService {
  // HIRA 비급여진료비 API
  static String get _apiKey => dotenv.env['HIRA_API_KEY'] ?? '';
  static const String _baseUrl =
      'http://apis.data.go.kr/B551182/nonPayInfoService';

  // ── 비급여 항목 목록 가져오기 ──────────────
  // itemNm: 항목명 (예: MRI, 초음파)
  // sidoCd: 지역코드 (종로구: 110000)
  Future<List<Map<String, dynamic>>> getNonPaymentList({
    String? itemNm,
    String sidoCd = '110000',
  }) async {
    final queryParams = {
      'serviceKey': _apiKey,
      'pageNo': '1',
      'numOfRows': '100',
      'sidoCd': sidoCd,
      'type': 'json',
      if (itemNm != null) 'itemNm': itemNm,
    };

    final uri = Uri.parse('$_baseUrl/getNonPayList')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['response']['body']['items']['item'];

        if (items == null) return [];

        // 리스트로 변환
        if (items is List) {
          return items.cast<Map<String, dynamic>>();
        } else {
          return [items as Map<String, dynamic>];
        }
      } else {
        throw Exception('API 오류: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('비급여 데이터 로딩 실패: $e');
    }
  }

  // ── 항목별 병원 가격 비교 ──────────────────
  // API 응답 데이터를 화면에 맞게 가공
  Map<String, List<Map<String, dynamic>>> groupByItem(
      List<Map<String, dynamic>> items) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final item in items) {
      final itemName = item['itemNm'] ?? '기타';
      grouped.putIfAbsent(itemName, () => []);
      grouped[itemName]!.add({
        'hospitalName': item['yadmNm'] ?? '',
        'minPrice': int.tryParse(item['minAmt']?.toString() ?? '0') ?? 0,
        'maxPrice': int.tryParse(item['maxAmt']?.toString() ?? '0') ?? 0,
        'avgPrice': int.tryParse(item['avgAmt']?.toString() ?? '0') ?? 0,
      });
    }

    return grouped;
  }
}