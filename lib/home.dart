import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:snacky/const/app_colors.dart';
import 'features/categories/presentation/providers/categorie_provider.dart';
import 'features/categories/presentation/widgets/category_cart.dart';
import 'features/products/presentation/providers/product_provider.dart';
import 'hero_banner.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categorieListNotifier.notifier).getCategories();
      ref.read(productListNotifier.notifier).getProduits();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(categorieListNotifier.notifier).getCategories(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorieState = ref.watch(categorieListNotifier);
    final productState = ref.watch(productListNotifier);
    // Limiter à 5 produits pour la section "Populaires"
    final popularProducts = productState.products.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.neutralGrey100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'BIENVENUE',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(
                Icons.notifications,
                color: AppColors.neutralBlack,
              ),
              onPressed: () {},
              tooltip: 'Notifications',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ============= HERO BANNER =============
            HeroBannerWithTypewriter(),

            const SizedBox(height: 20),

            // En-tête Catégorie et menu trois points sur la même ligne
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Catégorie",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (String value) {
                      if (value == 'voir_plus') {
                        context.go('/categories');
                      } else if (value == 'ajouter') {
                        context.go('/categories/create');
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'voir_plus',
                        child: Row(
                          children: [
                            Icon(Icons.list, size: 20),
                            SizedBox(width: 12),
                            Text('Voir plus'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'ajouter',
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 20),
                            SizedBox(width: 12),
                            Text('Ajouter'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Chargement initial
            if (categorieState.isLoading && categorieState.categories.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: SpinKitThreeBounce(color: Colors.orange, size: 30.0),
                ),
              ),

            // Erreur de chargement
            if (categorieState.error != null &&
                categorieState.categories.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Erreur : ${categorieState.error.toString()}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref
                              .read(categorieListNotifier.notifier)
                              .getCategories();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Réessayer"),
                      ),
                    ],
                  ),
                ),
              ),

            // Liste vide (sans erreur)
            if (!categorieState.isLoading &&
                categorieState.error == null &&
                categorieState.categories.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.category_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Aucune catégorie disponible",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.push('/categories/create');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Créer une catégorie"),
                      ),
                    ],
                  ),
                ),
              ),

            // Liste horizontale des catégories
            if (categorieState.categories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 180,
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount:
                        categorieState.categories.length +
                        (categorieState.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Loader à la fin pendant le chargement
                      if (index == categorieState.categories.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(
                              color: Colors.orange,
                            ),
                          ),
                        );
                      }

                      final categorie = categorieState.categories[index];

                      return Padding(
                        padding: const EdgeInsets.all(12),
                        child: CategoryCardTwo(
                          backgroundColor: Colors.grey.withOpacity(0.09),
                          id: categorie.id,
                          name: categorie.nom,
                          imagePath:
                              "assets/images/categories/${categorie.description}.png",
                          onTap: () {
                            context.push(
                              '/categories/${categorie.id}/products',
                              extra: categorie.nom,
                            );
                          },
                          onDelete: () {},
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ============= SECTION PRODUITS POPULAIRES =============
            // En-tête Produits et menu trois points
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Produits Populaires",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (String value) {
                      if (value == 'voir_plus') {
                        context.go('/products');
                      } else if (value == 'ajouter') {
                        context.go('/products/create');
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'voir_plus',
                        child: Row(
                          children: [
                            Icon(Icons.list, size: 20),
                            SizedBox(width: 12),
                            Text('Voir tous'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'ajouter',
                        child: Row(
                          children: [
                            Icon(Icons.add, size: 20),
                            SizedBox(width: 12),
                            Text('Ajouter'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Chargement initial produits
            if (productState.isLoading && productState.products.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: SpinKitThreeBounce(color: Colors.orange, size: 30.0),
                ),
              ),

            // Erreur de chargement produits
            if (productState.error != null && productState.products.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Erreur : ${productState.error.toString()}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ref.read(productListNotifier.notifier).getProduits();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Réessayer"),
                      ),
                    ],
                  ),
                ),
              ),

            // Liste vide produits
            if (!productState.isLoading &&
                productState.error == null &&
                productState.products.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Aucun produit disponible",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          context.push('/products/create');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Ajouter un produit"),
                      ),
                    ],
                  ),
                ),
              ),

            // Liste horizontale des produits populaires (limité à 5)
            if (popularProducts.isNotEmpty)
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: popularProducts.length,
                  itemBuilder: (context, index) {
                    final product = popularProducts[index];

                    return Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () {
                          context.push(
                            '/products/${product.id}',
                            extra: product.nom,
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Card(
                          elevation: 0.2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // IMAGE EN HAUT
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                child: product.imageUrl != null
                                    ? Image.network(
                                        product.imageUrl!,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.contain,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor:
                                                    Colors.grey[100]!,
                                                child: Container(
                                                  height: 120,
                                                  width: double.infinity,
                                                  color: Colors.white,
                                                ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  height: 120,
                                                  width: double.infinity,
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.fastfood,
                                                    size: 40,
                                                  ),
                                                ),
                                      )
                                    : Container(
                                        height: 120,
                                        width: double.infinity,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.fastfood,
                                          size: 40,
                                        ),
                                      ),
                              ),

                              // NOM + PRIX
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.nom,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Chip(
                                      label: Text(
                                        "${product.prix.toStringAsFixed(2)} F CFA",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      backgroundColor: AppColors.chipPrice,
                                      visualDensity: VisualDensity.compact,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
