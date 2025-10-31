import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';
import 'package:snacky/features/orders/presentation/providers/order_provider.dart';

import '../../../../const/app_colors.dart';

class OrderListPageWithFilters extends ConsumerStatefulWidget {
  const OrderListPageWithFilters({super.key});

  @override
  ConsumerState<OrderListPageWithFilters> createState() =>
      _OrderListPageWithFiltersState();
}

class _OrderListPageWithFiltersState
    extends ConsumerState<OrderListPageWithFilters> {
  String _selectedStatus = 'tous';
  final String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderListNotifier.notifier).getOrders();
    });
  }

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'en cours':
        return Colors.blue.shade100;
      case 'validé':
        return Colors.purple.shade100;
      case 'terminé':
        return Colors.green.shade100;
      case 'annulé':
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
        return Colors.green.shade700;
      case 'annulé':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  /* String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy à HH:mm').format(date);
  } */

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';

    // ✅ Convertir en heure locale avant d’afficher
    final localDate = date.toLocal();

    return DateFormat('dd/MM/yyyy à HH:mm').format(localDate);
  }

  String _formatOrderId(String? id) {
    if (id == null) return 'N/A';
    return id.length > 7 ? id.substring(0, 7) : id;
  }

  List<OrderEntity> _filterOrders(List<OrderEntity> orders) {
    return orders.where((order) {
      // Filtre par statut
      if (_selectedStatus != 'tous' &&
          order.statut.toLowerCase() != _selectedStatus.toLowerCase()) {
        return false;
      }

      // Filtre par recherche (nom ou téléphone)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = order.nomClient.toLowerCase().contains(query);
        final matchesPhone = order.telephone.toLowerCase().contains(query);
        final matchesId = order.id?.toLowerCase().contains(query) ?? false;
        if (!matchesName && !matchesPhone && !matchesId) return false;
      }

      return true;
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtres avancés'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statut',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Tous'),
                  selected: _selectedStatus == 'tous',
                  onSelected: (selected) {
                    setState(() => _selectedStatus = 'tous');
                  },
                ),
                FilterChip(
                  label: const Text('En cours'),
                  selected: _selectedStatus == 'en cours',
                  onSelected: (selected) {
                    setState(() => _selectedStatus = 'en cours');
                  },
                ),
                FilterChip(
                  label: const Text('Validé'),
                  selected: _selectedStatus == 'validé',
                  onSelected: (selected) {
                    setState(() => _selectedStatus = 'validé');
                  },
                ),
                FilterChip(
                  label: const Text('Terminé'),
                  selected: _selectedStatus == 'terminé',
                  onSelected: (selected) {
                    setState(() => _selectedStatus = 'terminé');
                  },
                ),
                SizedBox(height: 10),
                FilterChip(
                  label: const Text('Annulé'),
                  selected: _selectedStatus == 'annulé',
                  onSelected: (selected) {
                    setState(() => _selectedStatus = 'annulé');
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              setState(() {
                _selectedStatus = 'tous';
              });
              Navigator.pop(context);
            },
            child: Text(
              'Réinitialiser',
              style: TextStyle(color: AppColors.textOnColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Appliquer',
              style: TextStyle(color: AppColors.textOnColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderListNotifier);
    final filteredOrders = _filterOrders(orderState.orders);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Text(
              "General",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade600,
              ),
            ),
            Text(" / ", style: TextStyle(color: Colors.grey.shade400)),
            const Text(
              "Commandes",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton(
              onPressed: () {
                context.push('/orders/create');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Créer commande",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête "Orders" avec filtres
            Row(
              children: [
                const Text(
                  "Commandes",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // Boutons de filtre par statut
                _buildStatusButton('Tous', 'tous', filteredOrders.length),
                const SizedBox(width: 8),
                _buildStatusButton(
                  'En cours',
                  'en cours',
                  orderState.orders
                      .where((o) => o.statut.toLowerCase() == 'en cours')
                      .length,
                ),
                const SizedBox(width: 8),
                _buildStatusButton(
                  'Validé',
                  'validé',
                  orderState.orders
                      .where((o) => o.statut.toLowerCase() == 'validé')
                      .length,
                ),
                const SizedBox(width: 8),
                _buildStatusButton(
                  'Terminé',
                  'terminé',
                  orderState.orders
                      .where((o) => o.statut.toLowerCase() == 'terminé')
                      .length,
                ),
                const SizedBox(width: 8),
                _buildStatusButton(
                  'Annulé',
                  'annulé',
                  orderState.orders
                      .where((o) => o.statut.toLowerCase() == 'annulé')
                      .length,
                ),
                const SizedBox(width: 24),
                // Bouton Show avec compteur
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('Show'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${filteredOrders.length}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Table des commandes
            Expanded(
              child: orderState.isLoading
                  ? Center(
                      child: SpinKitThreeBounce(
                        color: AppColors.accentOrange,
                        size: 30.0,
                      ),
                    )
                  : orderState.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Erreur : ${orderState.error!.toString()}"),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(orderListNotifier.notifier).getOrders();
                            },
                            child: const Text("Réessayer"),
                          ),
                        ],
                      ),
                    )
                  : filteredOrders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Aucune commande trouvée",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
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
                        children: [
                          // En-tête du tableau
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                _buildTableHeader('No', flex: 1),
                                _buildTableHeader('Order ID', flex: 2),
                                _buildTableHeader(
                                  'Statut de la commande',
                                  flex: 2,
                                ),
                                _buildTableHeader('Restaurant', flex: 2),
                                _buildTableHeader('Customer', flex: 2),
                                _buildTableHeader('Date de création', flex: 3),
                                _buildTableHeader(
                                  'Date de mise à jour',
                                  flex: 3,
                                ),
                              ],
                            ),
                          ),
                          // Corps du tableau
                          Expanded(
                            child: ListView.separated(
                              itemCount: filteredOrders.length,
                              separatorBuilder: (context, index) => Divider(
                                height: 1,
                                color: Colors.grey.shade200,
                              ),
                              itemBuilder: (context, index) {
                                final order = filteredOrders[index];
                                return InkWell(
                                  onTap: () {
                                    context.push('/orders/detail/${order.id}');
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 20,
                                    ),
                                    child: Row(
                                      children: [
                                        _buildTableCell(
                                          '${index + 1}',
                                          flex: 1,
                                        ),
                                        _buildTableCell(
                                          _formatOrderId(order.id),
                                          flex: 2,
                                          isLink: true,
                                        ),
                                        _buildStatusCell(order.statut, flex: 2),
                                        _buildTableCell(
                                          order.surPlace
                                              ? 'Sur place${order.numeroTable != null ? " (T${order.numeroTable})" : ""}'
                                              : order.livraison
                                              ? 'Livraison'
                                              : 'N/A',
                                          flex: 2,
                                        ),
                                        _buildTableCell(
                                          order.nomClient,
                                          flex: 2,
                                        ),
                                        _buildTableCell(
                                          _formatDate(order.createdAt),
                                          flex: 3,
                                        ),
                                        _buildTableCell(
                                          _formatDate(order.createdAt),
                                          flex: 3,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          // Footer avec pagination
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade200),
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '1 of ${(filteredOrders.length / 10).ceil()}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                Row(
                                  children: [
                                    _buildPaginationButton('1', true),
                                    _buildPaginationButton('2', false),
                                    _buildPaginationButton('3', false),
                                    _buildPaginationButton('4...', false),
                                    _buildPaginationButton('10', false),
                                  ],
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

  Widget _buildStatusButton(String label, String status, int count) {
    final isSelected = _selectedStatus == status;
    return ElevatedButton(
      onPressed: () {
        setState(() => _selectedStatus = status);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.orange : Colors.white,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildTableCell(
    String text, {
    required int flex,
    bool isLink = false,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: isLink ? Colors.blue : Colors.grey.shade800,
          decoration: isLink ? TextDecoration.underline : null,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatusCell(String status, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusTextColor(status),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: _getStatusTextColor(status),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: InkWell(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade700,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
