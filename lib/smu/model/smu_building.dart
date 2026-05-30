import 'dart:ui';

class SmuBuilding {
  final String id;
  final String name;
  final String nameEn;
  final String nameJa;
  final String nameZh;
  final String description;
  final String descriptionEn;
  final String descriptionJa;
  final String descriptionZh;
  final List<String> departments;
  final List<String> departmentsEn;
  final List<String> departmentsJa;
  final List<String> departmentsZh;
  final List<SmuBuildingFloor> floors;
  final String? phone;
  // 캠퍼스 맵 이미지(994x1249) 위의 정규화 다각형 꼭짓점 (각 점: 0.0~1.0).
  final List<Offset> points;
  // 실측 GPS 좌표
  final double? lat;
  final double? lng;

  const SmuBuilding({
    required this.id,
    required this.name,
    this.nameEn = '',
    this.nameJa = '',
    this.nameZh = '',
    required this.description,
    this.descriptionEn = '',
    this.descriptionJa = '',
    this.descriptionZh = '',
    this.departments = const [],
    this.departmentsEn = const [],
    this.departmentsJa = const [],
    this.departmentsZh = const [],
    this.floors = const [],
    this.phone,
    required this.points,
    this.lat,
    this.lng,
  });

  String localizedName(String lang) {
    switch (lang) {
      case 'en': return nameEn.isNotEmpty ? nameEn : name;
      case 'ja': return nameJa.isNotEmpty ? nameJa : name;
      case 'zh': return nameZh.isNotEmpty ? nameZh : name;
      default:   return name;
    }
  }

  String localizedDescription(String lang) {
    switch (lang) {
      case 'en': return descriptionEn.isNotEmpty ? descriptionEn : description;
      case 'ja': return descriptionJa.isNotEmpty ? descriptionJa : description;
      case 'zh': return descriptionZh.isNotEmpty ? descriptionZh : description;
      default:   return description;
    }
  }

  List<String> localizedDepartments(String lang) {
    switch (lang) {
      case 'en': return departmentsEn.isNotEmpty ? departmentsEn : departments;
      case 'ja': return departmentsJa.isNotEmpty ? departmentsJa : departments;
      case 'zh': return departmentsZh.isNotEmpty ? departmentsZh : departments;
      default:   return departments;
    }
  }
}

class SmuBuildingFloor {
  final String floor;
  final String content;
  final String contentEn;
  final String contentJa;
  final String contentZh;

  const SmuBuildingFloor({
    required this.floor,
    required this.content,
    this.contentEn = '',
    this.contentJa = '',
    this.contentZh = '',
  });

  String localizedContent(String lang) {
    switch (lang) {
      case 'en': return contentEn.isNotEmpty ? contentEn : content;
      case 'ja': return contentJa.isNotEmpty ? contentJa : content;
      case 'zh': return contentZh.isNotEmpty ? contentZh : content;
      default:   return content;
    }
  }
}