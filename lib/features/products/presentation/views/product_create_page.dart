/*
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:image_picker/image_picker.dart'; // pour mobile
import 'package:file_picker/file_picker.dart'; // pour web
import 'package:snacky/const/app_input_style.dart';
import 'package:snacky/features/categories/presentation/providers/categorie_provider.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart'; // ✅ Utiliser ProductEntity

import 'package:snacky/features/products/presentation/providers/product_provider.dart';
import 'package:snacky/features/products/presentation/widgets/succes_dialog_product.dart';

class ProductCreatePage extends ConsumerStatefulWidget {
  const ProductCreatePage({super.key});

  @override
  ConsumerState<ProductCreatePage> createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends ConsumerState<ProductCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  File? _imageFile;
  Uint8List? _imageBytes;
  String? _selectedCategorieId;

  @override
  void initState() {
    super.initState();
    // Charger les catégories si elles ne sont pas déjà là
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categorieListNotifier.notifier).getCategories();
    });
  }

  Future<void> _pickImage() async {
    print("🔍 _pickImage called, kIsWeb: $kIsWeb");

    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          _imageBytes = result.files.single.bytes;
          _imageFile = null;
        });
        print("✅ Image selected for Web: ${_imageBytes!.length} bytes");
      }
    } else {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBytes = null;
        });
        print("✅ Image selected for Mobile: ${_imageFile!.path}");
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Debug avant de soumettre
    print("🔍 _submit called:");
    print("  _imageBytes != null: ${_imageBytes != null}");
    print("  _imageFile != null: ${_imageFile != null}");
    if (_imageBytes != null) {
      print("  _imageBytes length: ${_imageBytes!.length}");
    }

    // ✅ Créer directement un ProductEntity avec l'ID de catégorie en String
    final productEntity = ProductEntity(
      id: null, // backend génère
      nom: _nomController.text.trim(),
      description: _descriptionController.text.trim(),
      prix: double.tryParse(_prixController.text.trim()) ?? 0,
      imageUrl: null, // sera généré par le backend
      categorie: _selectedCategorieId, // ✅ Directement le String ID
    );

    print("📦 ProductEntity to send:");
    print("  nom: ${productEntity.nom}");
    print("  description: ${productEntity.description}");
    print("  prix: ${productEntity.prix}");
    print(
      "  categorie: ${productEntity.categorie} (${productEntity.categorie.runtimeType})",
    );

    // ✅ Envoyer le ProductEntity avec les images
    ref
        .read(createProductProvider.notifier)
        .createProduct(
          productEntity,
          imageFile: !kIsWeb ? _imageFile : null,
          imageBytes: kIsWeb ? _imageBytes : null,
        )
        .then((_) {
          final state = ref.read(createProductProvider);
          if (state.error == null && state.product != null) {
            print("✅ Produit créé avec succès: ${state.product!.nom}");
            if (context.mounted) {
              // Rafraîchir la liste des produits
              ref.read(productListNotifier.notifier).getProduits();
              showDialog(
                context: context,
                barrierDismissible:
                    false, // empêche de fermer en cliquant dehors
                builder: (context) {
                  return SuccesDialogProduct(
                    message: "Produit ajouté avec succès !",
                    onOk: () {
                      Navigator.pop(context); // ferme le dialog
                      context.go('/products'); // retour à la liste produits
                    },
                  );
                },
              );
            }
          } else {
            print("❌ Erreur lors de la création: ${state.error}");
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error?.toString() ?? "Erreur inconnue"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createProductProvider);
    final categorieState = ref.watch(categorieListNotifier);

    // 🔥 Nettoyer la sélection invalide de façon plus agressive
    if (_selectedCategorieId != null &&
        categorieState.categories.isNotEmpty &&
        !categorieState.categories.any((c) => c.id == _selectedCategorieId)) {
      _selectedCategorieId = null; // Nettoyage immédiat
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Créer un produit")),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Champ nom
                    TextFormField(
                      controller: _nomController,
                      decoration: AppInputStyles.textFieldDecoration(label: "Nom"),
                      validator: (val) =>
                          val == null || val.isEmpty ? "Nom requis" : null,
                    ),
                    const SizedBox(height: 12),

                    // Champ description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: AppInputStyles.textFieldDecoration(label: "Description"),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),

                    // Champ prix
                    TextFormField(
                      controller: _prixController,
                      decoration:AppInputStyles.textFieldDecoration(label: "Prix"),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Prix requis";
                        final prix = double.tryParse(val);
                        if (prix == null || prix <= 0) return "Prix invalide";
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Image picker
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: _imageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  _imageBytes!,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.add_photo_alternate,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Choisir une image",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ✅ Dropdown des catégories
                    _buildCategoryDropdown(
                      categorieState,
                      _selectedCategorieId,
                    ),

                    const SizedBox(height: 24),

                    // Bouton soumettre
                    createState.isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                        : SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text("Créer le produit"),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(
    CategorieListState categorieState,
    String? dropdownValue,
  ) {
    if (categorieState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.orange));
    }
    if (categorieState.error != null) {
      return Card(
        color: Colors.red[100],
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Erreur: ${categorieState.error}",
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    if (categorieState.categories.isEmpty) {
      return Card(
        color: Colors.amber[100],
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "Aucune catégorie disponible. Veuillez en créer une.",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return DropdownButtonFormField<String>(
      value: dropdownValue,
      decoration: AppInputStyles.textFieldDecoration(label: "Catégorie"),
      items: categorieState.categories.map((categorie) {
        return DropdownMenuItem<String>(
          value: categorie.id,
          child: Text(categorie.nom),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategorieId = value;
        });
      },
      validator: (val) => val == null ? "Catégorie requise" : null,
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    super.dispose();
  }
}
*/

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:snacky/const/app_input_style.dart';
import 'package:snacky/features/categories/presentation/providers/categorie_provider.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';

