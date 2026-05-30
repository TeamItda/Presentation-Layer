import 'dart:ui';

class SmuBuilding {
  final String id;
  final String name;
  final String description;
  final List<String> departments;
  final List<SmuBuildingFloor> floors;
  final String? phone;
  // 캠퍼스 맵 이미지(994x1249) 위의 정규화 다각형 꼭짓점 (각 점: 0.0~1.0).
  // 시계방향이든 반시계방향이든 자유롭게 정의 가능.
  final List<Offset> points;
  // 실측 GPS 좌표 (있으면 카카오 지도 마커에 사용,
  // 없으면 SmuMapGeo가 polygon 중심에서 affine으로 추정).
  final double? lat;
  final double? lng;

  const SmuBuilding({
    required this.id,
    required this.name,
    required this.description,
    this.departments = const [],
    this.floors = const [],
    this.phone,
    required this.points,
    this.lat,
    this.lng,
  });
}

class SmuBuildingFloor {
  final String floor; // "1F", "B1" 등
  final String content; // "강의실, 카페" 등

  const SmuBuildingFloor({required this.floor, required this.content});
}
