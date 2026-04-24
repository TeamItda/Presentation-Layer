import 'package:flutter/material.dart';
import '../../favorite/service/favorite_service.dart';

class FacilityDetailViewModel extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();

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
    _isFavorite = false;
    notifyListeners();
    _checkFavorite(f['id']);
  }

  Future<void> _checkFavorite(String facilityId) async {
    try {
      _isFavorite = await _favoriteService.isFavorite(facilityId);
      notifyListeners();
    } catch (e) {
      debugPrint('즐겨찾기 확인 실패: $e');
    }
  }

  Future<void> toggleFavorite() async {
    if (_facility == null) return;
    try {
      if (_isFavorite) {
        await _favoriteService.removeFavorite(_facility!['id']);
      } else {
        await _favoriteService.addFavorite(
          facilityId: _facility!['id'],
          name: _facility!['name'] ?? '',
          category: _facility!['type'] ?? '',
          address: _facility!['addr'] ?? '',
          distance: _facility!['dist'] ?? '',
          rating: (_facility!['rating'] ?? 0.0).toDouble(),
        );
      }
      _isFavorite = !_isFavorite;
      notifyListeners();
    } catch (e) {
      debugPrint('즐겨찾기 토글 실패: $e');
    }
  }
}