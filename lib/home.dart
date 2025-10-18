import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/const/app_colors.dart';

import 'features/categories/presentation/providers/categorie_provider.dart';
import 'features/categories/presentation/widgets/category_cart.dart';

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

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Bannière bleue
            Container(
              color: Colors.blue,
              width: double.infinity,
              height: 100,
              child: const Text("data"),
            ),
            const SizedBox(height: 20),

            // En-tête Catégorie et menu trois points sur la même ligne
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Catégorie",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
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
              SizedBox(
                height: 200,
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

                    return CategoryCardTwo(
                      id: categorie.id,
                      name: categorie.nom,
                      imagePath: "assets/images/f3.png",
                      onTap: () {
                        context.push(
                          '/categories/${categorie.id}/products',
                          extra: categorie.nom,
                        );
                      },
                      onDelete: () {},
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
