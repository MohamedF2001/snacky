import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snacky/features/products/presentation/providers/product_provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../../const/app_colors.dart';

class AllProductsPage extends ConsumerStatefulWidget {
  const AllProductsPage({super.key});

  @override
  ConsumerState<AllProductsPage> createState() => _AllProductsPageState();
}

class _AllProductsPageState extends ConsumerState<AllProductsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListNotifier.notifier).getProduits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(productListNotifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tous les Produits",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: productState.isLoading
          ? SpinKitThreeBounce(color: AppColors.accentOrange, size: 30.0)
          : productState.error != null
          ? Center(child: Text("Erreur : ${productState.error!.toString()}"))
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

                return InkWell(
                  onTap: () {
                    // Redirection vers la page de détail du produit
                    context.push('/products/${product.id}', extra: product.nom);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0.2,
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
                                          baseColor: Colors.orange,
                                          highlightColor: Colors.orange,
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
                                  style: const TextStyle(fontSize: 12,
                                  color: Colors.black),
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
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentOrange,
        foregroundColor: Colors.black,
        onPressed: () {
          context.push('/products/create');
        },
        icon: const Icon(Icons.add),
        label: const Text("Nouveau produit"),
      ),
    );
  }
}
