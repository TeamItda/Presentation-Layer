import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../service/childcare_service.dart';
import '../service/culture_service.dart';
import '../service/government_service.dart';
import '../service/hospital_service.dart';
import '../service/pharmacy_service.dart';
import '../service/restaurant_service.dart';
import '../service/school_service.dart';
import '../service/welfare_service.dart';
import '../service/facility_translation_service.dart'; // 추가

class FacilityListViewModel extends ChangeNotifier {
  final HospitalService _hospitalService = HospitalService();
  final PharmacyService _pharmacyService = PharmacyService();
  final SchoolService _schoolService = SchoolService();
  final ChildcareService _childcareService = ChildcareService();
  final WelfareService _welfareService = WelfareService();
  final RestaurantService _restaurantService = RestaurantService();
  final CultureService _cultureService = CultureService();
  final GovernmentService _governmentService = GovernmentService();
  final FacilityTranslationService _translationService = FacilityTranslationService(); // 추가

  final Map<String, LatLng?> _coordinateCache = <String, LatLng?>{};

  // 번역 캐시: 'en_name_서울대학교병원' → 'Seoul National University Hospital'
  final Map<String, String> _translationCache = {};

  List<Map<String, dynamic>> _facilities = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _viewMode = 'list';
  String _currentLang = 'ko'; // 현재 언어
  bool _isTranslating = false; // 번역 로딩 상태

  List<Map<String, dynamic>> get facilities => _facilities;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  String get viewMode => _viewMode;
  String get currentLang => _currentLang;
  bool get isTranslating => _isTranslating;

  List<Map<String, dynamic>> get mappableFacilities {
    return _facilities.where((facility) {
      final lat = facility['lat'];
      final lng = facility['lng'];
      return lat is num && lng is num && lat != 0 && lng != 0;
    }).toList();
  }

  void toggleViewMode() {
    _viewMode = _viewMode == 'list' ? 'map' : 'list';
    notifyListeners();
  }

  /// 언어 변경 시 호출 — chat_viewmodel의 changeLang과 연동
  Future<void> changeLang(String lang) async {
    if (_currentLang == lang) return;
    _currentLang = lang;

    // 한국어면 번역 불필요
    if (lang == 'ko') {
      _restoreOriginals();
      notifyListeners();
      return;
    }

    await _translateFacilities(lang);
  }

  /// 원본 한국어로 복원
  void _restoreOriginals() {
    for (final f in _facilities) {
      if (f['_originalName'] != null) f['name'] = f['_originalName'];
      if (f['_originalAddr'] != null) f['addr'] = f['_originalAddr'];
    }
  }

