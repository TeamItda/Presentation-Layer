import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchViewModel extends ChangeNotifier {
  // 최근 검색어 저장 키
  static const String _recentSearchKey = 'recent_searches';
  // 최근 검색어 최대 개수
  static const int _maxRecentSearches = 10;

  // ── 상태 변수 ──────────────────────────────
  List<String> _recentSearches = [];
  String _searchText = '';
  bool _isLoading = false;

  // ── Getter ─────────────────────────────────
  List<String> get recentSearches => _recentSearches;
  String get searchText => _searchText;
  bool get isLoading => _isLoading;

  // ── 초기화 (최근 검색어 불러오기) ──────────
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches = prefs.getStringList(_recentSearchKey) ?? [];
    } catch (e) {
      debugPrint('최근 검색어 로딩 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── 검색어 변경 ────────────────────────────
  void onSearchChanged(String query) {
    _searchText = query.trim();
    notifyListeners();
  }

  // ── 검색어 제출 (최근 검색어 저장) ─────────
  Future<void> submitSearch(String keyword) async {
    if (keyword.trim().isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      // 중복 제거 후 맨 앞에 추가
      _recentSearches.remove(keyword);
      _recentSearches.insert(0, keyword);

      // 최대 개수 초과 시 마지막 제거
      if (_recentSearches.length > _maxRecentSearches) {
        _recentSearches = _recentSearches.sublist(0, _maxRecentSearches);
      }

      await prefs.setStringList(_recentSearchKey, _recentSearches);
      notifyListeners();
    } catch (e) {
      debugPrint('검색어 저장 실패: $e');
    }
  }

  // ── 최근 검색어 하나 삭제 ──────────────────
  Future<void> removeRecentSearch(String keyword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches.remove(keyword);
      await prefs.setStringList(_recentSearchKey, _recentSearches);
      notifyListeners();
    } catch (e) {
      debugPrint('검색어 삭제 실패: $e');
    }
  }

  // ── 최근 검색어 전체 삭제 ─────────────────
  Future<void> clearRecentSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _recentSearches = [];
      await prefs.remove(_recentSearchKey);
      notifyListeners();
    } catch (e) {
      debugPrint('검색어 전체 삭제 실패: $e');
    }
  }

  // ── 검색어 초기화 ──────────────────────────
  void clearSearchText() {
    _searchText = '';
    notifyListeners();
  }
}