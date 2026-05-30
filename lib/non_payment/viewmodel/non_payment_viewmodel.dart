import 'package:flutter/material.dart';

import '../../facility/service/facility_translation_service.dart';
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
  final FacilityTranslationService _translationService =
      FacilityTranslationService();

  String _currentLang = 'ko';
  List<NonPaymentCategory> _originalCategories = [];
  List<NonPaymentCategory> _categories = [];
  List<NonPaymentCategory> _filteredCategories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchText = '';

  List<NonPaymentCategory> get categories => _filteredCategories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadNonPayments({
    String? itemNm,
    String? hospitalId,
    String? hospitalName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _nonPaymentService.getNonPaymentList(
        itemNm: itemNm,
        hospitalId: hospitalId,
        hospitalName: hospitalName,
      );
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
      _originalCategories = List.from(_categories);
      _filteredCategories = _categories;

      if (_currentLang != 'ko') {
        await changeLang(_currentLang);
      }
    } catch (e) {
      _errorMessage = '비급여 데이터를 불러오지 못했어요';
      debugPrint('비급여 로딩 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchText = query.trim();

    if (_searchText.isEmpty) {
      _filteredCategories = _categories;
    } else {
      _filteredCategories = _categories
          .where(
            (category) =>
                category.name.contains(_searchText) ||
                category.items
                    .any((item) => item.hospitalName.contains(_searchText)),
          )
          .toList();
    }
    notifyListeners();
  }

  Future<void> changeLang(String lang) async {
    _currentLang = lang;

    if (lang == 'ko') {
      _categories = List.from(_originalCategories);
      _filteredCategories = _categories;
      notifyListeners();
      return;
    }

    if (_originalCategories.isEmpty) return;

    final categoryNames = _originalCategories.map((c) => c.name).toList();
    final translatedCategoryNames =
        await _translationService.translateBatch(categoryNames, lang);

    final allHospitalNames = _originalCategories
        .expand((category) => category.items.map((item) => item.hospitalName))
        .toSet()
        .toList();
    final translatedHospitalNames =
        await _translationService.translateBatch(allHospitalNames, lang);
    final hospitalNameMap =
        Map.fromIterables(allHospitalNames, translatedHospitalNames);

    _categories = List.generate(_originalCategories.length, (index) {
      return NonPaymentCategory(
        name: translatedCategoryNames[index],
        items: _originalCategories[index].items.map((item) {
          return NonPaymentItem(
            hospitalName: hospitalNameMap[item.hospitalName] ?? item.hospitalName,
            minPrice: item.minPrice,
            maxPrice: item.maxPrice,
            avgPrice: item.avgPrice,
          );
        }).toList(),
      );
    });

    _filteredCategories = _categories;
    notifyListeners();
  }
}
