import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';
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
                                fit: BoxFit.cover,
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
                                "${product.prix.toStringAsFixed(2)} €",
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.orange[100],
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