  /// 시설 목록 전체 배치 번역
  Future<void> _translateFacilities(String lang) async {
    _isTranslating = true;
    notifyListeners();

    // 원본 보존 (최초 1회)
    for (final f in _facilities) {
      f['_originalName'] ??= f['name'];
      f['_originalAddr'] ??= f['addr'];
      f['_originalDept'] ??= f['dept'];
      f['_originalEquip'] ??= f['equip'];
    }

    // 캐시에 없는 것만 추려서 배치 번역
    final namesToTranslate = <String>[];
    final addrsToTranslate = <String>[];
    final deptToTranslate = <String>[];
    final equipToTranslate = <String>[];

    for (final f in _facilities) {
      final originalName = f['_originalName'] as String? ?? '';
      final originalAddr = f['_originalAddr'] as String? ?? '';
      final originalDept = f['_originalDept'] as String? ?? '';
      final originalEquip = f['_originalEquip'] as String? ?? '';

      if (!_translationCache.containsKey('${lang}_name_$originalName')) {
        if (!namesToTranslate.contains(originalName)) namesToTranslate.add(originalName);
      }
      if (!_translationCache.containsKey('${lang}_addr_$originalAddr')) {
        if (!addrsToTranslate.contains(originalAddr)) addrsToTranslate.add(originalAddr);
      }
      if (originalDept.isNotEmpty && !_translationCache.containsKey('${lang}_dept_$originalDept')) {
        if (!deptToTranslate.contains(originalDept)) deptToTranslate.add(originalDept);
      }
      if (originalEquip.isNotEmpty && !_translationCache.containsKey('${lang}_equip_$originalEquip')) {
        if (!equipToTranslate.contains(originalEquip)) equipToTranslate.add(originalEquip);
      }
    }

    // 시설명 배치 번역 (API 1번 호출)
    if (namesToTranslate.isNotEmpty) {
      final translated = await _translationService.translateBatch(namesToTranslate, lang);
      for (var i = 0; i < namesToTranslate.length; i++) {
        _translationCache['${lang}_name_${namesToTranslate[i]}'] = translated[i];
      }
    }

    // 주소 배치 로마자 변환 + 번역 (병렬 처리)
    if (addrsToTranslate.isNotEmpty) {
      final translated = await _translationService.translateAddressBatch(addrsToTranslate, lang);
      for (var i = 0; i < addrsToTranslate.length; i++) {
        _translationCache['${lang}_addr_${addrsToTranslate[i]}'] = translated[i];
      }
    }

    // 진료과 배치 번역
    if (deptToTranslate.isNotEmpty) {
      final translated = await _translationService.translateBatch(deptToTranslate, lang);
      for (var i = 0; i < deptToTranslate.length; i++) {
        _translationCache['${lang}_dept_${deptToTranslate[i]}'] = translated[i];
      }
    }

    // 장비 배치 번역
    if (equipToTranslate.isNotEmpty) {
      final translated = await _translationService.translateBatch(equipToTranslate, lang);
      for (var i = 0; i < equipToTranslate.length; i++) {
        _translationCache['${lang}_equip_${equipToTranslate[i]}'] = translated[i];
      }
    }

    // 캐시에서 번역 결과 적용
    for (final f in _facilities) {
      final originalName = f['_originalName'] as String? ?? '';
      final originalAddr = f['_originalAddr'] as String? ?? '';
      final originalDept = f['_originalDept'] as String? ?? '';
      final originalEquip = f['_originalEquip'] as String? ?? '';

      f['name'] = _translationCache['${lang}_name_$originalName'] ?? originalName;
      f['addr'] = _translationCache['${lang}_addr_$originalAddr'] ?? originalAddr;
      if (originalDept.isNotEmpty) {
        f['dept'] = _translationCache['${lang}_dept_$originalDept'] ?? originalDept;
      }
      if (originalEquip.isNotEmpty) {
        f['equip'] = _translationCache['${lang}_equip_$originalEquip'] ?? originalEquip;
      }
    }

    _isTranslating = false;
    notifyListeners();
  }

  Future<void> loadFacilities(String categoryId) async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    try {
      switch (categoryId) {
        case 'medical':
          await _loadHospitals();
          break;
        case 'pharmacy':
          await _loadPharmacies();
          break;
        case 'education':
          await _loadSchools();
          break;
        case 'childcare':
          await _loadChildcares();
          break;
        case 'welfare':
          await _loadWelfares();
          break;
        case 'food':
          await _loadRestaurants();
          break;
        case 'culture':
          await _loadCultures();
          break;
        case 'government':
          await _loadGovernments();
          break;
        default:
          _facilities = [];
      }

      // 로드 완료 후 현재 언어가 한국어가 아니면 바로 번역
      if (_currentLang != 'ko') {
        await _translateFacilities(_currentLang);
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = '데이터를 불러오지 못했습니다. $e';
      _facilities = [];
    }

    _isLoading = false;
    notifyListeners();
  }


  Future<void> _loadHospitals() async {
    final hospitals = await _hospitalService.fetchHospitals();
    _facilities = hospitals
        .map(
          (h) => {
        'id': h.id,
        'name': h.name,
        'addr': h.addr,
        'tel': h.tel,
        'rating': 0.0,
        'dist': '',
        'type': h.type,
        'homepage': h.homepage,
        'lat': h.lat,
        'lng': h.lng,
        'totalDocs': h.totalDocs,
        'specialists': h.specialists,
        'dept': h.departmentsText,
        'equip': h.equipmentText,
        'departments': h.departments,
        'equipment': h.equipment
            .map((e) => {'name': e.name, 'count': e.count})
            .toList(),
      },
    )
        .toList();
  }

  Future<void> _loadPharmacies() async {
    final pharmacies = await _pharmacyService.fetchPharmacies();
    _facilities = pharmacies
        .map(
          (p) => {
        'id': p.id,
        'name': p.name,
        'addr': p.addr,
        'tel': p.tel,
        'rating': 0.0,
        'dist': '',
        'lat': p.lat,
        'lng': p.lng,
      },
    )
        .toList();
  }

