import 'package:flutter/material.dart';

import 'package:favorite_places_app/screens/add_new_places_screen.dart';
import 'package:favorite_places_app/screens/your_places_screen.dart';

enum Routes {
  yourPlaces('/'),
  addNewPlaces('/add-place');

  final String path;

  const Routes(this.path);
}

Map<String, Widget Function(BuildContext)> routes = {
  Routes.yourPlaces.path: (context) => const YourPlacesScreen(),
  Routes.addNewPlaces.path: (context) => const AddNewPlacesScreen(),
};
