import 'package:favorite_places_app/data/place.dart';
import 'package:favorite_places_app/providers/places_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:favorite_places_app/routes/routes.dart';

class YourPlacesScreen extends ConsumerStatefulWidget {
  const YourPlacesScreen({super.key});

  @override
  YourPlacesScreenState createState() => YourPlacesScreenState();
}

class YourPlacesScreenState extends ConsumerState<YourPlacesScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(placesProvider);
  }

  void _onDismissed(
      BuildContext context, PlacesNotifier placesNotifier, Place place) {
    final placesNotifier = ref.read(placesProvider.notifier);
    placesNotifier.removePlace(place);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${place.title} removed!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(placesProvider);
    final placesNotifier = ref.read(placesProvider.notifier);

    Widget body = const Center(
      child: Text(
        'No places added yet.',
      ),
    );

    if (places.isNotEmpty) {
      body = ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return Dismissible(
            key: ValueKey(place.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _onDismissed(context, placesNotifier, place),
            background: Container(
              color: Theme.of(context).colorScheme.error,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
                size: 40,
              ),
            ),
            child: ListTile(
              title: Text(place.title),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Places',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.addNewPlaces.path);
            },
          ),
        ],
      ),
      body: body,
    );
  }
}
