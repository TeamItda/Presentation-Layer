String formatPrice(int price) {
  return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원';
}

String formatDistance(double meters) {
  if (meters < 1000) return '${meters.toInt()}m';
  return '${(meters / 1000).toStringAsFixed(1)}km';
}
