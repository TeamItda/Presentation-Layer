import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants.dart';
import '../../facility/service/hospital_service.dart';
import '../../facility/service/pharmacy_service.dart';
import '../../facility/service/school_service.dart';
import '../model/map_facility.dart';

class MapViewModel extends ChangeNotifier {
  MapViewModel({
    HospitalService? hospitalService,
    PharmacyService? pharmacyService,
    SchoolService? schoolService,
  }) : _hospitalService = hospitalService ?? HospitalService(),
       _pharmacyService = pharmacyService ?? PharmacyService(),
       _schoolService = schoolService ?? SchoolService();

  final HospitalService _hospitalService;
  final PharmacyService _pharmacyService;
  final SchoolService _schoolService;

// 마커 이미지 
  static const List<FacilityTypeOption> typeOptions = [
    FacilityTypeOption(
      id: 'all',
      label: '전체',
      color: Color(0xFF2563EB),
      icon: Icons.apps_rounded,
    ),
    FacilityTypeOption(
      id: 'medical',
      label: '병원',
      color: Color(0xFFDC2626),
      icon: Icons.local_hospital_rounded,
    ),
    FacilityTypeOption(
      id: 'pharmacy',
      label: '약국',
      color: Color(0xFF16A34A),
      icon: Icons.local_pharmacy_rounded,
    ),
    FacilityTypeOption(
      id: 'education',
      label: '학교',
      color: Color(0xFF7C3AED),
      icon: Icons.school_rounded,
    ),
  ];

  bool _isLoading = false;
  bool _initialized = false;
  String? _errorMessage;
  String _selectedTypeId = 'all';
  List<MapFacility> _facilities = const [];
  final Map<String, BitmapDescriptor> _markerIcons =
      <String, BitmapDescriptor>{};
  final Map<String, LatLng?> _geocodeCache = <String, LatLng?>{};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedTypeId => _selectedTypeId;

  List<MapFacility> get filteredFacilities {
    if (_selectedTypeId == 'all') {
      return _facilities;
    }
    return _facilities
        .where((facility) => facility.type == _selectedTypeId)
        .toList();
  }

