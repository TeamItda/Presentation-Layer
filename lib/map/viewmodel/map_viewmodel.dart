import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants.dart';
import '../../facility/service/childcare_service.dart';
import '../../facility/service/culture_service.dart';
import '../../facility/service/government_service.dart';
import '../../facility/service/hospital_service.dart';
import '../../facility/service/local_facility_catalog.dart';
import '../../facility/service/pharmacy_service.dart';
import '../../facility/service/restaurant_service.dart';
import '../../facility/service/school_service.dart';
import '../../facility/service/welfare_service.dart';
import '../model/map_facility.dart';

class MapViewModel extends ChangeNotifier {
  MapViewModel({
    HospitalService? hospitalService,
    PharmacyService? pharmacyService,
    SchoolService? schoolService,
    RestaurantService? restaurantService,
    WelfareService? welfareService,
    ChildcareService? childcareService,
    CultureService? cultureService,
    GovernmentService? governmentService,
  }) : _hospitalService = hospitalService ?? HospitalService(),
       _pharmacyService = pharmacyService ?? PharmacyService(),
       _schoolService = schoolService ?? SchoolService(),
       _restaurantService = restaurantService ?? RestaurantService(),
       _welfareService = welfareService ?? WelfareService(),
       _childcareService = childcareService ?? ChildcareService(),
       _cultureService = cultureService ?? CultureService(),
       _governmentService = governmentService ?? GovernmentService();

