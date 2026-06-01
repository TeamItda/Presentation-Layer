// 상가(상권)정보 업종분류 코드 (소상공인시장진흥공단)

class FoodFacilityCode {
  final String code;
  final String name;
  final String nameEn;
  final String nameJa;
  final String nameZh;
  final String midCode;
  final String midName;

  const FoodFacilityCode({
    required this.code,
    required this.name,
    required this.nameEn,
    required this.nameJa,
    required this.nameZh,
    required this.midCode,
    required this.midName,
  });

  String localizedName(String lang) {
    switch (lang) {
      case 'en': return nameEn.isNotEmpty ? nameEn : name;
      case 'ja': return nameJa.isNotEmpty ? nameJa : name;
      case 'zh': return nameZh.isNotEmpty ? nameZh : name;
      default:   return name;
    }
  }
}

const Map<String, FoodFacilityCode> foodFacilityCodes = {
  // I201 한식
  'I20101': FoodFacilityCode(code: 'I20101', name: '백반/한정식',            nameEn: 'Korean Set Meal',          nameJa: '白飯・韓定食',        nameZh: '韩式套餐',        midCode: 'I201', midName: '한식 음식점업'),
  'I20102': FoodFacilityCode(code: 'I20102', name: '국/탕/찌개류',           nameEn: 'Soup & Stew',              nameJa: 'スープ・チゲ',        nameZh: '汤/锅类',         midCode: 'I201', midName: '한식 음식점업'),
  'I20103': FoodFacilityCode(code: 'I20103', name: '족발/보쌈',              nameEn: 'Jokbal & Bossam',          nameJa: '足肉・ポッサム',      nameZh: '猪脚/包饭',       midCode: 'I201', midName: '한식 음식점업'),
  'I20104': FoodFacilityCode(code: 'I20104', name: '전/부침개',              nameEn: 'Korean Pancake',           nameJa: 'チヂミ',              nameZh: '煎饼类',          midCode: 'I201', midName: '한식 음식점업'),
  'I20105': FoodFacilityCode(code: 'I20105', name: '국수/칼국수',            nameEn: 'Noodle Soup',              nameJa: '麺料理',              nameZh: '面条类',          midCode: 'I201', midName: '한식 음식점업'),
  'I20106': FoodFacilityCode(code: 'I20106', name: '냉면/밀면',              nameEn: 'Cold Noodles',             nameJa: '冷麺',                nameZh: '冷面',            midCode: 'I201', midName: '한식 음식점업'),
  'I20107': FoodFacilityCode(code: 'I20107', name: '돼지고기 구이/찜',       nameEn: 'Pork BBQ',                 nameJa: '豚肉焼き・蒸し',      nameZh: '猪肉烤/蒸',       midCode: 'I201', midName: '한식 음식점업'),
  'I20108': FoodFacilityCode(code: 'I20108', name: '소고기 구이/찜',         nameEn: 'Beef BBQ',                 nameJa: '牛肉焼き・蒸し',      nameZh: '牛肉烤/蒸',       midCode: 'I201', midName: '한식 음식점업'),
  'I20109': FoodFacilityCode(code: 'I20109', name: '곱창 전골/구이',         nameEn: 'Grilled Intestines',       nameJa: 'ホルモン焼き',        nameZh: '肥肠烤/火锅',     midCode: 'I201', midName: '한식 음식점업'),
  'I20110': FoodFacilityCode(code: 'I20110', name: '닭/오리고기 구이/찜',    nameEn: 'Chicken & Duck BBQ',       nameJa: '鶏・鴨肉料理',        nameZh: '鸡/鸭肉烤/蒸',    midCode: 'I201', midName: '한식 음식점업'),
  'I20111': FoodFacilityCode(code: 'I20111', name: '횟집',                   nameEn: 'Raw Fish',                 nameJa: '刺身',                nameZh: '生鱼片',          midCode: 'I201', midName: '한식 음식점업'),
  'I20112': FoodFacilityCode(code: 'I20112', name: '해산물 구이/찜',         nameEn: 'Grilled Seafood',          nameJa: '海鮮焼き・蒸し',      nameZh: '海鲜烤/蒸',       midCode: 'I201', midName: '한식 음식점업'),
  'I20113': FoodFacilityCode(code: 'I20113', name: '복 요리 전문',           nameEn: 'Puffer Fish',              nameJa: 'フグ料理',            nameZh: '河豚料理',        midCode: 'I201', midName: '한식 음식점업'),
  'I20199': FoodFacilityCode(code: 'I20199', name: '기타 한식 음식점',       nameEn: 'Korean Restaurant',        nameJa: '韓国料理',            nameZh: '韩餐',            midCode: 'I201', midName: '한식 음식점업'),
  // I202 중식
  'I20201': FoodFacilityCode(code: 'I20201', name: '중국집',                 nameEn: 'Chinese Restaurant',       nameJa: '中華料理',            nameZh: '中餐馆',          midCode: 'I202', midName: '중식 음식점업'),
  'I20202': FoodFacilityCode(code: 'I20202', name: '마라탕/훠궈',            nameEn: 'Mala & Hotpot',            nameJa: 'マーラータン・火鍋',  nameZh: '麻辣烫/火锅',     midCode: 'I202', midName: '중식 음식점업'),
  // I203 일식
  'I20301': FoodFacilityCode(code: 'I20301', name: '일식 회/초밥',           nameEn: 'Sushi & Sashimi',          nameJa: '寿司・刺身',          nameZh: '寿司/生鱼片',     midCode: 'I203', midName: '일식 음식점업'),
  'I20302': FoodFacilityCode(code: 'I20302', name: '일식 카레/돈가스/덮밥',  nameEn: 'Curry & Katsu',            nameJa: 'カレー・とんかつ',    nameZh: '咖喱/猪排饭',     midCode: 'I203', midName: '일식 음식점업'),
  'I20303': FoodFacilityCode(code: 'I20303', name: '일식 면 요리',           nameEn: 'Ramen & Udon',             nameJa: 'ラーメン・うどん',    nameZh: '拉面/乌冬',       midCode: 'I203', midName: '일식 음식점업'),
  'I20399': FoodFacilityCode(code: 'I20399', name: '기타 일식 음식점',       nameEn: 'Japanese Restaurant',      nameJa: '和食',                nameZh: '日餐',            midCode: 'I203', midName: '일식 음식점업'),
  // I204 서양식
  'I20401': FoodFacilityCode(code: 'I20401', name: '경양식',                 nameEn: 'Western Food',             nameJa: '洋食',                nameZh: '西式餐厅',        midCode: 'I204', midName: '서양식 음식점업'),
  'I20402': FoodFacilityCode(code: 'I20402', name: '파스타/스테이크',        nameEn: 'Pasta & Steak',            nameJa: 'パスタ・ステーキ',    nameZh: '意面/牛排',       midCode: 'I204', midName: '서양식 음식점업'),
  'I20403': FoodFacilityCode(code: 'I20403', name: '패밀리레스토랑',         nameEn: 'Family Restaurant',        nameJa: 'ファミレス',          nameZh: '家庭餐厅',        midCode: 'I204', midName: '서양식 음식점업'),
  'I20499': FoodFacilityCode(code: 'I20499', name: '기타 서양식 음식점',     nameEn: 'Western Restaurant',       nameJa: 'その他洋食',          nameZh: '其他西餐',        midCode: 'I204', midName: '서양식 음식점업'),
  // I205 동남아
  'I20501': FoodFacilityCode(code: 'I20501', name: '베트남식 전문',          nameEn: 'Vietnamese',               nameJa: 'ベトナム料理',        nameZh: '越南菜',          midCode: 'I205', midName: '동남아시아 음식점업'),
  'I20599': FoodFacilityCode(code: 'I20599', name: '기타 동남아식 전문',     nameEn: 'Southeast Asian',          nameJa: '東南アジア料理',      nameZh: '东南亚菜',        midCode: 'I205', midName: '동남아시아 음식점업'),
  // I206 기타 외국식
  'I20601': FoodFacilityCode(code: 'I20601', name: '분류 안된 외국식 음식점',nameEn: 'Foreign Restaurant',       nameJa: 'その他外国料理',      nameZh: '其他外国餐厅',    midCode: 'I206', midName: '기타 외국식 음식점업'),
  // I207 구내식당/뷔페
  'I20701': FoodFacilityCode(code: 'I20701', name: '구내식당',               nameEn: 'Cafeteria',                nameJa: '社員食堂',            nameZh: '食堂',            midCode: 'I207', midName: '구내식당 및 뷔페'),
  'I20702': FoodFacilityCode(code: 'I20702', name: '뷔페',                   nameEn: 'Buffet',                   nameJa: 'バイキング',          nameZh: '自助餐',          midCode: 'I207', midName: '구내식당 및 뷔페'),
  // I210 간이 음식점
  'I21001': FoodFacilityCode(code: 'I21001', name: '빵/도넛',                nameEn: 'Bakery & Donuts',          nameJa: 'パン・ドーナツ',      nameZh: '面包/甜甜圈',     midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21002': FoodFacilityCode(code: 'I21002', name: '떡/한과',                nameEn: 'Rice Cake',                nameJa: '餅・韓菓',            nameZh: '糕点/韩式点心',   midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21003': FoodFacilityCode(code: 'I21003', name: '피자',                   nameEn: 'Pizza',                    nameJa: 'ピザ',                nameZh: '披萨',            midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21004': FoodFacilityCode(code: 'I21004', name: '버거',                   nameEn: 'Burger',                   nameJa: 'バーガー',            nameZh: '汉堡',            midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21005': FoodFacilityCode(code: 'I21005', name: '토스트/샌드위치/샐러드', nameEn: 'Toast & Sandwich & Salad', nameJa: 'トースト・サンドイッチ・サラダ', nameZh: '吐司/三明治/沙拉', midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21006': FoodFacilityCode(code: 'I21006', name: '치킨',                   nameEn: 'Fried Chicken',            nameJa: 'チキン',              nameZh: '炸鸡',            midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21007': FoodFacilityCode(code: 'I21007', name: '김밥/만두/분식',         nameEn: 'Kimbap & Dumplings',       nameJa: 'キンパ・餃子・軽食',  nameZh: '紫菜饭卷/饺子/小食', midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21008': FoodFacilityCode(code: 'I21008', name: '아이스크림/빙수',        nameEn: 'Ice Cream & Bingsu',       nameJa: 'アイスクリーム・かき氷', nameZh: '冰淇淋/刨冰',   midCode: 'I210', midName: '기타 간이 음식점업'),
  'I21099': FoodFacilityCode(code: 'I21099', name: '그 외 기타 간이 음식점', nameEn: 'Other Light Meals',        nameJa: 'その他軽食',          nameZh: '其他简餐',        midCode: 'I210', midName: '기타 간이 음식점업'),
  // I211 주점
  'I21101': FoodFacilityCode(code: 'I21101', name: '일반 유흥 주점',         nameEn: 'Bar',                      nameJa: '居酒屋',              nameZh: '酒吧',            midCode: 'I211', midName: '주점업'),
  'I21102': FoodFacilityCode(code: 'I21102', name: '무도 유흥 주점',         nameEn: 'Club & Bar',               nameJa: 'クラブ',              nameZh: '夜店',            midCode: 'I211', midName: '주점업'),
  'I21103': FoodFacilityCode(code: 'I21103', name: '생맥주 전문',            nameEn: 'Draft Beer Bar',           nameJa: '生ビール専門',        nameZh: '鲜啤酒吧',        midCode: 'I211', midName: '주점업'),
  'I21104': FoodFacilityCode(code: 'I21104', name: '요리 주점',              nameEn: 'Pub & Dining',             nameJa: '料理居酒屋',          nameZh: '餐酒吧',          midCode: 'I211', midName: '주점업'),
  // I212 카페
  'I21201': FoodFacilityCode(code: 'I21201', name: '카페',                   nameEn: 'Café',                     nameJa: 'カフェ',              nameZh: '咖啡厅',          midCode: 'I212', midName: '비알코올 음료점업'),
};

const Map<String, String> cuisineToFoodCode = {
  '한식': 'I20199',
  '일식': 'I20399',
  '중식': 'I20201',
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

const Map<String, String> categoryToFoodCode = {
  'cafe': 'I21201',
  'bakery': 'I21001',
  'bar': 'I21101',
  'restaurant': 'I20199',
  'meal_takeaway': 'I21099',
  'meal_delivery': 'I21099',
  'food': 'I21099',
};

/// 코드 → 소분류명 (한국어). 없으면 null.
String? lookupFoodSclsName(String? code) {
  if (code == null || code.isEmpty) return null;
  return foodFacilityCodes[code]?.name;
}

/// 코드 → 소분류명 (현지화). 없으면 null.
String? lookupFoodSclsNameLocalized(String? code, String lang) {
  if (code == null || code.isEmpty) return null;
  return foodFacilityCodes[code]?.localizedName(lang);
}

/// 코드 → 중분류명. 없으면 null.
String? lookupFoodMclsName(String? code) {
  if (code == null || code.isEmpty) return null;
  return foodFacilityCodes[code]?.midName;
}