  Future<void> _loadSchools() async {
    final schools = await _schoolService.fetchSchools();
    final facilities = <Map<String, dynamic>>[];

    for (final school in schools) {
      final position = school.lat != null && school.lng != null
          ? LatLng(school.lat!, school.lng!)
          : await _resolveCoordinate(school.geocodingAddress);

      facilities.add({
        'id': school.code,
        'name': school.name,
        'addr': school.displayAddress,
        'tel': school.tel,
        'rating': 0.0,
        'dist': '',
        'type': school.kind,
        'fondType': school.fondType,
        'homepage': school.homepage,
        'coedu': school.coedu,
        'hsType': school.hsType,
        'lat': position?.latitude ?? 0.0,
        'lng': position?.longitude ?? 0.0,
      });
    }

    _facilities = facilities;
  }

  Future<void> _loadChildcares() async {
    final list = await _childcareService.fetchChildcares();
    _facilities = list
        .map((c) => {
      'id': c.id,
      'name': c.name,
      'addr': c.addr,
      'tel': c.tel,
      'type': c.typeLabel,
      'publicPrivate': c.publicPrivateLabel,
      'operatingHours': c.operatingHours ?? '',
      'homepage': c.homepage ?? '',
      'rating': 0.0,
      'dist': '',
      'lat': c.lat ?? 0.0,
      'lng': c.lng ?? 0.0,
      'capacity': c.capacity,
      'currentCount': c.currentCount,
      'hasCctv': c.hasCctv,
      'staffCount': c.staffCount,
      'occupancyRate': c.occupancyRate,
    })
        .toList();
  }

  Future<void> _loadWelfares() async {
    final list = await _welfareService.fetchWelfares();
    _facilities = list
        .map((w) => {
      'id': w.id,
      'name': w.name,
      'addr': w.addr,
      'tel': w.tel,
      'type': w.type,
      'homepage': w.homepage ?? '',
      'rating': 0.0,
      'dist': '',
      'lat': w.lat ?? 0.0,
      'lng': w.lng ?? 0.0,
      'capacity': w.capacity,
      'staffCount': w.staffCount,
      if (w.longTermAdminSym != null && w.longTermAdminSym!.isNotEmpty)
        'longTermAdminSym': w.longTermAdminSym,
      if (w.adminPttnCd != null && w.adminPttnCd!.isNotEmpty)
        'adminPttnCd': w.adminPttnCd,
    })
        .toList();
  }

  Future<void> _loadRestaurants() async {
    final list = await _restaurantService.fetchRestaurants();
    _facilities = list
        .map((r) => {
      'id': r.id,
      'name': r.name,
      'addr': r.addr,
      'tel': r.tel,
      // 'type': sdsc2 표준 라벨(예: '일식 면 요리'/'카페'/'중국집').
      // food_facility_code.csv 매핑 → indsSclsCd 또는 cuisine 기반 추정 라벨.
      'type': r.displayCategoryLabel,
      'homepage': r.homepage ?? '',
      'rating': r.rating,
      'dist': '',
      'lat': r.lat ?? 0.0,
      'lng': r.lng ?? 0.0,
      'category': r.category,
    })
        .toList();
  }

  Future<void> _loadCultures() async {
    final list = await _cultureService.fetchCultures();
    _facilities = list
        .map((c) => {
      'id': c.id,
      'name': c.name,
      'addr': c.addr,
      'tel': c.tel,
      'type': c.type,
      'homepage': c.homepage ?? '',
      'rating': 0.0,
      'dist': '',
      'lat': c.lat ?? 0.0,
      'lng': c.lng ?? 0.0,
    })
        .toList();
  }

  Future<void> _loadGovernments() async {
    final list = await _governmentService.fetchGovernments();
    _facilities = list
        .map((g) => {
      'id': g.id,
      'name': g.name,
      'addr': g.addr,
      'tel': g.tel,
      'type': g.type,
      'homepage': g.homepage ?? '',
      'operatingHours': g.displayOperatingHours,
      'rating': 0.0,
      'dist': '',
      'lat': g.lat ?? 0.0,
      'lng': g.lng ?? 0.0,
    })
        .toList();
  }

  Future<LatLng?> _resolveCoordinate(String address) async {
    if (address.isEmpty) return null;
    if (_coordinateCache.containsKey(address)) return _coordinateCache[address];

    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) {
        _coordinateCache[address] = null;
        return null;
      }
      final position = LatLng(
        locations.first.latitude,
        locations.first.longitude,
      );
      _coordinateCache[address] = position;
      return position;
    } catch (_) {
      _coordinateCache[address] = null;
      return null;
    }
  }
}