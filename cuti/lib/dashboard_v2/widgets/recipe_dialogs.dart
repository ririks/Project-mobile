import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> showAddRecipeDialog(BuildContext context, {required Function(Map<String, dynamic>) onSave}) async {
  await showDialog(
    context: context,
    builder: (context) {
      return RecipeDialog(
        onSave: onSave,
      );
    },
  );
}

Future<void> showEditRecipeDialog(BuildContext context, Map<String, dynamic> recipe, Function(Map<String, dynamic>) onSave) async {
  await showDialog(
    context: context,
    builder: (context) {
      return RecipeDialog(
        onSave: onSave,
        initialData: recipe,
      );
    },
  );
}

class RecipeDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialData;

  const RecipeDialog({super.key, required this.onSave, this.initialData});

  @override
  State<RecipeDialog> createState() => _RecipeDialogState();
}

class _RecipeDialogState extends State<RecipeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData?['name'] ?? '');
    _descController = TextEditingController(text: widget.initialData?['description'] ?? '');
    _selectedImage = widget.initialData?['image'];
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialData != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Resep' : 'Tambah Resep'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _selectedImage != null
                    ? Image.file(_selectedImage!, height: 120, width: 120, fit: BoxFit.cover)
                    : Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[300],
                        ),
                        child: const Icon(Icons.camera_alt, size: 40, color: Colors.white70),
                      ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Resep'),
                validator: (value) => value == null || value.isEmpty ? 'Nama resep wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave({
                'name': _nameController.text,
                'description': _descController.text,
                'image': _selectedImage,
              });
              Navigator.of(context).pop();
            }
          },
          child: Text(isEdit ? 'Simpan' : 'Tambah'),
        ),
      ],
    );
  }
}
