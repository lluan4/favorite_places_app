import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  final void Function(File image) onPickImage;

  const ImageInput({super.key, required this.onPickImage});

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  File? _selectedImage;

  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 600,
    );

    if (pickedImage == null) return;

    setState(() {
      _selectedImage = File(pickedImage.path);
    });

    widget.onPickImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    Widget content = TextButton.icon(
      icon: const Icon(Icons.camera),
      label: const Text('Take Picture'),
      onPressed: _takePicture,
    );

    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: _takePicture,
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }

    final theme = Theme.of(context);
    return Container(
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.surfaceContainerLow,
          width: 1,
        ),
      ),
      child: content,
    );
  }
}
