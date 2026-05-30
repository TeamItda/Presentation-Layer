// === 상명대 캠퍼스 맵 / 카카오 지도 편집 모드 백업 ===
//
// 디버그 전용 편집 기능의 원본 코드를 참고용으로 보관합니다.
// 메인 코드(smu_view.dart, kakao_marker.dart, kakao_map_view_io.dart,
// kakao_map_view_web.dart, web/kakao_map.html)에서는 분리/제거되어 있고,
// 이 파일은 컴파일에 포함되지만 어디서도 import 하지 않아 dead code 입니다.
//
// 다시 활성화하려면:
//   1. 아래 /* ... */ 블록 안의 코드를 각 해당 파일에 머지
//   2. pubspec.yaml 에 `pointer_interceptor: ^0.10.1+2` 추가 (web에서 iframe 위 클릭용)
//   3. flutter pub get + 앱 재시작
//
// 두 가지 편집 모드:
//
// [1] 캠퍼스 맵 폴리곤 편집 모드
//   - kDebugMode 빌드의 우상단 "좌표 편집" 토글
//   - 꼭짓점 핸들 드래그/추가/삭제, 폴리곤 평행이동
//   - "전체 출력" 누르면 콘솔에 좌표 출력 → smu_buildings.dart 의 points: 에 복붙
//
// [2] 카카오 지도 마커 드래그 보정 모드
//   - kDebugMode 빌드의 우상단 "마커 보정" 토글
//   - 마커를 드래그해서 GPS 좌표 보정
//   - "보정값 출력" 누르면 콘솔에 lat/lng 출력 → smu_buildings.dart 의 SmuBuilding(...)에 복붙
//
// ignore_for_file: unused_element, dead_code, prefer_const_constructors

