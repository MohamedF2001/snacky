/*
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

        // ✅ CORRECTION : Conversion explicite pour éviter IdentityMap
        _produitsCommandes = order.produits.map((p) {
          String produitId;
          if (p.produit is ProductEntity) {
            produitId = (p.produit as ProductEntity).id ?? '';
          } else if (p.produit is String) {
            produitId = p.produit;
          } else {
            produitId = p.produit.toString();
          }

          // Créer une nouvelle Map explicite
          return <String, dynamic>{
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

  // ✅ CORRECTION : Méthode corrigée pour éviter l'erreur IdentityMap
  void _ajouterProduit(String produitId) {
    // Vérifier si le produit existe déjà dans la commande
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

    // ✅ CORRECTION : Créer une nouvelle Map explicite au lieu d'utiliser IdentityMap
    setState(() {
      _produitsCommandes.add({
        "produitId": produitId,
        "quantite": 1,
      });
    });

    // Afficher un message de confirmation
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Produit retiré de la commande"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // ✅ FIX: Méthode submit optimisée
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

        // ✅ FIX: Rafraîchir la liste et naviguer immédiatement
        ref.read(orderListNotifier.notifier).getOrders();

        // Navigation immédiate sans attendre le refresh des détails
        if (mounted) {
          context.go('/orders');
        }
      } else if (updateState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${updateState.error?.userMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.fastfood,
        size: 30,
        color: Colors.orange.shade400,
      ),
    );
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
          : Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Colonne de gauche
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
                  // Colonne de droite
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildClientCard(),
                          const SizedBox(height: 16),
                          _buildStatutCard(),
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
              */
/*InputDecoration(
                labelText: "Nom du client *",
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
              ),*//*

              validator: (val) => val == null || val.isEmpty ? "Nom requis" : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telephoneController,
              decoration:  AppInputStyles.textFieldDecoration(
                label: "Téléphone *",
                icon: Icons.phone_outlined,),
              */
/*InputDecoration(
                labelText: "Téléphone *",
                prefixIcon: const Icon(Icons.phone_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
              ),*//*

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
                decoration: AppInputStyles.textFieldDecoration(
                    label: "Numéro de table",
                icon: Icons.pin,),
                */
