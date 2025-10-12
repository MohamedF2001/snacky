// features/orders/presentation/pages/order_create_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';
import 'package:snacky/features/orders/presentation/providers/order_provider.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';
import 'package:snacky/features/products/presentation/providers/product_provider.dart';

class OrderCreatePage extends ConsumerStatefulWidget {
  const OrderCreatePage({super.key});

  @override
  ConsumerState<OrderCreatePage> createState() => _OrderCreatePageState();
}

class _OrderCreatePageState extends ConsumerState<OrderCreatePage> {
  final _formKey = GlobalKey<FormState>();

  final _nomClientController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _numeroTableController = TextEditingController();

  bool _surPlace = false;
  bool _livraison = false;

  // Liste des produits commandés avec leur quantité
  final List<Map<String, dynamic>> _produitsCommandes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productListNotifier.notifier).getProduits();
    });
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
    final exists =
    _produitsCommandes.any((item) => item["produitId"] == produitId);

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

    setState(() {
      _produitsCommandes.add({
        "produitId": produitId,
        "quantite": 1,
      });
    });
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

    if (!_surPlace && !_livraison) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez choisir 'Sur place' ou 'Livraison'"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_surPlace && _numeroTableController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer le numéro de table"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final produits = _produitsCommandes
        .map(
          (item) => OrderProductEntity(
        produit: item["produitId"],
        quantite: item["quantite"],
      ),
    )
        .toList();

    final order = OrderEntity(
      nomClient: _nomClientController.text.trim(),
      telephone: _telephoneController.text.trim(),
      produits: produits,
      coutTotal: _coutTotal,
      statut: "en cours",
      numeroTable: _surPlace && _numeroTableController.text.isNotEmpty
          ? int.tryParse(_numeroTableController.text.trim())
          : null,
      surPlace: _surPlace,
      livraison: _livraison,
    );

    await ref.read(createOrderProvider.notifier).createOrder(order);

    final state = ref.read(createOrderProvider);

    if (mounted) {
      if (state.error == null && state.order != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Commande créée avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
        ref.read(orderListNotifier.notifier).getOrders();
        context.go('/orders');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error?.toString() ?? "Erreur inconnue"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final produitsState = ref.watch(productListNotifier);
    final createState = ref.watch(createOrderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nouvelle Commande",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: createState.isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text("Création de la commande..."),
          ],
        ),
      )
          : Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== Informations Client =====
                  _buildClientCard(),
                  const SizedBox(height: 16),

                  // ===== Type de Commande =====
                  _buildTypeCommandeCard(),
                  const SizedBox(height: 16),

                  // ===== Produits =====
                  _buildProduitsCard(produitsState),
                  const SizedBox(height: 16),

                  // ===== Coût Total =====
                  _buildCoutTotalCard(),
                  const SizedBox(height: 24),

                  // ===== Bouton Créer =====
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.check_circle),
                      label: const Text(
                        "Créer la commande",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================== Widgets Partiels ==================

  Widget _buildClientCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text(
                  "Informations Client",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            TextFormField(
              controller: _nomClientController,
              decoration: InputDecoration(
                labelText: "Nom du client *",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (val) =>
              val == null || val.isEmpty ? "Le nom est requis" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telephoneController,
              decoration: InputDecoration(
                labelText: "Téléphone *",
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return "Le téléphone est requis";
                }
                if (val.length < 8) {
                  return "Numéro invalide (minimum 8 chiffres)";
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCommandeCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text(
                  "Type de Commande",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            SwitchListTile(
              title: const Text("Sur place"),
              subtitle: const Text("Le client consommera sur place"),
              value: _surPlace,
              activeColor: Colors.orange,
              secondary: const Icon(Icons.table_restaurant),
              onChanged: (val) => setState(() {
                _surPlace = val;
                if (val) _livraison = false;
              }),
            ),
            if (_surPlace)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _numeroTableController,
                  decoration: InputDecoration(
                    labelText: "Numéro de table *",
                    prefixIcon: const Icon(Icons.pin),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            SwitchListTile(
              title: const Text("Livraison"),
              subtitle: const Text("La commande sera livrée au client"),
              value: _livraison,
              activeColor: Colors.orange,
              secondary: const Icon(Icons.delivery_dining),
              onChanged: (val) => setState(() {
                _livraison = val;
                if (val) {
                  _surPlace = false;
                  _numeroTableController.clear();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  /*Widget _buildProduitsCard(productsState) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text(
                  "Produits",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            if (productsState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (productsState.products.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Aucun produit disponible",
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else ...[
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Ajouter un produit",
                    prefixIcon: const Icon(Icons.add_shopping_cart),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: productsState.products.map((p) {
                    return DropdownMenuItem(
                      value: p.id!,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(p.nom)),
                          Text(
                            "${p.prix} FCFA",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange),
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
                if (_produitsCommandes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Center(
                      child: Text("Aucun produit ajouté",
                          style: TextStyle(color: Colors.grey)),
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

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.orange[50],
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Text(
                              '$quantite',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(produit.nom,
                              style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              "$prixUnitaire FCFA × $quantite = $sousTotal FCFA"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.orange),
                                onPressed: () {
                                  if (quantite > 1) {
                                    _changerQuantite(index, quantite - 1);
                                  }
                                },
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$quantite',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
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
                        ),
                      );
                    }).toList(),
                  ),
              ],
          ],
        ),
      ),
    );
  }*/

  Widget _buildProduitsCard(productsState) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text(
                  "Produits",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            if (productsState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (productsState.products.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("Aucun produit disponible",
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else ...[
                /*DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Ajouter un produit",
                    prefixIcon: const Icon(Icons.add_shopping_cart),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: productsState.products.map<DropdownMenuItem<String>>((p) {
                    return DropdownMenuItem<String>(
                      value: p.id!,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(p.nom)),
                          Text(
                            "${p.prix} FCFA",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) _ajouterProduit(value);
                  },
                ),*/

                Container(
                  width: double.infinity,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true, // ← AJOUT IMPORTANT
                    decoration: InputDecoration(
                      labelText: "Ajouter un produit",
                      prefixIcon: const Icon(Icons.add_shopping_cart),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
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
                              "${p.prix} FCFA",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange
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
                ),
                const SizedBox(height: 16),
                if (_produitsCommandes.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Center(
                      child: Text("Aucun produit ajouté",
                          style: TextStyle(color: Colors.grey)),
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

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: Colors.orange[50],
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Text(
                              '$quantite',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(produit.nom,
                              style:
                              const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              "$prixUnitaire FCFA × $quantite = $sousTotal FCFA"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.orange),
                                onPressed: () {
                                  if (quantite > 1) {
                                    _changerQuantite(index, quantite - 1);
                                  }
                                },
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '$quantite',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
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
    return Card(
      elevation: 4,
      color: Colors.orange[100],
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.shopping_cart_checkout,
                    color: Colors.orange, size: 28),
                SizedBox(width: 8),
                Text(
                  "Coût Total",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              "${_coutTotal.toStringAsFixed(0)} FCFA",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
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
