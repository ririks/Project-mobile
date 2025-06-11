import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:io';
import '../widgets/recipe_dialogs.dart';

class ManageRecipesPage extends StatefulWidget {
  const ManageRecipesPage({super.key});

  @override
  State<ManageRecipesPage> createState() => _ManageRecipesPageState();
}

class _ManageRecipesPageState extends State<ManageRecipesPage> {
  final List<Map<String, dynamic>> _recipes = [];

  void _addRecipe(Map<String, dynamic> newRecipe) {
    setState(() {
      _recipes.add(newRecipe);
    });
  }

  void _editRecipe(int index, Map<String, dynamic> updatedRecipe) {
    setState(() {
      _recipes[index] = updatedRecipe;
    });
  }

  void _deleteRecipe(int index) {
    setState(() {
      _recipes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddRecipeDialog(context, onSave: _addRecipe),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _recipes.length,
        itemBuilder: (context, index) {
          final recipe = _recipes[index];
          return Card(
            margin: const EdgeInsets.all(8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Slidable(
              key: ValueKey(index),
              startActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) => showEditRecipeDialog(context, recipe, (updated) => _editRecipe(index, updated)),
                    icon: Icons.edit,
                    label: 'Edit',
                    backgroundColor: Colors.blue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  SlidableAction(
                    onPressed: (context) => _deleteRecipe(index),
                    icon: Icons.delete,
                    label: 'Hapus',
                    backgroundColor: Colors.red,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ],
              ),
              child: ListTile(
                leading: recipe['image'] != null
                    ? Image.file(recipe['image'], width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.food_bank, color: Colors.orange, size: 50),
                title: Text(recipe['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(recipe['description'], maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
          );
        },
      ),
    );
  }
}
