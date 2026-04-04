import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../service/hospital_service.dart';
import '../service/pharmacy_service.dart';
import '../service/school_service.dart';

class FacilityListViewModel extends ChangeNotifier {
  final HospitalService _hospitalService = HospitalService();
  final PharmacyService _pharmacyService = PharmacyService();
  final SchoolService _schoolService = SchoolService();

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
        default:
          _facilities = [];
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = '데이터를 불러오지 못했습니다: $e';
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
      final address = '${school.addr} ${school.addrDetail}'.trim();
      final position = await _resolveCoordinate(address);

      facilities.add({
        'id': school.code,
        'name': school.name,
        'addr': address,
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

  Future<LatLng?> _resolveCoordinate(String address) async {
    if (address.isEmpty) {
      return null;
    }
    if (_coordinateCache.containsKey(address)) {
      return _coordinateCache[address];
    }

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
