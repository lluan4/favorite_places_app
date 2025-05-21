import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:location/location.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'dart:ui' as ui;
import 'dart:typed_data';

class LocationInput extends StatefulWidget {
  final void Function(LocationData location, Uint8List imageBytes)
      onSelectLocation;
  const LocationInput({super.key, required this.onSelectLocation});

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  final GlobalKey _mapKey = GlobalKey();
  LocationData? _pickedLocation;
  bool _isLoading = false;

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;
    Uint8List? imageBytes;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    locationData = await location.getLocation();
    imageBytes = await _captureMapPng();

    setState(() {
      _pickedLocation = locationData;
      _isLoading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 5000));
      final imageBytes = await _captureMapPng();
      if (imageBytes != null) {
        widget.onSelectLocation(locationData, imageBytes);
      }
    });
  }

  Future<Uint8List?> _captureMapPng() async {
    try {
      RenderRepaintBoundary boundary =
          _mapKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Erro ao capturar snapshot: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget previewContent = Center(
      child: Text(
        'No Location Chosen',
        style: theme.textTheme.bodyLarge
            ?.copyWith(color: theme.colorScheme.primary),
      ),
    );

    if (_isLoading) {
      previewContent = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_pickedLocation != null) {
      previewContent = RepaintBoundary(
        key: _mapKey,
        child: FlutterMap(
          options: MapOptions(
              initialCenter: LatLng(_pickedLocation?.latitude ?? 0.0,
                  _pickedLocation?.longitude ?? 0.0),
              initialZoom: 15.2),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.teste.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(
                    _pickedLocation!.latitude!,
                    _pickedLocation!.longitude!,
                  ),
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.surfaceContainerLow,
              width: 1,
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
              onPressed: _getCurrentLocation,
            ),
          ],
        )
      ],
    );
  }
}
