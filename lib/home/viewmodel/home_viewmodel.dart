import 'package:flutter/material.dart';
import '../../facility/service/hospital_service.dart';
import '../../facility/service/pharmacy_service.dart';
import '../../facility/service/school_service.dart';
import '../../facility/service/facility_translation_service.dart';

class HomeViewModel extends ChangeNotifier {
  final HospitalService _hospitalService = HospitalService();
  final PharmacyService _pharmacyService = PharmacyService();
  final SchoolService _schoolService = SchoolService();
  final FacilityTranslationService _translationService =
      FacilityTranslationService();

  List<Map<String, dynamic>> _featuredFacilities = [];
  bool _isLoading = false;
  bool _loaded = false;
  String _currentLang = 'ko';

  List<Map<String, dynamic>> get featuredFacilities => _featuredFacilities;
  bool get isLoading => _isLoading;

  Future<void> loadFeatured() async {
    if (_loaded) return;
    _isLoading = true;
    notifyListeners();

    try {
      final hospitals = await _hospitalService.fetchHospitals();
      final pharmacies = await _pharmacyService.fetchPharmacies();

      _featuredFacilities = [];

      // 병원에서 대표 시설 찾기
      for (final h in hospitals) {
        if (h.name.contains('강북삼성병원')) {
          _featuredFacilities.add({
            'id': h.id,
            'name': h.name,
            'addr': h.addr,
            'tel': h.tel,
            'rating': 4.5,
            'dist': '0.8km',
            'category': 'medical',
            'type': h.type,
            'homepage': h.homepage,
            'lat': h.lat,
            'lng': h.lng,
            'totalDocs': h.totalDocs,
            'specialists': h.specialists,
            'dept': h.departmentsText,
            'equip': h.equipmentText,
          });
          break;
        }
      }

      // 약국에서 대표 시설 찾기
      for (final p in pharmacies) {
        if (p.name.contains('가람약국')) {
          _featuredFacilities.add({
            'id': p.id,
            'name': p.name,
            'addr': p.addr,
            'tel': p.tel,
            'rating': 4.3,
            'dist': '0.4km',
            'category': 'pharmacy',
          });
          break;
        }
      }

      // 학교 API 호출
      try {
        final schools = await _schoolService.fetchSchools();
        for (final s in schools) {
          if (s.name.contains('경기상업고등학교')) {
            _featuredFacilities.add({
              'id': s.code,
              'name': s.name,
              'addr': '${s.addr} ${s.addrDetail}',
              'tel': s.tel,
              'rating': 4.2,
              'dist': '0.9km',
              'category': 'education',
              'type': s.kind,
              'fondType': s.fondType,
              'coedu': s.coedu,
              'hsType': s.hsType,
              'homepage': s.homepage,
            });
            break;
          }
        }
      } catch (_) {}

      _loaded = true;

      // 로드 완료 후 현재 언어가 한국어가 아니면 번역 적용
      if (_currentLang != 'ko') {
        await _translate(_currentLang);
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }

  /// 언어 변경 — 아직 로드 안 됐으면 먼저 로드(로드 후 자동 번역).
  Future<void> changeLang(String lang) async {
    _currentLang = lang;

    if (!_loaded) {
      await loadFeatured();
      return;
    }

    if (lang == 'ko') {
      _restoreOriginals();
      notifyListeners();
      return;
    }

    await _translate(lang);
    notifyListeners();
  }

  void _restoreOriginals() {
    for (final f in _featuredFacilities) {
      if (f['_originalName'] != null) f['name'] = f['_originalName'];
      if (f['_originalAddr'] != null) f['addr'] = f['_originalAddr'];
    }
  }

  Future<void> _translate(String lang) async {
    if (_featuredFacilities.isEmpty) return;

    // 원본 보존 (최초 1회)
    for (final f in _featuredFacilities) {
      f['_originalName'] ??= f['name'];
      f['_originalAddr'] ??= f['addr'];
    }

    final names = _featuredFacilities
        .map((f) => f['_originalName'] as String? ?? '')
        .toList();
    final addrs = _featuredFacilities
        .map((f) => f['_originalAddr'] as String? ?? '')
        .toList();

    final translatedNames =
        await _translationService.translateBatch(names, lang);
    final translatedAddrs =
        await _translationService.translateAddressBatch(addrs, lang);

    for (var i = 0; i < _featuredFacilities.length; i++) {
      _featuredFacilities[i]['name'] = translatedNames[i];
      _featuredFacilities[i]['addr'] = translatedAddrs[i];
    }
  }
}
