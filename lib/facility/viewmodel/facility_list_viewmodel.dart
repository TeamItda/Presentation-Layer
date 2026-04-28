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

class FacilityListViewModel extends ChangeNotifier {
  final HospitalService _hospitalService = HospitalService();
  final PharmacyService _pharmacyService = PharmacyService();
  final SchoolService _schoolService = SchoolService();
  final ChildcareService _childcareService = ChildcareService();
  final WelfareService _welfareService = WelfareService();
  final RestaurantService _restaurantService = RestaurantService();
  final CultureService _cultureService = CultureService();
  final GovernmentService _governmentService = GovernmentService();

  final Map<String, LatLng?> _coordinateCache = <String, LatLng?>{};

  List<Map<String, dynamic>> _facilities = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String _viewMode = 'list';

  List<Map<String, dynamic>> get facilities => _facilities;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  String get viewMode => _viewMode;

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
              'type': r.category,
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
