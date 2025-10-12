// features/orders/presentation/pages/order_edit_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';
import 'package:snacky/features/orders/presentation/providers/order_provider.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';
import 'package:snacky/features/products/presentation/providers/product_provider.dart';

class OrderEditPage extends ConsumerStatefulWidget {
  final String orderId;

  const OrderEditPage({super.key, required this.orderId});

  @override
  ConsumerState<OrderEditPage> createState() => _OrderEditPageState();
}

class _OrderEditPageState extends ConsumerState<OrderEditPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomClientController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _numeroTableController = TextEditingController();

  bool _surPlace = false;
  bool _livraison = false;
  String _statut = 'en cours';

  List<Map<String, dynamic>> _produitsCommandes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrderData();
      ref.read(productListNotifier.notifier).getProduits();
    });
  }

  Future<void> _loadOrderData() async {
    await ref
        .read(detailOrderNotifier(widget.orderId).notifier)
        .getOrderById(widget.orderId);

    final orderState = ref.read(detailOrderNotifier(widget.orderId));

    if (orderState.order != null) {
      final order = orderState.order!;

      setState(() {
        _nomClientController.text = order.nomClient;
        _telephoneController.text = order.telephone;
        _numeroTableController.text = order.numeroTable?.toString() ?? '';
        _surPlace = order.surPlace;
        _livraison = order.livraison;
        _statut = order.statut;

        _produitsCommandes = order.produits.map((p) {
          String produitId;
          if (p.produit is ProductEntity) {
            produitId = (p.produit as ProductEntity).id ?? '';
          } else if (p.produit is String) {
            produitId = p.produit;
          } else {
            produitId = p.produit.toString();
          }

          return {
            "produitId": produitId,
            "quantite": p.quantite,
          };
        }).toList();

        _isLoading = false;
      });
    }
  }

  double get _coutTotal {
    final produits = ref.watch(productListNotifier).products;
    double total = 0;
    for (var item in _produitsCommandes) {
      final product = produits.firstWhere(
            (p) => p.id == item["produitId"],
        orElse: () => ProductEntity(
          id: null,
          nom: "Inconnu",
          description: "",
          prix: 0,
          imageUrl: null,
          categorie: null,
        ),
      );
      total += (product.prix ?? 0) * item["quantite"];
    }
    return total;
  }

  void _ajouterProduit(String produitId) {
    setState(() {
      _produitsCommandes.add({
        "produitId": produitId,
        "quantite": 1,
      });
    });
  }

  void _changerQuantite(int index, int nouvelleQuantite) {
    setState(() {
      _produitsCommandes[index]["quantite"] = nouvelleQuantite;
    });
  }

  void _supprimerProduit(int index) {
    setState(() {
      _produitsCommandes.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_produitsCommandes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez ajouter au moins un produit."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final produits = _produitsCommandes
        .map((item) => OrderProductEntity(
      produit: item["produitId"],
      quantite: item["quantite"],
    ))
        .toList();

    final orderState = ref.read(detailOrderNotifier(widget.orderId));
    final originalOrder = orderState.order!;

    final updatedOrder = OrderEntity(
      id: originalOrder.id,
      client: originalOrder.client,
      nomClient: _nomClientController.text.trim(),
      telephone: _telephoneController.text.trim(),
      produits: produits,
      coutTotal: _coutTotal,
      statut: _statut,
      numeroTable: _surPlace && _numeroTableController.text.isNotEmpty
          ? int.tryParse(_numeroTableController.text.trim())
          : null,
      surPlace: _surPlace,
      livraison: _livraison,
      createdAt: originalOrder.createdAt,
      updatedAt: DateTime.now(),
    );

    // Appeler le use case de mise à jour
    await ref.read(updateOrderProvider.notifier).updateOrder(updatedOrder);

    final updateState = ref.read(updateOrderProvider);

    if (mounted) {
      if (updateState.error == null && updateState.order != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Commande mise à jour avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        // Rafraîchir la liste des commandes
        ref.read(orderListNotifier.notifier).getOrders();
        context.go('/orders/detail/${widget.orderId}');
      } else if (updateState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${updateState.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final produitsState = ref.watch(productListNotifier);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Modifier la commande")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier la commande"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _submit,
            tooltip: 'Enregistrer',
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width > 800
              ? MediaQuery.of(context).size.width / 2
              : MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informations client
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Informations Client",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _nomClientController,
                              decoration: const InputDecoration(
                                labelText: "Nom du client",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              validator: (val) => val == null || val.isEmpty
                                  ? "Nom requis"
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _telephoneController,
                              decoration: const InputDecoration(
                                labelText: "Téléphone",
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (val) => val == null || val.isEmpty
                                  ? "Téléphone requis"
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Statut
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Statut de la commande",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _statut,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.info),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'en cours',
                                  child: Text('En cours'),
                                ),
                                DropdownMenuItem(
                                  value: 'validé',
                                  child: Text('Validé'),
                                ),
                                DropdownMenuItem(
                                  value: 'terminé',
                                  child: Text('Terminé'),
                                ),
                                DropdownMenuItem(
                                  value: 'annulé',
                                  child: Text('Annulé'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _statut = value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Type de commande
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Type de commande",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SwitchListTile(
                              title: const Text("Sur place"),
                              subtitle: const Text(
                                  "La commande est pour consommation sur place"),
                              value: _surPlace,
                              onChanged: (val) => setState(() {
                                _surPlace = val;
                                if (val) _livraison = false;
                              }),
                            ),
                            if (_surPlace)
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                                child: TextFormField(
                                  controller: _numeroTableController,
                                  decoration: const InputDecoration(
                                    labelText: "Numéro de table",
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.table_restaurant),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            const SizedBox(height: 8),
                            SwitchListTile(
                              title: const Text("Livraison"),
                              subtitle: const Text(
                                  "La commande sera livrée au client"),
                              value: _livraison,
                              onChanged: (val) => setState(() {
                                _livraison = val;
                                if (val) _surPlace = false;
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Produits
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: produitsState.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Produits",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Ajouter un produit",
                                prefixIcon: Icon(Icons.add_shopping_cart),
                              ),
                              items: produitsState.products.map((p) {
                                return DropdownMenuItem(
                                  value: p.id!,
                                  child: Text(
                                      "${p.nom} - ${p.prix} FCFA"),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) _ajouterProduit(value);
                              },
                            ),
                            const SizedBox(height: 16),
                            if (_produitsCommandes.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    "Aucun produit ajouté",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics:
                                const NeverScrollableScrollPhysics(),
                                itemCount: _produitsCommandes.length,
                                itemBuilder: (context, index) {
                                  final item = _produitsCommandes[index];
                                  final produit = produitsState.products
                                      .firstWhere(
                                        (p) => p.id == item["produitId"],
                                    orElse: () => ProductEntity(
                                      id: item["produitId"],
                                      nom: "Produit inconnu",
                                      description: "",
                                      prix: 0,
                                      imageUrl: null,
                                      categorie: null,
                                    ),
                                  );

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6),
                                    elevation: 2,
                                    child: ListTile(
                                      title: Text(produit.nom),
                                      subtitle: Text(
                                        "Prix: ${produit.prix} FCFA - Qté: ${item["quantite"]} - Total: ${(produit.prix ?? 0) * item["quantite"]} FCFA",
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove,
                                                size: 20),
                                            onPressed: () {
                                              if (item["quantite"] > 1) {
                                                _changerQuantite(index,
                                                    item["quantite"] - 1);
                                              }
                                            },
                                          ),
                                          Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[100],
                                              borderRadius:
                                              BorderRadius.circular(
                                                  4),
                                            ),
                                            child: Text(
                                              '${item["quantite"]}',
                                              style: const TextStyle(
                                                fontWeight:
                                                FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add,
                                                size: 20),
                                            onPressed: () {
                                              _changerQuantite(index,
                                                  item["quantite"] + 1);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () =>
                                                _supprimerProduit(index),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Coût total
                    Card(
                      color: Colors.orange[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Coût total :",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${_coutTotal.toStringAsFixed(2)} FCFA",
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
                    const SizedBox(height: 24),

                    // Bouton d'enregistrement
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.save),
                        label: const Text(
                          "Enregistrer les modifications",
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomClientController.dispose();
    _telephoneController.dispose();
    _numeroTableController.dispose();
    super.dispose();
  }
}