  final HospitalService _hospitalService;
  final PharmacyService _pharmacyService;
  final SchoolService _schoolService;
  final RestaurantService _restaurantService;
  final WelfareService _welfareService;
  final ChildcareService _childcareService;
  final CultureService _cultureService;
  final GovernmentService _governmentService;

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
      color: AppColors.medical,
      icon: Icons.local_hospital_rounded,
    ),
    FacilityTypeOption(
      id: 'pharmacy',
      label: '약국',
      color: AppColors.pharmacy,
      icon: Icons.local_pharmacy_rounded,
    ),
    FacilityTypeOption(
      id: 'education',
      label: '학교',
      color: AppColors.education,
      icon: Icons.school_rounded,
    ),
    FacilityTypeOption(
      id: 'childcare',
      label: '보육',
      color: AppColors.childcare,
      icon: Icons.child_care_rounded,
    ),
    FacilityTypeOption(
      id: 'welfare',
      label: '복지',
      color: AppColors.welfare,
      icon: Icons.volunteer_activism_rounded,
    ),
    FacilityTypeOption(
      id: 'food',
      label: '맛집',
      color: AppColors.food,
      icon: Icons.restaurant_rounded,
    ),
    FacilityTypeOption(
      id: 'culture',
      label: '문화',
      color: AppColors.culture,
      icon: Icons.museum_rounded,
    ),
    FacilityTypeOption(
      id: 'government',
      label: '공공',
      color: AppColors.government,
      icon: Icons.account_balance_rounded,
    ),
  ];

  bool _isLoading = false;
  bool _initialized = false;
  String? _errorMessage;
  String _selectedTypeId = 'all';
  String? _selectedFacilityMarkerId;
  List<MapFacility> _facilities = const [];
  List<MapFacility>? _filteredCache;
  final Map<String, BitmapDescriptor> _markerIcons =
      <String, BitmapDescriptor>{};
  final Map<String, LatLng?> _geocodeCache = <String, LatLng?>{};

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedTypeId => _selectedTypeId;

  BitmapDescriptor? iconFor(String type) => _markerIcons[type];

  List<MapFacility> get filteredFacilities {
    return _filteredCache ??= _selectedTypeId == 'all'
        ? _facilities
        : _facilities
            .where((facility) => facility.type == _selectedTypeId)
            .toList();
  }

  MapFacility? get selectedFacility {
    final selectedId = _selectedFacilityMarkerId;
    if (selectedId == null) {
      return null;
    }
    for (final facility in filteredFacilities) {
      if (facility.id == selectedId) {
        return facility;
      }
    }
    return null;
  }

  CameraPosition get initialCameraPosition => const CameraPosition(
    target: LatLng(AppConstants.jongnoCenterLat, AppConstants.jongnoCenterLng),
    zoom: 14.1,
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
      _filteredCache = null;
      _syncSelection();
      if (_facilities.isEmpty) {
        _errorMessage = '시설 목록 데이터에서 표시할 좌표를 찾지 못했습니다.';
      }
    } catch (_) {
      _facilities = const [];
      _filteredCache = null;
      _errorMessage = '시설 목록을 불러오지 못했습니다.';
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
    _filteredCache = null;
    _syncSelection();
    notifyListeners();
  }

  void selectFacility(String markerId) {
    if (_selectedFacilityMarkerId == markerId) {
      return;
    }
    _selectedFacilityMarkerId = markerId;
    notifyListeners();
  }

  void clearSelectedFacility() {
    if (_selectedFacilityMarkerId == null) {
      return;
    }
    _selectedFacilityMarkerId = null;
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
    final restaurants = await _restaurantService.fetchRestaurants();
    final welfares = await _welfareService.fetchWelfares();
    final childcares = await _childcareService.fetchChildcares();
    final cultures = await _cultureService.fetchCultures();
    final governments = await _governmentService.fetchGovernments();

    final facilities = <MapFacility>[
      for (final hospital in hospitals)
        if (_isValidCoordinate(hospital.lat, hospital.lng))
          MapFacility(
            id: 'medical:${hospital.id}',
            facilityId: hospital.id,
            categoryId: 'medical',
            name: hospital.name,
            type: 'medical',
            collectionName: 'facility_list',
            position: LatLng(hospital.lat, hospital.lng),
            address: hospital.addr,
            phone: hospital.tel,
            homepage: hospital.homepage,
          ),
      for (final pharmacy in pharmacies)
        if (_isValidCoordinate(pharmacy.lat, pharmacy.lng))
          MapFacility(
            id: 'pharmacy:${pharmacy.id}',
            facilityId: pharmacy.id,
            categoryId: 'pharmacy',
            name: pharmacy.name,
            type: 'pharmacy',
            collectionName: 'facility_list',
            position: LatLng(pharmacy.lat, pharmacy.lng),
            address: pharmacy.addr,
            phone: pharmacy.tel,
          ),
      for (final restaurant in restaurants)
        if (restaurant.lat != null &&
            restaurant.lng != null &&
            _isValidCoordinate(restaurant.lat!, restaurant.lng!))
          MapFacility(
            id: 'food:${restaurant.id}',
            facilityId: restaurant.id,
            categoryId: 'food',
            name: restaurant.name,
            type: 'food',
            subtype: restaurant.displayCategoryLabel,
            collectionName: 'facility_list',
            position: LatLng(restaurant.lat!, restaurant.lng!),
            address: restaurant.addr,
            phone: restaurant.tel,
            homepage: restaurant.homepage,
          ),
      for (final welfare in welfares)
        if (welfare.lat != null &&
            welfare.lng != null &&
            _isValidCoordinate(welfare.lat!, welfare.lng!))
          MapFacility(
            id: 'welfare:${welfare.id}',
            facilityId: welfare.id,
            categoryId: 'welfare',
            name: welfare.name,
            type: 'welfare',
            subtype: welfare.type,
            collectionName: 'facility_list',
            position: LatLng(welfare.lat!, welfare.lng!),
            address: welfare.addr,
            phone: welfare.tel,
            homepage: welfare.homepage,
          ),
      for (final cc in childcares)
        if (cc.lat != null &&
            cc.lng != null &&
            _isValidCoordinate(cc.lat!, cc.lng!))
          MapFacility(
            id: 'childcare:${cc.id}',
            facilityId: cc.id,
            categoryId: 'childcare',
            name: cc.name,
            type: 'childcare',
            subtype: cc.typeLabel,
            collectionName: 'facility_list',
            position: LatLng(cc.lat!, cc.lng!),
            address: cc.addr,
            phone: cc.tel,
            homepage: cc.homepage,
          ),
      for (final cu in cultures)
        if (cu.lat != null &&
            cu.lng != null &&
            _isValidCoordinate(cu.lat!, cu.lng!))
          MapFacility(
            id: 'culture:${cu.id}',
            facilityId: cu.id,
            categoryId: 'culture',
            name: cu.name,
            type: 'culture',
            subtype: cu.type,
            collectionName: 'facility_list',
            position: LatLng(cu.lat!, cu.lng!),
            address: cu.addr,
            phone: cu.tel,
            homepage: cu.homepage,
          ),
      for (final g in governments)
        if (g.lat != null &&
            g.lng != null &&
            _isValidCoordinate(g.lat!, g.lng!))
          MapFacility(
            id: 'government:${g.id}',
            facilityId: g.id,
            categoryId: 'government',
            name: g.name,
            type: 'government',
            subtype: g.type,
            collectionName: 'facility_list',
            position: LatLng(g.lat!, g.lng!),
            address: g.addr,
            phone: g.tel,
            homepage: g.homepage,
          ),
    ];

    for (final school in schools) {
      final position = school.lat != null && school.lng != null
          ? LatLng(school.lat!, school.lng!)
          : await _geocodeAddress(school.geocodingAddress);
      if (position == null || !_isNearJongno(position, school.displayAddress)) {
        continue;
      }
      facilities.add(
        MapFacility(
          id: 'education:${school.code}',
          facilityId: school.code,
          categoryId: 'education',
          name: school.name,
          type: 'education',
          collectionName: 'facility_list',
          position: position,
          address: school.displayAddress,
          phone: school.tel,
          homepage: school.homepage,
        ),
      );
    }

    for (final seed in LocalFacilityCatalog.all) {
      // welfare/childcare/culture/government는 별도 서비스에서 처리됨 (중복 방지)
      if (seed.categoryId == 'welfare' ||
          seed.categoryId == 'childcare' ||
          seed.categoryId == 'culture' ||
          seed.categoryId == 'government') {
        continue;
      }
      final position = await _resolveSeedPosition(seed);
      if (position == null || !_isNearJongno(position, seed.address)) {
        continue;
      }
      facilities.add(
        MapFacility(
          id: '${seed.categoryId}:${seed.id}',
          facilityId: seed.id,
          categoryId: seed.categoryId,
          name: seed.name,
          type: seed.categoryId,
          collectionName: 'facility_list',
          position: position,
          address: seed.address,
          phone: seed.phone,
          homepage: seed.homepage,
        ),
      );
    }

    facilities.sort((a, b) => a.name.compareTo(b.name));
    return facilities;
  }

  Future<LatLng?> _resolveSeedPosition(LocalFacilitySeed seed) async {
    if (seed.lat != null && seed.lng != null) {
      return LatLng(seed.lat!, seed.lng!);
    }
    return _geocodeAddress(seed.address);
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

  void _syncSelection() {
    final selectedId = _selectedFacilityMarkerId;
    if (selectedId == null) {
      return;
    }
    final exists = filteredFacilities.any((facility) => facility.id == selectedId);
    if (!exists) {
      _selectedFacilityMarkerId = null;
    }
  }

  Future<BitmapDescriptor> _buildMarkerIcon(FacilityTypeOption option) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(96, 96);
    final center = Offset(size.width / 2, size.height / 2);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const ui.MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center.translate(0, 3), 30, shadowPaint);

    final outerPaint = Paint()
      ..color = option.color.withValues(alpha: 0.18);
    canvas.drawCircle(center, 36, outerPaint);

    final fillPaint = Paint()..color = option.color;
    canvas.drawCircle(center, 30, fillPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5;
    canvas.drawCircle(center, 30, borderPaint);

    final iconPainter = TextPainter(textDirection: TextDirection.ltr);
    iconPainter.text = TextSpan(
      text: String.fromCharCode(option.icon.codePoint),
      style: TextStyle(
        fontSize: 32,
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
      size.width.toInt(),
      size.height.toInt(),
    );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      imagePixelRatio: 2,
      width: 42,
      height: 42,
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
