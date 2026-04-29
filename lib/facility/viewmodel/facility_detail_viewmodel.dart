import 'package:flutter/material.dart';
import '../../favorite/service/favorite_service.dart';
import '../../review/service/review_service.dart';

class FacilityDetailViewModel extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();
  final ReviewService _reviewService = ReviewService();

  Map<String, dynamic>? _facility;
  bool _isFavorite = false;
  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> _myReviews = [];
  bool _isReviewLoading = false;

  Map<String, dynamic>? get facility => _facility;
  bool get isFavorite => _isFavorite;
  List<Map<String, dynamic>> get reviews => _reviews;
  List<Map<String, dynamic>> get myReviews => _myReviews;
  bool get isReviewLoading => _isReviewLoading;

  void setFacility(Map<String, dynamic> f) {
    _facility = f;
    _isFavorite = false;
    _reviews = [];
    _myReviews = [];
    notifyListeners();
    _checkFavorite(f['id']);
    loadReviews(f['id']);
  }

  Future<void> loadReviews(String facilityId) async {
    _isReviewLoading = true;
    notifyListeners();

    try {
      final allData = await _reviewService.getReviews(facilityId);
      _reviews = allData.map((r) => {
        'user': r['userName'] ?? '익명',
        'rating': r['rating'] ?? 0,
        'text': r['content'] ?? '',
        'date': _formatDate(r['createdAt']),
        'id': r['id'] ?? '',
        'uid': r['uid'] ?? '',
      }).toList();

      final myData = await _reviewService.getMyReviews();
      _myReviews = myData
          .where((r) => r['facilityId'] == facilityId)
          .map((r) => {
        'user': r['userName'] ?? '익명',
        'rating': r['rating'] ?? 0,
        'text': r['content'] ?? '',
        'date': _formatDate(r['createdAt']),
        'id': r['id'] ?? '',
        'uid': r['uid'] ?? '',
      }).toList();

    } catch (e) {
      debugPrint('후기 로딩 실패: $e');
    } finally {
      _isReviewLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _reviewService.deleteReview(reviewId);
      _reviews.removeWhere((r) => r['id'] == reviewId);
      _myReviews.removeWhere((r) => r['id'] == reviewId);
      notifyListeners();
    } catch (e) {
      debugPrint('후기 삭제 실패: $e');
    }
  }

  String _formatDate(dynamic createdAt) {
    if (createdAt == null) return '';
    try {
      final date = createdAt.toDate();
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
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