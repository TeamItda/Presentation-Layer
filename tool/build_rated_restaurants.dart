// 사전 계산 스크립트: Google Places Nearby Search로 종로구를 그리드 검색해서
// 리뷰 수가 일정 기준 이상인 식당만 모아 assets/jongno_rated_restaurants.json 으로 저장한다.
//
// 비용 절감:
//   - 종로구 polygon(boundary) 바깥 셀은 호출하지 않음 → bbox 대비 약 70% 절감
//   - 각 셀 응답을 tool/.places_cache/ 에 저장 → 재실행 시 동일 셀은 무료
//   - --dry-run 으로 호출 전 셀 수만 미리 확인 가능
//
// 사전 준비:
//   1) Google Cloud Console에서 해당 API 키에 "Places API"를 활성화
//   2) Billing(결제) 활성화
//
// 실행:
//   dart run tool/build_rated_restaurants.dart <API_KEY>
//
// 옵션:
//   --min=<n>      최소 리뷰 수 (기본 500)
//   --type=<t>     Places type (기본 restaurant; 예: cafe, bakery, bar)
//   --step=<m>     그리드 간격(미터, 기본 900)
//   --radius=<m>   각 셀 검색 반경(미터, 기본 1000)
//   --dry-run      실제 API 호출 없이 셀 개수와 캐시 hit 수만 출력
//   --no-cache     캐시 무시하고 모두 다시 호출
//   --no-polygon   종로구 polygon 필터 끄기 (bounding box 전체 호출)

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

const double _south = 37.5450;
const double _north = 37.6100;
const double _west = 126.9320;
const double _east = 127.0560;
const String _outputPath = 'assets/jongno_rated_restaurants.json';
const String _boundaryPath = 'assets/jongno_boundary.json';
const String _cacheDir = 'tool/.places_cache';

const double _metersPerLatDeg = 111000.0;
const double _metersPerLngDegAt37 = 88800.0;

Future<void> main(List<String> args) async {
  final options = _parseOptions(args);

  if (options.apiKey == null && !options.dryRun) {
    stderr.writeln(
      'Usage: dart run tool/build_rated_restaurants.dart <API_KEY> [--min=500] [--type=restaurant] [--step=900] [--radius=1000] [--dry-run] [--no-cache] [--no-polygon]',
    );
    stderr.writeln('');
    stderr.writeln(
      'Enable "Places API" with billing on the API key in Google Cloud Console.',
    );
    exit(1);
  }

  final stepLat = options.stepMeters / _metersPerLatDeg;
  final stepLng = options.stepMeters / _metersPerLngDegAt37;

  final allCells = <List<double>>[];
  for (var lat = _south; lat <= _north; lat += stepLat) {
    for (var lng = _west; lng <= _east; lng += stepLng) {
      allCells.add([lat, lng]);
    }
  }

  List<List<double>> cells = allCells;
  if (options.usePolygonFilter) {
    final polygon = await _loadJongnoPolygon();
    cells = allCells
        .where((c) => _pointInPolygon(c[0], c[1], polygon))
        .toList();
    stdout.writeln(
      'Polygon filter: ${allCells.length} → ${cells.length} cells (skipped ${allCells.length - cells.length} outside Jongno-gu)',
    );
  }

  final cacheDir = Directory(_cacheDir);
  if (options.useCache && !cacheDir.existsSync()) {
    cacheDir.createSync(recursive: true);
  }

  var cacheHits = 0;
  var willCall = 0;
  for (final c in cells) {
    if (options.useCache && _cacheFile(c[0], c[1]).existsSync()) {
      cacheHits++;
    } else {
      willCall++;
    }
  }

  stdout.writeln('Type: ${options.placeType}, min reviews: ${options.minReviews}');
  stdout.writeln(
    'Cells: ${cells.length} (cache hits: $cacheHits, will call: $willCall)',
  );
  final estimatedCalls = willCall * 2; // 평균 1~3 calls/cell with pagination
  final estimatedCost = estimatedCalls * 0.032;
  stdout.writeln(
    'Estimated API calls: ~$estimatedCalls, estimated cost: ~\$${estimatedCost.toStringAsFixed(2)}',
  );

  if (options.dryRun) {
    stdout.writeln('Dry run — no API calls made.');
    return;
  }

  final places = <String, Map<String, dynamic>>{};
  var apiCallCount = 0;

  for (var i = 0; i < cells.length; i++) {
    final lat = cells[i][0];
    final lng = cells[i][1];
    List<Map<String, dynamic>> items;
    final cacheFile = _cacheFile(lat, lng);

    if (options.useCache && cacheFile.existsSync()) {
      final cached = jsonDecode(cacheFile.readAsStringSync());
      items = (cached as List).cast<Map<String, dynamic>>();
      stdout.writeln(
        '[${i + 1}/${cells.length}] cache hit (${items.length})',
      );
    } else {
      final result = await _searchCell(
        options.apiKey!,
        lat,
        lng,
        options.radiusMeters,
        options.placeType,
      );
      apiCallCount += result.callCount;
      items = result.items;
      stdout.writeln(
        '[${i + 1}/${cells.length}] (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}) → ${items.length} hits (${result.callCount} calls)',
      );
      if (result.fatalError) {
        stderr.writeln('Aborting due to fatal API error.');
        exit(2);
      }
      if (options.useCache) {
        cacheFile.writeAsStringSync(jsonEncode(items));
      }
    }

    for (final p in items) {
      final id = p['place_id'] as String?;
      if (id != null) places[id] = p;
    }
  }

  final filtered = places.values.where((p) {
    final total = p['user_ratings_total'];
    return total is int && total >= options.minReviews;
  }).toList()
    ..sort(
      (a, b) =>
          (b['user_ratings_total'] as int).compareTo(a['user_ratings_total'] as int),
    );

  stdout.writeln('');
  stdout.writeln('API calls made this run: $apiCallCount');
  stdout.writeln(
    'Estimated spend this run: ~\$${(apiCallCount * 0.032).toStringAsFixed(2)}',
  );
  stdout.writeln('Unique places found: ${places.length}');
  stdout.writeln('With ≥${options.minReviews} reviews: ${filtered.length}');

  final data = filtered.map((p) {
    final geom = p['geometry'] as Map<String, dynamic>?;
    final loc = geom?['location'] as Map<String, dynamic>?;
    final types = (p['types'] as List?)?.cast<String>() ?? const <String>[];
    final category = types.firstWhere(
      (t) =>
          t != 'point_of_interest' && t != 'establishment' && t != 'food',
      orElse: () => types.isNotEmpty ? types.first : 'restaurant',
    );
    final name = (p['name'] ?? '').toString();
    return <String, dynamic>{
      'id': p['place_id'],
      'name': name,
      'addr': p['vicinity'] ?? '',
      'lat': loc?['lat'],
      'lng': loc?['lng'],
      'rating': p['rating'],
      'userRatingsTotal': p['user_ratings_total'],
      'category': category,
      'cuisine': _classifyCuisine(name, category),
    };
  }).toList();

  final output = <String, dynamic>{
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'minReviews': options.minReviews,
    'count': data.length,
    'data': data,
  };

  await File(_outputPath).writeAsString(
    const JsonEncoder.withIndent('  ').convert(output),
  );
  stdout.writeln('Wrote $_outputPath');
}

