import 'package:flutter/material.dart';
import '../service/non_payment_service.dart';

class NonPaymentCategory {
  final String name;
  final List<NonPaymentItem> items;

  const NonPaymentCategory({
    required this.name,
    required this.items,
  });
}

class NonPaymentItem {
  final String hospitalName;
  final int minPrice;
  final int maxPrice;
  final int avgPrice;

  const NonPaymentItem({
    required this.hospitalName,
    required this.minPrice,
    required this.maxPrice,
    required this.avgPrice,
  });
}

class NonPaymentViewModel extends ChangeNotifier {
  final NonPaymentService _nonPaymentService = NonPaymentService();

  // ── 상태 변수 ──────────────────────────────
  List<NonPaymentCategory> _categories = [];
  List<NonPaymentCategory> _filteredCategories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchText = '';

  // ── Getter ─────────────────────────────────
  List<NonPaymentCategory> get categories => _filteredCategories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── 비급여 데이터 불러오기 ─────────────────
  Future<void> loadNonPayments({String? itemNm}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _nonPaymentService.getNonPaymentList(itemNm: itemNm);
      final grouped = _nonPaymentService.groupByItem(data);

      _categories = grouped.entries.map((entry) {
        return NonPaymentCategory(
          name: entry.key,
          items: entry.value.map((item) {
            return NonPaymentItem(
              hospitalName: item['hospitalName'] ?? '',
              minPrice: item['minPrice'] ?? 0,
              maxPrice: item['maxPrice'] ?? 0,
              avgPrice: item['avgPrice'] ?? 0,
            );
          }).toList(),
        );
      }).toList();

      _filteredCategories = _categories;
    } catch (e) {
      _errorMessage = '비급여 데이터를 불러오지 못했어요';
      debugPrint('비급여 로딩 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── 검색 필터링 ────────────────────────────
  void search(String query) {
    _searchText = query.trim();

    if (_searchText.isEmpty) {
      _filteredCategories = _categories;
    } else {
      _filteredCategories = _categories
          .where((c) =>
      c.name.contains(_searchText) ||
          c.items.any((i) => i.hospitalName.contains(_searchText)))
          .toList();
    }
    notifyListeners();
  }
}