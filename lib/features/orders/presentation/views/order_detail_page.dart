
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:snacky/const/app_colors.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';
import 'package:snacky/features/orders/presentation/providers/order_provider.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';

class OrderDetailPageEnhanced extends ConsumerStatefulWidget {
  final String orderId;

  const OrderDetailPageEnhanced({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailPageEnhanced> createState() =>
      _OrderDetailPageEnhancedState();
}

class _OrderDetailPageEnhancedState
    extends ConsumerState<OrderDetailPageEnhanced> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(detailOrderNotifier(widget.orderId).notifier)
          .getOrderById(widget.orderId);
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy à HH:mm').format(date);
  }

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'en cours':
        return Colors.blue.shade100;
      case 'validé':
        return Colors.purple.shade100;
      case 'terminé':
      case 'terminee':
        return Colors.green.shade100;
      case 'annulé':
      case 'annule':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'en cours':
        return Colors.blue.shade700;
      case 'validé':
        return Colors.purple.shade700;
      case 'terminé':
      case 'terminee':
        return Colors.green.shade700;
      case 'annulé':
      case 'annule':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _getStatusLabel(String statut) {
    switch (statut.toLowerCase()) {
      case 'en cours':
        return 'EN COURS';
      case 'validé':
        return 'VALIDÉ';
      case 'terminé':
      case 'terminee':
        return 'TERMINÉ';
      case 'annulé':
      case 'annule':
        return 'ANNULÉ';
      default:
        return statut.toUpperCase();
    }
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette commande ? '
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
      await ref.read(deleteOrderProvider.notifier).deleteOrder(widget.orderId);
      final deleteState = ref.read(deleteOrderProvider);

      if (mounted) {
        if (deleteState.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Commande supprimée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          ref.read(orderListNotifier.notifier).getOrders();
          context.go('/orders');
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

  Future<void> _updateStatus(String orderId, String newStatus) async {
    await ref
        .read(updateOrderStatusProvider.notifier)
        .updateOrderStatus(orderId, newStatus);

    final updateState = ref.read(updateOrderStatusProvider);

    if (mounted) {
      if (updateState.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statut mis à jour: $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
        ref
            .read(detailOrderNotifier(widget.orderId).notifier)
            .getOrderById(widget.orderId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${updateState.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Map<String, dynamic> _extractProductInfo(dynamic produit) {
    String name = 'Produit inconnu';
    double price = 0.0;
    String? imageUrl;

    try {
      if (produit == null) {
        return {'name': name, 'price': price, 'imageUrl': imageUrl};
      }

      if (produit is ProductEntity) {
        name = produit.nom;
        price = produit.prix ?? 0.0;
        imageUrl = produit.imageUrl;
      } else if (produit is Map) {
        name = produit['nom']?.toString() ?? 'Produit inconnu';
        price = (produit['prix'] as num?)?.toDouble() ?? 0.0;
        imageUrl = produit['imageUrl']?.toString();
      } else if (produit is String) {
        name = 'Produit $produit';
      } else {
        try {
          name = (produit as dynamic).nom ?? 'Produit inconnu';
          price = ((produit as dynamic).prix as num?)?.toDouble() ?? 0.0;
          imageUrl = (produit as dynamic).imageUrl;
        } catch (e) {
          print("⚠️ Type produit non géré: ${produit.runtimeType}");
        }
      }
    } catch (e) {
      print("❌ Erreur extraction produit: $e");
    }

    return {'name': name, 'price': price, 'imageUrl': imageUrl};
  }

  Widget _buildProductItem(OrderProductEntity product) {
    final info = _extractProductInfo(product.produit);
    final String productName = info['name'];
    final double productPrice = info['price'];
    final String? imageUrl = info['imageUrl'];
    final double sousTotal = productPrice * product.quantite;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: [
          // Image du produit
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderImage();
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            )
                : _buildPlaceholderImage(),
          ),
          const SizedBox(width: 16),

          // Informations du produit
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Prix unitaire: ${productPrice.toStringAsFixed(2)} FCFA',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.shopping_cart,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Quantité: ${product.quantite}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Quantité et prix
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'x${product.quantite}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${sousTotal.toStringAsFixed(2)} FCFA',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.fastfood,
        size: 30,
        color: Colors.orange.shade400,
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, double amount,
      {bool isBold = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 18 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black : Colors.grey.shade700,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} FCFA',
            style: TextStyle(
              fontSize: isBold ? 20 : 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isTotal ? Colors.black : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(detailOrderNotifier(widget.orderId));
    final updateStatusState = ref.watch(updateOrderStatusProvider);

    if (orderState.isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Commande ...',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    if (orderState.error != null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Commande ....',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erreur: ${orderState.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(detailOrderNotifier(widget.orderId).notifier)
                      .getOrderById(widget.orderId);
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    final order = orderState.order;
    if (order == null) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Commande ...',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        body: const Center(child: Text('Commande introuvable')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Commande #${order.id?.substring(0, 8) ?? 'N/A'}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.darkBlue),
            onPressed: () {
              context.push('/orders/edit/${order.id}');
            },
            tooltip: 'Modifier',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.primaryRed),
            onPressed: _showDeleteConfirmation,
            tooltip: 'Supprimer',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: updateStatusState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : 
         Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colonne de gauche : Produits et total
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Card Produits commandés
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
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
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                'Produits commandés',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                  
                            // Liste des produits
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: order.produits.length,
                              separatorBuilder: (context, index) =>
                                  Divider(
                                    height: 1,
                                    color: Colors.grey.shade200,
                                  ),
                              itemBuilder: (context, index) {
                                return _buildProductItem(
                                    order.produits[index]);
                              },
                            ),
                  
                            const Divider(height: 1),
                  
                            // Section récapitulatif
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  const Divider(height: 24),
                                  _buildPriceRow(
                                    'Coût Total',
                                    order.coutTotal,
                                    isBold: true,
                                    isTotal: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                  
                      // Boutons d'action
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Imprimer la facture
                              },
                              icon: const Icon(Icons.print),
                              label: const Text('Imprimer'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Envoyer par email
                              },
                              icon: const Icon(Icons.email_outlined),
                              label: const Text('Envoyer'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
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
              const SizedBox(width: 24),
              // Colonne de droite : Informations client et statut
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Card Statut
                      _buildInfoCard(
                        title: 'Statut',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.statut),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _getStatusLabel(order.statut),
                                style: TextStyle(
                                  color: _getStatusTextColor(order.statut),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (order.statut.toLowerCase() == 'en cours')
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _updateStatus(order.id!, 'validé'),
                                  icon: const Icon(Icons.check_circle),
                                  label:
                                  const Text('Valider la commande'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            if (order.statut.toLowerCase() == 'validé')
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      _updateStatus(order.id!, 'terminé'),
                                  icon: const Icon(Icons.done_all),
                                  label: const Text(
                                      'Marquer comme terminée'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                  
                      // Card Informations Client
                      _buildInfoCard(
                        title: 'Informations Client',
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.person_outline,
                              label: 'Nom du client',
                              value: order.nomClient,
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              icon: Icons.phone_outlined,
                              label: 'Téléphone',
                              value: order.telephone,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                  
                      // Card Type de commande
                      _buildInfoCard(
                        title: 'Type de commande',
                        child: Column(
                          children: [
                            if (order.surPlace)
                              _buildInfoRow(
                                icon: Icons.restaurant,
                                label: 'Sur place',
                                value: order.numeroTable != null
                                    ? 'Table ${order.numeroTable}'
                                    : 'Oui',
                              ),
                            if (order.surPlace && order.livraison)
                              const Divider(height: 24),
                            if (order.livraison)
                              _buildInfoRow(
                                icon: Icons.delivery_dining,
                                label: 'Livraison',
                                value: 'Oui',
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                  
                      // Card Informations temporelles
                      _buildInfoCard(
                        title: 'Informations temporelles',
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Créée le',
                              value: _formatDate(order.createdAt),
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              icon: Icons.update_outlined,
                              label: 'Dernière mise à jour',
                              value: _formatDate(order.updatedAt),
                            ),
                          ],
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

