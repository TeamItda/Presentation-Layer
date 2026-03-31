import 'package:google_maps_flutter/google_maps_flutter.dart';

//지도 기본 설정
class MapDefaults {
  static const LatLng jongnoCenter = LatLng(37.57295, 126.97936);
  static const double defaultZoom = 14;
  static const double minZoom = 11;
  static const double maxZoom = 18;

// 종로구청 중심
  static final LatLngBounds jongnoBounds = LatLngBounds(
    southwest: LatLng(37.557, 126.954),
    northeast: LatLng(37.592, 127.022),
  );

  static const CameraPosition jongnoCamera = CameraPosition(
    target: jongnoCenter,
    zoom: defaultZoom,
  );
}