import 'package:snacky/features/products/presentation/providers/product_provider.dart';
import 'package:snacky/features/products/presentation/widgets/succes_dialog_product.dart';

class ProductCreatePage extends ConsumerStatefulWidget {
  const ProductCreatePage({super.key});

  @override
  ConsumerState<ProductCreatePage> createState() => _ProductCreatePageState();
}

class _ProductCreatePageState extends ConsumerState<ProductCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  final _searchController = TextEditingController();

  File? _imageFile;
  Uint8List? _imageBytes;
  String? _selectedCategorieId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categorieListNotifier.notifier).getCategories();
    });
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    print("🔍 _pickImage called, kIsWeb: $kIsWeb");

    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          _imageBytes = result.files.single.bytes;
          _imageFile = null;
        });
        print("✅ Image selected for Web: ${_imageBytes!.length} bytes");
      }
    } else {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBytes = null;
        });
        print("✅ Image selected for Mobile: ${_imageFile!.path}");
      }
    }
  }

  List<dynamic> _getFilteredCategories(List categories) {
    if (_searchQuery.isEmpty) return categories;
    return categories.where((categorie) {
      return categorie.nom.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    print("🔍 _submit called:");
    print("  _imageBytes != null: ${_imageBytes != null}");
    print("  _imageFile != null: ${_imageFile != null}");
    if (_imageBytes != null) {
      print("  _imageBytes length: ${_imageBytes!.length}");
    }

    final productEntity = ProductEntity(
      id: null,
      nom: _nomController.text.trim(),
      description: _descriptionController.text.trim(),
      prix: double.tryParse(_prixController.text.trim()) ?? 0,
      imageUrl: null,
      categorie: _selectedCategorieId,
    );

    print("📦 ProductEntity to send:");
    print("  nom: ${productEntity.nom}");
    print("  description: ${productEntity.description}");
    print("  prix: ${productEntity.prix}");
    print("  categorie: ${productEntity.categorie} (${productEntity.categorie.runtimeType})");

    ref
        .read(createProductProvider.notifier)
        .createProduct(
      productEntity,
      imageFile: !kIsWeb ? _imageFile : null,
      imageBytes: kIsWeb ? _imageBytes : null,
    )
        .then((_) {
      final state = ref.read(createProductProvider);
      if (state.error == null && state.product != null) {
        print("✅ Produit créé avec succès: ${state.product!.nom}");
        if (context.mounted) {
          ref.read(productListNotifier.notifier).getProduits();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return SuccesDialogProduct(
                message: "Produit ajouté avec succès !",
                onOk: () {
                  Navigator.pop(context);
                  context.go('/products');
                },
              );
            },
          );
        }
      } else {
        print("❌ Erreur lors de la création: ${state.error}");
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error?.toString() ?? "Erreur inconnue"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createProductProvider);
    final categorieState = ref.watch(categorieListNotifier);

    if (_selectedCategorieId != null &&
        categorieState.categories.isNotEmpty &&
        !categorieState.categories.any((c) => c.id == _selectedCategorieId)) {
      _selectedCategorieId = null;
    }

    final filteredCategories = _getFilteredCategories(categorieState.categories);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            Text(
              "Produits",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              " / ",
              style: TextStyle(color: Colors.grey.shade400),
            ),
            const Text(
              "Créer un produit",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📂 COLONNE GAUCHE - Formulaire
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      // En-tête du formulaire
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.fastfood,
                              color: Colors.orange.shade700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Informations du produit",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Image upload
                      const Text(
                        "Image du produit",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _imageBytes != null
                              ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  _imageBytes!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          )
                              : _imageFile != null
                              ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          )
                              : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Cliquez pour ajouter une image",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "PNG, JPG jusqu'à 10MB",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Nom du produit
                      const Text(
                        "Nom du produit",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nomController,
                        decoration: AppInputStyles.textFieldDecoration(
                          label: "Ex: Burger Poulet",
                        ),
                        validator: (val) =>
                        val == null || val.isEmpty ? "Nom requis" : null,
                      ),
                      const SizedBox(height: 20),
                      // Description
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: AppInputStyles.textFieldDecoration(
                          label: "Décrivez votre produit...",
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),
                      // Prix
                      const Text(
                        "Prix",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _prixController,
                        decoration: AppInputStyles.textFieldDecoration(
                          label: "Prix en F CFA",
                        ).copyWith(
                          prefixIcon: const Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Prix requis";
                          final prix = double.tryParse(val);
                          if (prix == null || prix <= 0) return "Prix invalide";
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Résumé de la catégorie sélectionnée
                      if (_selectedCategorieId != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange.shade700,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Catégorie sélectionnée",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      categorieState.categories
                                          .firstWhere((c) => c.id == _selectedCategorieId)
                                          .nom,
                                      style: TextStyle(
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.orange.shade700,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedCategorieId = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Bouton de création
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: createState.isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: createState.isLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Créer le produit",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 24),
            // 📝 COLONNE DROITE - Sélection de catégorie
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.category,
                                  color: Colors.orange.shade700,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Sélectionner une catégorie",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _selectedCategorieId != null
                                ? "1 catégorie sélectionnée"
                                : "Aucune catégorie sélectionnée",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Barre de recherche
                          TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                            decoration: InputDecoration(
                              hintText: "Rechercher une catégorie...",
                              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // Liste des catégories
                    Expanded(
                      child: categorieState.isLoading
                          ? const Center(
                        child: CircularProgressIndicator(color: Colors.orange),
                      )
                          : categorieState.error != null
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Erreur: ${categorieState.error}",
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                          : filteredCategories.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? "Aucune catégorie disponible"
                                  : "Aucune catégorie trouvée",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                          : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: filteredCategories.length,
                        separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final categorie = filteredCategories[index];
                          final isSelected = _selectedCategorieId == categorie.id;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedCategorieId = categorie.id;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange.shade50
                                    : Colors.grey.shade50,
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.orange
                                      : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: categorie.description != null
                                        ? Image.network(
                                      width: 50,
                                      height: 50,
                                      "assets/images/categories/${categorie.description}.png",
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Icon(
                                            Icons.category,
                                            color: Colors.grey.shade400,
                                            size: 30,
                                          ),
                                    )
                                        : Icon(
                                      Icons.category,
                                      color: Colors.grey.shade400,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Nom de la catégorie
                                  Expanded(
                                    child: Text(
                                      categorie.nom,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isSelected
                                            ? Colors.orange.shade900
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  // Radio button
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? Colors.orange
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.orange
                                            : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Center(
                                      child: Icon(
                                        Icons.circle,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                    )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
