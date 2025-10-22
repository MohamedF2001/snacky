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
                                backgroundColor: Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
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
      decoration: InputDecoration(
        labelText: "Catégorie",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
