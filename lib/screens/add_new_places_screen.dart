import 'package:favorite_places_app/data/place.dart';
import 'package:favorite_places_app/providers/places_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddNewPlacesScreen extends ConsumerStatefulWidget {
  const AddNewPlacesScreen({super.key});

  @override
  AddNewPlacesScreenState createState() => AddNewPlacesScreenState();
}

class AddNewPlacesScreenState extends ConsumerState<AddNewPlacesScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();

  void _navigationBack() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Place added successfully!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _saveForm(PlacesNotifier placesNotifier) {
    final currentState = _formKey.currentState;
    if (currentState == null) return;

    if (!currentState.validate()) return;

    final newPlace = Place(
      id: DateTime.now().toString(),
      title: _titleController.text,
    );

    placesNotifier.addPlace(newPlace);
    _navigationBack();
  }

  @override
  void initState() {
    super.initState();
    ref.read(placesProvider);
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
        title: const Text('Add New Place'),
      ),
      body: Padding(
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
              ElevatedButton(
                onPressed: () => _saveForm(placesNotifier),
                child: const Text(
                  'Submit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
