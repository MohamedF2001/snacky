/*import 'package:flutter/material.dart';
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
}*/


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/categories/presentation/providers/categorie_provider.dart';
import 'package:snacky/features/categories/domain/entities/categorie_entity.dart';
import 'package:snacky/features/categories/presentation/widgets/succes_dialog.dart';

import '../../../../const/app_input_style.dart';
import 'package:snacky/main.dart';

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

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  // Largeur du conteneur de formulaire selon la taille d'écran
  double _getFormWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return width; // Mobile : pleine largeur
    } else if (width < 1024) {
      return width * 0.7; // Tablette : 70% de la largeur
    } else {
      return width * 0.5; // Desktop : 50% de la largeur
    }
  }

  // Padding selon la taille d'écran
  double _getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 16.0; // Mobile
    } else if (width < 1024) {
      return 24.0; // Tablette
    } else {
      return 32.0; // Desktop
    }
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createCategoryProvider);
    final createNotifier = ref.read(createCategoryProvider.notifier);
    final isMobile = _isMobile(context);
    final isTablet = _isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Ajouter une Catégorie",
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: isMobile,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: _getFormWidth(context),
              padding: EdgeInsets.all(_getPadding(context)),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // En-tête avec icône (optionnel, plus joli)
                    if (!isMobile) ...[
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.category,
                            size: 48,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          "Nouvelle Catégorie",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          "Remplissez les informations ci-dessous",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Champ Nom
                    TextFormField(
                      controller: _nomController,
                      decoration: AppInputStyles.textFieldDecoration(
                        label: "Nom de la catégorie",
                      ),
                      style: TextStyle(fontSize: isMobile ? 15 : 16),
                      validator: (value) =>
                      value == null || value.isEmpty
                          ? "Le nom est requis"
                          : null,
                    ),
                    SizedBox(height: isMobile ? 16 : 20),

                    // Champ Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: AppInputStyles.textFieldDecoration(
                        label: "Description",
                      ),
                      style: TextStyle(fontSize: isMobile ? 15 : 16),
                      maxLines: isMobile ? 4 : 5,
                      validator: (value) =>
                      value == null || value.isEmpty
                          ? "La description est requise"
                          : null,
                    ),

                    SizedBox(height: isMobile ? 24 : 32),

                    // Bouton Ajouter
                    SizedBox(
                      width: isMobile
                          ? double.infinity
                          : _getFormWidth(context) / 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: isMobile ? 14 : 16,
                          ),
                          elevation: 2,
                        ),
                        onPressed: createState.isLoading
                            ? null
                            : () => _submit(createNotifier),
                        child: createState.isLoading
                            ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Ajouter la catégorie",
                              style: TextStyle(
                                fontSize: isMobile ? 15 : 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Bouton Annuler (mobile uniquement)
                    if (isMobile) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text(
                          "Annuler",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit(CreateCategoryNotifier createNotifier) async {
    // Si mode démo actif, on affiche une popup
    if (demo) {
      _showDemoDialog();
      return;
    }
    // Sinon on procède à la création
    _submitForm(createNotifier);
  }

  void _showDemoDialog() {
    final isMobile = _isMobile(context);

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
                child: Icon(
                  Icons.info,
                  color: Colors.blue.shade700,
                  size: isMobile ? 20 : 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Mode Démo",
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "Cette fonctionnalité n'est pas disponible en mode démo. "
                "Veuillez désactiver le mode démo pour ajouter une catégorie.",
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Fermer",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 14 : 16,
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

      // Refresh liste
      await ref.read(categorieListNotifier.notifier).getCategories();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return SuccessDialog(
              message: "Catégorie ajoutée avec succès !",
              onOk: () {
                Navigator.pop(context);
                context.go('/categories');
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

