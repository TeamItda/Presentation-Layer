import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../facility/model/restaurant_model.dart';
import '../../facility/service/facility_translation_service.dart';
import '../data/smu_buildings.dart';
import '../data/smu_map_geo.dart';
import '../model/smu_building.dart';
import 'kakao_map_view.dart';

class SmuView extends StatefulWidget {
  const SmuView({super.key});

  @override
  State<SmuView> createState() => _SmuViewState();
}

class _SmuViewState extends State<SmuView> with SingleTickerProviderStateMixin {
  static const double _campusAspectRatio = 994 / 1249;

  late final TabController _tabController;
  late final Future<List<RestaurantModel>> _nearbyRestaurantsFuture;

  bool _showCampusMarkers = true;
  bool _showFoodMarkers = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nearbyRestaurantsFuture = _loadNearbyRestaurants();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<RestaurantModel>> _loadNearbyRestaurants() async {
    final jsonString = await rootBundle.loadString(
      'assets/smu_nearby_restaurants.json',
    );
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final rows = decoded['data'] as List<dynamic>? ?? const [];
    return rows
        .whereType<Map<String, dynamic>>()
        .map(RestaurantModel.fromLocal)
        .where((r) => r.lat != null && r.lng != null)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    context.locale;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/SMU_LOGO.jpg',
                height: 28,
                width: 28,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'smu.title'.tr(),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.subText,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              tabs: [
                Tab(text: 'smu.tab_kakao'.tr()),
                Tab(text: 'smu.tab_campus'.tr()),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKakaoTab(),
          _buildCampusTab(),
        ],
      ),
    );
  }

  Widget _buildKakaoTab() {
    return FutureBuilder<List<RestaurantModel>>(
      future: _nearbyRestaurantsFuture,
      builder: (context, snapshot) {
        final restaurants = snapshot.data ?? const <RestaurantModel>[];
        final markers = _buildMarkers(restaurants);
        final reloadKey = 'kakao-'
            '${_showCampusMarkers ? '1' : '0'}'
            '${_showFoodMarkers ? '1' : '0'}'
            '-${restaurants.length}';
        return Stack(
          children: [
            KakaoMapPlatformView(
              key: ValueKey(reloadKey),
              lat: AppConstants.smuCenterLat,
              lng: AppConstants.smuCenterLng,
              appKey: AppConstants.kakaoMapAppKey,
              markers: markers,
              onMarkerTap: (id) => _onMarkerTap(id, restaurants),
            ),
            Positioned(
              top: 12,
              right: 28,
              child: PointerInterceptor(
                child: _MarkerLayerToggles(
                  showCampus: _showCampusMarkers,
                  showFood: _showFoodMarkers,
                  foodLoading: snapshot.connectionState == ConnectionState.waiting,
                  foodCount: restaurants.length,
                  campusDotColor: const Color(0xFF2563EB),
                  foodDotColor: const Color(0xFFF97316),
                  onCampusChanged: (v) =>
                      setState(() => _showCampusMarkers = v),
                  onFoodChanged: (v) => setState(() => _showFoodMarkers = v),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static const String _campusMarkerColor = '#2563EB';
  static const String _foodMarkerColor = '#F97316';

  List<KakaoBuildingMarker> _buildMarkers(
      List<RestaurantModel> restaurants,
      ) {
    final lang = context.locale.languageCode;
    final list = <KakaoBuildingMarker>[];
    if (_showCampusMarkers) {
      for (final b in smuBuildings) {
        final pos = SmuMapGeo.markerPositionOf(b);
        list.add(KakaoBuildingMarker(
          id: 'b:${b.id}',
          label: b.localizedName(lang), // ← 지도 마커 이름도 현지화
          lat: pos.lat,
          lng: pos.lng,
          color: _campusMarkerColor,
        ));
      }
    }
    if (_showFoodMarkers) {
      for (final r in restaurants) {
        final lat = r.lat;
        final lng = r.lng;
        if (lat == null || lng == null) continue;
        final cat = r.displayCategoryLabel;
        list.add(KakaoBuildingMarker(
          id: 'r:${r.id}',
          label: cat.isEmpty ? r.name : '${r.name} ($cat)',
          lat: lat,
          lng: lng,
          color: _foodMarkerColor,
        ));
      }
    }
    return list;
  }

  void _onMarkerTap(String id, List<RestaurantModel> restaurants) {
    if (!mounted) return;
    final lang = context.locale.languageCode;
    if (id.startsWith('b:')) {
      final buildingId = id.substring(2);
      final b = smuBuildings.firstWhere(
            (x) => x.id == buildingId,
        orElse: () => smuBuildings.first,
      );
      if (b.id != buildingId) return;
      _showBuildingSheet(context, b, lang);
    } else if (id.startsWith('r:')) {
      final rid = id.substring(2);
      RestaurantModel? r;
      for (final x in restaurants) {
        if (x.id == rid) {
          r = x;
          break;
        }
      }
      if (r != null) _showRestaurantSheet(context, r);
    }
  }

  Widget _buildCampusTab() {
    return ColoredBox(
      color: Colors.white,
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 5,
        child: Center(
          child: AspectRatio(
            aspectRatio: _campusAspectRatio,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/SMU_CAMPUSMAP.png',
                        fit: BoxFit.contain,
                        key: const ValueKey('SMU_CAMPUSMAP_v2'),
                        errorBuilder: (_, __, ___) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'smu.campus_empty'.tr(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.subText,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    for (final b in smuBuildings) _hotspotFor(b),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _hotspotFor(SmuBuilding b) {
    return Positioned.fill(
      key: ValueKey('hotspot_${b.id}'),
      child: _BuildingHotspot(
        points: b.points,
        onTap: () {
          final lang = context.locale.languageCode;
          _showBuildingSheet(context, b, lang);
        },
      ),
    );
  }

  void _showBuildingSheet(BuildContext context, SmuBuilding b, String lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _BuildingInfoSheet(building: b, lang: lang),
    );
  }

  void _showRestaurantSheet(BuildContext context, RestaurantModel r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _RestaurantInfoSheet(restaurant: r),
    );
  }
}

/// 카카오 지도 우상단의 마커 레이어 토글 카드.
class _MarkerLayerToggles extends StatelessWidget {
  final bool showCampus;
  final bool showFood;
  final bool foodLoading;
  final int foodCount;
  final Color campusDotColor;
  final Color foodDotColor;
  final ValueChanged<bool> onCampusChanged;
  final ValueChanged<bool> onFoodChanged;

  const _MarkerLayerToggles({
    required this.showCampus,
    required this.showFood,
    required this.foodLoading,
    required this.foodCount,
    required this.campusDotColor,
    required this.foodDotColor,
    required this.onCampusChanged,
    required this.onFoodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _chip(
              dotColor: campusDotColor,
              label: 'smu.layer_campus'
                  .tr(namedArgs: {'count': '${smuBuildings.length}'}),
              selected: showCampus,
              loading: false,
              onSelected: onCampusChanged,
            ),
            const SizedBox(height: 6),
            _chip(
              dotColor: foodDotColor,
              label: foodLoading
                  ? 'smu.layer_campus_loading'.tr()
                  : 'smu.layer_food'.tr(namedArgs: {'count': '$foodCount'}),
              selected: showFood,
              loading: foodLoading,
              onSelected: foodLoading ? null : onFoodChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip({
    required Color dotColor,
    required String label,
    required bool selected,
    required bool loading,
    required ValueChanged<bool>? onSelected,
  }) {
    return FilterChip(
      avatar: loading
          ? const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: dotColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 2),
          ],
        ),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? dotColor : AppColors.subText,
        ),
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.white,
      selectedColor: dotColor.withValues(alpha: 0.12),
      checkmarkColor: dotColor,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(
        color: selected ? dotColor : AppColors.border,
        width: 1.2,
      ),
    );
  }
}

/// 정규화 다각형 꼭짓점의 평균(중심점)
Offset _centroid(List<Offset> points) {
  if (points.isEmpty) return const Offset(0.5, 0.5);
  double sx = 0, sy = 0;
  for (final p in points) {
    sx += p.dx;
    sy += p.dy;
  }
  return Offset(sx / points.length, sy / points.length);
}

class _BuildingHotspot extends StatefulWidget {
  final List<Offset> points;
  final VoidCallback onTap;

  const _BuildingHotspot({
    required this.points,
    required this.onTap,
  });

  @override
  State<_BuildingHotspot> createState() => _BuildingHotspotState();
}

class _BuildingHotspotState extends State<_BuildingHotspot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _highlight;

  bool _hovered = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      reverseDuration: const Duration(milliseconds: 260),
    );
    _highlight = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setHovered(bool v) {
    if (_hovered == v) return;
    _hovered = v;
    _syncAnimation();
  }

  void _setPressed(bool v) {
    if (_pressed == v) return;
    _pressed = v;
    _syncAnimation();
  }

  void _syncAnimation() {
    if (_hovered || _pressed) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: _PolygonHitArea(
            points: widget.points,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onEnter: (_) => _setHovered(true),
              onExit: (_) => _setHovered(false),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: widget.onTap,
                onTapDown: (_) => _setPressed(true),
                onTapUp: (_) => _setPressed(false),
                onTapCancel: () => _setPressed(false),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _highlight,
              builder: (context, _) {
                final t = _highlight.value;
                if (t <= 0.001) return const SizedBox.shrink();
                return _PoppedOutBuilding(
                  points: widget.points,
                  progress: t,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PoppedOutBuilding extends StatelessWidget {
  final List<Offset> points;
  final double progress;

  const _PoppedOutBuilding({required this.points, required this.progress});

  @override
  Widget build(BuildContext context) {
    final centroid = _centroid(points);
    final scale = 1.0 + 0.08 * progress;
    return Transform.scale(
      scale: scale,
      alignment: Alignment(centroid.dx * 2 - 1, centroid.dy * 2 - 1),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PolygonShadowPainter(
                points: points,
                elevation: 10.0 * progress,
              ),
            ),
          ),
          Positioned.fill(
            child: ClipPath(
              clipper: _PolygonClipper(points),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/SMU_CAMPUSMAP.png',
                    fit: BoxFit.contain,
                  ),
                  ColoredBox(
                    color: Colors.white.withValues(alpha: 0.08 * progress),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _PolygonFillStrokePainter(
                  points: points,
                  fillColor: Colors.transparent,
                  strokeColor:
                  AppColors.primary.withValues(alpha: 0.55 + 0.4 * progress),
                  strokeWidth: 1.2 + 1.6 * progress,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Path _buildPolygonPath(List<Offset> points, Size size) {
  final path = Path();
  if (points.isEmpty) return path;
  path.moveTo(points[0].dx * size.width, points[0].dy * size.height);
  for (int i = 1; i < points.length; i++) {
    path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
  }
  path.close();
  return path;
}

bool _pointsEqual(List<Offset> a, List<Offset> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class _PolygonClipper extends CustomClipper<Path> {
  final List<Offset> points;
  const _PolygonClipper(this.points);

  @override
  Path getClip(Size size) => _buildPolygonPath(points, size);

  @override
  bool shouldReclip(covariant _PolygonClipper old) =>
      !_pointsEqual(old.points, points);
}

class _PolygonFillStrokePainter extends CustomPainter {
  final List<Offset> points;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;

  _PolygonFillStrokePainter({
    required this.points,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 3) return;
    final path = _buildPolygonPath(points, size);
    if (fillColor.a > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill,
      );
    }
    if (strokeWidth > 0 && strokeColor.a > 0) {
      canvas.drawPath(
        path,
        Paint()
          ..color = strokeColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PolygonFillStrokePainter old) {
    return old.fillColor != fillColor ||
        old.strokeColor != strokeColor ||
        old.strokeWidth != strokeWidth ||
        !_pointsEqual(old.points, points);
  }
}

class _PolygonShadowPainter extends CustomPainter {
  final List<Offset> points;
  final double elevation;

  _PolygonShadowPainter({required this.points, required this.elevation});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 3 || elevation <= 0) return;
    final path = _buildPolygonPath(points, size);
    canvas.drawShadow(path, Colors.black, elevation, false);
  }

  @override
  bool shouldRepaint(covariant _PolygonShadowPainter old) {
    return old.elevation != elevation || !_pointsEqual(old.points, points);
  }
}

class _PolygonHitArea extends SingleChildRenderObjectWidget {
  final List<Offset> points;

  const _PolygonHitArea({required this.points, required Widget super.child});

  @override
  _RenderPolygonHitArea createRenderObject(BuildContext context) =>
      _RenderPolygonHitArea(points);

  @override
  void updateRenderObject(
      BuildContext context, _RenderPolygonHitArea renderObject) {
    renderObject.points = points;
  }
}

class _RenderPolygonHitArea extends RenderProxyBox {
  _RenderPolygonHitArea(this._points);

  List<Offset> _points;
  set points(List<Offset> value) {
    if (_pointsEqual(_points, value)) return;
    _points = value;
  }

  bool _inside(Offset position) {
    if (_points.length < 3) return false;
    final w = size.width;
    final h = size.height;
    final px = position.dx;
    final py = position.dy;
    int crossings = 0;
    for (int i = 0; i < _points.length; i++) {
      final j = (i + 1) % _points.length;
      final ax = _points[i].dx * w;
      final ay = _points[i].dy * h;
      final bx = _points[j].dx * w;
      final by = _points[j].dy * h;
      if ((ay > py) != (by > py)) {
        final xIntersect = (bx - ax) * (py - ay) / (by - ay) + ax;
        if (px < xIntersect) crossings++;
      }
    }
    return (crossings & 1) == 1;
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!_inside(position)) return false;
    if (child != null && child!.hitTest(result, position: position)) {
      result.add(BoxHitTestEntry(this, position));
      return true;
    }
    return false;
  }
}

class _BuildingInfoSheet extends StatelessWidget {
  final SmuBuilding building;
  final String lang;

  const _BuildingInfoSheet({required this.building, required this.lang});

  @override
  Widget build(BuildContext context) {
    final name = building.localizedName(lang);
    final description = building.localizedDescription(lang);
    final departments = building.localizedDepartments(lang);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        if (description.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.subText,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'common.close'.tr(),
                    onPressed: () {
                      final nav = Navigator.of(context);
                      if (nav.canPop()) nav.pop();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.subText,
                      size: 22,
                    ),
                    splashRadius: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
              ),
              if (departments.isNotEmpty) ...[
                const SizedBox(height: 22),
                _sectionTitle('smu.section_departments'.tr()),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: departments
                      .map(
                        (d) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        d,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ],
              if (building.floors.isNotEmpty) ...[
                const SizedBox(height: 22),
                _sectionTitle('smu.section_floors'.tr()),
                const SizedBox(height: 8),
                ...building.floors.map((f) => _buildFloorRow(f, lang)),
              ],
              if (building.phone != null && building.phone!.isNotEmpty) ...[
                const SizedBox(height: 22),
                _sectionTitle('smu.section_contact'.tr()),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      building.phone!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
    );
  }

  Widget _buildFloorRow(SmuBuildingFloor f, String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              f.floor,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              f.localizedContent(lang),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.text,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RestaurantInfoSheet extends StatefulWidget {
  final RestaurantModel restaurant;

  const _RestaurantInfoSheet({required this.restaurant});

  @override
  State<_RestaurantInfoSheet> createState() => _RestaurantInfoSheetState();
}

class _RestaurantInfoSheetState extends State<_RestaurantInfoSheet> {
  final _translationService = FacilityTranslationService();

  String? _translatedName;
  String? _translatedCategory;
  String? _translatedAddr;
  bool _isTranslating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _translate());
  }

  Future<void> _translate() async {
    final lang = context.locale.languageCode;
    if (lang == 'ko') return;
    if (!mounted) return;
    setState(() => _isTranslating = true);
    try {
      final r = widget.restaurant;
      final nameResult = await _translationService.translateBatch([r.name], lang);
      final addrResult = r.addr.isNotEmpty
          ? await _translationService.translateAddressBatch([r.addr], lang)
          : <String>[];
      if (!mounted) return;
      setState(() {
        _translatedName = nameResult.isNotEmpty ? nameResult[0] : null;
        _translatedCategory = r.displayCategoryLabelLocalized(lang);
        _translatedAddr = addrResult.isNotEmpty ? addrResult[0] : null;
        _isTranslating = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  Future<void> _openKakaoSearch() async {
    final url =
        'https://map.kakao.com/?q=${Uri.encodeQueryComponent(widget.restaurant.name)}';
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    final lang = context.locale.languageCode;
    final displayName = _translatedName ?? r.name;
    final displayCategory = _translatedCategory ?? r.displayCategoryLabelLocalized(lang);
    final displayAddr = _translatedAddr ?? r.addr;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.restaurant_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isTranslating
                            ? Container(
                          height: 22,
                          width: 120,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )
                            : Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        if (displayCategory.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            displayCategory,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.subText,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'common.close'.tr(),
                    onPressed: () {
                      final nav = Navigator.of(context);
                      if (nav.canPop()) nav.pop();
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.subText,
                      size: 22,
                    ),
                    splashRadius: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 36,
                      minHeight: 36,
                    ),
                  ),
                ],
              ),
              if (r.rating > 0) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFBBF24),
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      r.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    if (r.userRatingsTotal != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(${r.userRatingsTotal})',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.subText,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
              if (displayAddr.isNotEmpty) ...[
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      color: AppColors.subText,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _isTranslating
                          ? Container(
                        height: 16,
                        width: 200,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                          : Text(
                        displayAddr,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.text,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (r.tel.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.phone_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      r.tel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _openKakaoSearch,
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text('smu.kakaoplace_button'.tr()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}