import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/categories/presentation/providers/categorie_provider.dart';
import 'package:snacky/features/categories/presentation/widgets/category_cart.dart';
import 'package:snacky/features/categories/presentation/widgets/succes_dialog.dart';

class CategorieListPage extends ConsumerStatefulWidget {
  const CategorieListPage({super.key});

  @override
  ConsumerState<CategorieListPage> createState() => _CategorieListPageState();
}

class _CategorieListPageState extends ConsumerState<CategorieListPage> {
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
    final deleteState = ref.watch(deleteCategoryProvider);

    // ✅ Écouter les changements de l'état de suppression
    ref.listen<DeleteCategoryState>(
      deleteCategoryProvider,
          (previous, next) {
        if (next.success) {
          // ✅ Recharger la liste après suppression réussie
          ref.read(categorieListNotifier.notifier).getCategories();

          // ✅ Réinitialiser l'état de suppression
          ref.read(deleteCategoryProvider.notifier).reset();

          // ✅ Afficher un dialogue de succès
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return SuccessDialog(
                message: "Catégorie supprimée avec succès ! ✅",
                onOk: () {
                  Navigator.pop(context);
                },
              );
            },
          );
        } else if (next.error != null) {
          // ✅ Afficher l'erreur si la suppression échoue
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erreur : ${next.error.toString()}"),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );

          // ✅ Réinitialiser l'erreur
          ref.read(deleteCategoryProvider.notifier).clearError();
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Catégories',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          // ✅ Bouton de rafraîchissement dans l'AppBar
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(categorieListNotifier.notifier).getCategories();
              },
              tooltip: 'Rafraîchir',
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(categorieListNotifier.notifier).getCategories();
        },
        child: _buildBody(categorieState, deleteState),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.black,
        onPressed: () {
          context.push('/categories/create');
        },
        icon: const Icon(Icons.add),
        label: const Text("Nouvelle catégorie"),
      ),
    );
  }

  // ✅ Construire le corps de la page selon l'état
  Widget _buildBody(CategorieListState categorieState, DeleteCategoryState deleteState) {
    // Chargement initial
    if (categorieState.isLoading && categorieState.categories.isEmpty) {
      return const Center(
        child: SpinKitThreeBounce(color: Colors.orange, size: 30.0),
      );
    }

    // Erreur de chargement
    if (categorieState.error != null && categorieState.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              "Erreur : ${categorieState.error.toString()}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(categorieListNotifier.notifier).getCategories();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Réessayer"),
            ),
          ],
        ),
      );
    }

    // Liste vide
    if (categorieState.categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
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
      );
    }

    // Grille de catégories
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3 / 2.5,
      ),
      itemCount: categorieState.categories.length +
          (categorieState.isLoading ? 1 : 0), // +1 pour le loader si chargement
      itemBuilder: (context, index) {
        // ✅ Afficher un loader à la fin pendant le chargement de plus d'items
        if (index == categorieState.categories.length) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final categorie = categorieState.categories[index];

        return CategoryCard(
          id: categorie.id,
          name: categorie.nom,
          imagePath: "assets/images/categories/${categorie.description}.png",
          onTap: () {
            context.push(
              '/categories/${categorie.id}/products',
              extra: categorie.nom,
            );
          },
          onDelete: () {
            //_confirmDelete(context, categorie.id);
          },
          isDeleting: deleteState.isLoading,
        );
      },
    );
  }

  // ✅ Boîte de dialogue de confirmation améliorée
  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text("Confirmation de suppression"),
          ],
        ),
        content: const Text(
          "Êtes-vous sûr de vouloir supprimer cette catégorie ?\n\n"
              "⚠️ Tous les produits associés à cette catégorie seront également affectés.\n\n"
              "Cette action est irréversible.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // ✅ Lancer la suppression
              ref.read(deleteCategoryProvider.notifier).deleteCategory(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }
}