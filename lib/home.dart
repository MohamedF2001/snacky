/*
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
*/


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
  final ScrollController _scrollController = ScrollController();

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
    final popularProducts = productState.products.take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.neutralGrey100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'BIENVENUE',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.notifications, color: AppColors.neutralBlack),
              onPressed: () {},
              tooltip: 'Notifications',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        final horizontalPadding = isMobile ? 12.0 : 24.0;
        final verticalGap = isMobile ? 12.0 : 24.0;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                isMobile ? HeroBannerMobilee()
                    : const HeroBannerWithTypewriter(),
                SizedBox(height: verticalGap),

                // ======= CATÉGORIES =======
                _buildSectionHeader(
                  title: "Catégorie",
                  onSeeAll: () => context.go('/categories'),
                  onAdd: () => context.go('/categories/create'),
                ),
                SizedBox(height: 10),
                _buildCategorieList(categorieState, isMobile),

                SizedBox(height: verticalGap),

                // ======= PRODUITS POPULAIRES =======
                _buildSectionHeader(
                  title: "Produits Populaires",
                  onSeeAll: () => context.go('/products'),
                  onAdd: () => context.go('/products/create'),
                ),
                SizedBox(height: 10),
                _buildPopularProducts(popularProducts),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeAll,
    required VoidCallback onAdd,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'voir_plus') onSeeAll();
            else if (value == 'ajouter') onAdd();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(value: 'voir_plus', child: Row(children: [Icon(Icons.list, size: 20), SizedBox(width: 12), Text('Voir plus')])),
            const PopupMenuItem(value: 'ajouter', child: Row(children: [Icon(Icons.add, size: 20), SizedBox(width: 12), Text('Ajouter')])),
          ],
        ),
      ],
    );
  }

  Widget _buildCategorieList(categorieState, bool isMobile) {
    if (categorieState.isLoading && categorieState.categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: SpinKitThreeBounce(color: Colors.orange, size: 30),
        ),
      );
    }

    if (categorieState.error != null && categorieState.categories.isEmpty) {
      return _buildErrorWidget(categorieState.error.toString(), () {
        ref.read(categorieListNotifier.notifier).getCategories();
      });
    }

    if (!categorieState.isLoading && categorieState.categories.isEmpty) {
      return _buildEmptyWidget(
        icon: Icons.category_outlined,
        message: "Aucune catégorie disponible",
        buttonText: "Créer une catégorie",
        onPressed: () => context.push('/categories/create'),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: categorieState.categories.length + (categorieState.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == categorieState.categories.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            );
          }
          final cat = categorieState.categories[index];
          return Padding(
            padding: const EdgeInsets.all(12),
            child: CategoryCardTwo(
              backgroundColor: Colors.grey.withOpacity(0.09),
              id: cat.id,
              name: cat.nom,
              imagePath: "assets/images/categories/${cat.description}.png",
              onTap: () => context.push('/categories/${cat.id}/products', extra: cat.nom),
              onDelete: () {},
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularProducts(List products) {
    if (products.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => context.push('/products/${product.id}', extra: product.nom),
              borderRadius: BorderRadius.circular(16),
              child: Card(
                elevation: 0.2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: product.imageUrl != null
                          ? Image.network(
                        product.imageUrl!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.contain,
                        loadingBuilder: (c, child, progress) {
                          if (progress == null) return child;
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(height: 120, color: Colors.white),
                          );
                        },
                        errorBuilder: (c, e, s) => Container(
                          height: 120,
                          color: Colors.grey[300],
                          child: const Icon(Icons.fastfood, size: 40),
                        ),
                      )
                          : Container(
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.fastfood, size: 40),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.nom, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                          const SizedBox(height: 8),
                          Chip(
                            label: Text("${product.prix.toStringAsFixed(2)} F CFA", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                            backgroundColor: AppColors.chipPrice,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    );
  }

  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text("Erreur : $message", textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text("Réessayer")),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget({required IconData icon, required String message, required String buttonText, required VoidCallback onPressed}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: onPressed, icon: const Icon(Icons.add), label: Text(buttonText)),
          ],
        ),
      ),
    );
  }
}


