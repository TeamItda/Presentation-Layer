class SmuBuilding {
  final String id;
  final String name;
  final String description;
  final List<String> departments;
  final List<SmuBuildingFloor> floors;
  final String? phone;
  // 캠퍼스 맵 이미지 내 정규화 좌표 (0.0 ~ 1.0)
  final double left;
  final double top;
  final double width;
  final double height;

  const SmuBuilding({
    required this.id,
    required this.name,
    required this.description,
    this.departments = const [],
    this.floors = const [],
    this.phone,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

class SmuBuildingFloor {
  final String floor;   // "1F", "B1" 등
  final String content; // "강의실, 카페" 등

  const SmuBuildingFloor({required this.floor, required this.content});
}
