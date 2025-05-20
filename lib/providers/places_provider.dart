import 'package:favorite_places_app/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlacesNotifier extends Notifier<List<Place>> {
  @override
  List<Place> build() => [];

  void _onAddPlace(Place place) {
    if (state.contains(place)) return;
    state = [...state, place];
  }

  void _onRemovePlace(Place place) {
    if (!state.contains(place)) return;
    state = state.where((p) => p != place).toList();
  }

  void addPlace(Place place) => _onAddPlace(place);
  void removePlace(Place place) => _onRemovePlace(place);
}

final placesProvider = NotifierProvider<PlacesNotifier, List<Place>>(
  PlacesNotifier.new,
);
