import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
        return Colors.orange;
      case 'validé':
        return Colors.blue;
      case 'terminé':
      case 'terminee':
        return Colors.green;
      case 'annulé':
      case 'annule':
        return Colors.red;
      default:
        return Colors.grey;
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

  // 🔥 MÉTHODE HELPER POUR EXTRAIRE LES INFOS PRODUIT
  Map<String, dynamic> _extractProductInfo(dynamic produit) {
    String name = 'Produit inconnu';
    double price = 0.0;
    String? imageUrl;

    try {
      if (produit == null) {
        return {'name': name, 'price': price, 'imageUrl': imageUrl};
      }

      // Si c'est une ProductEntity
      if (produit is ProductEntity) {
        name = produit.nom;
        price = produit.prix ?? 0.0;
        imageUrl = produit.imageUrl;
      }
      // Si c'est un Map (objet JSON)
      else if (produit is Map) {
        name = produit['nom']?.toString() ?? 'Produit inconnu';
        price = (produit['prix'] as num?)?.toDouble() ?? 0.0;
        imageUrl = produit['imageUrl']?.toString();
      }
      // Si c'est juste un String (ID)
      else if (produit is String) {
        name = 'Produit $produit';
      }
      // Autre cas (essayer d'accéder dynamiquement)
      else {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Image du produit
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 70,
                    height: 70,
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.attach_money,
                          size: 16, color: Colors.grey[600]),
                      Text(
                        'Prix unitaire: ${productPrice.toStringAsFixed(2)} FCFA',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.shopping_cart,
                          size: 16, color: Colors.grey[600]),
                      Text(
                        'Quantité: ${product.quantite}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Prix total
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${product.quantite}x',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${sousTotal.toStringAsFixed(2)} FCFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.fastfood,
        size: 35,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildStatusChip(String statut) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getStatusColor(statut),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statut.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
        appBar: AppBar(title: const Text('Détails de la commande')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (orderState.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détails de la commande')),
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
        appBar: AppBar(title: const Text('Détails de la commande')),
        body: const Center(child: Text('Commande introuvable')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Commande #${order.id?.substring(0, 8) ?? 'N/A'}'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit,color: Colors.blue,),
                  onPressed: () {
                    context.push('/orders/edit/${order.id}');
                  },
                  tooltip: 'Modifier',
                ),
                IconButton(
                  icon: const Icon(Icons.delete,color: Colors.red,),
                  onPressed: _showDeleteConfirmation,
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          )
        ],
      ),
      body: updateStatusState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Statut
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Statut',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        _buildStatusChip(order.statut),
                      ],
                    ),
                    if (order.statut != 'terminé' &&
                        order.statut != 'annulé')
                      const SizedBox(height: 16),
                    if (order.statut == 'en cours')
                      ElevatedButton.icon(
                        onPressed: () =>
                            _updateStatus(order.id!, 'validé'),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Valider la commande'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    if (order.statut == 'validé')
                      ElevatedButton.icon(
                        onPressed: () =>
                            _updateStatus(order.id!, 'terminé'),
                        icon: const Icon(Icons.done_all),
                        label: const Text('Marquer comme terminée'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Informations client
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations Client',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.person,
                      'Nom du client',
                      order.nomClient,
                    ),
                    _buildInfoRow(
                      Icons.phone,
                      'Téléphone',
                      order.telephone,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Type de commande
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Type de commande',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    if (order.surPlace)
                      _buildInfoRow(
                        Icons.restaurant,
                        'Sur place',
                        order.numeroTable != null
                            ? 'Table ${order.numeroTable}'
                            : 'Oui',
                      ),
                    if (order.livraison)
                      _buildInfoRow(
                        Icons.delivery_dining,
                        'Livraison',
                        'Oui',
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Liste des produits
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Produits commandés',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    ...order.produits.map(_buildProductItem),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Résumé financier
            Card(
              elevation: 4,
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Coût Total',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${order.coutTotal.toStringAsFixed(2)} FCFA',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dates
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations temporelles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Créée le',
                      _formatDate(order.createdAt),
                    ),
                    _buildInfoRow(
                      Icons.update,
                      'Dernière mise à jour',
                      _formatDate(order.updatedAt),
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
