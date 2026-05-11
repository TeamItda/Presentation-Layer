import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'dart:convert';

class NonPaymentService {
  static const String _apiKey =
      '6a730286a7b7542d56e228b687194d29faf9f4b3a7f96455384b6e8b89eb5227';
  static const String _baseUrl =
      'https://apis.data.go.kr/B551182/nonPaymentDamtInfoService';
  static const int _pageSize = 1000;
  static const int _maxPages = 10;

  // (sidoCd, sgguCd, itemNm) → 페이지별 결과 캐시
  final Map<String, List<Map<String, dynamic>>> _cache = {};

  Future<List<Map<String, dynamic>>> getNonPaymentList({
    String? itemNm,
    String sidoCd = '110000',
    String? sgguCd = '110016', // 종로구 (없으면 전체 시도)
    String? hospitalName,
  }) async {
    final cacheKey = '$sidoCd|${sgguCd ?? ""}|${itemNm ?? ""}';
    final cached = _cache[cacheKey];
    final all = cached ?? await _fetchAllPages(
      sidoCd: sidoCd,
      sgguCd: sgguCd,
      itemNm: itemNm,
    );
    if (cached == null) _cache[cacheKey] = all;

    if (hospitalName != null && hospitalName.isNotEmpty) {
      return all
          .where((r) => r['yadmNm'].toString().contains(hospitalName))
          .toList();
    }
    return all;
  }

  Future<List<Map<String, dynamic>>> _fetchAllPages({
    required String sidoCd,
    String? sgguCd,
    String? itemNm,
  }) async {
    final all = <Map<String, dynamic>>[];
    for (var page = 1; page <= _maxPages; page++) {
      final params = <String, String>{
        'serviceKey': _apiKey,
        'pageNo': '$page',
        'numOfRows': '$_pageSize',
        'sidoCd': sidoCd,
        if (sgguCd != null && sgguCd.isNotEmpty) 'sgguCd': sgguCd,
        if (itemNm != null) 'itemNm': itemNm,
      };
      final uri = Uri.parse('$_baseUrl/getNonPaymentItemHospList2')
          .replace(queryParameters: params);

      try {
        final response = await http.get(
          uri,
          headers: const {'Accept-Charset': 'UTF-8'},
        );
        if (response.statusCode != 200) break;

        final body = utf8.decode(response.bodyBytes);
        final document = XmlDocument.parse(body);
        final items = document.findAllElements('item').toList();
        if (items.isEmpty) break;

        for (final item in items) {
          String getText(String tag) =>
              item.findElements(tag).firstOrNull?.innerText.trim() ?? '';
          final minPrc = int.tryParse(getText('minPrc')) ?? 0;
          final maxPrc = int.tryParse(getText('maxPrc')) ?? 0;
          final avgPrc = ((minPrc + maxPrc) / 2).round();
          all.add({
            'itemNm': getText('npayKorNm'),
            'yadmNm': getText('yadmNm'),
            'ykiho': getText('ykiho'),
            'minAmt': minPrc.toString(),
            'maxAmt': maxPrc.toString(),
            'avgAmt': avgPrc.toString(),
          });
        }

        if (items.length < _pageSize) break;
      } catch (_) {
        break;
      }
    }
    return all;
  }

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
