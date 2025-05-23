import 'dart:io';
import 'dart:typed_data';

import 'package:favorite_places_app/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';

import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;

Future<sql.Database> _getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  return sql.openDatabase(
    path.join(dbPath, 'places.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE user_places (id TEXT PRIMARY KEY, title TEXT, image TEXT, lat REAL, lng REAL, address TEXT)',
      );
    },
    version: 1,
  );
}

Future<Uint8List> _loadImageBytes(String path) async {
  final bytes = await File(path).readAsBytes();
  return bytes;
}

class PlacesNotifier extends Notifier<List<Place>> {
  @override
  List<Place> build() => [];

  Future<void> loadPlaces() async {
    final db = await _getDatabase();
    final data = await db.query('user_places');

    final futures = data.map(
      (item) async {
        final location = LocationData.fromMap({
          'latitude': item['lat'] as double?,
          'longitude': item['lng'] as double?,
        });
        final Uint8List imageBytes =
            await _loadImageBytes(item['image'] as String);

        final place = await Place.create(
          id: item['id'] as String,
          title: item['title'] as String,
          imageBytes: imageBytes,
          location: location,
        );

        return place;
      },
    ).toList();

    final List<Place> places = await Future.wait(futures);

    state = places;
  }

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

    final db = await _getDatabase();
    db.insert(
      'user_places',
      {
        'id': newPlace.id,
        'title': newPlace.title,
        'image': newPlace.image?.path,
        'lat': newPlace.location.latitude,
        'lng': newPlace.location.longitude,
        'address': newPlace.address,
      },
    );

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
