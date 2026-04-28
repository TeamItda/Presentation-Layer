class LocalFacilitySeed {
  const LocalFacilitySeed({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.address,
    this.type,
    this.phone,
    this.homepage,
    this.lat,
    this.lng,
  });

  final String id;
  final String name;
  final String categoryId;
  final String address;
  final String? type;
  final String? phone;
  final String? homepage;
  final double? lat;
  final double? lng;
}

class LocalFacilityCatalog {
  static const Map<String, List<LocalFacilitySeed>> byCategory = {
    'childcare': [
      LocalFacilitySeed(
        id: 'childcare-1',
        name: '종로구육아종합지원센터',
        categoryId: 'childcare',
        address: '서울 종로구 성균관로 91',
        phone: '02-764-3523',
        homepage: 'https://jongno.childcare.go.kr',
        type: '육아지원센터',
        lat: 37.5896,
        lng: 126.9988,
      ),
      LocalFacilitySeed(
        id: 'childcare-2',
        name: '구립숭인어린이집',
        categoryId: 'childcare',
        address: '서울 종로구 종로65길 30',
        phone: '02-762-3959',
        type: '구립어린이집',
        lat: 37.5730,
        lng: 127.0155,
      ),
      LocalFacilitySeed(
        id: 'childcare-3',
        name: '서울혜화어린이집',
        categoryId: 'childcare',
        address: '서울 종로구 대학로 89',
        phone: '02-747-6991',
        type: '어린이집',
        lat: 37.5822,
        lng: 127.0016,
      ),
    ],
    'welfare': [
      LocalFacilitySeed(
        id: 'welfare-1',
        name: '종로노인종합복지관',
        categoryId: 'welfare',
        address: '서울 종로구 율곡로19길 17-8',
        phone: '02-742-9500',
        type: '노인복지관',
        lat: 37.5748,
        lng: 127.0080,
      ),
      LocalFacilitySeed(
        id: 'welfare-2',
        name: '종로종합사회복지관',
        categoryId: 'welfare',
        address: '서울 종로구 평창문화로 87',
        phone: '02-766-8282',
        type: '사회복지관',
        lat: 37.6066,
        lng: 126.9687,
      ),
      LocalFacilitySeed(
        id: 'welfare-3',
        name: '서울특별시립서울장애인종합복지관 종로지원',
        categoryId: 'welfare',
        address: '서울 종로구 대학로 101',
        phone: '02-440-5700',
        type: '장애인복지',
        lat: 37.5828,
        lng: 127.0024,
      ),
    ],
    'food': [
      LocalFacilitySeed(
        id: 'food-1',
        name: '광장시장 빈대떡',
        categoryId: 'food',
        address: '서울 종로구 창경궁로 88',
        type: '시장맛집',
        lat: 37.5704,
        lng: 126.9991,
      ),
      LocalFacilitySeed(
        id: 'food-2',
        name: '토속촌 삼계탕',
        categoryId: 'food',
        address: '서울 종로구 자하문로5길 5',
        phone: '02-737-7444',
        type: '한식',
        lat: 37.5774,
        lng: 126.9706,
      ),
      LocalFacilitySeed(
        id: 'food-3',
        name: '익선동 수제만두 골목',
        categoryId: 'food',
        address: '서울 종로구 수표로28길 23',
        type: '분식',
        lat: 37.5741,
        lng: 126.9898,
      ),
    ],
    'culture': [
      LocalFacilitySeed(
        id: 'culture-1',
        name: '국립현대미술관 서울',
        categoryId: 'culture',
        address: '서울 종로구 삼청로 30',
        phone: '02-3701-9500',
        homepage: 'https://www.mmca.go.kr',
        type: '미술관',
        lat: 37.5788,
        lng: 126.9803,
      ),
      LocalFacilitySeed(
        id: 'culture-2',
        name: '서울공예박물관',
        categoryId: 'culture',
        address: '서울 종로구 율곡로3길 4',
        phone: '02-6450-7000',
        homepage: 'https://craftmuseum.seoul.go.kr',
        type: '박물관',
        lat: 37.5764,
        lng: 126.9849,
      ),
      LocalFacilitySeed(
        id: 'culture-3',
        name: '세종문화회관',
        categoryId: 'culture',
        address: '서울 종로구 세종대로 175',
        phone: '02-399-1000',
        homepage: 'https://www.sejongpac.or.kr',
        type: '공연장',
        lat: 37.5726,
        lng: 126.9769,
      ),
    ],
    'government': [
      LocalFacilitySeed(
        id: 'government-1',
        name: '종로구청',
        categoryId: 'government',
        address: '서울 종로구 삼봉로 43',
        phone: '02-2148-1111',
        homepage: 'https://www.jongno.go.kr',
        type: '구청',
        lat: 37.5735,
        lng: 126.9790,
      ),
      LocalFacilitySeed(
        id: 'government-2',
        name: '종로구보건소',
        categoryId: 'government',
        address: '서울 종로구 자하문로19길 36',
        phone: '02-2148-3500',
        type: '보건소',
        lat: 37.5808,
        lng: 126.9691,
      ),
      LocalFacilitySeed(
        id: 'government-3',
        name: '정부서울청사',
        categoryId: 'government',
        address: '서울 종로구 세종대로 209',
        phone: '02-2100-3399',
        type: '행정기관',
        lat: 37.5750,
        lng: 126.9768,
      ),
    ],
  };

  static List<LocalFacilitySeed> getByCategory(String categoryId) {
    return byCategory[categoryId] ?? const [];
  }

  static List<LocalFacilitySeed> get all {
    return byCategory.values.expand((items) => items).toList();
  }
}
