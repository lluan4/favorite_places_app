import 'package:favorite_places_app/models/place.dart';
import 'package:flutter/material.dart';

import 'package:favorite_places_app/screens/place_details_screen.dart';
import 'package:favorite_places_app/screens/add_new_places_screen.dart';
import 'package:favorite_places_app/screens/your_places_screen.dart';

enum Routes {
  yourPlaces('/'),
  addNewPlaces('/add-place'),
  placeDetails('/place-details');

  final String path;

  const Routes(this.path);
}

Map<String, Widget Function(BuildContext)> routes = {
  Routes.yourPlaces.path: (context) => const YourPlacesScreen(),
  Routes.addNewPlaces.path: (context) => const AddNewPlacesScreen(),
  Routes.placeDetails.path: (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! Place) {
      throw FlutterError(
          'Esperado um Place em arguments para ${Routes.placeDetails.path}');
    }
    return PlaceDetailsScreen(place: args);
  },
};
