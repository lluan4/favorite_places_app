import 'dart:io';
import 'dart:typed_data';

import 'package:favorite_places_app/models/place.dart';
import 'package:favorite_places_app/providers/places_provider.dart';
import 'package:favorite_places_app/widgets/image_input.dart';
import 'package:favorite_places_app/widgets/location_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';

class AddNewPlacesScreen extends ConsumerStatefulWidget {
  const AddNewPlacesScreen({super.key});

  @override
  AddNewPlacesScreenState createState() => AddNewPlacesScreenState();
}

class AddNewPlacesScreenState extends ConsumerState<AddNewPlacesScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  File? _selectedImage;
  LocationData? _pickedLocation;
  Uint8List? _imageBytes;

  void _onPickedImage(File image) {
    _selectedImage = image;
  }

  void _onSelectLocation(LocationData location, Uint8List imageBytes) {
    _imageBytes = imageBytes;
    _pickedLocation = location;
  }

  void _navigationBack() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Place added successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop();
  }

  void _saveForm(PlacesNotifier placesNotifier) async {
    final currentState = _formKey.currentState;
    if (currentState == null) return;

    if (!currentState.validate() ||
        _selectedImage == null ||
        _pickedLocation == null ||
        _imageBytes == null) return;

    final newPlace = await Place.create(
      title: _titleController.text,
      image: _selectedImage,
      location: _pickedLocation!,
      imageBytes: _imageBytes!,
    );

    placesNotifier.addPlace(newPlace);
    _navigationBack();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placesNotifier = ref.read(placesProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add New Place',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        backgroundColor: theme.colorScheme.surfaceDim,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ImageInput(
                onPickImage: _onPickedImage,
              ),
              const SizedBox(height: 12),
              LocationInput(
                onSelectLocation: _onSelectLocation,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _saveForm(placesNotifier),
                    label: const Text('Add Place'),
                    icon: const Icon(Icons.add),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
