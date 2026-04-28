import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class JongnoBoundaryOverlay {
  static const String _assetPath = 'assets/jongno_boundary.json';
  static const List<LatLng> _outerMask = [
    LatLng(37.7200, 126.8200),
    LatLng(37.7200, 127.1400),
    LatLng(37.4300, 127.1400),
    LatLng(37.4300, 126.8200),
  ];

  static List<LatLng>? _cachedBoundary;

  static Future<List<LatLng>> loadBoundary() async {
    if (_cachedBoundary != null) {
      return _cachedBoundary!;
    }

    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final coordinates = decoded['coordinates'] as List<dynamic>;
    _cachedBoundary = coordinates
        .map((point) => point as List<dynamic>)
        .map((point) => LatLng(
              (point[1] as num).toDouble(),
              (point[0] as num).toDouble(),
            ))
        .toList();
    return _cachedBoundary!;
  }

  static Future<Set<Polygon>> buildMaskPolygons({
    required Color strokeColor,
  }) async {
    final boundary = await loadBoundary();
    return {
      Polygon(
        polygonId: const PolygonId('jongno-mask'),
        points: _outerMask,
        holes: [boundary],
        fillColor: const Color(0xAA0F172A),
        strokeColor: const Color(0x00000000),
        strokeWidth: 0,
      ),
      Polygon(
        polygonId: const PolygonId('jongno-outline'),
        points: boundary,
        fillColor: const Color(0x00000000),
        strokeColor: strokeColor,
        strokeWidth: 2,
      ),
    };
  }
}
