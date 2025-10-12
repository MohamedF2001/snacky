/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snacky/const/app_style.dart';
import 'package:snacky/features/products/presentation/providers/product_provider.dart';

class DetailsProductPage extends ConsumerStatefulWidget {
  final String produitId;
  final String productNom;

  const DetailsProductPage({super.key, required this.produitId,
  required this.productNom});

  @override
  ConsumerState<DetailsProductPage> createState() => _DetailsProductPageState();
}

class _DetailsProductPageState extends ConsumerState<DetailsProductPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(detailProductNotifier(widget.produitId).notifier)
          .getProductByIdUsecase
          .execute(widget.produitId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(detailProductNotifier(widget.produitId));
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Détails de ${widget.productNom ?? ''}"),
      ),
      body: productState.isLoading
          ? SpinKitThreeBounce(color: Colors.orange, size: 30.0)
          : productState.error != null
          ? Center(child: Text("Erreur : ${productState.error}"))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(16),
                            ),
                            child: productState.product?.imageUrl != null
                                ? Image.network(
                                    productState.product!.imageUrl!,
                                    height: 400, // taille fixe pour uniformité
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child; // image déjà chargée
                                          }
                                          // sinon, afficher le shimmer
                                          return Shimmer.fromColors(
                                            baseColor: Colors.grey[300]!,
                                            highlightColor: Colors.grey[100]!,
                                            child: Container(
                                              height: 400,
                                              width: double.infinity,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              height: 280,
                                              width: double.infinity,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.fastfood,
                                                size: 40,
                                              ),
                                            ),
                                  )
                                : Container(
                                    height: 280,
                                    width: double.infinity,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.fastfood, size: 40),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: SizedBox(
                              height: 400,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    productState.product?.nom ?? '',
                                    style: TextStyle(
                                      fontSize: AppStyle.titleFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(flex: 2),
                                  Text(
                                    productState.product?.description ?? '',
                                    style: TextStyle(
                                      fontSize: AppStyle.descriptionFontSize,
                                    ),
                                  ),
                                  const Spacer(),
                                  Chip(
                                    labelPadding: AppStyle.chipPadding,
                                    label: Text(
                                      "${productState.product?.prix.toStringAsFixed(2)} €",
                                      style: TextStyle(
                                        fontSize: AppStyle.priceFontSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    backgroundColor: Colors.orange[100],
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  Spacer(),
                                  Container(
                                    width: 200, // Largeur fixe pour le bouton
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Text(
                                        "Ajouter au panier",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Spacer(flex: 1),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snacky/const/app_style.dart';
import 'package:snacky/features/products/presentation/providers/product_provider.dart';

class DetailsProductPage extends ConsumerStatefulWidget {
  final String produitId;
  final String productNom;

  const DetailsProductPage({
    super.key,
    required this.produitId,
    required this.productNom,
  });

  @override
  ConsumerState<DetailsProductPage> createState() => _DetailsProductPageState();
}

class _DetailsProductPageState extends ConsumerState<DetailsProductPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(detailProductNotifier(widget.produitId).notifier)
          .getProductById(widget.produitId);
    });
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirmer la suppression'),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${widget.productNom}" ?\n'
              'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Appeler le provider de suppression
      await ref
          .read(deleteProductProvider.notifier)
          .deleteProduct(widget.produitId);

      final deleteState = ref.read(deleteProductProvider);

      if (mounted) {
        if (deleteState.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produit supprimé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          // Rafraîchir la liste des produits
          ref.read(productListNotifier.notifier).getProduits();
          // Redirection vers la liste des produits
          context.go('/products');
        } else if (deleteState.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${deleteState.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(detailProductNotifier(widget.produitId));
    final deleteState = ref.watch(deleteProductProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Détails de ${widget.productNom}"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                // Bouton Modifier dans l'AppBar
                IconButton(
                  icon: const Icon(Icons.edit,color: Colors.blue,),
                  onPressed: () {
                    context.push('/products/edit/${widget.produitId}');
                  },
                  tooltip: 'Modifier',
                ),
                // Bouton Supprimer dans l'AppBar
                IconButton(
                  icon: const Icon(Icons.delete,color: Colors.red ,),
                  onPressed: _showDeleteConfirmation,
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          )
        ],
      ),
      body: deleteState.isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text('Suppression en cours...'),
          ],
        ),
      )
          : productState.isLoading
          ? const SpinKitThreeBounce(color: Colors.orange, size: 30.0)
          : productState.error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text("Erreur : ${productState.error}"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(detailProductNotifier(widget.produitId)
                    .notifier)
                    .getProductById(widget.produitId);
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Row(
                children: [
                  // Image du produit
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(16),
                      ),
                      child:
                      productState.product?.imageUrl != null
                          ? Image.network(
                        productState.product!.imageUrl!,
                        height: 400,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child,
                            loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Shimmer.fromColors(
                            baseColor:
                            Colors.grey[300]!,
                            highlightColor:
                            Colors.grey[100]!,
                            child: Container(
                              height: 400,
                              width: double.infinity,
                              color: Colors.white,
                            ),
                          );
                        },
                        errorBuilder: (context, error,
                            stackTrace) =>
                            Container(
                              height: 280,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.fastfood,
                                size: 40,
                              ),
                            ),
                      )
                          : Container(
                        height: 280,
                        width: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                            Icons.fastfood,
                            size: 40),
                      ),
                    ),
                  ),

                  // Informations du produit
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        height: 400,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            // Nom
                            Text(
                              productState.product?.nom ?? '',
                              style: TextStyle(
                                fontSize: AppStyle.titleFontSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(flex: 2),

                            // Description
                            Text(
                              productState.product?.description ??
                                  '',
                              style: TextStyle(
                                fontSize: AppStyle
                                    .descriptionFontSize,
                              ),
                            ),
                            const Spacer(),

                            // Prix
                            Chip(
                              labelPadding: AppStyle.chipPadding,
                              label: Text(
                                "${productState.product?.prix.toStringAsFixed(2)} €",
                                style: TextStyle(
                                  fontSize:
                                  AppStyle.priceFontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: Colors.orange[100],
                              visualDensity:
                              VisualDensity.compact,
                              materialTapTargetSize:
                              MaterialTapTargetSize
                                  .shrinkWrap,
                            ),
                            const Spacer(),

                            // Boutons d'action (Modifier et Supprimer)
                            Row(
                              children: [
                                // Bouton Modifier
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      context.push(
                                          '/products/edit/${widget.produitId}');
                                    },
                                    icon:
                                    const Icon(Icons.edit),
                                    label:
                                    const Text("Modifier"),
                                    style:
                                    ElevatedButton.styleFrom(
                                      backgroundColor:
                                      const Color(0xFF1E3A8A),
                                      foregroundColor:
                                      Colors.white,
                                      padding: const EdgeInsets
                                          .symmetric(
                                          vertical: 12),
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Bouton Supprimer
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed:
                                    _showDeleteConfirmation,
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    label: const Text(
                                      "Supprimer",
                                      style: TextStyle(
                                          color: Colors.red),
                                    ),
                                    style:
                                    OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Colors.red),
                                      padding: const EdgeInsets
                                          .symmetric(
                                          vertical: 12),
                                      shape:
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(
                                            8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(flex: 1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}