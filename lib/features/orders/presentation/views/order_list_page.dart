/*
// features/orders/presentation/pages/all_orders_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:snacky/features/orders/presentation/providers/order_provider.dart';

class AllOrdersPage extends ConsumerStatefulWidget {
  const AllOrdersPage({super.key});

  @override
  ConsumerState<AllOrdersPage> createState() => _AllOrdersPageState();
}

class _AllOrdersPageState extends ConsumerState<AllOrdersPage> {
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

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderListNotifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Toutes les Commandes",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(orderListNotifier.notifier).getOrders();
              },
            ),
          ),
        ],
      ),
      body: orderState.isLoading
          ? const Center(
        child: SpinKitThreeBounce(color: Colors.orange, size: 30.0),
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
          : orderState.orders.isEmpty
          ? const Center(
        child: Text(
          "Aucune commande",
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orderState.orders.length,
        itemBuilder: (context, index) {
          final order = orderState.orders[index];
          String updateStatus(String currentStatus) {
            if (currentStatus == "en cours") {
              return "validé";
            } else if (currentStatus == "validé") {
              return "terminé";
            } else if (currentStatus == "terminé") {
              return "terminé"; // rien à faire, c’est déjà le dernier état
            } else {
              throw ArgumentError("Statut inconnu : $currentStatus");
            }
          }
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec ID et statut
                  ElevatedButton(
                      onPressed: () {
                        print("ZZZZ");
                        ref.read(updateOrderStatusProvider.notifier).
                        updateOrderStatus(order.id!,updateStatus(order.statut));
                        //ref.read(orderListNotifier.notifier).getOrders();
                        print("OKK");
                      }, child: Text("VV")),
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
                        padding: const EdgeInsets.symmetric(
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
                          style: const TextStyle(fontSize: 16),
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
                        style: const TextStyle(fontSize: 14),
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
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Type de commande
                  Row(
                    children: [
                      if (order.surPlace)
                        Container(
                          padding: const EdgeInsets.symmetric(
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
                              if (order.numeroTable != null)
                                Text(
                                  " - Table ${order.numeroTable}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[800],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      if (order.livraison)
                        Container(
                          padding: const EdgeInsets.symmetric(
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
                                  color: Colors.green[800]),
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
          );
        },
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
}*/
