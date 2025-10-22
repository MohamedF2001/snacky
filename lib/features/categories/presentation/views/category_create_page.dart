import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/categories/presentation/providers/categorie_provider.dart';
import 'package:snacky/features/categories/domain/entities/categorie_entity.dart';
import 'package:snacky/features/categories/presentation/widgets/succes_dialog.dart';

import '../../../../const/app_input_style.dart';

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
                    decoration: AppInputStyles.textFieldDecoration(label: "Nom"),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Champ requis" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: AppInputStyles.textFieldDecoration(label: "Description"),
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
                        backgroundColor: Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: createState.isLoading
                          ? null
                          : () => _submitForm(createNotifier),
                      child: createState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: Center(child: CircularProgressIndicator(color: Colors.orange)),
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
        /* ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Catégorie ajoutée avec succès"),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/categories'); */
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
