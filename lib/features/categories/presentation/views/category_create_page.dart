import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/categories/presentation/providers/categorie_provider.dart';
import 'package:snacky/features/categories/domain/entities/categorie_entity.dart';
import 'package:snacky/features/categories/presentation/widgets/succes_dialog.dart';

import '../../../../const/app_input_style.dart';
import 'package:snacky/main.dart'; // ...existing code... (import pour la variable demo)

class CategoryCreatePage extends ConsumerStatefulWidget {
  const CategoryCreatePage({super.key});

  @override
  ConsumerState<CategoryCreatePage> createState() => _CategoryCreatePageState();
}

class _CategoryCreatePageState extends ConsumerState<CategoryCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createCategoryProvider);
    final createNotifier = ref.read(createCategoryProvider.notifier);
    //final categorieState = ref.watch(categorieListNotifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter une Catégorie")),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: AppInputStyles.textFieldDecoration(
                      label: "Nom",
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Champ requis" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: AppInputStyles.textFieldDecoration(
                      label: "Description",
                    ),
                    maxLines: 5,
                    validator: (value) =>
                        value == null || value.isEmpty ? "Champ requis" : null,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width:
                        MediaQuery.of(context).size.width /
                        4, // moitié de la moitié
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: createState.isLoading
                          ? null
                          : () => _submit(
                              createNotifier,
                            ), // <-- modifié pour gérer le mode demo
                      child: createState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.orange,
                                ),
                              ),
                            )
                          : const Text("Ajouter"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit(CreateCategoryNotifier createNotifier) async {
    // Si mode démo actif, on affiche une popup et on n'appelle pas la création réelle
    if (demo) {
      _showDemoDialog();
      return;
    }
    // Sinon on procède à la création
    _submitForm(createNotifier);
  }

  void _showDemoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.info, color: Colors.blue.shade700, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                "Mode Démo",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "Cette fonctionnalité n'est pas disponible en mode démo. "
            "Veuillez désactiver le mode démo pour ajouter une catégorie.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Fermer",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _submitForm(CreateCategoryNotifier createNotifier) async {
    if (_formKey.currentState!.validate()) {
      final categorie = CategorieEntity(
        id: '',
        nom: _nomController.text,
        description: _descriptionController.text,
      );

      await createNotifier.createCategory(categorie);

      // refresh liste
      await ref.read(categorieListNotifier.notifier).getCategories();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false, // empêche de fermer en cliquant dehors
          builder: (context) {
            return SuccessDialog(
              message: "Catégorie ajoutée avec succès !",
              onOk: () {
                Navigator.pop(context); // ferme le dialog
                context.go('/categories'); // redirection
              },
            );
          },
        );
      }
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
