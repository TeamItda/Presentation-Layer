import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapFacility {
  const MapFacility({
    required this.id,
    required this.facilityId,
    required this.categoryId,
    required this.name,
    required this.type,
    required this.collectionName,
    required this.position,
    this.address,
    this.phone,
    this.homepage,
    this.imageAssetPath,
    this.imageUrl,
  });

  final String id;
  final String facilityId;
  final String categoryId;
  final String name;
  final String type;
  final String collectionName;
  final LatLng position;
  final String? address;
  final String? phone;
  final String? homepage;
  final String? imageAssetPath;
  final String? imageUrl;
}
