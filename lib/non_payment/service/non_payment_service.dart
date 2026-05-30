import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class NonPaymentService {
  static const String _apiKey =
      '6a730286a7b7542d56e228b687194d29faf9f4b3a7f96455384b6e8b89eb5227';
  static const String _baseUrl =
      'https://apis.data.go.kr/B551182/nonPaymentDamtInfoService';

  Future<List<Map<String, dynamic>>> getNonPaymentList({
    String? itemNm,
    String sidoCd = '110000',
    String? hospitalId,
    String? hospitalName,
  }) async {
    final queryParams = {
      'serviceKey': _apiKey,
      'pageNo': '1',
      'numOfRows': '100',
      'sidoCd': sidoCd,
      if (itemNm != null) 'itemNm': itemNm,
    };

    final uri = Uri.parse('$_baseUrl/getNonPaymentItemHospList2')
        .replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {'Accept-Charset': 'UTF-8'},
      );

      if (response.statusCode != 200) {
        throw Exception('API ?ㅻ쟾: ${response.statusCode}');
      }

      final body = utf8.decode(response.bodyBytes);
      final document = XmlDocument.parse(body);
      final items = document.findAllElements('item');

      if (items.isEmpty) return [];

      final result = items.map((item) {
        String getText(String tag) =>
            item.findElements(tag).firstOrNull?.innerText.trim() ?? '';

        final minPrc = int.tryParse(getText('minPrc')) ?? 0;
        final maxPrc = int.tryParse(getText('maxPrc')) ?? 0;
        final avgPrc = ((minPrc + maxPrc) / 2).round();

        return {
          'itemNm': getText('npayKorNm'),
          'yadmNm': getText('yadmNm'),
          'ykiho': getText('ykiho'),
          'minAmt': minPrc.toString(),
          'maxAmt': maxPrc.toString(),
          'avgAmt': avgPrc.toString(),
        };
      }).toList();

      if (hospitalId != null && hospitalId.isNotEmpty) {
        final matchedById = result
            .where((r) => r['ykiho'].toString().trim() == hospitalId.trim())
            .toList();
        if (matchedById.isNotEmpty) {
          return matchedById;
        }
      }

      if (hospitalName != null && hospitalName.isNotEmpty) {
        final normalizedHospitalName = _normalizeName(hospitalName);
        final matchedByName = result.where((r) {
          final apiHospitalName = r['yadmNm'].toString();
          final normalizedApiHospitalName = _normalizeName(apiHospitalName);
          return apiHospitalName.contains(hospitalName) ||
              normalizedApiHospitalName.contains(normalizedHospitalName) ||
              normalizedHospitalName.contains(normalizedApiHospitalName);
        }).toList();
        if (matchedByName.isNotEmpty) {
          return matchedByName;
        }
      }

      return result;
    } catch (e) {
      throw Exception('鍮꾧툒???곗씠??濡쒕뵫 ?ㅽ뙣: $e');
    }
  }

  String _normalizeName(String value) {
    return value.replaceAll(RegExp(r'[\s\(\)\[\]\{\},.\-]'), '');
  }

  Map<String, List<Map<String, dynamic>>> groupByItem(
    List<Map<String, dynamic>> items,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final item in items) {
      final itemName = item['itemNm'] ?? '湲고?';
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
