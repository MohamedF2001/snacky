// features/orders/presentation/pages/order_list_page_with_filters.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';
import 'package:snacky/features/orders/presentation/providers/order_provider.dart';

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
                  borderSide: const BorderSide(color: Colors.black, width: 2),
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
                ? const Center(
              child: SpinKitThreeBounce(
                color: Colors.orange,
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
                                    color: Colors.white,
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
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  order.nomClient,
                                  style: const TextStyle(
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(Icons.phone,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                order.telephone,
                                style:
                                const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Nombre de produits
                          Row(
                            children: [
                              const Icon(Icons.shopping_bag,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                "${order.produits.length} produit(s)",
                                style:
                                const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

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
                                  color: Colors.orange,
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