// features/products/presentation/pages/product_edit_page.dart
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

class ProductEditPage extends ConsumerStatefulWidget {
  final String productId;

  const ProductEditPage({super.key, required this.productId});

  @override
  ConsumerState<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends ConsumerState<ProductEditPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();

  File? _imageFile;
  Uint8List? _imageBytes;
  String? _selectedCategorieId;
  String? _currentImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProductData();
      ref.read(categorieListNotifier.notifier).getCategories();
    });
  }

  Future<void> _loadProductData() async {
    await ref
        .read(detailProductNotifier(widget.productId).notifier)
        .getProductById(widget.productId);

    final productState = ref.read(detailProductNotifier(widget.productId));

    if (productState.product != null) {
      final product = productState.product!;

      setState(() {
        _nomController.text = product.nom;
        _descriptionController.text = product.description;
        _prixController.text = product.prix.toString();
        _currentImageUrl = product.imageUrl;

        // Gérer la catégorie
        if (product.categorie != null) {
          if (product.categorie is String) {
            _selectedCategorieId = product.categorie;
          } else {
            try {
              _selectedCategorieId = product.categorie.id;
            } catch (e) {
              print("⚠️ Erreur extraction categorie.id: $e");
            }
          }
        }

        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null) {
        setState(() {
          _imageBytes = result.files.single.bytes;
          _imageFile = null;
          _currentImageUrl = null; // Remplace l'ancienne image
        });
      }
    } else {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBytes = null;
          _currentImageUrl = null; // Remplace l'ancienne image
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final productState = ref.read(detailProductNotifier(widget.productId));
    final originalProduct = productState.product!;

    final updatedProduct = ProductEntity(
      id: originalProduct.id,
      nom: _nomController.text.trim(),
      description: _descriptionController.text.trim(),
      prix: double.tryParse(_prixController.text.trim()) ?? 0,
      imageUrl: _currentImageUrl, // Garder l'ancienne si pas de nouvelle
      categorie: _selectedCategorieId,
    );

    await ref.read(updateProductProvider.notifier).updateProduct(
      updatedProduct,
      imageFile: !kIsWeb ? _imageFile : null,
      imageBytes: kIsWeb ? _imageBytes : null,
    );

    final updateState = ref.read(updateProductProvider);

    if (mounted) {
      if (updateState.error == null && updateState.product != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit mis à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        // Rafraîchir la liste des produits
        ref.read(productListNotifier.notifier).getProduits();
        context.go('/products');
      } else if (updateState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${updateState.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(updateProductProvider);
    final categorieState = ref.watch(categorieListNotifier);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Modifier le produit")),
        body: const Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le produit"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submit,
            tooltip: 'Enregistrer',
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width > 800
              ? MediaQuery.of(context).size.width / 2
              : MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Champ nom
                    TextFormField(
                      controller: _nomController,
                      decoration: AppInputStyles.textFieldDecoration(
                        label: "Nom du produit",
                      ),
                      validator: (val) =>
                      val == null || val.isEmpty ? "Nom requis" : null,
                    ),
                    const SizedBox(height: 16),

                    // Champ description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: AppInputStyles.textFieldDecoration(
                        label: "Description",
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Champ prix
                    TextFormField(
                      controller: _prixController,
                      decoration: AppInputStyles.textFieldDecoration(
                        label: "Prix",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Prix requis";
                        final prix = double.tryParse(val);
                        if (prix == null || prix <= 0) return "Prix invalide";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Image picker
                    const Text(
                      "Image du produit",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _imageBytes != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                            : _imageFile != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                            : _currentImageUrl != null
                            ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius:
                              BorderRadius.circular(12),
                              child: Image.network(
                                _currentImageUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius:
                                  BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "Tap pour changer",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                            : Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Choisir une image",
                              style: TextStyle(
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Dropdown des catégories
                    _buildCategoryDropdown(categorieState),
                    const SizedBox(height: 24),

                    // Bouton soumettre
                    updateState.isLoading
                        ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                        : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          "Enregistrer les modifications",
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding:
                          const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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

  Widget _buildCategoryDropdown(CategorieListState categorieState) {
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
            "Aucune catégorie disponible",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return DropdownButtonFormField<String>(
      value: _selectedCategorieId,
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