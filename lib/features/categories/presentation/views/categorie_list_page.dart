/*
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
    ref.listen<DeleteCategoryState>(deleteCategoryProvider, (previous, next) {
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
    });

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

  // ✅ Construire le corps de la page selon l'état
  Widget _buildBody(
    CategorieListState categorieState,
    DeleteCategoryState deleteState,
  ) {
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
      itemCount:
          categorieState.categories.length +
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
  */
/* void _confirmDelete(BuildContext context, String id) {
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
  } *//*

}
*/



/*
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

  // Déterminer le nombre de colonnes selon la largeur d'écran
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 2; // Mobile : 2 colonnes
    } else if (width < 900) {
      return 3; // Tablette portrait : 3 colonnes
    } else if (width < 1200) {
      return 4; // Tablette paysage : 4 colonnes
    } else {
      return 5; // Desktop : 5 colonnes
    }
  }

  // Déterminer l'aspect ratio selon la largeur d'écran
  double _getChildAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 0.85; // Mobile : cartes plus hautes
    } else if (width < 900) {
      return 0.9; // Tablette portrait
    } else {
      return 3 / 2.5; // Desktop : ratio original
    }
  }

  // Déterminer le padding selon la largeur d'écran
  double _getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 8.0; // Mobile : padding réduit
    } else if (width < 900) {
      return 12.0; // Tablette
    } else {
      return 16.0; // Desktop
    }
  }

  // Déterminer l'espacement selon la largeur d'écran
  double _getSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return 8.0; // Mobile : espacement réduit
    } else if (width < 900) {
      return 10.0; // Tablette
    } else {
      return 12.0; // Desktop
    }
  }

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  @override
  Widget build(BuildContext context) {
    final categorieState = ref.watch(categorieListNotifier);
    final deleteState = ref.watch(deleteCategoryProvider);
    final isMobile = _isMobile(context);

    // ✅ Écouter les changements de l'état de suppression
    ref.listen<DeleteCategoryState>(deleteCategoryProvider, (previous, next) {
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
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Catégories',
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // ✅ Bouton de rafraîchissement dans l'AppBar
          Padding(
            padding: EdgeInsets.only(right: isMobile ? 8 : 20),
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

  // ✅ Construire le corps de la page selon l'état
  Widget _buildBody(
      CategorieListState categorieState,
      DeleteCategoryState deleteState,
      ) {
    // Chargement initial
    if (categorieState.isLoading && categorieState.categories.isEmpty) {
      return const Center(
        child: SpinKitThreeBounce(color: Colors.orange, size: 30.0),
      );
    }

    // Erreur de chargement
    if (categorieState.error != null && categorieState.categories.isEmpty) {
      return _buildErrorState(categorieState);
    }

    // Liste vide
    if (categorieState.categories.isEmpty) {
      return _buildEmptyState(context);
    }

    // Grille de catégories responsive
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
      categorieState.categories.length +
          (categorieState.isLoading ? 1 : 0), // +1 pour le loader si chargement
      itemBuilder: (context, index) {
        // ✅ Afficher un loader à la fin pendant le chargement de plus d'items
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
            //_confirmDelete(context, categorie.id);
          },
          isDeleting: deleteState.isLoading,
        );
      },
    );
  }

  // ✅ État d'erreur responsive
  Widget _buildErrorState(CategorieListState categorieState) {
    final isMobile = _isMobile(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isMobile ? 48 : 64,
              color: Colors.red,
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              "Erreur : ${categorieState.error.toString()}",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(categorieListNotifier.notifier).getCategories();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Réessayer"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: isMobile ? 10 : 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ État vide responsive
  Widget _buildEmptyState(BuildContext context) {
    final isMobile = _isMobile(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: isMobile ? 48 : 64,
              color: Colors.grey[400],
            ),
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
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 24,
                  vertical: isMobile ? 10 : 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// ✅ Boîte de dialogue de confirmation améliorée
*/
/* void _confirmDelete(BuildContext context, String id) {
    final isMobile = _isMobile(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Confirmation de suppression",
                style: TextStyle(fontSize: isMobile ? 16 : 18),
              ),
            ),
          ],
        ),
        content: Text(
          "Êtes-vous sûr de vouloir supprimer cette catégorie ?\n\n"
              "⚠️ Tous les produits associés à cette catégorie seront également affectés.\n\n"
              "Cette action est irréversible.",
          style: TextStyle(fontSize: isMobile ? 13 : 14),
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
  } *//*

}*/


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
            content: Text("Erreur : ${next.error}"),
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
      categorieState.categories.length + (categorieState.isLoading ? 1 : 0),
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
          onDelete: () {},
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
              "Erreur : ${state.error}",
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