File _cacheFile(double lat, double lng) {
  final name =
      '${lat.toStringAsFixed(4)}_${lng.toStringAsFixed(4)}.json';
  return File('$_cacheDir/$name');
}

Future<List<List<double>>> _loadJongnoPolygon() async {
  final raw = await File(_boundaryPath).readAsString();
  final decoded = jsonDecode(raw) as Map<String, dynamic>;
  final coords = decoded['coordinates'] as List<dynamic>;
  return coords
      .map((p) => p as List<dynamic>)
      .map((p) => [(p[1] as num).toDouble(), (p[0] as num).toDouble()])
      .toList();
}

bool _pointInPolygon(double lat, double lng, List<List<double>> polygon) {
  var inside = false;
  for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final xi = polygon[i][1], yi = polygon[i][0];
    final xj = polygon[j][1], yj = polygon[j][0];
    final intersect = ((yi > lat) != (yj > lat)) &&
        (lng < (xj - xi) * (lat - yi) / (yj - yi) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

// 이름과 Google 분류를 보고 한식/일식/중식 같은 한국식 카테고리로 분류.
// Legacy Places API가 cuisine 정보를 안 줘서 키워드 매칭으로 보완.
String? _classifyCuisine(String name, String category) {
  final lower = name.toLowerCase();

  bool has(List<String> kws) => kws.any(lower.contains);

  // 패스트푸드 브랜드 (가장 먼저 매칭)
  const fastFood = [
    '맥도날드', '맥날', '버거킹', 'kfc', '롯데리아', '맘스터치',
    '써브웨이', '서브웨이', '버거', '햄버거',
  ];
  if (has(fastFood)) return '패스트푸드';

  // 치킨 전문
  const chicken = ['교촌', 'bbq', 'bhc', '굽네', '처갓집', '네네', '페리카나', '치킨'];
  if (has(chicken)) return '치킨';

  // 일식
  const japanese = [
    '스시', '초밥', '사시미', '회', '라멘', '돈까스', '돈가스',
    '우동', '소바', '돈부리', '덮밥', '가츠', '카츠', '오뎅',
    '이자카야', '오니기리', '야끼토리', '타코야끼', '오코노미야끼',
    '교자', '야끼니쿠', '일식', '쇼유', '갓덴',
  ];
  if (has(japanese)) return '일식';

  // 중식
  const chinese = [
    '짜장', '짬뽕', '탕수육', '마라', '훠궈', '딘타이펑',
    '중화', '북경', '사천', '중식', '딤섬', '훈둔',
    '우육면', '꿔바로우', '양꼬치', '양고기',
  ];
  if (has(chinese)) return '중식';

  // 양식
  const western = [
    '이탈리', '파스타', '피자', '스테이크', '비스트로', '프렌치',
    '리조또', '함박', '에스프레소', '마떼오', 'di matteo',
  ];
  if (has(western)) return '양식';

  // 분식
  const bunsik = ['떡볶이', '김밥', '라볶이', '분식', '먹쉬돈나'];
  if (has(bunsik)) return '분식';

  // 한식 (가장 다양한 키워드)
  const korean = [
    '삼계탕', '한정식', '백반', '갈비', '삼겹살', '비빔밥', '김치',
    '국밥', '해장국', '칼국수', '수제비', '냉면', '국수', '면옥',
    '한식', '쌈밥', '한우', '곰탕', '설렁탕', '닭갈비', '닭한마리',
    '족발', '보쌈', '순대', '아구찜', '낙지', '추어탕', '동태탕',
    '된장', '청국장', '죽', '북엇국', '명태', '감자탕', '돼지국밥',
    '굴', '회덮밥', '연포탕', '쭈꾸미', '닭볶음탕', '곱창', '대구탕',
    '만두', '한옥', '집밥', '왕비집', '큰기와집', '북악정',
    '장모님', '오박사네', '왕돈까스',
  ];
  if (has(korean)) return '한식';

  // 카테고리 기반 fallback
  switch (category) {
    case 'cafe':
      return '카페';
    case 'bakery':
      return '베이커리';
    case 'bar':
      return '술집';
    case 'meal_takeaway':
      return '포장 식당';
    case 'meal_delivery':
      return '배달 식당';
  }

  return null;
}

class _CellResult {
  _CellResult(this.items, this.callCount, this.fatalError);
  final List<Map<String, dynamic>> items;
  final int callCount;
  final bool fatalError;
}

Future<_CellResult> _searchCell(
  String apiKey,
  double lat,
  double lng,
  int radius,
  String type,
) async {
  final results = <Map<String, dynamic>>[];
  String? pageToken;
  var calls = 0;
  for (var page = 0; page < 3; page++) {
    if (pageToken != null) {
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    final params = <String, String>{
      'location': '$lat,$lng',
      'radius': '$radius',
      'type': type,
      'language': 'ko',
      'key': apiKey,
      if (pageToken != null) 'pagetoken': pageToken,
    };
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/place/nearbysearch/json',
      params,
    );
    final res = await http.get(uri);
    calls++;
    if (res.statusCode != 200) {
      stderr.writeln('  HTTP ${res.statusCode}');
      return _CellResult(results, calls, false);
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final status = body['status'] as String?;
    if (status == 'INVALID_REQUEST' && pageToken != null) {
      await Future<void>.delayed(const Duration(seconds: 2));
      continue;
    }
    if (status != 'OK' && status != 'ZERO_RESULTS') {
      stderr.writeln('  API status: $status — ${body['error_message'] ?? ''}');
      final fatal = status == 'REQUEST_DENIED' ||
          status == 'OVER_QUERY_LIMIT' ||
          status == 'OVER_DAILY_LIMIT';
      return _CellResult(results, calls, fatal);
    }
    final items = (body['results'] as List?) ?? const [];
    for (final item in items) {
      if (item is Map<String, dynamic>) results.add(item);
    }
    pageToken = body['next_page_token'] as String?;
    if (pageToken == null || pageToken.isEmpty) break;
  }
  return _CellResult(results, calls, false);
}

class _Options {
  _Options({
    required this.apiKey,
    required this.minReviews,
    required this.placeType,
    required this.stepMeters,
    required this.radiusMeters,
    required this.dryRun,
    required this.useCache,
    required this.usePolygonFilter,
  });
  final String? apiKey;
  final int minReviews;
  final String placeType;
  final int stepMeters;
  final int radiusMeters;
  final bool dryRun;
  final bool useCache;
  final bool usePolygonFilter;
}

_Options _parseOptions(List<String> args) {
  String? apiKey;
  var min = 500;
  var type = 'restaurant';
  var step = 900;
  var radius = 1000;
  var dryRun = false;
  var useCache = true;
  var usePolygonFilter = true;

  for (final arg in args) {
    if (arg.startsWith('--min=')) {
      min = int.tryParse(arg.substring(6)) ?? min;
    } else if (arg.startsWith('--type=')) {
      type = arg.substring(7);
    } else if (arg.startsWith('--step=')) {
      step = int.tryParse(arg.substring(7)) ?? step;
    } else if (arg.startsWith('--radius=')) {
      radius = int.tryParse(arg.substring(9)) ?? radius;
    } else if (arg == '--dry-run') {
      dryRun = true;
    } else if (arg == '--no-cache') {
      useCache = false;
    } else if (arg == '--no-polygon') {
      usePolygonFilter = false;
    } else if (!arg.startsWith('--')) {
      apiKey = arg;
    }
  }

  return _Options(
    apiKey: apiKey,
    minReviews: min,
    placeType: type,
    stepMeters: step,
    radiusMeters: radius,
    dryRun: dryRun,
    useCache: useCache,
    usePolygonFilter: usePolygonFilter,
  );
}
