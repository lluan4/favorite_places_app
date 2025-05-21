import 'dart:io';
import 'dart:typed_data';

import 'package:location/location.dart';
import 'package:uuid/uuid.dart';
import 'package:geocoding/geocoding.dart';

const _uuid = Uuid();

class Place {
  final String id;
  final String title;
  final File? image;
  final LocationData location;
  final String address;
  final Uint8List imageBytes;

  Place._({
    required this.id,
    required this.title,
    required this.image,
    required this.location,
    required this.address,
    required this.imageBytes,
  });

  static Future<Place> create({
    required String title,
    File? image,
    required LocationData location,
    required Uint8List imageBytes,
  }) async {
    String address;
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude!,
        location.longitude!,
      );
      final pm = placemarks.first;
      address = [
        pm.street,
        pm.subLocality,
        pm.locality,
        pm.postalCode,
        pm.country,
      ].where((s) => s?.isNotEmpty == true).join(', ');
    } catch (_) {
      address = 'Endereço não disponível';
    }

    return Place._(
      id: _uuid.v4(),
      title: title,
      image: image,
      location: location,
      address: address,
      imageBytes: imageBytes,
    );
  }
}
