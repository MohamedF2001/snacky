// features/orders/presentation/pages/order_list_page_with_filters.dart
/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';
import 'package:snacky/features/orders/presentation/providers/order_provider.dart';
import 'package:snacky/features/orders/presentation/widgets/info_client.dart';

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
  String _selectedType = 'tous';
  String _searchQuery = '';
  DateTimeRange? _dateRange;

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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  List<OrderEntity> _filterOrders(List<OrderEntity> orders) {
    return orders.where((order) {
      // Filtre par statut
      if (_selectedStatus != 'tous' &&
          order.statut.toLowerCase() != _selectedStatus.toLowerCase()) {
        return false;
      }

      // Filtre par type
      if (_selectedType == 'surplace' && !order.surPlace) return false;
      if (_selectedType == 'livraison' && !order.livraison) return false;

      // Filtre par recherche (nom ou téléphone)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = order.nomClient.toLowerCase().contains(query);
        final matchesPhone = order.telephone.toLowerCase().contains(query);
        if (!matchesName && !matchesPhone) return false;
      }

      // Filtre par date
      if (_dateRange != null && order.createdAt != null) {
        final orderDate = order.createdAt!;
        if (orderDate.isBefore(_dateRange!.start) ||
            orderDate.isAfter(_dateRange!.end.add(const Duration(days: 1)))) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.orange,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filtrer les commandes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Filtre par statut
              const Text(
                'Statut',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Tous'),
                    selected: _selectedStatus == 'tous',
                    onSelected: (selected) {
                      setModalState(() => _selectedStatus = 'tous');
                      setState(() => _selectedStatus = 'tous');
                    },
                  ),
                  FilterChip(
                    label: const Text('En cours'),
                    selected: _selectedStatus == 'en cours',
                    onSelected: (selected) {
                      setModalState(() => _selectedStatus = 'en cours');
                      setState(() => _selectedStatus = 'en cours');
                    },
                  ),
                  FilterChip(
                    label: const Text('Validé'),
                    selected: _selectedStatus == 'validé',
                    onSelected: (selected) {
                      setModalState(() => _selectedStatus = 'validé');
                      setState(() => _selectedStatus = 'validé');
                    },
                  ),
                  FilterChip(
                    label: const Text('Terminé'),
                    selected: _selectedStatus == 'terminé',
                    onSelected: (selected) {
                      setModalState(() => _selectedStatus = 'terminé');
                      setState(() => _selectedStatus = 'terminé');
                    },
                  ),
                  FilterChip(
                    label: const Text('Annulé'),
                    selected: _selectedStatus == 'annulé',
                    onSelected: (selected) {
                      setModalState(() => _selectedStatus = 'annulé');
                      setState(() => _selectedStatus = 'annulé');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filtre par type
              const Text(
                'Type de commande',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Tous'),
                    selected: _selectedType == 'tous',
                    onSelected: (selected) {
                      setModalState(() => _selectedType = 'tous');
                      setState(() => _selectedType = 'tous');
                    },
                  ),
                  FilterChip(
                    label: const Text('Sur place'),
                    selected: _selectedType == 'surplace',
                    onSelected: (selected) {
                      setModalState(() => _selectedType = 'surplace');
                      setState(() => _selectedType = 'surplace');
                    },
                  ),
                  FilterChip(
                    label: const Text('Livraison'),
                    selected: _selectedType == 'livraison',
                    onSelected: (selected) {
                      setModalState(() => _selectedType = 'livraison');
                      setState(() => _selectedType = 'livraison');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filtre par date
              const Text(
                'Période',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _selectDateRange();
                      },
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _dateRange == null
                            ? 'Sélectionner une période'
                            : '${DateFormat('dd/MM/yy').format(_dateRange!.start)} - ${DateFormat('dd/MM/yy').format(_dateRange!.end)}',
                      ),
                    ),
                  ),
                  if (_dateRange != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setModalState(() => _dateRange = null);
                        setState(() => _dateRange = null);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedStatus = 'tous';
                          _selectedType = 'tous';
                          _dateRange = null;
                        });
                        setState(() {
                          _selectedStatus = 'tous';
                          _selectedType = 'tous';
                          _dateRange = null;
                        });
                      },
                      child: const Text('Réinitialiser'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Appliquer'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderListNotifier);
    final filteredOrders = _filterOrders(orderState.orders);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Toutes les Commandes",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.read(orderListNotifier.notifier).getOrders();
                  },
                ),
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.filter_list),
                      if (_selectedStatus != 'tous' ||
                          _selectedType != 'tous' ||
                          _dateRange != null)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 8,
                              minHeight: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: _showFilterDialog,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou téléphone...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Chips des filtres actifs
          if (_selectedStatus != 'tous' ||
              _selectedType != 'tous' ||
              _dateRange != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  if (_selectedStatus != 'tous')
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text('Statut: $_selectedStatus'),
                        onDeleted: () {
                          setState(() => _selectedStatus = 'tous');
                        },
                      ),
                    ),
                  if (_selectedType != 'tous')
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text('Type: $_selectedType'),
                        onDeleted: () {
                          setState(() => _selectedType = 'tous');
                        },
                      ),
                    ),
                  if (_dateRange != null)
                    Chip(
                      label: Text(
                        'Période: ${DateFormat('dd/MM').format(_dateRange!.start)} - ${DateFormat('dd/MM').format(_dateRange!.end)}',
                      ),
                      onDeleted: () {
                        setState(() => _dateRange = null);
                      },
                    ),
                ],
              ),
            ),

          // Résultat de la recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${filteredOrders.length} commande(s) trouvée(s)',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Liste des commandes
          Expanded(
            child: orderState.isLoading
                ?  Center(
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
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      context.push('/orders/detail/${order.id}');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // En-tête avec ID et statut
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Commande #${order.id?.substring(0, 8) ?? 'N/A'}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Chip(
                                label: Text(
                                  order.statut.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor:
                                _getStatusColor(order.statut),
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Informations client
                          InfoClient(
                              nom: order.nomClient,
                              telephone: order.telephone,
                              nbrProduits: order.produits.length.toString()
                          ),
                          // Type de commande
                          Row(
                            children: [
                              if (order.surPlace)
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.restaurant,
                                          size: 14,
                                          color: Colors.blue[800]),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Sur place",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[800],
                                        ),
                                      ),
                                      if (order.numeroTable !=
                                          null)
                                        Text(
                                          " - Table ${order.numeroTable}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                            Colors.blue[800],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              if (order.livraison)
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius:
                                    BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.delivery_dining,
                                          size: 14,
                                          color:
                                          Colors.green[800]),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Livraison",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          const Divider(),

                          // Prix et date
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDate(order.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                "${order.coutTotal.toStringAsFixed(2)} FCFA",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 40,),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
        onPressed: () {
          context.push('/orders/create');
        },
        icon: const Icon(Icons.add),
        label: const Text("Nouvelle commande"),
      ),
    );
  }
}
*/


