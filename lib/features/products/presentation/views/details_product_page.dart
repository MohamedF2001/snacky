import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snacky/const/app_colors.dart';
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
                  icon: const Icon(Icons.edit, color: AppColors.darkBlue),
                  onPressed: () {
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
                  onPressed: deleteState.isLoading ? null : _showDeleteConfirmation,
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
          ? const Center(
        child: SpinKitThreeBounce(
            color: AppColors.accentOrange, size: 30.0),
      )
          : productState.error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: AppColors.primaryRed),
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
                Icon(
                  Icons.fastfood,
                  size: 80,
                  color: Colors.grey,
                ),
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
              Text(
                'Aucune image',
                style: TextStyle(color: Colors.grey),
              ),
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
              content: productState.product?.description ?? 'Aucune description',
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
                onPressed: () {
                  context.push('/products/edit/${widget.produitId}');
                },
                icon: const Icon(Icons.edit),
                label: const Text("Modifier"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: Colors.white,
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