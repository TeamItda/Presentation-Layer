import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../favorite/service/favorite_service.dart';
import '../../review/service/review_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FavoriteService _favoriteService = FavoriteService();
  final ReviewService _reviewService = ReviewService();

  // ── 상태 변수 ──────────────────────────────
  String _userName = '';
  String _userEmail = '';
  String _currentLanguage = '한국어';
  int _reviewCount = 0;
  int _favoriteCount = 0;
  bool _isLoading = false;

  // ── Getter ─────────────────────────────────
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get currentLanguage => _currentLanguage;
  int get reviewCount => _reviewCount;
  int get favoriteCount => _favoriteCount;
  bool get isLoading => _isLoading;

  // ── 초기 데이터 불러오기 ──────────────────
  Future<void> loadUserData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Firebase Auth에서 유저 정보 가져오기
      final user = _auth.currentUser;
      if (user != null) {
        _userName = user.displayName ?? '이름 없음';
        _userEmail = user.email ?? '';
      }

      // 즐겨찾기 개수 가져오기
      final favorites = await _favoriteService.getFavorites();
      _favoriteCount = favorites.length;

      // 내 후기 개수 가져오기
      final reviews = await _reviewService.getMyReviews();
      _reviewCount = reviews.length;

    } catch (e) {
      debugPrint('유저 데이터 로딩 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── 언어 변경 ─────────────────────────────
  void changeLang(String locale) {
    switch (locale) {
      case 'ko': _currentLanguage = '한국어'; break;
      case 'en': _currentLanguage = 'English'; break;
      case 'zh': _currentLanguage = '中文'; break;
      case 'ja': _currentLanguage = '日本語'; break;
    }
    notifyListeners();
  }
}