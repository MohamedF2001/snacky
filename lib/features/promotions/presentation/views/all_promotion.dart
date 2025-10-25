import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:snacky/features/promotions/presentation/providers/promotion_provider.dart';

import '../../../../const/app_colors.dart';

class AllPromotionPage extends ConsumerStatefulWidget {
  const AllPromotionPage({super.key});

  @override
  ConsumerState<AllPromotionPage> createState() => _AllPromotionPageState();
}

class _AllPromotionPageState extends ConsumerState<AllPromotionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(promotionListNotifier.notifier).getPromotions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final promotionState = ref.watch(promotionListNotifier);

    // ✅ Écouter les changements de l'état de suppression
    ref.listen<DeletePromotionState>(
      deletePromotionProvider,
          (previous, next) {
        if (next.success) {
          // ✅ Recharger la liste après suppression réussie
          ref.read(promotionListNotifier.notifier).getPromotions();

          // ✅ Réinitialiser l'état de suppression
          ref.read(deletePromotionProvider.notifier).reset();

          // ✅ Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Promotion supprimée avec succès"),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else if (next.error != null) {
          // ✅ Afficher l'erreur si la suppression échoue
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Erreur : ${next.error!.toString()}"),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );

          // ✅ Réinitialiser l'erreur
          ref.read(deletePromotionProvider.notifier).clearError();
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Toutes les Promotions",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: promotionState.isLoading
          ? const Center(
        child: SpinKitThreeBounce(color: Colors.orange, size: 30.0),
      )
          : promotionState.error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Erreur : ${promotionState.error!.toString()}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(promotionListNotifier.notifier).getPromotions();
              },
              child: const Text("Réessayer"),
            ),
          ],
        ),
      )
          : promotionState.promotions.isEmpty
          ? const Center(
        child: Text(
          "Aucune promotion disponible",
          style: TextStyle(fontSize: 16),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3 / 2.5,
        ),
        itemCount: promotionState.promotions.length,
        itemBuilder: (context, index) {
          final promotion = promotionState.promotions[index];

          return InkWell(
            onTap: () {
              context.push('/promotions/${promotion.id}', extra: promotion.nom);
            },
            borderRadius: BorderRadius.circular(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child:
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // IMAGE EN HAUT
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: Image.asset(
                        "assets/images/prom.png",
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.contain,
                      )
                    ),
                    // DESCRIPTION
                    SizedBox(height: 10,),
                    Text(
                      promotion.nom,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentOrange,
        foregroundColor: Colors.black,
        onPressed: () {
          context.push('/promotions/create');
        },
        icon: const Icon(Icons.add),
        label: const Text("Nouvelle promotion"),
      ),
    );
  }

  // ✅ Méthode pour afficher les produits selon leur type
  Widget _buildProduitsList(dynamic promotion) {
    // Récupérer les IDs des produits
    final produitsIds = promotion.produitsIds as List<String>;

    if (produitsIds.isEmpty) {
      return const Text(
        "Aucun produit",
        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
      );
    }

    // Si on a les objets complets
    if (promotion.produits is List &&
        promotion.produits.isNotEmpty &&
        promotion.produits.first.nom != null &&
        promotion.produits.first.nom.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: promotion.produits.length,
        itemBuilder: (context, i) {
          final produit = promotion.produits[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              "• ${produit.nom} (${produit.prix} F CFA)",
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      );
    }
    // Sinon, afficher juste le nombre de produits
    else {
      return Text(
        "${produitsIds.length} produit(s)",
        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
      );
    }
  }

  // ✅ Formater les dates
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  // ✅ Boîte de dialogue de confirmation améliorée
  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation de suppression"),
        content: const Text(
          "Êtes-vous sûr de vouloir supprimer cette promotion ?\n\nCette action est irréversible.",
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
              ref.read(deletePromotionProvider.notifier).deletePromotion(id);
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
