/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snacky/const/app_colors.dart';
import 'package:snacky/features/products/presentation/providers/product_provider.dart';

class ProductsByCategoryPage extends ConsumerStatefulWidget {
  final String categorieId;
  final String categorieNom;

  const ProductsByCategoryPage({
    super.key,
    required this.categorieId,
    required this.categorieNom,
  });

  @override
  ConsumerState<ProductsByCategoryPage> createState() =>
      _ProductsByCategoryPageState();
}

class _ProductsByCategoryPageState
    extends ConsumerState<ProductsByCategoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(productByCategorieNotifier(widget.categorieId).notifier)
          .getProductsByCategorie(widget.categorieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(
      productByCategorieNotifier(widget.categorieId),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Liste des produits pour la catégorie ${widget.categorieNom}",
        ),
      ),
      body: productState.isLoading
          ? SpinKitThreeBounce(color: Colors.orange, size: 30.0)
          : productState.error != null
          ? Center(child: Text('Erreur : ${productState.error!.toString()}'))
          : productState.products.isEmpty
          ? const Center(child: Text("Aucun produit disponible"))
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // nombre de colonnes
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 2.5, // ratio largeur / hauteur
              ),
              itemCount: productState.products.length,
              itemBuilder: (context, index) {
                final product = productState.products[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // IMAGE EN HAUT
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: product.imageUrl != null
                            ? Image.network(
                                product.imageUrl!,
                                height: 110, // taille fixe pour uniformité
                                width: double.infinity,
                                fit: BoxFit.contain,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child; // ✅ Image chargée
                                      }
                                      // 🌟 Shimmer pendant le chargement
                                      return Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          height: 110,
                                          width: double.infinity,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 80,
                                      width: double.infinity,
                                      color: Colors.grey[300],
                                      child: const Icon(
                                        Icons.fastfood,
                                        size: 40,
                                      ),
                                    ),
                              )
                            : Container(
                                height: 80,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Icon(Icons.fastfood, size: 40),
                              ),
                      ),

                      // NOM + PRIX
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.nom,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Chip(
                              label: Text(
                                "${product.prix.toStringAsFixed(2)} F CFA",
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: AppColors.chipPrice,
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ),

                      // DESCRIPTION
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snacky/const/app_colors.dart';
import 'package:snacky/features/products/presentation/providers/product_provider.dart';

class ProductsByCategoryPage extends ConsumerStatefulWidget {
  final String categorieId;
  final String categorieNom;

  const ProductsByCategoryPage({
    super.key,
    required this.categorieId,
    required this.categorieNom,
  });

  @override
  ConsumerState<ProductsByCategoryPage> createState() =>
      _ProductsByCategoryPageState();
}

class _ProductsByCategoryPageState
    extends ConsumerState<ProductsByCategoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(productByCategorieNotifier(widget.categorieId).notifier)
          .getProductsByCategorie(widget.categorieId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(
      productByCategorieNotifier(widget.categorieId),
    );
    final colorScheme = Theme.of(context).colorScheme;

    // Responsive breakpoints
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 650;
    final bool isTablet = screenWidth >= 650 && screenWidth < 1024;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Liste des produits : ${widget.categorieNom}",
          style: TextStyle(
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: productState.isLoading
          ? Center(
        child: SpinKitThreeBounce(
          color: colorScheme.primary,
          size: 30.0,
        ),
      )
          : productState.error != null
          ? Center(child: Text('Erreur : ${productState.error}'))
          : productState.products.isEmpty
          ? const Center(child: Text("Aucun produit disponible"))

      // ---------------------------------------------
      // MOBILE → LISTE
      // ---------------------------------------------
          : isMobile
          ? _buildMobileList(productState)
          :

      // ---------------------------------------------
      // TABLETTE / WEB → GRILLE
      // ---------------------------------------------
      _buildGrid(productState, isTablet),
    );
  }

  // ---------------------------------------------------------
  // LISTE MOBILE
  // ---------------------------------------------------------
  Widget _buildMobileList(productState) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: productState.products.length,
      itemBuilder: (context, index) {
        final product = productState.products[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 1,
          child: InkWell(
            onTap: () {},
            child: Row(
              children: [
                // IMAGE
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                  child: product.imageUrl != null
                      ? Image.network(
                    product.imageUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;

                      return Shimmer.fromColors(
                        baseColor: colorScheme.primary.withOpacity(0.1),
                        highlightColor: colorScheme.primary.withOpacity(0.05),
                        child: Container(
                          width: 100,
                          height: 100,
                          color: Colors.white,
                        ),
                      );
                    },
                  )
                      : Container(
                    width: 100,
                    height: 100,
                    color: colorScheme.surfaceVariant,
                    child: Icon(Icons.fastfood, size: 40, color: colorScheme.onSurfaceVariant),
                  ),
                ),

                const SizedBox(width: 10),

                // TEXTES
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NOM
                        Text(
                          product.nom,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        // DESCRIPTION
                        Text(
                          product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // PRIX
                        Chip(
                          label: Text(
                            "${product.prix.toStringAsFixed(2)} F CFA",
                            style: TextStyle(fontSize: 12, color: colorScheme.onSecondaryContainer),
                          ),
                          backgroundColor: colorScheme.secondaryContainer,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // GRID WEB / TABLETTE
  // ---------------------------------------------------------
  Widget _buildGrid(productState, bool isTablet) {
    final colorScheme = Theme.of(context).colorScheme;
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isTablet ? 3 : 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: isTablet ? 3 / 3 : 3 / 2.5,
      ),
      itemCount: productState.products.length,
      itemBuilder: (context, index) {
        final product = productState.products[index];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // IMAGE
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: product.imageUrl != null
                    ? Image.network(
                  product.imageUrl!,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return Shimmer.fromColors(
                      baseColor: colorScheme.primary.withOpacity(0.1),
                      highlightColor: colorScheme.primary.withOpacity(0.05),
                      child: Container(
                        height: 110,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    );
                  },
                )
                    : Container(
                  height: 110,
                  width: double.infinity,
                  color: colorScheme.surfaceVariant,
                  child: Icon(Icons.fastfood, size: 40, color: colorScheme.onSurfaceVariant),
                ),
              ),

              // NOM + PRIX
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.nom,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Chip(
                      label: Text(
                        "${product.prix.toStringAsFixed(2)} F CFA",
                        style: TextStyle(fontSize: 12, color: colorScheme.onSecondaryContainer),
                      ),
                      backgroundColor: colorScheme.secondaryContainer,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),

              // DESCRIPTION
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


