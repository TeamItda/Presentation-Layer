// 상가(상권)정보 업종분류 코드 (소상공인시장진흥공단)
//
// 출처: assets/food_facility_code.CSV 의 I2(음식점업) 대분류 — 43개 소분류.
//
// 사용처: sdsc2 API 응답의 `indsSclsCd` 같은 6자리 업종소분류 코드를
// "일식 면 요리" 같은 한국어 표시 라벨로 변환.

class FoodFacilityCode {
  final String code; // 소분류 코드 (예: 'I20303')
  final String name; // 소분류명 (예: '일식 면 요리')
  final String midCode; // 중분류 코드 (예: 'I203')
  final String midName; // 중분류명 (예: '일식 음식점업')

  const FoodFacilityCode({
    required this.code,
    required this.name,
    required this.midCode,
    required this.midName,
  });
}

/// 업종소분류 코드 → FoodFacilityCode 매핑.
const Map<String, FoodFacilityCode> foodFacilityCodes = {
  // I201 한식 음식점업
  'I20101': FoodFacilityCode(code: 'I20101', name: '백반/한정식', midCode: 'I201', midName: '한식 음식점업'),
  'I20102': FoodFacilityCode(code: 'I20102', name: '국/탕/찌개류', midCode: 'I201', midName: '한식 음식점업'),
  'I20103': FoodFacilityCode(code: 'I20103', name: '족발/보쌈', midCode: 'I201', midName: '한식 음식점업'),
  'I20104': FoodFacilityCode(code: 'I20104', name: '전/부침개', midCode: 'I201', midName: '한식 음식점업'),
  'I20105': FoodFacilityCode(code: 'I20105', name: '국수/칼국수', midCode: 'I201', midName: '한식 음식점업'),
  'I20106': FoodFacilityCode(code: 'I20106', name: '냉면/밀면', midCode: 'I201', midName: '한식 음식점업'),
  'I20107': FoodFacilityCode(code: 'I20107', name: '돼지고기 구이/찜', midCode: 'I201', midName: '한식 음식점업'),
  'I20108': FoodFacilityCode(code: 'I20108', name: '소고기 구이/찜', midCode: 'I201', midName: '한식 음식점업'),
  'I20109': FoodFacilityCode(code: 'I20109', name: '곱창 전골/구이', midCode: 'I201', midName: '한식 음식점업'),
  'I20110': FoodFacilityCode(code: 'I20110', name: '닭/오리고기 구이/찜', midCode: 'I201', midName: '한식 음식점업'),
  'I20111': FoodFacilityCode(code: 'I20111', name: '횟집', midCode: 'I201', midName: '한식 음식점업'),
  'I20112': FoodFacilityCode(code: 'I20112', name: '해산물 구이/찜', midCode: 'I201', midName: '한식 음식점업'),
  'I20113': FoodFacilityCode(code: 'I20113', name: '복 요리 전문', midCode: 'I201', midName: '한식 음식점업'),
  'I20199': FoodFacilityCode(code: 'I20199', name: '기타 한식 음식점', midCode: 'I201', midName: '한식 음식점업'),
  // I202 중식 음식점업
  'I20201': FoodFacilityCode(code: 'I20201', name: '중국집', midCode: 'I202', midName: '중식 음식점업'),
  'I20202': FoodFacilityCode(code: 'I20202', name: '마라탕/훠궈', midCode: 'I202', midName: '중식 음식점업'),
  // I203 일식 음식점업
  'I20301': FoodFacilityCode(code: 'I20301', name: '일식 회/초밥', midCode: 'I203', midName: '일식 음식점업'),
  'I20302': FoodFacilityCode(code: 'I20302', name: '일식 카레/돈가스/덮밥', midCode: 'I203', midName: '일식 음식점업'),
  'I20303': FoodFacilityCode(code: 'I20303', name: '일식 면 요리', midCode: 'I203', midName: '일식 음식점업'),
  'I20399': FoodFacilityCode(code: 'I20399', name: '기타 일식 음식점', midCode: 'I203', midName: '일식 음식점업'),
  // I204 서양식 음식점업
  'I20401': FoodFacilityCode(code: 'I20401', name: '경양식', midCode: 'I204', midName: '서양식 음식점업'),
  'I20402': FoodFacilityCode(code: 'I20402', name: '파스타/스테이크', midCode: 'I204', midName: '서양식 음식점업'),
  'I20403': FoodFacilityCode(code: 'I20403', name: '패밀리레스토랑', midCode: 'I204', midName: '서양식 음식점업'),
  'I20499': FoodFacilityCode(code: 'I20499', name: '기타 서양식 음식점', midCode: 'I204', midName: '서양식 음식점업'),
  // I205 동남아시아 음식점업
  'I20501': FoodFacilityCode(code: 'I20501', name: '베트남식 전문', midCode: 'I205', midName: '동남아시아 음식점업'),
  'I20599': FoodFacilityCode(code: 'I20599', name: '기타 동남아식 전문', midCode: 'I205', midName: '동남아시아 음식점업'),
  // I206 기타 외국식 음식점업
  'I20601': FoodFacilityCode(code: 'I20601', name: '분류 안된 외국식 음식점', midCode: 'I206', midName: '기타 외국식 음식점업'),
  // I207 구내식당 및 뷔페
  'I20701': FoodFacilityCode(code: 'I20701', name: '구내식당', midCode: 'I207', midName: '구내식당 및 뷔페'),
  'I20702': FoodFacilityCode(code: 'I20702', name: '뷔페', midCode: 'I207', midName: '구내식당 및 뷔페'),
  // I210 기타 간이 음식점업
  'I21001': FoodFacilityCode(code: 'I21001', name: '빵/도넛', midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21002': FoodFacilityCode(code: 'I21002', name: '떡/한과', midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21003': FoodFacilityCode(code: 'I21003', name: '피자', midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21004': FoodFacilityCode(code: 'I21004', name: '버거', midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21005': FoodFacilityCode(code: 'I21005', name: '토스트/샌드위치/샐러드', midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21006': FoodFacilityCode(code: 'I21006', name: '치킨', midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21007': FoodFacilityCode(code: 'I21007', name: '김밥/만두/분식', midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21008': FoodFacilityCode(code: 'I21008', name: '아이스크림/빙수', midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21099': FoodFacilityCode(code: 'I21099', name: '그 외 기타 간이 음식점', midCode: 'I210', midName: '기타 간이 음식점업'),
  // I211 주점업
  'I21101': FoodFacilityCode(code: 'I21101', name: '일반 유흥 주점', midCode: 'I211', midName: '주점업'),
  'I21102': FoodFacilityCode(code: 'I21102', name: '무도 유흥 주점', midCode: 'I211', midName: '주점업'),
  'I21103': FoodFacilityCode(code: 'I21103', name: '생맥주 전문', midCode: 'I211', midName: '주점업'),
  'I21104': FoodFacilityCode(code: 'I21104', name: '요리 주점', midCode: 'I211', midName: '주점업'),
  // I212 비알코올 음료점업
  'I21201': FoodFacilityCode(code: 'I21201', name: '카페', midCode: 'I212', midName: '비알코올 음료점업'),
};

/// 우리 정적 식당 데이터(jongno_rated_restaurants.json, smu_nearby_restaurants.json)의
/// `cuisine` 한국어 값 → 가장 가까운 indsSclsCd 추정. sdsc2 표준 라벨로 일관성을 맞추기 위함.
const Map<String, String> cuisineToFoodCode = {
  '한식': 'I20199', // 기타 한식 음식점
  '일식': 'I20399',
  '중식': 'I20201', // 중국집
  '양식': 'I20499',
  '동남아': 'I20599',
  '베트남': 'I20501',
  '햄버거': 'I21004',
  '버거': 'I21004',
  '피자': 'I21003',
  '치킨': 'I21006',
  '분식': 'I21007',
  '간식': 'I21008',
  '빵': 'I21001',
  '베이커리': 'I21001',
  '도넛': 'I21001',
  '아이스크림': 'I21008',
  '떡': 'I21002',
  '뷔페': 'I20702',
};

/// 영문 category(Google Places / 내부 분류) → 추정 indsSclsCd.
const Map<String, String> categoryToFoodCode = {
  'cafe': 'I21201',
  'bakery': 'I21001',
  'bar': 'I21101',
  'restaurant': 'I20199', // 한식 음식점이 가장 흔하므로 기본값
  'meal_takeaway': 'I21099',
  'meal_delivery': 'I21099',
  'food': 'I21099',
};

/// 코드 → 소분류명. 없으면 null.
String? lookupFoodSclsName(String? code) {
  if (code == null || code.isEmpty) return null;
  return foodFacilityCodes[code]?.name;
}

/// 코드 → 중분류명. 없으면 null.
String? lookupFoodMclsName(String? code) {
  if (code == null || code.isEmpty) return null;
  return foodFacilityCodes[code]?.midName;
}
