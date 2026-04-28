import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapDefaults {
  static const LatLng jongnoCenter = LatLng(37.57295, 126.97936);
  static const double defaultZoom = 14;
  static const double minZoom = 11;
  static const double maxZoom = 18;

  static final LatLngBounds jongnoBounds = LatLngBounds(
    southwest: const LatLng(37.557, 126.954),
    northeast: const LatLng(37.592, 127.022),
  );

  static const CameraPosition jongnoCamera = CameraPosition(
    target: jongnoCenter,
    zoom: defaultZoom,
  );

  static const List<LatLng> seoulOuterMask = [
    LatLng(37.7200, 126.8200),
    LatLng(37.7200, 127.1400),
    LatLng(37.4300, 127.1400),
    LatLng(37.4300, 126.8200),
  ];

  // 종로구 경계를 단순화한 폴리곤이다.
  static const List<LatLng> jongnoMaskHole = [
    LatLng(37.5958, 126.9582),
    LatLng(37.6042, 126.9668),
    LatLng(37.6061, 126.9801),
    LatLng(37.6048, 126.9950),
    LatLng(37.5990, 127.0089),
    LatLng(37.5935, 127.0175),
    LatLng(37.5840, 127.0207),
    LatLng(37.5735, 127.0194),
    LatLng(37.5682, 127.0141),
    LatLng(37.5628, 127.0059),
    LatLng(37.5588, 126.9970),
    LatLng(37.5565, 126.9884),
    LatLng(37.5567, 126.9787),
    LatLng(37.5585, 126.9706),
    LatLng(37.5615, 126.9640),
    LatLng(37.5681, 126.9585),
    LatLng(37.5769, 126.9554),
    LatLng(37.5860, 126.9553),
  ];
}
