import 'package:favorite_places_app/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite_api.dart';

class PlacesNotifier extends Notifier<List<Place>> {
  @override
  List<Place> build() => [];

  Future<void> _onAddPlace(Place place) async {
    if (state.contains(place)) return;

    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(place.image?.path ?? '');
    final copiedImage = await place.image?.copy('${appDir.path}/$fileName');
    final newPlace = await Place.create(
      title: place.title,
      image: copiedImage,
      location: place.location,
      imageBytes: place.imageBytes,
    );

    final dbPath = await sql.getDatabasesPath();
    sql.openDatabase(path.join(dbPath, 'places.db'));

    state = [...state, newPlace];
  }

  Future<void> _onRemovePlace(Place place) async {
    if (!state.contains(place)) return;
    final imgFile = place.image;

    if (imgFile != null) {
      try {
        if (await imgFile.exists()) {
          await imgFile.delete();
        }
      } catch (e) {
        print('Erro ao deletar imagem: $e');
      }
    }

    state = state.where((p) => p != place).toList();
  }

  void addPlace(Place place) => _onAddPlace(place);
  void removePlace(Place place) => _onRemovePlace(place);
}

final placesProvider = NotifierProvider<PlacesNotifier, List<Place>>(
  PlacesNotifier.new,
);
