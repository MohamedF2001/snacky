import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:snacky/features/promotions/domain/entities/promotion_entity.dart';
import 'package:snacky/features/promotions/presentation/providers/promotion_provider.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';

import '../../../../const/app_input_style.dart';
import '../../../../core/providers/demo_provider.dart';
import '../../../products/presentation/providers/product_provider.dart';
import 'package:snacky/main.dart'; // 👈 Import pour accéder à la variable demo

class CreatePromotionPage extends ConsumerStatefulWidget {
  const CreatePromotionPage({super.key});

  @override
  ConsumerState<CreatePromotionPage> createState() =>
      _CreatePromotionPageState();
}

class _CreatePromotionPageState extends ConsumerState<CreatePromotionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _tarifController = TextEditingController();
  final _searchController = TextEditingController();
  DateTime? _dateDebut;
  DateTime? _dateFin;
  List<ProductEntity> _selectedProducts = [];
  String _searchQuery = '';

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListNotifier.notifier).getProduits();
    });
  }

  @override
  void dispose() {
    _nomController.dispose();
    _tarifController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String formatDate(DateTime? date) {
    if (date == null) return "";
    return DateFormat('dd/MM/yyyy - HH:mm').format(date);
  }

  List<ProductEntity> _getFilteredProducts(List<ProductEntity> products) {
    if (_searchQuery.isEmpty) return products;
    return products.where((product) {
      return product.nom.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  /// Méthode appelée par le bouton : respecte le mode demo
  Future<void> _submit() async {
    /*if (demo) {
      _showDemoDialog();
      return;
    }*/
    if (ref.read(demoProvider)) { _showDemoDialog(); return; }
    await _createPromotion();
  }

  /// Contient la logique originale de création
  Future<void> _createPromotion() async {
    if (!_formKey.currentState!.validate() || _selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez remplir tous les champs et sélectionner au moins un produit",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final promo = PromotionEntity(
      nom: _nomController.text,
      tarif: double.tryParse(_tarifController.text) ?? 0.0,
      produits: _selectedProducts,
      dateDebut: _dateDebut!,
      dateFin: _dateFin!,
    );

    // Utilise le provider comme avant
    final createPromotionUsecase = ref.read(createPromotionProvider);

    final result = await createPromotionUsecase.execute(promo);

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : ${failure.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        setState(() => isSubmitting = false);
      },
      (success) {
        ref.read(promotionListNotifier.notifier).getPromotions();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Promotion créée avec succès !"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        context.pop();
      },
    );
  }

  /// Popup mode demo
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
            "Veuillez désactiver le mode démo pour créer une promotion.",
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

  @override
  Widget build(BuildContext context) {
    final createPromotionUsecase = ref.watch(createPromotionProvider);
    final productState = ref.watch(productListNotifier);

    if (productState.isLoading && productState.products.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    final filteredProducts = _getFilteredProducts(productState.products);

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
              "Promotions",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
            Text(" / ", style: TextStyle(color: Colors.grey.shade400)),
            const Text(
              "Créer une promotion",
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
            // 📝 COLONNE gauche - Formulaire
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
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.local_offer,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Informations de la promotion",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Nom de la promotion
                      const Text(
                        "Nom de la promotion",
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
                          label: "Ex: Menu Spécial du Vendredi",
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Nom requis" : null,
                      ),
                      const SizedBox(height: 20),
                      // Tarif
                      const Text(
                        "Tarif promotionnel",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _tarifController,
                        keyboardType: TextInputType.number,
                        decoration: AppInputStyles.textFieldDecoration(
                          icon: Icons.percent,
                          label: "Pourcentage",
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Tarif requis" : null,
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),
                      // Dates
                      const Text(
                        "Période de validité",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Date de début
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Date de début",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(2023),
                                      lastDate: DateTime(2030),
                                      initialDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (time != null) {
                                        setState(() {
                                          _dateDebut = DateTime(
                                            picked.year,
                                            picked.month,
                                            picked.day,
                                            time.hour,
                                            time.minute,
                                          );
                                        });
                                      }
                                    }
                                  },
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      decoration:
                                          AppInputStyles.textFieldDecoration(
                                            label: "Sélectionner",
                                          ).copyWith(
                                            prefixIcon: const Icon(
                                              Icons.calendar_today,
                                            ),
                                          ),
                                      controller: TextEditingController(
                                        text: formatDate(_dateDebut),
                                      ),
                                      validator: (_) => _dateDebut == null
                                          ? "Date début requise"
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Date de fin
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Date de fin",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      firstDate: DateTime(2023),
                                      lastDate: DateTime(2030),
                                      initialDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      final time = await showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      );
                                      if (time != null) {
                                        setState(() {
                                          _dateFin = DateTime(
                                            picked.year,
                                            picked.month,
                                            picked.day,
                                            time.hour,
                                            time.minute,
                                          );
                                        });
                                      }
                                    }
                                  },
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      decoration:
                                          AppInputStyles.textFieldDecoration(
                                            label: "Sélectionner",
                                          ).copyWith(
                                            prefixIcon: const Icon(
                                              Icons.calendar_today,
                                            ),
                                          ),
                                      controller: TextEditingController(
                                        text: formatDate(_dateFin),
                                      ),
                                      validator: (_) => _dateFin == null
                                          ? "Date fin requise"
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Résumé de la sélection
                      if (_selectedProducts.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.orange.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Produits sélectionnés (${_selectedProducts.length})",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _selectedProducts.map((product) {
                                  return Chip(
                                    label: Text(product.nom),
                                    backgroundColor: Colors.white,
                                    deleteIcon: const Icon(
                                      Icons.close,
                                      size: 16,
                                    ),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedProducts.remove(product);
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      // Bouton de création
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : _submit, // <-- utilise _submit qui respecte le mode demo
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
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
                                      "Créer la promotion",
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
            // 📦 COLONNE droite - Liste des produits
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
                    // En-tête de la section produits
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
                                  Icons.shopping_bag_outlined,
                                  color: Colors.orange.shade700,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Sélectionner les produits",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "${_selectedProducts.length} produit(s) sélectionné(s)",
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
                              hintText: "Rechercher un produit...",
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey.shade400,
                              ),
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
                    // Liste des produits
                    Expanded(
                      child: filteredProducts.isEmpty
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
                                    "Aucun produit trouvé",
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
                              itemCount: filteredProducts.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                final isSelected = _selectedProducts.contains(
                                  product,
                                );

                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedProducts.remove(product);
                                      } else {
                                        _selectedProducts.add(product);
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
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
                                        // Image du produit
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: product.imageUrl != null
                                                ? Image.network(
                                                    product.imageUrl!,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Icon(
                                                          Icons.fastfood,
                                                          color: Colors
                                                              .grey
                                                              .shade400,
                                                          size: 30,
                                                        ),
                                                  )
                                                : Icon(
                                                    Icons.fastfood,
                                                    color: Colors.grey.shade400,
                                                    size: 30,
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Informations du produit
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.nom,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w600,
                                                  color: isSelected
                                                      ? Colors.orange.shade900
                                                      : Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                product.description,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Prix
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.orange
                                                : Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            "${product.prix.toStringAsFixed(0)} F",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.grey.shade700,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Checkbox
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.orange
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.orange
                                                  : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: isSelected
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 16,
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
