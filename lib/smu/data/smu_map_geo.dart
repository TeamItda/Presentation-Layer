import 'dart:math' as math;
import 'dart:ui';

import '../../core/constants.dart';
import '../model/smu_building.dart';

/// 캠퍼스 맵 이미지(정규화 0~1) ↔ GPS 위경도 변환 유틸.
///
/// 가정:
///  - 이미지 중심(0.5, 0.5)이 캠퍼스 중심([AppConstants.smuCenterLat]/[AppConstants.smuCenterLng])에 대응
///  - 이미지 위 방향이 정북(N). 회전된 맵이라면 [bearingDeg]를 시계방향 회전각(도)로 설정
///  - 이미지 가로 전체가 [lngSpan]만큼의 경도, 세로 전체가 [latSpan]만큼의 위도를 커버
///
/// 실측 좌표를 가진 건물은 [SmuBuilding.lat]/[SmuBuilding.lng]에 직접 넣으면
/// 그 값이 우선됩니다. 그 외엔 polygon centroid에서 자동 변환합니다.
///
/// 결과 좌표가 어긋난다면 아래 상수들을 조정해 보세요:
///  - [latSpan]/[lngSpan]: 맵 이미지가 실제 커버하는 위·경도 범위 (deg)
///  - [bearingDeg]: 맵 이미지가 정북에서 시계방향으로 얼마나 돌아가 있는지
class SmuMapGeo {
  /// 이미지 세로 전체가 커버하는 위도 범위 (deg). 서울 위도 기준 1deg ≈ 111km.
  /// 0.003 ≈ 333m.
  static const double latSpan = 0.003;

  /// 이미지 가로 전체가 커버하는 경도 범위 (deg). 서울 위도 기준 1deg lng ≈ 88km.
  /// 0.0035 ≈ 308m.
  static const double lngSpan = 0.0035;

  /// 이미지가 정북에서 시계방향으로 회전한 각도 (deg). 0이면 정북 일치.
  static const double bearingDeg = 0.0;

  /// 이미지 정규화 좌표 → (lat, lng).
  static ({double lat, double lng}) toLatLng(Offset imagePoint) {
    final dx = imagePoint.dx - 0.5;
    final dy = imagePoint.dy - 0.5;

    // 회전 전 단계: 이미지 위쪽이 북쪽이므로 dy가 작아질수록 lat ↑
    final dLatN = -dy * latSpan;
    final dLngE = dx * lngSpan;

    // 이미지 회전 보정 (양의 bearingDeg = 맵이 시계방향으로 회전된 상태)
    final r = bearingDeg * math.pi / 180.0;
    final cosR = math.cos(r);
    final sinR = math.sin(r);

    final dLat = dLatN * cosR - dLngE * sinR;
    final dLng = dLatN * sinR + dLngE * cosR;

    return (
      lat: AppConstants.smuCenterLat + dLat,
      lng: AppConstants.smuCenterLng + dLng,
    );
  }

  /// 건물의 마커 위치. [SmuBuilding.lat]/[SmuBuilding.lng]가 있으면 그 값,
  /// 없으면 polygon centroid 기반 추정값.
  static ({double lat, double lng}) markerPositionOf(SmuBuilding b) {
    if (b.lat != null && b.lng != null) {
      return (lat: b.lat!, lng: b.lng!);
    }
    return toLatLng(_centroid(b.points));
  }

  static Offset _centroid(List<Offset> pts) {
    if (pts.isEmpty) return const Offset(0.5, 0.5);
    double sx = 0, sy = 0;
    for (final p in pts) {
      sx += p.dx;
      sy += p.dy;
    }
    return Offset(sx / pts.length, sy / pts.length);
  }
}
