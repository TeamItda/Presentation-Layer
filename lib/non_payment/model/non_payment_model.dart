class NonPaymentModel {
  final String itemName;      // 비급여 항목명 (MRI, 초음파 등)
  final String hospitalName;  // 병원명
  final String hospitalId;    // 병원 ID
  final int minPrice;         // 최소 가격
  final int maxPrice;         // 최대 가격
  final int avgPrice;         // 평균 가격

  const NonPaymentModel({
    required this.itemName,
    required this.hospitalName,
    required this.hospitalId,
    required this.minPrice,
    required this.maxPrice,
    required this.avgPrice,
  });

  // HIRA API 응답 → NonPaymentModel
  factory NonPaymentModel.fromMap(Map<String, dynamic> map) {
    return NonPaymentModel(
      itemName: map['itemNm'] ?? '',
      hospitalName: map['yadmNm'] ?? '',
      hospitalId: map['ykiho'] ?? '',
      minPrice: int.tryParse(map['minAmt']?.toString() ?? '0') ?? 0,
      maxPrice: int.tryParse(map['maxAmt']?.toString() ?? '0') ?? 0,
      avgPrice: int.tryParse(map['avgAmt']?.toString() ?? '0') ?? 0,
    );
  }

  // 가격 포맷 (1000 단위 콤마)
  String formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    ) +
        '원';
  }

  String get formattedMin => formatPrice(minPrice);
  String get formattedMax => formatPrice(maxPrice);
  String get formattedAvg => formatPrice(avgPrice);
}