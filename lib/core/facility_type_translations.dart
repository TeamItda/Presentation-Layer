/// 시설 타입 다국어 매핑
/// f['type'] 값을 현재 언어에 맞게 변환할 때 사용
class FacilityTypeTranslations {
  static const Map<String, Map<String, String>> _typeMap = {
    // ── 의료시설 ──────────────────────────────
    '의원': {'en': 'Clinic', 'zh': '诊所', 'ja': 'クリニック'},
    '병원': {'en': 'Hospital', 'zh': '医院', 'ja': '病院'},
    '종합병원': {'en': 'General Hospital', 'zh': '综合医院', 'ja': '総合病院'},
    '상급종합병원': {'en': 'Tertiary Hospital', 'zh': '三级医院', 'ja': '高度専門病院'},
    '한의원': {'en': 'Korean Medicine Clinic', 'zh': '韩医院', 'ja': '韓方クリニック'},
    '한방병원': {'en': 'Korean Medicine Hospital', 'zh': '韩方医院', 'ja': '韓方病院'},
    '치과의원': {'en': 'Dental Clinic', 'zh': '牙科诊所', 'ja': '歯科クリニック'},
    '치과병원': {'en': 'Dental Hospital', 'zh': '牙科医院', 'ja': '歯科病院'},
    '요양병원': {'en': 'Care Hospital', 'zh': '疗养医院', 'ja': '療養病院'},
    '정신병원': {'en': 'Psychiatric Hospital', 'zh': '精神病院', 'ja': '精神科病院'},
    '조산원': {'en': 'Birthing Center', 'zh': '助产院', 'ja': '助産院'},

    // ── 어린이집/유치원 ───────────────────────
    '국공립': {'en': 'Public', 'zh': '公立', 'ja': '公立'},
    '사회복지법인': {'en': 'Social Welfare', 'zh': '社会福利法人', 'ja': '社会福祉法人'},
    '법인·단체': {'en': 'Corporation', 'zh': '法人团体', 'ja': '法人・団体'},
    '민간': {'en': 'Private', 'zh': '民间', 'ja': '民間'},
    '가정': {'en': 'Home-based', 'zh': '家庭式', 'ja': '家庭型'},
    '부모협동': {'en': 'Parent Cooperative', 'zh': '家长合作', 'ja': '保護者共同'},
    '직장': {'en': 'Workplace', 'zh': '职场', 'ja': '職場'},
    '어린이집': {'en': 'Daycare Center', 'zh': '托儿所', 'ja': '保育園'},
    '사립(사인)': {'en': 'Private', 'zh': '私立', 'ja': '私立'},
    '공립(단설)': {'en': 'Public (Standalone)', 'zh': '公立(独立)', 'ja': '公立(単独)'},
    '공립(병설)': {'en': 'Public (Attached)', 'zh': '公立(附属)', 'ja': '公立(併設)'},

    // ── 복지시설 ──────────────────────────────
    '노인요양시설': {'en': 'Elderly Care Facility', 'zh': '老人疗养院', 'ja': '老人介護施設'},
    '노인요양공동생활가정': {'en': 'Elderly Group Home', 'zh': '老人共同生活家庭', 'ja': '老人共同生活ホーム'},
    '주야간보호': {'en': 'Day & Night Care', 'zh': '日夜间护理', 'ja': 'デイナイトケア'},
    '방문요양': {'en': 'Home Care Service', 'zh': '上门护理', 'ja': '訪問介護'},
    '방문목욕': {'en': 'Home Bathing Service', 'zh': '上门沐浴', 'ja': '訪問入浴'},
    '방문간호': {'en': 'Home Nursing', 'zh': '上门护理', 'ja': '訪問看護'},
    '단기보호': {'en': 'Short-term Care', 'zh': '短期护理', 'ja': '短期保護'},
    '복지용구': {'en': 'Welfare Equipment', 'zh': '福利器具', 'ja': '福祉用具'},

    // ── 문화시설 ──────────────────────────────
    '미술관': {'en': 'Art Museum', 'zh': '美术馆', 'ja': '美術館'},
    '박물관': {'en': 'Museum', 'zh': '博物馆', 'ja': '博物館'},
    '공연장': {'en': 'Performance Hall', 'zh': '演出场地', 'ja': '公演場'},
    '도서관': {'en': 'Library', 'zh': '图书馆', 'ja': '図書館'},
    '문학관': {'en': 'Literature Hall', 'zh': '文学馆', 'ja': '文学館'},
    '문화의집': {'en': 'Culture House', 'zh': '文化之家', 'ja': '文化の家'},
    '지방문화원': {'en': 'Local Culture Center', 'zh': '地方文化院', 'ja': '地域文化院'},
    '생활문화센터': {'en': 'Community Culture Center', 'zh': '生活文化中心', 'ja': '生活文化センター'},
    '지역문화재단': {'en': 'Regional Culture Foundation', 'zh': '地区文化财团', 'ja': '地域文化財団'},
    '고궁': {'en': 'Palace', 'zh': '古宫', 'ja': '古宮'},

    // ── 공공기관 ──────────────────────────────
    '구청': {'en': 'District Office', 'zh': '区政府', 'ja': '区役所'},
    '주민센터': {'en': 'Community Center', 'zh': '居民中心', 'ja': '住民センター'},
    '경찰서': {'en': 'Police Station', 'zh': '警察局', 'ja': '警察署'},
    '소방서': {'en': 'Fire Station', 'zh': '消防局', 'ja': '消防署'},
    '보건소': {'en': 'Public Health Center', 'zh': '保健所', 'ja': '保健所'},
    '세무서': {'en': 'Tax Office', 'zh': '税务局', 'ja': '税務署'},
    '우체국': {'en': 'Post Office', 'zh': '邮局', 'ja': '郵便局'},
    '행정기관': {'en': 'Government Office', 'zh': '行政机关', 'ja': '行政機関'},
    '교육기관': {'en': 'Education Institution', 'zh': '教育机构', 'ja': '教育機関'},
    '복지기관': {'en': 'Welfare Institution', 'zh': '福利机构', 'ja': '福祉機関'},

    // ── 학교 ─────────────────────────────────
    '초등학교': {'en': 'Elementary School', 'zh': '小学', 'ja': '小学校'},
    '중학교': {'en': 'Middle School', 'zh': '初中', 'ja': '中学校'},
    '고등학교': {'en': 'High School', 'zh': '高中', 'ja': '高校'},
    '특수학교': {'en': 'Special School', 'zh': '特殊学校', 'ja': '特別支援学校'},
    '국립': {'en': 'National', 'zh': '国立', 'ja': '国立'},
    '공립': {'en': 'Public', 'zh': '公立', 'ja': '公立'},
    '사립': {'en': 'Private', 'zh': '私立', 'ja': '私立'},
    '남녀공학': {'en': 'Coed', 'zh': '男女合校', 'ja': '男女共学'},
    '남학교': {'en': 'Boys School', 'zh': '男校', 'ja': '男子校'},
    '여학교': {'en': 'Girls School', 'zh': '女校', 'ja': '女子校'},

    // ── 맛집 ─────────────────────────────────
    '한식': {'en': 'Korean', 'zh': '韩食', 'ja': '韓国料理'},
    '중식': {'en': 'Chinese', 'zh': '中餐', 'ja': '中華料理'},
    '일식': {'en': 'Japanese', 'zh': '日料', 'ja': '日本料理'},
    '양식': {'en': 'Western', 'zh': '西餐', 'ja': '洋食'},
    '분식': {'en': 'Korean Snacks', 'zh': '小吃', 'ja': '粉食'},
    '카페': {'en': 'Cafe', 'zh': '咖啡厅', 'ja': 'カフェ'},
    '베이커리': {'en': 'Bakery', 'zh': '面包店', 'ja': 'ベーカリー'},
    '치킨': {'en': 'Chicken', 'zh': '炸鸡', 'ja': 'チキン'},
    '피자': {'en': 'Pizza', 'zh': '披萨', 'ja': 'ピザ'},
    '패스트푸드': {'en': 'Fast Food', 'zh': '快餐', 'ja': 'ファストフード'},
    '식당': {'en': 'Restaurant', 'zh': '餐厅', 'ja': 'レストラン'},
    '음식': {'en': 'Food', 'zh': '餐饮', 'ja': '飲食'},
    '포장 식당': {'en': 'Takeout', 'zh': '外卖餐厅', 'ja': 'テイクアウト'},
    '배달 식당': {'en': 'Delivery', 'zh': '外卖', 'ja': 'デリバリー'},
  };

  /// type 값을 현재 언어로 변환
  /// 매핑이 없으면 원본 반환
  static String translate(String type, String lang) {
    if (lang == 'ko' || type.isEmpty) return type;
    return _typeMap[type]?[lang] ?? type;
  }
}