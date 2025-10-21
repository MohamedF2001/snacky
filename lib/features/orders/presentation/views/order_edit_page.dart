/*
// features/orders/presentation/pages/order_edit_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/const/app_colors.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';
import 'package:snacky/features/orders/presentation/providers/order_provider.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';
import 'package:snacky/features/products/presentation/providers/product_provider.dart';

import '../../../../const/app_input_style.dart';

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
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(Icons.save),
              onPressed: _submit,
              tooltip: 'Enregistrer',
            ),
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
                              decoration: AppInputStyles.textFieldDecoration(
                                icon: Icons.person,
                                  label: "Nom du Client"),
                              validator: (val) => val == null || val.isEmpty
                                  ? "Nom requis"
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _telephoneController,
                              decoration:AppInputStyles.textFieldDecoration(
                                icon: Icons.phone,
                                  label: "Téléphone"),
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
                              decoration: AppInputStyles.textFieldDecoration(
                                icon: Icons.info,
                                label: ""
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
                              inactiveThumbColor: Colors.grey,
                              activeColor: AppColors.accentOrange,
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
                                  decoration: AppInputStyles.textFieldDecoration(
                                    icon: Icons.table_restaurant,
                                      label: "Numéro de table"
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
                              decoration: AppInputStyles.textFieldDecoration(
                                icon: Icons.add_shopping_cart,
                                  label: "Ajouter un produit"),
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
                                              color: Colors.grey.shade300,
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
                                color: Colors.black,
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
                          backgroundColor: AppColors.darkBlue,
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
}*/


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:snacky/const/app_colors.dart';
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
    // 🔥 FIX: Vérifier si le produit existe déjà
    final exists = _produitsCommandes.any((item) => item["produitId"] == produitId);

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ce produit est déjà dans la commande"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // ✅ Récupération du notifier
    final updateNotifier = ref.read(updateOrderProvider.notifier);

    // ✅ Création d’un objet ProductEntity à partir de ton produit
    final produit = ProductEntity(
      id: produitId,
      nom: "Nom du produit", // <-- tu peux le récupérer via ton modèle
      prix: 2000, description: '', // exemple, selon ta structure
    );

    // ✅ Ajout du produit via le provider
    //updateNotifier.addProductToOrder(produit);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Produit ajouté à la commande"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    setState(() {
      _produitsCommandes.add({
        "produitId": produitId,
        "quantite": 1,
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Produit ajouté avec succès"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _changerQuantite(int index, int nouvelleQuantite) {
    if (nouvelleQuantite < 1) return;
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

        // 🔥 FIX: Rafraîchir la liste ET les détails
        ref.read(orderListNotifier.notifier).getOrders();
        await ref
            .read(detailOrderNotifier(widget.orderId).notifier)
            .getOrderById(widget.orderId);

        if (mounted) {
          //context.push('/orders/detail/${widget.orderId}');
          context.go('/orders');
        }
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
    final updateState = ref.watch(updateOrderProvider);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text("Modifier la commande"),
        ),
        body: const Center(child: CircularProgressIndicator(color: Colors.orange)),
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
        title: const Text(
          "Modifier la commande",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: ElevatedButton.icon(
              onPressed: updateState.isLoading ? null : _submit,
              icon: const Icon(Icons.save),
              label: const Text("Enregistrer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: updateState.isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text("Mise à jour en cours..."),
          ],
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colonne de gauche
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildClientCard(),
                      const SizedBox(height: 16),
                      _buildStatutCard(),
                      const SizedBox(height: 16),
                      _buildTypeCommandeCard(),
                    ],
                  ),
                ),
                const SizedBox(width: 24),

                // Colonne de droite
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildProduitsCard(produitsState),
                      const SizedBox(height: 16),
                      _buildCoutTotalCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClientCard() {
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
            Row(
              children: [
                Icon(Icons.person_outline, color: Colors.grey.shade600, size: 22),
                const SizedBox(width: 8),
                Text(
                  "Informations Client",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomClientController,
              decoration: InputDecoration(
                labelText: "Nom du client *",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
              ),
              validator: (val) => val == null || val.isEmpty ? "Nom requis" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telephoneController,
              decoration: InputDecoration(
                labelText: "Téléphone *",
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (val) =>
              val == null || val.isEmpty ? "Téléphone requis" : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatutCard() {
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
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade600, size: 22),
                const SizedBox(width: 8),
                Text(
                  "Statut de la commande",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _statut,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.circle),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'en cours', child: Text('En cours')),
                DropdownMenuItem(value: 'validé', child: Text('Validé')),
                DropdownMenuItem(value: 'terminé', child: Text('Terminé')),
                DropdownMenuItem(value: 'annulé', child: Text('Annulé')),
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
    );
  }

  Widget _buildTypeCommandeCard() {
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
            Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.grey.shade600, size: 22),
                const SizedBox(width: 8),
                Text(
                  "Type de Commande",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sur place
            InkWell(
              onTap: () => setState(() {
                _surPlace = !_surPlace;
                if (_surPlace) _livraison = false;
              }),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _surPlace ? Colors.orange.shade50 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _surPlace ? Colors.orange : Colors.grey.shade300,
                    width: _surPlace ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.table_restaurant,
                      color: _surPlace ? Colors.orange : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sur place",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                              _surPlace ? Colors.orange.shade700 : Colors.black,
                            ),
                          ),
                          Text(
                            "Le client consommera sur place",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: _surPlace,
                      onChanged: (val) => setState(() {
                        _surPlace = val ?? false;
                        if (_surPlace) _livraison = false;
                      }),
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),

            if (_surPlace) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _numeroTableController,
                decoration: InputDecoration(
                  labelText: "Numéro de table",
                  prefixIcon: const Icon(Icons.pin),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.orange, width: 2),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
            ],

            const SizedBox(height: 12),

            // Livraison
            InkWell(
              onTap: () => setState(() {
                _livraison = !_livraison;
                if (_livraison) {
                  _surPlace = false;
                  _numeroTableController.clear();
                }
              }),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _livraison ? Colors.green.shade50 : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _livraison ? Colors.green : Colors.grey.shade300,
                    width: _livraison ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.delivery_dining,
                      color: _livraison ? Colors.green : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Livraison",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color:
                              _livraison ? Colors.green.shade700 : Colors.black,
                            ),
                          ),
                          Text(
                            "La commande sera livrée au client",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: _livraison,
                      onChanged: (val) => setState(() {
                        _livraison = val ?? false;
                        if (_livraison) {
                          _surPlace = false;
                          _numeroTableController.clear();
                        }
                      }),
                      activeColor: Colors.green,
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

  Widget _buildProduitsCard(productsState) {
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
            Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.grey.shade600, size: 22),
                const SizedBox(width: 8),
                Text(
                  "Produits",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (productsState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              )
            else if (productsState.products.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        "Aucun produit disponible",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: "Ajouter un produit",
                    prefixIcon: const Icon(Icons.add_shopping_cart),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.orange, width: 2),
                    ),
                  ),
                  items: productsState.products.map<DropdownMenuItem<String>>((p) {
                    return DropdownMenuItem<String>(
                      value: p.id!,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              p.nom,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "${p.prix?.toStringAsFixed(0)} FCFA",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) _ajouterProduit(value);
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                if (_produitsCommandes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.shopping_basket_outlined,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            "Aucun produit ajouté",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: _produitsCommandes.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final produit = productsState.products.firstWhere(
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

                      final prixUnitaire = produit.prix ?? 0;
                      final quantite = item["quantite"];
                      final sousTotal = prixUnitaire * quantite;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.orange,
                              radius: 24,
                              child: Text(
                                '$quantite',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    produit.nom,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${prixUnitaire.toStringAsFixed(0)} FCFA × $quantite = ${sousTotal.toStringAsFixed(0)} FCFA",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_circle,
                                    color: quantite > 1
                                        ? Colors.orange
                                        : Colors.grey.shade400,
                                  ),
                                  onPressed: () {
                                    if (quantite > 1) {
                                      _changerQuantite(index, quantite - 1);
                                    }
                                  },
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.orange),
                                  ),
                                  child: Text(
                                    '$quantite',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle,
                                      color: Colors.orange),
                                  onPressed: () =>
                                      _changerQuantite(index, quantite + 1),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _supprimerProduit(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildCoutTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_cart_checkout,
                  color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 12),
              Text(
                "Coût Total",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          Text(
            "${_coutTotal.toStringAsFixed(0)} FCFA",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
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


