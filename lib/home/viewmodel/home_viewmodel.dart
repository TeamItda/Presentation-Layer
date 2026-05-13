import 'package:flutter/material.dart';
import '../../facility/service/hospital_service.dart';
import '../../facility/service/pharmacy_service.dart';
import '../../facility/service/school_service.dart';

class HomeViewModel extends ChangeNotifier {
  final HospitalService _hospitalService = HospitalService();
  final PharmacyService _pharmacyService = PharmacyService();
  final SchoolService _schoolService = SchoolService();

  List<Map<String, dynamic>> _featuredFacilities = [];
  bool _isLoading = false;
  bool _loaded = false;

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
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
  }
}
