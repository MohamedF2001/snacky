import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';
import 'package:snacky/features/orders/presentation/providers/order_provider.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';
import 'package:snacky/features/products/presentation/providers/product_provider.dart';

import '../../../../const/app_input_style.dart';

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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          "Nouvelle Commande",
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
              onPressed: createState.isLoading ? null : _submit,
              icon: const Icon(Icons.check_circle),
              label: const Text("Créer la commande"),
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
          : Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Colonne de gauche : Produits et total
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildProduitsCard(produitsState),
                          const SizedBox(height: 16),
                          _buildCoutTotalCard(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Colonne de droite : Informations client et type
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildClientCard(),
                          const SizedBox(height: 16),
                          _buildTypeCommandeCard(),
                        ],
                      ),
                    )
                  ),
                ],
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
              decoration: AppInputStyles.textFieldDecoration(
                label: "Nom du client *",
                icon: Icons.person_outline,),
              validator: (val) =>
              val == null || val.isEmpty ? "Le nom est requis" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telephoneController,
              decoration: AppInputStyles.textFieldDecoration(
                label: "Téléphone *",
                icon: Icons.phone_outlined,),
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
                              color: _surPlace ? Colors.orange.shade700 : Colors.black,
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
                decoration: AppInputStyles.textFieldDecoration(
                  label: "Numéro de table *",
                  icon: Icons.pin,),
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
                              color: _livraison ? Colors.green.shade700 : Colors.black,
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
                  items: productsState.products
                      .map<DropdownMenuItem<String>>((p) {
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
                    children:
                    _produitsCommandes.asMap().entries.map((entry) {
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
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
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

