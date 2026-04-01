import 'package:flutter/material.dart';

class FacilityDetailViewModel extends ChangeNotifier {
  Map<String, dynamic>? _facility;
  bool _isFavorite = false;
  final List<Map<String, dynamic>> _reviews = [
    {'user': '김민수', 'rating': 5, 'text': '친절하고 좋아요.', 'date': '2025.02.15'},
    {'user': 'Sarah', 'rating': 4, 'text': 'Clean. English OK.', 'date': '2025.02.10'},
    {'user': '박지현', 'rating': 4, 'text': '진료 만족합니다.', 'date': '2025.01.28'},
  ];

  Map<String, dynamic>? get facility => _facility;
  bool get isFavorite => _isFavorite;
  List<Map<String, dynamic>> get reviews => _reviews;

  void setFacility(Map<String, dynamic> f) {
    _facility = f;
    notifyListeners();
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }
}