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
  ConsumerState<OrderListPageWithFilters> createState() => _OrderListPageWithFiltersState();
}

class _OrderListPageWithFiltersState extends ConsumerState<OrderListPageWithFilters> {
  String _selectedStatus = 'tous';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // On force un rafraîchissement au montage de la page
    Future.microtask(() {
      ref.read(orderListNotifier.notifier).getOrders();
    });
  }

  Color _statusBg(String statut) {
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
        return Colors.grey.shade200;
    }
  }

  Color _statusColor(String statut) {
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
        return Colors.grey.shade800;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return DateFormat('dd/MM/yyyy HH:mm').format(date.toLocal());
  }

  List<OrderEntity> _filter(List<OrderEntity> list) {
    if (list.isEmpty) return [];
    
    return list.where((o) {
      if (_selectedStatus != "tous") {
        final currentStatut = o.statut.toLowerCase().trim();
        final targetStatut = _selectedStatus.toLowerCase().trim();
        if (currentStatut != targetStatut) {
          return false;
        }
      }

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final name = o.nomClient.toLowerCase();
        final phone = o.telephone.toLowerCase();
        final id = (o.id ?? "").toLowerCase();
        
        if (!name.contains(q) && !phone.contains(q) && !id.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => StatefulBuilder(
        builder: (_, setModalState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Filtrer par statut",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: [
                  "tous",
                  "en cours",
                  "validé",
                  "terminé",
                  "annulé"
                ].map((status) {
                  final selected = _selectedStatus == status;
                  return ChoiceChip(
                    label: Text(status.toUpperCase()),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedStatus = status);
                      setModalState(() {});
                    },
                    selectedColor: Colors.orange,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text("Appliquer"),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderListNotifier);
    final orders = _filter(orderState.orders);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Commandes",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/orders/create'),
          )
        ],
      ),

      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Rechercher (nom, id, téléphone)",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // Filter & count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  "${orders.length} résultats",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _openFilter,
                )
              ],
            ),
          ),

          const SizedBox(height: 4),

          Expanded(
            child: orderState.isLoading && orders.isEmpty
                ? Center(
              child: SpinKitThreeBounce(
                color: AppColors.accentOrange,
                size: 28,
              ),
            )
                : orderState.error != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "Une erreur est survenue",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      orderState.error!.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => ref.read(orderListNotifier.notifier).getOrders(),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Réessayer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
                : orders.isEmpty
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 58, color: Colors.grey.shade400),
                const SizedBox(height: 8),
                Text("Aucune commande trouvée",
                    style: TextStyle(color: Colors.grey.shade600)),
              ],
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final o = orders[i];
                return InkWell(
                  onTap: () => context.push('/orders/detail/${o.id}'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300.withOpacity(.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // HEADER : ID + STATUS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "#${o.id?.substring(0, 6) ?? '---'}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _statusBg(o.statut),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  o.statut.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _statusColor(o.statut),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          // CLIENT
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                o.nomClient,
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                o.telephone,
                                style: TextStyle(color: Colors.grey.shade600),
                              )
                            ],
                          ),

                          const SizedBox(height: 6),

                          // TYPE
                          Text(
                            o.surPlace
                                ? "Sur place (T${o.numeroTable ?? '-'})"
                                : o.livraison
                                ? "Livraison"
                                : "N/A",
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // DATE
                          Row(
                            children: [
                              Icon(Icons.access_time,
                                  size: 16, color: Colors.grey.shade500),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(o.createdAt),
                                style: TextStyle(color: Colors.grey.shade600),
                              )
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
        ],
      ),
    );
  }
}