// features/orders/presentation/pages/order_list_page_with_filters.dart
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
  String _searchQuery = '';

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
      case 'en cours':
        return Colors.blue.shade100;
      case 'validé':
      case 'validé':
        return Colors.purple.shade100;
      case 'terminé':
      case 'terminé':
      case 'terminé':
        return Colors.green.shade100;
      case 'annulé':
      case 'annulé':
      case 'annulé':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'en cours':
      case 'en cours':
        return Colors.blue.shade700;
      case 'validé':
      case 'validé':
        return Colors.purple.shade700;
      case 'terminé':
      case 'terminé':
      case 'terminé':
        return Colors.green.shade700;
      case 'annulé':
      case 'annulé':
      case 'annulé':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd yyyy HH:mm a').format(date);
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
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
            onPressed: () {
              setState(() {
                _selectedStatus = 'tous';
              });
              Navigator.pop(context);
            },
            child: const Text('Réinitialiser'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Appliquer'),
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
            Text(
              " / ",
              style: TextStyle(color: Colors.grey.shade400),
            ),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Boutons de filtre par statut
                _buildStatusButton('Tous', 'tous', filteredOrders.length),
                const SizedBox(width: 8),
                _buildStatusButton('En cours', 'en cours',
                    orderState.orders.where((o) => o.statut.toLowerCase() == 'en cours').length),
                const SizedBox(width: 8),
                _buildStatusButton('Validé', 'validé',
                    orderState.orders.where((o) => o.statut.toLowerCase() == 'validé').length),
                const SizedBox(width: 8),
                _buildStatusButton('Terminé', 'terminé',
                    orderState.orders.where((o) => o.statut.toLowerCase() == 'terminé').length),
                const SizedBox(width: 8),
                _buildStatusButton('Annulé', 'annulé',
                    orderState.orders.where((o) => o.statut.toLowerCase() == 'annulé').length),
                const SizedBox(width: 24),
                // Bouton Show avec compteur
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('Show'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                          _buildTableHeader('Statut de la commande', flex: 2),
                          _buildTableHeader('Restaurant', flex: 2),
                          _buildTableHeader('Customer', flex: 2),
                          _buildTableHeader('Date de création', flex: 3),
                          _buildTableHeader('Date de mise à jour', flex: 3),
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
                                  _buildTableCell('${index + 1}', flex: 1),
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
                                  _buildTableCell(order.nomClient, flex: 2),
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
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
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

  Widget _buildTableCell(String text, {required int flex, bool isLink = false}) {
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

