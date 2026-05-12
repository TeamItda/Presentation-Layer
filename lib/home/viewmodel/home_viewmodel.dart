import 'package:flutter/material.dart';
import '../../facility/service/facility_translation_service.dart';

class HomeViewModel extends ChangeNotifier {
  final FacilityTranslationService _translationService = FacilityTranslationService();

  final List<Map<String, dynamic>> _originalFacilities = [
    {'id': '1', 'name': '서울대학교병원', 'addr': '종로구 대학로 101', 'rating': 4.5, 'dist': '0.8km', 'category': 'medical', 'icon': '🏥'},
    {'id': '11', 'name': '광장시장 빈대떡', 'addr': '종로구 창경궁로 88', 'rating': 4.8, 'dist': '0.4km', 'category': 'food', 'icon': '🍽'},
    {'id': '15', 'name': '국립현대미술관 서울', 'addr': '종로구 삼청로 30', 'rating': 4.7, 'dist': '0.9km', 'category': 'culture', 'icon': '🎭'},
  ];

  List<Map<String, dynamic>> featuredFacilities = [];

  HomeViewModel() {
    featuredFacilities = List.from(_originalFacilities);
  }

  Future<void> changeLang(String lang) async {
    if (lang == 'ko') {
      featuredFacilities = List.from(_originalFacilities);
      notifyListeners();
      return;
    }

    final names = _originalFacilities.map((f) => f['name'] as String).toList();
    final addrs = _originalFacilities.map((f) => f['addr'] as String).toList();

    final translatedNames = await _translationService.translateBatch(names, lang);
    final translatedAddrs = await _translationService.translateAddressBatch(addrs, lang);

    featuredFacilities = List.generate(_originalFacilities.length, (i) {
      return {
        ..._originalFacilities[i],
        'name': translatedNames[i],
        'addr': translatedAddrs[i],
      };
    });

    notifyListeners();
  }
}