/* ────────────────────────────────────────────────────────────────────────
   kakao_marker.dart 추가 필드
   ────────────────────────────────────────────────────────────────────────

class KakaoBuildingMarker {
  ...
  final bool draggable;

  const KakaoBuildingMarker({
    ...
    this.draggable = false,
  });
}

typedef KakaoMarkerDrag = void Function(
  String markerId,
  double lat,
  double lng,
);

   ────────────────────────────────────────────────────────────────────────
   KakaoMapPlatformView (io/web) onMarkerDragEnd 콜백
   ────────────────────────────────────────────────────────────────────────

// 위젯 필드:
final KakaoMarkerDrag? onMarkerDragEnd;

// _handleChannelMessage / message listener 의 switch 에 case 추가:
case 'markerDragEnd':
  final id = data['id'];
  final lat = (data['lat'] as num?)?.toDouble();
  final lng = (data['lng'] as num?)?.toDouble();
  if (id is String && lat != null && lng != null) {
    widget.onMarkerDragEnd?.call(id, lat, lng);
  }
  break;

// markers JSON 직렬화에 draggable 포함:
'draggable': m.draggable,

// HTML/JS 측 marker 생성:
var marker = new kakao.maps.Marker({
  position: pos, map: map, title: b.label, draggable: !!b.draggable
});
if (b.draggable) {
  kakao.maps.event.addListener(marker, 'dragend', function() {
    var p = marker.getPosition();
    postFlutter({type:'markerDragEnd', id:b.id, lat:p.getLat(), lng:p.getLng()});
  });
}

   ────────────────────────────────────────────────────────────────────────
   SmuView 편집 모드 State + 메서드
   ────────────────────────────────────────────────────────────────────────

// 캠퍼스 폴리곤 편집
bool _editMode = false;
final Map<String, List<Offset>> _coordOverrides = {};

// 카카오 마커 보정
bool _kakaoEditMode = false;
final Map<String, ({double lat, double lng})> _kakaoOverrides = {};

List<Offset> _coordsFor(SmuBuilding b) =>
    _coordOverrides[b.id] ?? b.points;

void _setOverride(String id, List<Offset> pts) {
  setState(() => _coordOverrides[id] = pts);
}

void _movePolygon(String id, double dxN, double dyN) {
  final b = smuBuildings.firstWhere((x) => x.id == id);
  final pts = _coordsFor(b)
      .map((p) => Offset(
            (p.dx + dxN).clamp(0.0, 1.0),
            (p.dy + dyN).clamp(0.0, 1.0),
          ))
      .toList(growable: false);
  _setOverride(id, pts);
}

void _moveVertex(String id, int idx, double dxN, double dyN) {
  final b = smuBuildings.firstWhere((x) => x.id == id);
  final pts = List<Offset>.of(_coordsFor(b));
  final p = pts[idx];
  pts[idx] = Offset(
    (p.dx + dxN).clamp(0.0, 1.0),
    (p.dy + dyN).clamp(0.0, 1.0),
  );
  _setOverride(id, pts);
}

void _deleteVertex(String id, int idx) {
  final b = smuBuildings.firstWhere((x) => x.id == id);
  final pts = List<Offset>.of(_coordsFor(b));
  if (pts.length <= 3) return;
  pts.removeAt(idx);
  _setOverride(id, pts);
}

void _addVertex(String id, int insertIdx, Offset point) {
  final b = smuBuildings.firstWhere((x) => x.id == id);
  final pts = List<Offset>.of(_coordsFor(b));
  pts.insert(insertIdx.clamp(0, pts.length), point);
  _setOverride(id, pts);
}

void _printOneBuilding(SmuBuilding b) {
  final pts = _coordsFor(b);
  final lines = pts
      .map((p) =>
          '      Offset(${p.dx.toStringAsFixed(3)}, ${p.dy.toStringAsFixed(3)}),')
      .join('\n');
  debugPrint('\n// [${b.id}] ${b.name}\n    points: [\n$lines\n    ],');
}

void _printAllBuildings() {
  final sb = StringBuffer('\n// === 캠퍼스 맵 다각형 좌표 (복붙용) ===\n');
  for (final b in smuBuildings) {
    final pts = _coordsFor(b);
    sb.writeln('    // ${b.name} (${b.id})');
    sb.writeln('    points: [');
    for (final p in pts) {
      sb.writeln(
          '      Offset(${p.dx.toStringAsFixed(3)}, ${p.dy.toStringAsFixed(3)}),');
    }
    sb.writeln('    ],');
  }
  debugPrint(sb.toString());
}

void _onKakaoMarkerDragEnd(String id, double lat, double lng) {
  if (!mounted) return;
  setState(() => _kakaoOverrides[id] = (lat: lat, lng: lng));
  debugPrint(
    '// [$id] dragend → lat: ${lat.toStringAsFixed(6)}, lng: ${lng.toStringAsFixed(6)}',
  );
}

void _printAllKakaoOverrides() {
  if (_kakaoOverrides.isEmpty) {
    debugPrint('// (카카오 마커 보정 없음)');
    return;
  }
  final sb = StringBuffer(
    '\n// === 카카오 마커 좌표 보정 (SmuBuilding 생성자 인자로 추가) ===\n',
  );
  for (final b in smuBuildings) {
    final o = _kakaoOverrides[b.id];
    if (o == null) continue;
    sb.writeln('    // ${b.name} (${b.id})');
    sb.writeln('    lat: ${o.lat.toStringAsFixed(6)},');
    sb.writeln('    lng: ${o.lng.toStringAsFixed(6)},');
  }
  debugPrint(sb.toString());
}

   ────────────────────────────────────────────────────────────────────────
   캠퍼스 탭 오버레이 (Stack 추가 자식)
   ────────────────────────────────────────────────────────────────────────

if (kDebugMode)
  Positioned(
    top: 12, right: 12,
    child: _EditControls(
      editMode: _editMode,
      onToggle: () => setState(() => _editMode = !_editMode),
      onPrintAll: _printAllBuildings,
    ),
  ),

// InteractiveViewer 의 panEnabled/scaleEnabled 를 !_editMode 로 비활성화
// _hotspotFor 에 editMode + onMove/onVertexMove/onVertexDelete/onVertexAdd/onPrint 콜백 전달

   ────────────────────────────────────────────────────────────────────────
   카카오 탭 오버레이 (Stack 으로 KakaoMapPlatformView 와 함께 묶고)
   ────────────────────────────────────────────────────────────────────────

Stack(children: [
  KakaoMapPlatformView(
    key: ValueKey('kakao-${_kakaoEditMode ? 'edit' : 'view'}'),
    ...
    markers: smuBuildings.map((b) => KakaoBuildingMarker(
      ...
      draggable: _kakaoEditMode,
    )).toList(),
    onMarkerTap: _kakaoEditMode ? null : (id) { ... },
    onMarkerDragEnd: _onKakaoMarkerDragEnd,
  ),
  if (kDebugMode)
    Positioned(
      top: 12, right: 12,
      child: PointerInterceptor(  // iframe 위 클릭이 새지 않게
        child: _EditControls(
          editMode: _kakaoEditMode,
          onToggle: () => setState(() => _kakaoEditMode = !_kakaoEditMode),
          onPrintAll: _printAllKakaoOverrides,
          editLabelOn: '마커 보정 ON',
          editLabelOff: '마커 보정',
          printLabel: '보정값 출력',
        ),
      ),
    ),
])

   ────────────────────────────────────────────────────────────────────────
   _BuildingHotspot.editMode 분기
   ────────────────────────────────────────────────────────────────────────

class _BuildingHotspot extends StatefulWidget {
  ...
  final bool editMode;
  final void Function(double dxPx, double dyPx) onMove;
  final void Function(int vertexIdx, double dxPx, double dyPx) onVertexMove;
  final void Function(int vertexIdx) onVertexDelete;
  final void Function(int insertIdx, Offset normalizedPoint) onVertexAdd;
  final VoidCallback onPrint;
}

@override
Widget build(BuildContext context) {
  if (widget.editMode) return _buildEditMode();
  return _buildInteractive();
}

Widget _buildEditMode() {
  return LayoutBuilder(builder: (context, c) {
    final w = c.maxWidth;
    final h = c.maxHeight;
    final centroid = _centroid(widget.points);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _PolygonFillStrokePainter(
                points: widget.points,
                fillColor: Colors.orange.withValues(alpha: 0.22),
                strokeColor: Colors.orange,
                strokeWidth: 1.6,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: _PolygonHitArea(
            points: widget.points,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onLongPress: widget.onPrint,
              onPanUpdate: (d) => widget.onMove(d.delta.dx, d.delta.dy),
            ),
          ),
        ),
        Positioned(
          left: centroid.dx * w - 60,
          top: centroid.dy * h - 8,
          width: 120,
          child: IgnorePointer(
            child: Text(
              widget.building.name,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.w800,
                color: Colors.black, height: 1.1,
                shadows: [
                  Shadow(color: Colors.white, blurRadius: 3),
                  Shadow(color: Colors.white, blurRadius: 3),
                ],
              ),
            ),
          ),
        ),
        for (int i = 0; i < widget.points.length; i++)
          _edgeAddMarker(i, w, h),
        for (int i = 0; i < widget.points.length; i++)
          _vertexHandle(i, w, h),
      ],
    );
  });
}

Widget _vertexHandle(int idx, double w, double h) {
  final canDelete = widget.points.length > 3;
  final p = widget.points[idx];
  return Positioned(
    left: p.dx * w - 11, top: p.dy * h - 11,
    width: 22, height: 22,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (d) => widget.onVertexMove(idx, d.delta.dx, d.delta.dy),
      onDoubleTap: canDelete ? () => widget.onVertexDelete(idx) : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: canDelete ? Colors.orange : Colors.grey,
            width: 2.5,
          ),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
        ),
      ),
    ),
  );
}

Widget _edgeAddMarker(int edgeStartIdx, double w, double h) {
  final a = widget.points[edgeStartIdx];
  final b = widget.points[(edgeStartIdx + 1) % widget.points.length];
  final midX = (a.dx + b.dx) / 2;
  final midY = (a.dy + b.dy) / 2;
  return Positioned(
    left: midX * w - 9, top: midY * h - 9,
    width: 18, height: 18,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onVertexAdd(edgeStartIdx + 1, Offset(midX, midY)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal, shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.8),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
        ),
        child: const Icon(Icons.add_rounded, size: 12, color: Colors.white),
      ),
    ),
  );
}

   ────────────────────────────────────────────────────────────────────────
   _EditControls 위젯
   ────────────────────────────────────────────────────────────────────────

class _EditControls extends StatelessWidget {
  final bool editMode;
  final VoidCallback onToggle;
  final VoidCallback onPrintAll;
  final String editLabelOn;
  final String editLabelOff;
  final String printLabel;

  const _EditControls({
    required this.editMode,
    required this.onToggle,
    required this.onPrintAll,
    this.editLabelOn = '편집 ON',
    this.editLabelOff = '좌표 편집',
    this.printLabel = '전체 출력',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _pill(
          onTap: onToggle,
          color: editMode ? Colors.orange : Colors.black87,
          icon: editMode ? Icons.edit_off_rounded : Icons.tune_rounded,
          label: editMode ? editLabelOn : editLabelOff,
        ),
        if (editMode) ...[
          const SizedBox(height: 8),
          _pill(
            onTap: onPrintAll,
            color: Colors.black87,
            icon: Icons.copy_all_rounded,
            label: printLabel,
          ),
        ],
      ],
    );
  }

  Widget _pill({
    required VoidCallback onTap,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
*/
