import 'package:flutter/material.dart';
import '../model/hospital_model.dart';
import '../model/pharmacy_model.dart';
import '../model/school_model.dart';
import '../service/hospital_service.dart';
import '../service/pharmacy_service.dart';
import '../service/school_service.dart';

class FacilityListViewModel extends ChangeNotifier {
  final HospitalService _hospitalService = HospitalService();
  final PharmacyService _pharmacyService = PharmacyService();
  final SchoolService _schoolService = SchoolService();

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
    _facilities = hospitals.map((h) => {
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
      'equipment': h.equipment.map((e) => {'name': e.name, 'count': e.count}).toList(),
    }).toList();
  }

  Future<void> _loadPharmacies() async {
    final pharmacies = await _pharmacyService.fetchPharmacies();
    _facilities = pharmacies.map((p) => {
      'id': p.id,
      'name': p.name,
      'addr': p.addr,
      'tel': p.tel,
      'rating': 0.0,
      'dist': '',
      'lat': p.lat,
      'lng': p.lng,
    }).toList();
  }

  Future<void> _loadSchools() async {
    final schools = await _schoolService.fetchSchools();
    _facilities = schools.map((s) => {
      'id': s.code,
      'name': s.name,
      'addr': '${s.addr} ${s.addrDetail}',
      'tel': s.tel,
      'rating': 0.0,
      'dist': '',
      'type': s.kind,
      'fondType': s.fondType,
      'homepage': s.homepage,
      'coedu': s.coedu,
      'hsType': s.hsType,
    }).toList();
  }
}