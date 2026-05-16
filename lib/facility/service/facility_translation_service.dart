import 'dart:convert';
import 'package:http/http.dart' as http;

class FacilityTranslationService {
  // 발급받은 Google Cloud Translation API 키
  static const String _googleApiKey = 'AIzaSyBY_FxNXeh6JeAohHwZB9fuAidXt4rue74';

  // Google 언어 코드 매핑
  static const Map<String, String> _googleLangMap = {
    'en': 'en',
    'zh': 'zh-CN',
    'ja': 'ja',
  };

  /// 배치 번역 - 여러 텍스트를 한 번에 번역 (Google Translation API)-50개씩
  Future<List<String>> translateBatch(
      List<String> texts, String targetLang) async {
    final googleTarget = _googleLangMap[targetLang];
    if (googleTarget == null || texts.isEmpty) return texts;

    // 50개씩 나눠서 처리
    const chunkSize = 50;
    final results = <String>[];

    for (var i = 0; i < texts.length; i += chunkSize) {
      final chunk = texts.sublist(i,
          (i + chunkSize < texts.length) ? i + chunkSize : texts.length);

      try {
        final uri = Uri.https(
          'translation.googleapis.com',
          '/language/translate/v2',
          {'key': _googleApiKey},
        );

        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'q': chunk,
            'source': 'ko',
            'target': googleTarget,
            'format': 'text',
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final translations = data['data']['translations'] as List;
          results.addAll(translations
              .map((t) => t['translatedText'] as String));
        } else {
          results.addAll(chunk); // 실패 시 원본
        }
      } catch (e) {
        results.addAll(chunk); // 실패 시 원본
      }
    }

    return results;
  }

  /// 시설명 단건 번역 (내부적으로 배치 사용)
  Future<String?> translateName(String text, String targetLang) async {
    if (text.isEmpty) return null;
    final results = await translateBatch([text], targetLang);
    return results.isNotEmpty ? results[0] : null;
  }

  /// 주소 로마자 변환 (Google Geocoding API)
  Future<String?> romanizeAddress(String koreanAddress) async {
    if (koreanAddress.isEmpty) return null;

    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/geocode/json',
        {
          'address': koreanAddress,
          'language': 'en',
          'region': 'KR',
          'key': _googleApiKey,
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'] as String?;
        }
      }
    } catch (e) {
      // 변환 실패 시 원본 반환
    }
    return null;
  }

  /// 주소 배치 로마자 변환 후 번역
  /// - 영어: Geocoding으로 로마자 변환 (병렬 처리)
  /// - 중/일: 로마자 변환 후 Translation API로 배치 번역
  Future<List<String>> translateAddressBatch(
      List<String> addresses, String targetLang) async {
    if (addresses.isEmpty) return addresses;

    // 모든 주소 로마자 변환 (병렬 처리)
    final romanizedList = await Future.wait(
      addresses.map((addr) => romanizeAddress(addr)),
    );

    // 로마자 변환 실패 시 원본 유지
    final romanized = List<String>.generate(
      addresses.length,
          (i) => romanizedList[i] ?? addresses[i],
    );

    // 영어는 로마자 그대로 반환
    if (targetLang == 'en') return romanized;

    // 중/일은 로마자 주소를 배치로 번역
    return await translateBatch(romanized, targetLang);
  }
}