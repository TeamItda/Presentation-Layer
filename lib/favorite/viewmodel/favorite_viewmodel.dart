import 'package:flutter/material.dart';
import '../service/favorite_service.dart';
import '../../facility/service/facility_translation_service.dart';

class FavoriteItem {
  final String id;
  final String name;
  final String category;
  final String address;
  final String distance;
  final double rating;

  const FavoriteItem({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.distance,
    required this.rating,
  });

  factory FavoriteItem.fromMap(Map<String, dynamic> map) {
    return FavoriteItem(
      id: map['facilityId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      address: map['address'] ?? '',
      distance: map['distance'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
    );
  }
}

class FavoriteViewModel extends ChangeNotifier {
  final FavoriteService _favoriteService = FavoriteService();
  final FacilityTranslationService _translationService = FacilityTranslationService();
  List<FavoriteItem> _originalFavorites = [];
  String _currentLang = 'ko';

  // ── 상태 변수 ──────────────────────────────
  List<FavoriteItem> _favorites = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getter ─────────────────────────────────
  List<FavoriteItem> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── 즐겨찾기 목록 불러오기 ─────────────────
  Future<void> loadFavorites() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _favoriteService.getFavorites();
      _originalFavorites = data.map((e) => FavoriteItem.fromMap(e)).toList();
      _favorites = List.from(_originalFavorites);

      // 현재 언어가 한국어가 아니면 번역
      if (_currentLang != 'ko') {
        await changeLang(_currentLang);
      }
    } catch (e) {
      _errorMessage = '즐겨찾기를 불러오지 못했어요';
      debugPrint('즐겨찾기 로딩 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── 즐겨찾기 추가 ──────────────────────────
  Future<void> addFavorite({
    required String facilityId,
    required String name,
    required String category,
    required String address,
    required String distance,
    required double rating,
  }) async {
    try {
      await _favoriteService.addFavorite(
        facilityId: facilityId,
        name: name,
        category: category,
        address: address,
        distance: distance,
        rating: rating,
      );
      await loadFavorites(); // 목록 새로고침
    } catch (e) {
      debugPrint('즐겨찾기 추가 실패: $e');
    }
  }

  // ── 즐겨찾기 삭제 ──────────────────────────
  Future<void> removeFavorite(String facilityId) async {
    try {
      await _favoriteService.removeFavorite(facilityId);
      _favorites.removeWhere((f) => f.id == facilityId);
      notifyListeners();
    } catch (e) {
      debugPrint('즐겨찾기 삭제 실패: $e');
    }
  }

  // ── 즐겨찾기 여부 확인 ─────────────────────
  Future<bool> isFavorite(String facilityId) async {
    return await _favoriteService.isFavorite(facilityId);
  }
  Future<void> changeLang(String lang) async {
    _currentLang = lang;

    if (lang == 'ko') {
      _favorites = List.from(_originalFavorites);
      notifyListeners();
      return;
    }

    if (_originalFavorites.isEmpty) return;

    final names = _originalFavorites.map((f) => f.name).toList();
    final addrs = _originalFavorites.map((f) => f.address).toList();

    final translatedNames = await _translationService.translateBatch(names, lang);
    final translatedAddrs = await _translationService.translateAddressBatch(addrs, lang);

    _favorites = List.generate(_originalFavorites.length, (i) {
      return FavoriteItem(
        id: _originalFavorites[i].id,
        name: translatedNames[i],
        category: _originalFavorites[i].category,
        address: translatedAddrs[i],
        distance: _originalFavorites[i].distance,
        rating: _originalFavorites[i].rating,
      );
    });

    notifyListeners();
  }
}