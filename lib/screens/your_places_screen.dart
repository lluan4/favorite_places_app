import 'package:favorite_places_app/models/place.dart';
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
  late Future<void> _placesFuture;

  @override
  void initState() {
    super.initState();
    ref.read(placesProvider);
    _placesFuture = ref.read(placesProvider.notifier).loadPlaces();
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
    final theme = Theme.of(context);
    final places = ref.watch(placesProvider);
    final placesNotifier = ref.read(placesProvider.notifier);

    final TextStyle? textStyle =
        theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface);
    final TextStyle? subtitleStyle =
        theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface);

    Widget body = Center(
      child: Text(
        'No places added yet.',
        style: textStyle,
      ),
    );

    if (places.isNotEmpty) {
      body = FutureBuilder(
          future: _placesFuture,
          builder: (context, snapshot) => snapshot.connectionState ==
                  ConnectionState.waiting
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final place = places[index];
                    return Dismissible(
                      key: ValueKey(place.id),
                      background: Container(
                        color: theme.colorScheme.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) =>
                          _onDismissed(context, placesNotifier, place),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: MemoryImage(place.imageBytes),
                        ),
                        title: Text(place.title, style: textStyle),
                        subtitle: Text(place.address, style: subtitleStyle),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            Routes.placeDetails.path,
                            arguments: place,
                          );
                        },
                      ),
                    );
                  },
                ));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Places',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        backgroundColor: theme.colorScheme.surfaceDim,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.addNewPlaces.path);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: body,
      ),
    );
  }
}
