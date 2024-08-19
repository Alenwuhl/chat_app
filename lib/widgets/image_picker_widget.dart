import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onImagePicked});

  final void Function(File pickedImage) onImagePicked;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  void _pickImage(ImageSource source) async {
    final pickedImageFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (pickedImageFile == null) {
      return;
    }
    setState(() {
      _pickedImage = File(pickedImageFile.path);
    });

    widget.onImagePicked(_pickedImage!);
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4), // Espacio para el borde
          decoration: BoxDecoration(
            border: Border.all(
              width: 2, // Grosor del borde
              color: Colors.white, // Color del borde
            ),
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundColor: _pickedImage == null
                ? const Color.fromARGB(255, 200, 200, 200) // Fondo gris claro cuando no hay imagen
                : Colors.transparent,
            backgroundImage: _pickedImage != null ? FileImage(_pickedImage!) : null,
            child: _pickedImage == null
                ? const Icon(
                    Icons.person,
                    size: 40,
                    color: Color.fromARGB(255, 72, 72, 72),
                  )
                : null,
          ),
        ),
        TextButton.icon(
          onPressed: _showImageSourceDialog,
          icon: const Icon(Icons.image),
          label: const Text('Add Image'),
        ),
      ],
    );
  }
}