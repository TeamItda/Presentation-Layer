import 'package:flutter/material.dart';

class AppConstants {
  static const String jongnoSidoCd = '110000';
  static const String jongnoSiGunGuCd = '110011';
  static const String chatBackendUrl = 'http://localhost:8000';
  static const String hiraApiKey = '';
  static const String neisApiKey = '';
  static const String childcareApiKey = '';   // 사회보장정보원 어린이집 API 키
  static const String kindergartenApiKey =
      '05e2c43f4df6475aa6b3ac3ac53d5bcd'; // 교육부 유치원알리미 API 키
  static const String kindergartenApiBaseUrl =
      'https://e-childschoolinfo.moe.go.kr/api/notice';
  static const String nhisApiKey = '';         // 건강보험심사평가원 장기요양기관 API 키
  static const String smallBizApiKey =
      '5ec247e8eb6fb09a9d6ab018d5c71685c2faf1a6854cd58219cb91115266e268';
  static const String cultureApiKey = '';      // 문화체육관광부 API 키
  static const String googleMapsApiKey =
      'AIzaSyDDxfuNuVSbsOg5myMHfVGGnG1tEPhlgFs';
  // 지도 초기 진입 중심은 종로구청 인근 좌표
  static const double jongnoCenterLat = 37.57295;
  static const double jongnoCenterLng = 126.97936;
  // 종로구 주변까지 여유 있게 둘러볼 수 있는 카메라 바운드
  static const double jongnoSouthLat = 37.5100;
  static const double jongnoWestLng = 126.8900;
  static const double jongnoNorthLat = 37.6500;
  static const double jongnoEastLng = 127.1000;

  // 카카오 지도 JavaScript SDK 키 (WebView용)
  static const String kakaoMapAppKey = 'a9f70751c51791b399a2b5b56eb8f889';
  // 카카오 디벨로퍼스 REST API 키. 
  static const String kakaoRestApiKey = 'f1a3cd800714f4b8835a3193f3949873';
  // 상명대학교 서울캠퍼스 정문 인근 좌표
  static const double smuCenterLat = 37.602493;
  static const double smuCenterLng = 126.955243;
}

class AppColors {
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFDBEAFE);
  static const Color navy = Color(0xFF1E3A5F);
  static const Color text = Color(0xFF1E293B);
  static const Color subText = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color background = Color(0xFFF5F6FA);
  static const Color card = Color(0xFFFFFFFF);
  static const Color medical = Color(0xFFEF4444);
  static const Color pharmacy = Color(0xFFEC4899);
  static const Color education = Color(0xFF3B82F6);
  static const Color childcare = Color(0xFFF59E0B);
  static const Color welfare = Color(0xFF10B981);
  static const Color food = Color(0xFFF97316);
  static const Color culture = Color(0xFF8B5CF6);
  static const Color government = Color(0xFF0891B2);
  static const Color chatGreen = Color(0xFF10B981);
}

class Category {
  final String id;
  final String name;
  final String icon;
  final IconData materialIcon;
  final Color color;
  final Color bgColor;
  final int count;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.materialIcon,
    required this.color,
    required this.bgColor,
    required this.count,
  });
}

final List<Category> categories = [
  Category(
    id: 'medical',
    name: '의료시설',
    icon: '🏥',
    materialIcon: Icons.local_hospital_rounded,
    color: AppColors.medical,
    bgColor: const Color(0xFFFEF2F2),
    count: 89,
  ),
  Category(
    id: 'pharmacy',
    name: '약국',
    icon: '💊',
    materialIcon: Icons.local_pharmacy_rounded,
    color: AppColors.pharmacy,
    bgColor: const Color(0xFFFDF2F8),
    count: 134,
  ),
  Category(
    id: 'education',
    name: '교육시설',
    icon: '🎓',
    materialIcon: Icons.school_rounded,
    color: AppColors.education,
    bgColor: const Color(0xFFEFF6FF),
    count: 67,
  ),
  Category(
    id: 'childcare',
    name: '육아돌봄',
    icon: '🍼',
    materialIcon: Icons.child_care_rounded,
    color: AppColors.childcare,
    bgColor: const Color(0xFFFFFBEB),
    count: 42,
  ),
  Category(
    id: 'welfare',
    name: '노인복지',
    icon: '🤝',
    materialIcon: Icons.volunteer_activism_rounded,
    color: AppColors.welfare,
    bgColor: const Color(0xFFECFDF5),
    count: 28,
  ),
  Category(
    id: 'food',
    name: '맛집',
    icon: '🍽',
    materialIcon: Icons.restaurant_rounded,
    color: AppColors.food,
    bgColor: const Color(0xFFFFF7ED),
    count: 156,
  ),
  Category(
    id: 'culture',
    name: '문화시설',
    icon: '🎭',
    materialIcon: Icons.museum_rounded,
    color: AppColors.culture,
    bgColor: const Color(0xFFF5F3FF),
    count: 45,
  ),
  Category(
    id: 'government',
    name: '공공기관',
    icon: '🏛',
    materialIcon: Icons.account_balance_rounded,
    color: AppColors.government,
    bgColor: const Color(0xFFECFEFF),
    count: 31,
  ),
];

Category getCategoryById(String id) {
  return categories.firstWhere((c) => c.id == id, orElse: () => categories[0]);
}
