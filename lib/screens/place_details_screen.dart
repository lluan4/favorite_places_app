import 'package:favorite_places_app/models/place.dart';
import 'package:flutter/material.dart';

class PlaceDetailsScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(place.title),
      ),
      body: Stack(
        children: [
          Image.file(
            place.image!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ],
      ),
    );
  }
}
