import 'package:flutter/material.dart';

class AppConstants {
  static const String jongnoSidoCd = '110000';
  static const String jongnoSiGunGuCd = '110011';
  static const String chatBackendUrl = 'http://localhost:8000';
  static const String hiraApiKey = '';
  static const String neisApiKey = '';
  static const String googleMapsApiKey =
      'AIzaSyDDxfuNuVSbsOg5myMHfVGGnG1tEPhlgFs';
  // 지도 초기 진입 중심은 종로구청 인근 좌표
  static const double jongnoCenterLat = 37.57295;
  static const double jongnoCenterLng = 126.97936;
  // 종로구보다 살짝 넓은 범위로 지도 제한
  static const double jongnoSouthLat = 37.5450;
  static const double jongnoWestLng = 126.9320;
  static const double jongnoNorthLat = 37.6100;
  static const double jongnoEastLng = 127.0560;
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
  final Color color;
  final Color bgColor;
  final int count;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
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
    color: AppColors.medical,
    bgColor: const Color(0xFFFEF2F2),
    count: 89,
  ),
  Category(
    id: 'pharmacy',
    name: '약국',
    icon: '💊',
    color: AppColors.pharmacy,
    bgColor: const Color(0xFFFDF2F8),
    count: 134,
  ),
  Category(
    id: 'education',
    name: '교육시설',
    icon: '🎓',
    color: AppColors.education,
    bgColor: const Color(0xFFEFF6FF),
    count: 67,
  ),
  Category(
    id: 'childcare',
    name: '육아돌봄',
    icon: '🍼',
    color: AppColors.childcare,
    bgColor: const Color(0xFFFFFBEB),
    count: 42,
  ),
  Category(
    id: 'welfare',
    name: '노인복지',
    icon: '🤝',
    color: AppColors.welfare,
    bgColor: const Color(0xFFECFDF5),
    count: 28,
  ),
  Category(
    id: 'food',
    name: '맛집',
    icon: '🍽',
    color: AppColors.food,
    bgColor: const Color(0xFFFFF7ED),
    count: 156,
  ),
  Category(
    id: 'culture',
    name: '문화시설',
    icon: '🎭',
    color: AppColors.culture,
    bgColor: const Color(0xFFF5F3FF),
    count: 45,
  ),
  Category(
    id: 'government',
    name: '공공기관',
    icon: '🏛',
    color: AppColors.government,
    bgColor: const Color(0xFFECFEFF),
    count: 31,
  ),
];

Category getCategoryById(String id) {
  return categories.firstWhere((c) => c.id == id, orElse: () => categories[0]);
}
