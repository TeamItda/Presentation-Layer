class HospitalModel {
  final String id;
  final String name;
  final String type;
  final String addr;
  final String tel;
  final String homepage;
  final double lat;
  final double lng;
  final int totalDocs;
  final int specialists;
  final List<String> departments;
  final List<EquipmentInfo> equipment;

  HospitalModel({
    required this.id,
    required this.name,
    required this.type,
    required this.addr,
    required this.tel,
    required this.homepage,
    required this.lat,
    required this.lng,
    required this.totalDocs,
    required this.specialists,
    required this.departments,
    required this.equipment,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) {
    return HospitalModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      addr: json['addr'] ?? '',
      tel: json['tel'] ?? '',
      homepage: json['homepage'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      totalDocs: json['totalDocs'] ?? 0,
      specialists: json['specialists'] ?? 0,
      departments: List<String>.from(json['departments'] ?? []),
      equipment: (json['equipment'] as List<dynamic>?)
          ?.map((e) => EquipmentInfo.fromJson(e))
          .toList() ??
          [],
    );
  }

  String get departmentsText => departments.join(', ');

  String get equipmentText =>
      equipment.map((e) => '${e.name} ${e.count}대').join(', ');
}

class EquipmentInfo {
  final String name;
  final int count;

  EquipmentInfo({required this.name, required this.count});

  factory EquipmentInfo.fromJson(Map<String, dynamic> json) {
    return EquipmentInfo(
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
