/// 카카오 지도 위에 표시할 단일 마커.
class KakaoBuildingMarker {
  final String id;
  final String label;
  final double lat;
  final double lng;
  // 마커 색상(hex, 예: '#2563EB'). null 이면 카카오 기본 마커.
  final String? color;

  const KakaoBuildingMarker({
    required this.id,
    required this.label,
    required this.lat,
    required this.lng,
    this.color,
  });
}

typedef KakaoMarkerTap = void Function(String markerId);
