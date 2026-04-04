import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapFacility {
  const MapFacility({
    required this.id,
    required this.name,
    required this.type,
    required this.collectionName,
    required this.position,
    this.address,
    this.phone,
  });

  final String id;
  final String name;
  final String type;
  final String collectionName;
  final LatLng position;
  final String? address;
  final String? phone;
}