  Set<Marker> get markers {
    return filteredFacilities.map((facility) {
      final option = optionFor(facility.type);
      return Marker(
        markerId: MarkerId(facility.id),
        position: facility.position,
        icon: _markerIcons[facility.type] ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: facility.name,
          snippet: [
            option.label,
            if (facility.address != null && facility.address!.isNotEmpty)
              facility.address!,
          ].join(' · '),
        ),
      );
    }).toSet();
  }

  CameraPosition get initialCameraPosition => const CameraPosition(
    target: LatLng(AppConstants.jongnoCenterLat, AppConstants.jongnoCenterLng),
    zoom: 14.1,
  );

  CameraTargetBounds get cameraTargetBounds => CameraTargetBounds(
    LatLngBounds(
      southwest: const LatLng(
        AppConstants.jongnoSouthLat,
        AppConstants.jongnoWestLng,
      ),
      northeast: const LatLng(
        AppConstants.jongnoNorthLat,
        AppConstants.jongnoEastLng,
      ),
    ),
  );

  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await refresh();
  }

  Future<void> refresh() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ensureMarkerIcons();
      _facilities = await _loadFacilitiesFromServices();
      if (_facilities.isEmpty) {
        _errorMessage = '시설 목록 데이터에서 표시할 좌표를 찾지 못했습니다.';
      }
    } catch (error) {
      _facilities = const [];
      _errorMessage = '시설 목록 데이터를 불러오지 못했습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectType(String typeId) {
    if (_selectedTypeId == typeId) {
      return;
    }
    _selectedTypeId = typeId;
    notifyListeners();
  }

  FacilityTypeOption optionFor(String typeId) {
    return typeOptions.firstWhere(
      (option) => option.id == typeId,
      orElse: () => typeOptions.first,
    );
  }

  Future<void> _ensureMarkerIcons() async {
    for (final option in typeOptions.where((entry) => entry.id != 'all')) {
      _markerIcons[option.id] = await _buildMarkerIcon(option);
    }
  }

  Future<List<MapFacility>> _loadFacilitiesFromServices() async {
    final hospitals = await _hospitalService.fetchHospitals();
    final pharmacies = await _pharmacyService.fetchPharmacies();
    final schools = await _schoolService.fetchSchools();

    final facilities = <MapFacility>[
      for (final hospital in hospitals)
        if (_isValidCoordinate(hospital.lat, hospital.lng))
          MapFacility(
            id: 'medical:${hospital.id}',
            name: hospital.name,
            type: 'medical',
            collectionName: 'facility_list',
            position: LatLng(hospital.lat, hospital.lng),
            address: hospital.addr,
            phone: hospital.tel,
          ),
      for (final pharmacy in pharmacies)
        if (_isValidCoordinate(pharmacy.lat, pharmacy.lng))
          MapFacility(
            id: 'pharmacy:${pharmacy.id}',
            name: pharmacy.name,
            type: 'pharmacy',
            collectionName: 'facility_list',
            position: LatLng(pharmacy.lat, pharmacy.lng),
            address: pharmacy.addr,
            phone: pharmacy.tel,
          ),
    ];

    for (final school in schools) {
      final fullAddress = [
        school.addr,
        school.addrDetail,
      ].where((value) => value.trim().isNotEmpty).join(' ');
      final position = await _geocodeAddress(fullAddress);
      if (position == null || !_isNearJongno(position, fullAddress)) {
        continue;
      }
      facilities.add(
        MapFacility(
          id: 'education:${school.code}',
          name: school.name,
          type: 'education',
          collectionName: 'facility_list',
          position: position,
          address: fullAddress,
          phone: school.tel,
        ),
      );
    }

    facilities.retainWhere(
      (facility) => _isNearJongno(facility.position, facility.address),
    );

    facilities.sort((a, b) => a.name.compareTo(b.name));
    return facilities;
  }

  bool _isValidCoordinate(double lat, double lng) {
    return lat != 0 && lng != 0;
  }

  Future<LatLng?> _geocodeAddress(String address) async {
    if (address.trim().isEmpty) {
      return null;
    }
    if (_geocodeCache.containsKey(address)) {
      return _geocodeCache[address];
    }

    try {
      final placemarks = await locationFromAddress(address);
      if (placemarks.isEmpty) {
        _geocodeCache[address] = null;
        return null;
      }
      final position = LatLng(
        placemarks.first.latitude,
        placemarks.first.longitude,
      );
      _geocodeCache[address] = position;
      return position;
    } catch (_) {
      _geocodeCache[address] = null;
      return null;
    }
  }

  bool _isNearJongno(LatLng position, String? address) {
    if (address != null && address.contains('종로')) {
      return true;
    }
    final latDelta = (position.latitude - AppConstants.jongnoCenterLat).abs();
    final lngDelta = (position.longitude - AppConstants.jongnoCenterLng).abs();
    return latDelta <= 0.13 && lngDelta <= 0.13;
  }

  Future<BitmapDescriptor> _buildMarkerIcon(FacilityTypeOption option) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(132, 148);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final circleRect = Rect.fromLTWH(16, 0, 100, 100);
    final center = circleRect.center;

    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.16);
    canvas.drawCircle(center.translate(0, 6), 46, shadowPaint);

    final circlePaint = Paint()..color = option.color;
    canvas.drawCircle(center, 44, circlePaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, 44, borderPaint);

    final pointerPath = Path()
      ..moveTo(66, 136)
      ..lineTo(45, 88)
      ..lineTo(87, 88)
      ..close();
    canvas.drawPath(pointerPath, circlePaint);
    canvas.drawPath(pointerPath, borderPaint);

    final iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = TextSpan(
      text: String.fromCharCode(option.icon.codePoint),
      style: TextStyle(
        fontSize: 48,
        fontFamily: option.icon.fontFamily,
        package: option.icon.fontPackage,
        color: Colors.white,
      ),
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        center.dx - (iconPainter.width / 2),
        center.dy - (iconPainter.height / 2),
      ),
    );

    final image = await recorder.endRecording().toImage(
      rect.width.toInt(),
      rect.height.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: 2,
      width: 66,
      height: 74,
    );
  }
}

class FacilityTypeOption {
  const FacilityTypeOption({
    required this.id,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String id;
  final String label;
  final Color color;
  final IconData icon;
}
