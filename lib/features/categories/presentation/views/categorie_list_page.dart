import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:snacky/features/categories/presentation/providers/categorie_provider.dart';
import 'package:snacky/features/categories/presentation/widgets/category_cart.dart';
import 'package:snacky/features/categories/presentation/widgets/succes_dialog.dart';

import '../../../../const/app_colors.dart';

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
    //_scrollController.addListener(_onScroll);
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

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }

  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 900) return 0.9;
    return 3 / 2.5;
  }

  double _getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 900) return 12.0;
    return 16.0;
  }

  double _getSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 900) return 10.0;
    return 12.0;
  }

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
              //Navigator.of(ctx).pop();
              // ✅ Lancer la suppression
              //ref.read(deleteCategoryProvider.notifier).deleteCategory(id);
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      const Text("Oup's"),
                    ],
                  ),
                  content: const Text(
                    "Vous ne pouvez pas effectuer cette action vu que vous n'etes pas propriétaire",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text("Fermer"),
                    ),
                  ],
                ),
              );
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

  @override
  Widget build(BuildContext context) {
    final categorieState = ref.watch(categorieListNotifier);
    final deleteState = ref.watch(deleteCategoryProvider);
    final isMobile = _isMobile(context);

    ref.listen<DeleteCategoryState>(deleteCategoryProvider, (previous, next) {
      if (next.success) {
        ref.read(categorieListNotifier.notifier).getCategories();
        ref.read(deleteCategoryProvider.notifier).reset();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => SuccessDialog(
            message: "Catégorie supprimée avec succès ! ✅",
            onOk: () => Navigator.pop(context),
          ),
        );
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : ${next.error?.userMessage}"),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(deleteCategoryProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Catégories",
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: isMobile ? 8 : 20),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: "Rafraîchir",
              onPressed: () {
                ref.read(categorieListNotifier.notifier).getCategories();
              },
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(categorieListNotifier.notifier).getCategories();
        },
        child: _buildBody(categorieState, deleteState),
      ),
      floatingActionButton: isMobile
          ? FloatingActionButton(
        backgroundColor: AppColors.accentOrange,
        foregroundColor: Colors.black,
        onPressed: () {
          context.push('/categories/create');
        },
        child: const Icon(Icons.add),
      )
          : FloatingActionButton.extended(
        backgroundColor: AppColors.accentOrange,
        foregroundColor: Colors.black,
        onPressed: () {
          context.push('/categories/create');
        },
        icon: const Icon(Icons.add),
        label: const Text("Nouvelle catégorie"),
      ),
    );
  }

  // =============================================================
  // BODY COMPLET AVEC LISTE SUR MOBILE & GRILLE SUR GRAND ÉCRAN
  // =============================================================
  Widget _buildBody(
      CategorieListState categorieState,
      DeleteCategoryState deleteState,
      ) {
    final isMobile = _isMobile(context);

    if (categorieState.isLoading && categorieState.categories.isEmpty) {
      return const Center(
        child: SpinKitThreeBounce(color: Colors.orange, size: 30),
      );
    }

    if (categorieState.error != null && categorieState.categories.isEmpty) {
      return _buildErrorState(categorieState);
    }

    if (categorieState.categories.isEmpty) {
      return _buildEmptyState(context);
    }

    // 📱 =========================================================
    // 📱 **MOBILE = LISTE VERTICALE**
    // 📱 =========================================================
    if (isMobile) {
      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: categorieState.categories.length +
            (categorieState.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == categorieState.categories.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            );
          }

          final categorie = categorieState.categories[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CategoryListCard(
              id: categorie.id,
              name: categorie.nom,
              imagePath: "assets/images/categories/${categorie.description}.png",
              onTap: () {
                context.push(
                  '/categories/${categorie.id}/products',
                  extra: categorie.nom,
                );
              },
              onDelete: () {},
              isDeleting: deleteState.isLoading,
            ),
          );
        },
      );
    }

    // 💻 =========================================================
    // 💻 **TABLETTE & DESKTOP = GRILLE**
    // 💻 =========================================================
    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(_getPadding(context)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        crossAxisSpacing: _getSpacing(context),
        mainAxisSpacing: _getSpacing(context),
        childAspectRatio: _getChildAspectRatio(context),
      ),
      itemCount:
      categorieState.categories.length,
      //+ (categorieState.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == categorieState.categories.length) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
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
            _confirmDelete(context, categorie.id);
          },
          isDeleting: deleteState.isLoading,
        );
      },
    );
  }

  // =============================================================
  //   UI ÉTATS SECONDAIRES
  // =============================================================

  Widget _buildErrorState(CategorieListState state) {
    final isMobile = _isMobile(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: isMobile ? 48 : 64),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              "Erreur : ${state.error?.userMessage}",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontSize: isMobile ? 14 : 16),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(categorieListNotifier.notifier).getCategories();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Réessayer"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isMobile = _isMobile(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined,
              size: isMobile ? 48 : 64, color: Colors.grey[400]),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            "Aucune catégorie disponible",
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/categories/create');
            },
            icon: const Icon(Icons.add),
            label: const Text("Créer une catégorie"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentOrange,
              foregroundColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}