/*InputDecoration(
                  labelText: "Numéro de table",
                  prefixIcon: const Icon(Icons.pin),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.orange, width: 2),
                  ),
                ),*//*

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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: produit.imageUrl != null && produit.imageUrl.isNotEmpty
                                  ? Image.network(
                                produit.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholderImage();
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 60,
                                    height: 60,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200, width: 2),

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
*/


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:snacky/features/orders/domain/entities/order_entity.dart';
import 'package:snacky/features/orders/presentation/providers/order_provider.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';
import 'package:snacky/features/products/presentation/providers/product_provider.dart';
import '../../../../const/app_input_style.dart';
import '../../../../const/app_colors.dart';

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
    await ref.read(detailOrderNotifier(widget.orderId).notifier).getOrderById(widget.orderId);
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
          return <String, dynamic>{"produitId": produitId, "quantite": p.quantite};
        }).toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  double get _coutTotal {
    final produits = ref.watch(productListNotifier).products;
    double total = 0;
    for (var item in _produitsCommandes) {
      final product = produits.firstWhere(
            (p) => p.id == item["produitId"],
        orElse: () => ProductEntity(id: null, nom: "Inconnu", description: "", prix: 0, imageUrl: null, categorie: null),
      );
      total += (product.prix ?? 0) * item["quantite"];
    }
    return total;
  }

  void _ajouterProduit(String produitId) {
    final exists = _produitsCommandes.any((item) => item["produitId"] == produitId);
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ce produit est déjà dans la commande"), backgroundColor: Colors.orange, duration: Duration(seconds: 2)));
      return;
    }
    setState(() {
      _produitsCommandes.add({"produitId": produitId, "quantite": 1});
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produit ajouté avec succès"), backgroundColor: Colors.green, duration: Duration(seconds: 1)));
  }

  void _changerQuantite(int index, int nouvelleQuantite) {
    if (nouvelleQuantite < 1) return;
    setState(() {
      _produitsCommandes[index]["quantite"] = nouvelleQuantite;
    });
  }

  void _supprimerProduit(int index) {
    setState(() => _produitsCommandes.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produit retiré de la commande"), backgroundColor: Colors.red, duration: Duration(seconds: 1)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_produitsCommandes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez ajouter au moins un produit."), backgroundColor: Colors.red));
      return;
    }
    if (!_surPlace && !_livraison) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez choisir 'Sur place' ou 'Livraison'"), backgroundColor: Colors.red));
      return;
    }
    if (_surPlace && _numeroTableController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Veuillez entrer le numéro de table"), backgroundColor: Colors.red));
      return;
    }
    final produits = _produitsCommandes.map((item) => OrderProductEntity(produit: item["produitId"], quantite: item["quantite"])).toList();
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
      numeroTable: _surPlace && _numeroTableController.text.isNotEmpty ? int.tryParse(_numeroTableController.text.trim()) : null,
      surPlace: _surPlace,
      livraison: _livraison,
      createdAt: originalOrder.createdAt,
      updatedAt: DateTime.now(),
    );
    await ref.read(updateOrderProvider.notifier).updateOrder(updatedOrder);
    final updateState = ref.read(updateOrderProvider);
    if (mounted) {
      if (updateState.error == null && updateState.order != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Commande mise à jour avec succès'), backgroundColor: Colors.green));
        ref.read(orderListNotifier.notifier).getOrders();
        if (mounted) context.go('/orders');
      } else if (updateState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${updateState.error}'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildPlaceholderImage() {
    return Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.fastfood, size: 30, color: Colors.orange.shade400));
  }

  @override
  void dispose() {
    _nomClientController.dispose();
    _telephoneController.dispose();
    _numeroTableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produitsState = ref.watch(productListNotifier);
    final updateState = ref.watch(updateOrderProvider);
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => context.pop()), backgroundColor: Colors.white, elevation: 0, title: const Text("Modifier la commande", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black))),
        body: const Center(child: CircularProgressIndicator(color: Colors.orange)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => context.pop()),
        title: const Text("Modifier la commande", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: updateState.isLoading ? null : _submit,
              icon: const Icon(Icons.save),
              label: const Text("Enregistrer"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            ),
          ),
        ],
      ),
      body: updateState.isLoading
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(color: Colors.orange), SizedBox(height: 16), Text("Mise à jour en cours...")]))
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: LayoutBuilder(builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final isMobile = maxW <= 800;
            final pagePadding = isMobile ? 12.0 : 24.0;
            final gap = isMobile ? 12.0 : 24.0;
            if (isMobile) {
              // Single column mobile layout
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildProduitsCard(produitsState, isMobile),
                    SizedBox(height: gap),
                    _buildCoutTotalCard(),
                    SizedBox(height: gap),
                    _buildClientCard(isMobile),
                    SizedBox(height: gap),
                    _buildStatutCard(isMobile),
                    SizedBox(height: gap),
                    _buildTypeCommandeCard(isMobile),
                    SizedBox(height: gap),
                    ElevatedButton.icon(
                      onPressed: updateState.isLoading ? null : _submit,
                      icon: const Icon(Icons.save),
                      label: const Text("Enregistrer la commande"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            } else {
              // Two-column desktop/tablet layout
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        _buildProduitsCard(produitsState, isMobile),
                        SizedBox(height: gap),
                        _buildCoutTotalCard(),
                      ]),
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    flex: 1,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        _buildClientCard(isMobile),
                        SizedBox(height: gap),
                        _buildStatutCard(isMobile),
                        SizedBox(height: gap),
                        _buildTypeCommandeCard(isMobile),
                      ]),
                    ),
                  ),
                ],
              );
            }
          }),
        ),
      ),
    );
  }

  Widget _buildClientCard(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 4))]),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.person_outline, color: Colors.grey.shade600, size: isMobile ? 20 : 22), const SizedBox(width: 8), Text("Informations Client", style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800))]),
          SizedBox(height: isMobile ? 10 : 16),
          TextFormField(controller: _nomClientController, decoration: AppInputStyles.textFieldDecoration(label: "Nom du client *", icon: Icons.person_outline), validator: (val) => val == null || val.isEmpty ? "Nom requis" : null),
          SizedBox(height: isMobile ? 10 : 16),
          TextFormField(controller: _telephoneController, decoration: AppInputStyles.textFieldDecoration(label: "Téléphone *", icon: Icons.phone_outlined), keyboardType: TextInputType.phone, validator: (val) => val == null || val.isEmpty ? "Téléphone requis" : null),
        ]),
      ),
    );
  }

  Widget _buildStatutCard(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 4))]),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.info_outline, color: Colors.grey.shade600, size: isMobile ? 20 : 22), const SizedBox(width: 8), Text("Statut de la commande", style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800))]),
          SizedBox(height: isMobile ? 10 : 16),
          DropdownButtonFormField<String>(
            value: _statut,
            decoration: InputDecoration(prefixIcon: const Icon(Icons.circle), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.orange, width: 2))),
            items: const [
              DropdownMenuItem(value: 'en cours', child: Text('En cours')),
              DropdownMenuItem(value: 'validé', child: Text('Validé')),
              DropdownMenuItem(value: 'terminé', child: Text('Terminé')),
              DropdownMenuItem(value: 'annulé', child: Text('Annulé')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _statut = value);
            },
          ),
        ]),
      ),
    );
  }

  Widget _buildTypeCommandeCard(bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 4))]),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.restaurant_menu, color: Colors.grey.shade600, size: isMobile ? 20 : 22), const SizedBox(width: 8), Text("Type de Commande", style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800))]),
          SizedBox(height: isMobile ? 10 : 16),
          InkWell(
            onTap: () => setState(() {
              _surPlace = !_surPlace;
              if (_surPlace) _livraison = false;
            }),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _surPlace ? Colors.orange.shade50 : Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: _surPlace ? Colors.orange : Colors.grey.shade300, width: _surPlace ? 2 : 1)),
              child: Row(children: [
                Icon(Icons.table_restaurant, color: _surPlace ? Colors.orange : Colors.grey.shade600),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Sur place", style: TextStyle(fontWeight: FontWeight.w600, color: _surPlace ? Colors.orange.shade700 : Colors.black)), Text("Le client consommera sur place", style: TextStyle(fontSize: isMobile ? 12 : 12, color: Colors.grey.shade600))])),
                Checkbox(value: _surPlace, onChanged: (val) => setState(() { _surPlace = val ?? false; if (_surPlace) _livraison = false; }), activeColor: Colors.orange)
              ]),
            ),
          ),
          if (_surPlace) ...[
            SizedBox(height: 12),
            TextFormField(controller: _numeroTableController, decoration: AppInputStyles.textFieldDecoration(label: "Numéro de table", icon: Icons.pin), keyboardType: TextInputType.number),
          ],
          SizedBox(height: 12),
          InkWell(
            onTap: () => setState(() {
              _livraison = !_livraison;
              if (_livraison) { _surPlace = false; _numeroTableController.clear(); }
            }),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _livraison ? Colors.green.shade50 : Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: _livraison ? Colors.green : Colors.grey.shade300, width: _livraison ? 2 : 1)),
              child: Row(children: [
                Icon(Icons.delivery_dining, color: _livraison ? Colors.green : Colors.grey.shade600),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Livraison", style: TextStyle(fontWeight: FontWeight.w600, color: _livraison ? Colors.green.shade700 : Colors.black)), Text("La commande sera livrée au client", style: TextStyle(fontSize: isMobile ? 12 : 12, color: Colors.grey.shade600))])),
                Checkbox(value: _livraison, onChanged: (val) => setState(() { _livraison = val ?? false; if (_livraison) { _surPlace = false; _numeroTableController.clear(); } }), activeColor: Colors.green)
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildProduitsCard(productsState, bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 4))]),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(Icons.shopping_cart, color: Colors.grey.shade600, size: isMobile ? 20 : 22), const SizedBox(width: 8), Text("Produits", style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800))]),
          SizedBox(height: isMobile ? 10 : 16),
          if (productsState.isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(color: Colors.orange)))
          else if (productsState.products.isEmpty)
            Center(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey), const SizedBox(height: 8), Text("Aucun produit disponible", style: TextStyle(color: Colors.grey.shade600))])))
          else ...[
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: InputDecoration(labelText: "Ajouter un produit", prefixIcon: const Icon(Icons.add_shopping_cart), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.orange, width: 2))),
                items: productsState.products.map<DropdownMenuItem<String>>((p) => DropdownMenuItem<String>(value: p.id!, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(p.nom, overflow: TextOverflow.ellipsis)), Text("${p.prix?.toStringAsFixed(0)} FCFA", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange))]))).toList(),
                onChanged: (value) { if (value != null) _ajouterProduit(value); },
              ),
              SizedBox(height: isMobile ? 10 : 16),
              const Divider(),
              SizedBox(height: isMobile ? 10 : 16),
              if (_produitsCommandes.isEmpty)
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)), child: Center(child: Column(children: [Icon(Icons.shopping_basket_outlined, size: 48, color: Colors.grey.shade400), const SizedBox(height: 8), Text("Aucun produit ajouté", style: TextStyle(color: Colors.grey.shade600))])))
              else
                Column(children: _produitsCommandes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final produit = productsState.products.firstWhere((p) => p.id == item["produitId"], orElse: () => ProductEntity(id: item["produitId"], nom: "Produit inconnu", description: "", prix: 0, imageUrl: null, categorie: null));
                  final prixUnitaire = produit.prix ?? 0;
                  final quantite = item["quantite"];
                  final sousTotal = prixUnitaire * quantite;
                  return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange.shade200)), child: Row(children: [
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: produit.imageUrl != null && produit.imageUrl.isNotEmpty ? Image.network(produit.imageUrl, width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (c,e,s)=>_buildPlaceholderImage(), loadingBuilder: (c,child,progress){ if (progress==null) return child; return Container(width:56,height:56,color:Colors.grey[200],child:Center(child:CircularProgressIndicator(value: progress.expectedTotalBytes!=null ? progress.cumulativeBytesLoaded/progress.expectedTotalBytes! : null, strokeWidth:2))); }) : _buildPlaceholderImage()),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(produit.nom, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)), const SizedBox(height: 4), Text("${prixUnitaire.toStringAsFixed(0)} FCFA × $quantite = ${sousTotal.toStringAsFixed(0)} FCFA", style: TextStyle(fontSize: 12, color: Colors.grey.shade700))])),
                    Row(children: [
                      IconButton(icon: Icon(Icons.remove_circle, color: quantite > 1 ? Colors.orange : Colors.grey.shade400), onPressed: () { if (quantite > 1) _changerQuantite(index, quantite - 1); }),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.orange)), child: Text('$quantite', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                      IconButton(icon: const Icon(Icons.add_circle, color: Colors.orange), onPressed: () => _changerQuantite(index, quantite + 1)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _supprimerProduit(index)),
                    ])
                  ]));
                }).toList())
            ]
        ]),
      ),
    );
  }

  Widget _buildCoutTotalCard() {
    return Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200, width: 2)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.shopping_cart_checkout, color: Colors.orange.shade700, size: 24), const SizedBox(width: 8), Text("Coût Total", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800))]), Text("${_coutTotal.toStringAsFixed(0)} FCFA", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]));
  }
}
