class LtcProgram {
  final String name;
  final String typeCode;
  final String? location;
  final int targetCount;
  final int frequency;

  const LtcProgram({
    required this.name,
    required this.typeCode,
    this.location,
    required this.targetCount,
    required this.frequency,
  });

  String get typeLabel {
    switch (typeCode) {
      case '1': return '치료';
      case '2': return '예술치료';
      case '3': return '여가/사회참여';
      case '4': return '신체활동';
      case '5': return '인지활동';
      default:  return typeCode.isEmpty ? '프로그램' : typeCode;
    }
  }
}

class LtcAcceptance {
  final int currentMen;
  final int currentWomen;
  final int capacityMen;
  final int capacityWomen;

  const LtcAcceptance({
    this.currentMen = 0,
    this.currentWomen = 0,
    this.capacityMen = 0,
    this.capacityWomen = 0,
  });

  int get current => currentMen + currentWomen;
  int get capacity => capacityMen + capacityWomen;
  double get occupancyRate =>
      capacity > 0 ? (current / capacity).clamp(0.0, 1.0) : 0.0;
}
