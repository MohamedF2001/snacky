/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snacky/const/app_colors.dart';
import 'package:snacky/const/app_style.dart';
import 'package:snacky/features/products/presentation/providers/product_provider.dart';
import 'package:snacky/main.dart'; // 👈 Importez main.dart pour accéder à la variable demo

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
    // 🎯 Vérifier si on est en mode démo
    if (demo) {
      _showDemoDialog();
      return;
    }

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

  /// Affiche une popup indiquant que l'on est en mode démo
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
            "Veuillez désactiver le mode démo pour modifier ou supprimer un produit.",
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
                  icon: const Icon(Icons.edit, color: AppColors.darkBlue),
                  onPressed: demo
                      ? _showDemoDialog
                      : () {
                          context.push('/products/edit/${widget.produitId}');
                        },
                  tooltip: 'Modifier',
                ),
                // Bouton Supprimer dans l'AppBar
                IconButton(
                  icon: deleteState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.orange,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.delete, color: Colors.red),
                  onPressed: deleteState.isLoading
                      ? null
                      : _showDeleteConfirmation,
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ),
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
          ? const Center(
              child: SpinKitThreeBounce(
                color: AppColors.accentOrange,
                size: 30.0,
              ),
            )
          : productState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.primaryRed,
                  ),
                  const SizedBox(height: 16),
                  Text("Erreur : ${productState.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(
                            detailProductNotifier(widget.produitId).notifier,
                          )
                          .getProductById(widget.produitId);
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                // Responsive: deux colonnes pour les écrans larges
                final isWideScreen = constraints.maxWidth > 900;

                if (isWideScreen) {
                  return _buildTwoColumnLayout(productState);
                } else {
                  return _buildSingleColumnLayout(productState);
                }
              },
            ),
    );
  }

  // Layout à deux colonnes avec scroll indépendant
  Widget _buildTwoColumnLayout(productState) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colonne gauche - Image du produit
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: _buildProductImageCard(productState),
            ),
          ),
          const SizedBox(width: 24),
          // Colonne droite - Informations et actions
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              child: _buildProductInfoCard(productState),
            ),
          ),
        ],
      ),
    );
  }

  // Layout à une colonne pour les petits écrans
  Widget _buildSingleColumnLayout(productState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              _buildProductImageCard(productState),
              const SizedBox(height: 24),
              _buildProductInfoCard(productState),
            ],
          ),
        ),
      ),
    );
  }

  // Card de l'image du produit
  Widget _buildProductImageCard(productState) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: productState.product?.imageUrl != null
            ? Image.network(
                productState.product!.imageUrl!,
                height: 500,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 500,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 500,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fastfood, size: 80, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'Image non disponible',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            : Container(
                height: 500,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fastfood, size: 80, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('Aucune image', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
      ),
    );
  }

  // Card des informations du produit
  Widget _buildProductInfoCard(productState) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec icône
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fastfood,
                    size: 28,
                    color: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Informations produit",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        productState.product?.nom ?? '',
                        style: TextStyle(
                          fontSize: AppStyle.titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32),

            // Section Description
            _buildInfoSection(
              icon: Icons.description,
              iconColor: Colors.blue,
              title: "Description",
              content:
                  productState.product?.description ?? 'Aucune description',
            ),
            const SizedBox(height: 24),

            // Section Prix
            _buildPriceSection(productState.product?.prix ?? 0),
            const SizedBox(height: 32),

            // Boutons d'action
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: iconColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: AppStyle.descriptionFontSize,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(double prix) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.attach_money,
              color: Colors.green,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Prix du produit",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${prix.toStringAsFixed(2)} F CFA",
                style: TextStyle(
                  fontSize: AppStyle.priceFontSize + 4,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        const Divider(height: 32),
        Row(
          children: [
            // Bouton Retour
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/products'),
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                label: const Text(
                  "Retour",
                  style: TextStyle(color: Colors.black),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Bouton Modifier
            Expanded(
              child: ElevatedButton.icon(
                onPressed: demo
                    ? _showDemoDialog
                    : () {
                        context.push('/products/edit/${widget.produitId}');
                      },
                icon: const Icon(Icons.edit),
                label: const Text("Modifier"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Bouton Supprimer (pleine largeur)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showDeleteConfirmation,
            icon: const Icon(Icons.delete, color: AppColors.primaryRed),
            label: const Text(
              "Supprimer ce produit",
              style: TextStyle(color: AppColors.primaryRed),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryRed),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snacky/const/app_colors.dart';
import 'package:snacky/const/app_style.dart';
import 'package:snacky/features/products/presentation/providers/product_provider.dart';
import 'package:snacky/main.dart';

import '../../../../core/providers/demo_provider.dart';

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
    /*if (demo) {
      _showDemoDialog();
      return;
    }*/
    if (ref.read(demoProvider)) { _showDemoDialog(); return; }

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
          'Voulez-vous supprimer "${widget.productNom}" ?',
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
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
              const SizedBox(width: 8),
              const Text("Oup's"),
            ],
          ),
          content: const Text(
            "Vous ne pouvez pas effectuer cette action vu que vous n'etes pas propriétaire",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Fermer"),
            ),
          ],
        ),
      );
      //await ref
      //    .read(deleteProductProvider.notifier)
      //    .deleteProduct(widget.produitId);

      //final deleteState = ref.read(deleteProductProvider);

      // if (mounted) {
      //   if (deleteState.success) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(
      //         content: Text('Produit supprimé avec succès'),
      //         backgroundColor: Colors.green,
      //       ),
      //     );
      //     ref.read(productListNotifier.notifier).getProduits();
      //     context.go('/products');
      //   } else if (deleteState.error != null) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text('Erreur: ${deleteState.error}'),
      //         backgroundColor: Colors.red,
      //       ),
      //     );
      //   }
      // }
    }
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
              Icon(Icons.info, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 12),
              const Text(
                "Mode Démo",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            "Cette fonctionnalité n'est pas disponible en mode démo.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(detailProductNotifier(widget.produitId));
    final deleteState = ref.watch(deleteProductProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Détails"),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: colorScheme.primary),
            onPressed: ref.watch(demoProvider)
                ? _showDemoDialog
                : () => context.push('/products/edit/${widget.produitId}'),
          ),
          IconButton(
            icon: deleteState.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.delete, color: colorScheme.error),
            onPressed: deleteState.isLoading ? null : _showDeleteConfirmation,
          ),
        ],
      ),
      body: deleteState.isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : productState.isLoading
              ? Center(
                  child: SpinKitThreeBounce(
                    color: colorScheme.primary,
                    size: 30.0,
                  ),
                )
              : productState.error != null
                  ? Center(child: Text("Erreur : ${productState.error}"))
                  : _buildMobileLayout(productState),
    );
  }

  // ---------------------------------------------------------------------------
  // ------------------------- MOBILE VERSION UNIQUEMENT ------------------------
  // ---------------------------------------------------------------------------

  Widget _buildMobileLayout(productState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImageMobile(productState),
          const SizedBox(height: 16),
          _buildProductInfoMobile(productState),
          const SizedBox(height: 24),
          _buildMobileButtons(),
        ],
      ),
    );
  }

  // ----------------------------- IMAGE MOBILE --------------------------------

  Widget _buildProductImageMobile(productState) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: productState.product?.imageUrl != null
          ? Image.network(
        productState.product!.imageUrl!,
        height: 250,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 250,
              width: double.infinity,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (_, __, ___) => _fallbackImage(),
      )
          : _fallbackImage(),
    );
  }

  Widget _fallbackImage() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.fastfood, size: 60, color: Colors.grey),
      ),
    );
  }

  // -------------------------- INFOS MOBILE -----------------------------------

  Widget _buildProductInfoMobile(productState) {
    final product = productState.product;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.nom,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            // Description
            _buildInfoTile(
              icon: Icons.description,
              title: "Description",
              content: product.description,
            ),
            const SizedBox(height: 14),

            // Prix
            _buildPriceMobile(product.prix),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String content,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorScheme.surfaceVariant.withOpacity(0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceMobile(double prix) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_money, size: 24, color: Colors.green),
          const SizedBox(width: 12),
          Text(
            "${prix.toStringAsFixed(2)} F CFA",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------ ACTION BUTTONS MOBILE ----------------------------

  Widget _buildMobileButtons() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            label: Text("Retour", style: TextStyle(color: colorScheme.onSurface)),
            onPressed: () => context.go('/products'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text("Modifier"),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            onPressed: ref.watch(demoProvider)
                ? _showDemoDialog
                : () => context.push('/products/edit/${widget.produitId}'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: Icon(Icons.delete, color: colorScheme.error),
            label: Text(
              "Supprimer",
              style: TextStyle(color: colorScheme.error),
            ),
            onPressed: _showDeleteConfirmation,
          ),
        ),
      ],
    );
  }
}


