import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:snacky/const/app_style.dart';
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

    // ✅ Écouter la suppression
    ref.listen<DeletePromotionState>(
      deletePromotionProvider,
          (previous, next) {
        if (next.success) {
          ref.read(promotionListNotifier.notifier).getPromotions();
          ref.read(deletePromotionProvider.notifier).reset();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Promotion supprimée avec succès"),
              backgroundColor: Colors.green,
            ),
          );
        } else if (next.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text("Erreur : ${next.error.toString()}"),
            ),
          );

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
        child: SpinKitThreeBounce(color: Colors.orange, size: 30),
      )
          : promotionState.error != null
          ? _buildError(promotionState)
          : promotionState.promotions.isEmpty
          ? const Center(child: Text("Aucune promotion disponible"))
          : LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;

          return isMobile
              ? _buildMobileList(promotionState)
              : _buildDesktopGrid(promotionState);
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accentOrange,
        foregroundColor: Colors.black,
        onPressed: () => context.push('/promotions/create'),
        icon: const Icon(Icons.add),
        label: const Text("Nouvelle promotion"),
      ),
    );
  }

  // 📱 -------------------------- LIST VIEW MOBILE --------------------------
  Widget _buildMobileList(promotionState) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: promotionState.promotions.length,
      itemBuilder: (context, index) {
        final promotion = promotionState.promotions[index];

        return Card(
          elevation: 0.3,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            onTap: () =>
                context.push('/promotions/${promotion.id}', extra: promotion.nom),

            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                "assets/images/prom.png",
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),

            title: Text(
              promotion.nom,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            subtitle: Text(
              "Du ${_formatDate(promotion.dateDebut)} au ${_formatDate(promotion.dateFin)}",
              maxLines: 1,
            ),

            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, promotion.id),
            ),
          ),
        );
      },
    );
  }

  // 🖥️ -------------------------- GRID DESKTOP / TABLETTE --------------------------
  Widget _buildDesktopGrid(promotionState) {
    return GridView.builder(
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
          onTap: () => context.push('/promotions/${promotion.id}', extra: promotion.nom),
          borderRadius: BorderRadius.circular(16),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      "assets/images/prom.png",
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
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
    );
  }

  // ----------------------------- Erreur UI -----------------------------
  Widget _buildError(promotionState) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Erreur : ${promotionState.error.toString()}",
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                ref.read(promotionListNotifier.notifier).getPromotions(),
            child: const Text("Réessayer"),
          ),
        ],
      ),
    );
  }

  // ----------------------------- Boite de dialogue suppression -----------------------------
  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation de suppression",
        style: TextStyle(fontSize: AppStyle.descriptionFontSize)),
        content: const Text(
          "Êtes-vous sûr de vouloir supprimer cette promotion ?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(deletePromotionProvider.notifier).deletePromotion(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );
  }

  // ----------------------------- Formatage dates -----------------------------
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}


