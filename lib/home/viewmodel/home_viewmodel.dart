import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final List<Map<String, dynamic>> featuredFacilities = [
    {'id': '1', 'name': '서울대학교병원', 'addr': '종로구 대학로 101', 'rating': 4.5, 'dist': '0.8km', 'category': 'medical', 'icon': '🏥'},
    {'id': '11', 'name': '광장시장 빈대떡', 'addr': '종로구 창경궁로 88', 'rating': 4.8, 'dist': '0.4km', 'category': 'food', 'icon': '🍽'},
    {'id': '15', 'name': '국립현대미술관 서울', 'addr': '종로구 삼청로 30', 'rating': 4.7, 'dist': '0.9km', 'category': 'culture', 'icon': '🎭'},
  ];
}