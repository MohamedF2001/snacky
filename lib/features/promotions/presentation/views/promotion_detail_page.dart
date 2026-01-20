import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:snacky/features/promotions/presentation/providers/promotion_provider.dart';
import 'package:snacky/features/promotions/domain/entities/promotion_entity.dart';

import '../../../../const/app_colors.dart';
import '../../../../const/app_style.dart';
import '../../../categories/presentation/widgets/succes_dialog.dart';

class PromotionDetailPage extends ConsumerStatefulWidget {
  final String promotionId;

  const PromotionDetailPage({super.key, required this.promotionId});

  @override
  ConsumerState<PromotionDetailPage> createState() =>
      _PromotionDetailPageState();
}

class _PromotionDetailPageState extends ConsumerState<PromotionDetailPage> {
  PromotionEntity? _promotion;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPromotion();
  }

  void _loadPromotion() {
    setState(() => _isLoading = true);

    try {
      // Charger la promotion depuis la liste (provider déjà peuplé)
      final promotionState = ref.read(promotionListNotifier);
      _promotion = promotionState.promotions.firstWhere(
            (p) => p.id == widget.promotionId,
        orElse: () => throw Exception('Promotion non trouvée'),
      );
    } catch (_) {
      _promotion = null;
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Écouter les changements de suppression
    ref.listen<DeletePromotionState>(deletePromotionProvider, (previous, next) {
      if (next.success) {
        // Réinitialiser l'état
        ref.read(deletePromotionProvider.notifier).reset();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return SuccessDialog(
              message: "Promotion supprimée avec succès",
              onOk: () {
                Navigator.pop(context);
                context.go('/promotions');
              },
            );
          },
        );
      } else if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : ${next.error!.toString()}"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        ref.read(deletePromotionProvider.notifier).clearError();
      }
    });

    final deleteState = ref.watch(deletePromotionProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          _promotion?.nom ?? "Détails de la promotion",
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                // Bouton d'édition
                // IconButton(
                //   icon: const Icon(Icons.edit, color: AppColors.darkBlue),
                //   onPressed: () {
                //     //context.push('/promotions/${widget.promotionId}/edit');
                //   },
                //   tooltip: 'Modifier',
                // ),
                const SizedBox(width: 10),
                // Bouton de suppression
                IconButton(
                  icon: deleteState.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.orange,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.delete, color: Colors.red),
                  onPressed: deleteState.isLoading
                      ? null
                      : () => _confirmDelete(context, widget.promotionId),
                  tooltip: 'Supprimer',
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: SpinKitThreeBounce(
          color: AppColors.accentOrange,
          size: 30.0,
        ),
      )
          : _promotion == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              "Promotion non trouvée",
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/promotions'),
              child: const Text("Retour à la liste"),
            ),
          ],
        ),
      )
          : LayoutBuilder(
        builder: (context, constraints) {
          // Breakpoints :
          // mobile <= 700
          // tablet 700..1100
          // desktop > 1100
          final maxW = constraints.maxWidth;
          final bool isMobile = maxW <= 700;
          final bool isTablet = maxW > 700 && maxW <= 1100;
          final bool isWide = maxW > 1100;

          // Sizes adapted
          final double pagePadding = isMobile ? 12 : 24;
          final double cardPadding = isMobile ? 12 : 20;
          final double titleFontSize = isMobile ? 16 : 20;
          final double nameFontSize = isMobile ? 18 : 20;
          final double labelFontSize = isMobile ? 12 : 14;
          final double valueFontSize = isMobile ? 16 : 25;
          final double sectionSpacing = isMobile ? 12 : 24;
          final double iconSize = isMobile ? 20 : 24;
          final double imageHeight = isMobile ? 220 : 360;

          if (isWide) {
            // Desktop: two-column layout (similar to original)
            return Padding(
              padding: EdgeInsets.all(pagePadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: main info, dates, actions
                  Expanded(
                    flex: 4,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMainInfoCard(
                            cardPadding: cardPadding,
                            titleFontSize: titleFontSize,
                            nameFontSize: nameFontSize,
                            labelFontSize: labelFontSize,
                            valueFontSize: valueFontSize,
                            iconSize: iconSize,
                          ),
                          SizedBox(height: sectionSpacing),
                          _buildDatesCard(
                            cardPadding: cardPadding,
                            titleFontSize: titleFontSize,
                            labelFontSize: labelFontSize,
                            iconSize: iconSize,
                          ),
                          SizedBox(height: sectionSpacing),
                          _buildActionButtons(context, isMobile),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right column: products list
                  Expanded(
                    flex: 6,
                    child: SingleChildScrollView(
                      child: _buildProductsCard(
                        cardPadding: cardPadding,
                        isMobile: isMobile,
                        labelFontSize: labelFontSize,
                        valueFontSize: valueFontSize,
                        imageHeight: imageHeight,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Tablet & Mobile: single column stacked
            return SingleChildScrollView(
              padding: EdgeInsets.all(pagePadding),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMainInfoCard(
                        cardPadding: cardPadding,
                        titleFontSize: titleFontSize,
                        nameFontSize: nameFontSize,
                        labelFontSize: labelFontSize,
                        valueFontSize: valueFontSize,
                        iconSize: iconSize,
                      ),
                      SizedBox(height: sectionSpacing),
                      _buildDatesCard(
                        cardPadding: cardPadding,
                        titleFontSize: titleFontSize,
                        labelFontSize: labelFontSize,
                        iconSize: iconSize,
                      ),
                      SizedBox(height: sectionSpacing),
                      _buildProductsCard(
                        cardPadding: cardPadding,
                        isMobile: isMobile,
                        labelFontSize: labelFontSize,
                        valueFontSize: valueFontSize,
                        imageHeight: imageHeight,
                      ),
                      SizedBox(height: sectionSpacing),
                      _buildActionButtons(context, isMobile),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // -------------------------
  // MAIN INFO CARD
  // -------------------------
  Widget _buildMainInfoCard({
    required double cardPadding,
    required double titleFontSize,
    required double nameFontSize,
    required double labelFontSize,
    required double valueFontSize,
    required double iconSize,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(iconSize * 0.45),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.local_offer,
                    size: iconSize,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nom de la promotion",
                        style: TextStyle(
                          fontSize: labelFontSize,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _promotion!.nom,
                        style: TextStyle(
                          fontSize: nameFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.percent, color: Colors.green, size: iconSize),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tarif promotionnel",
                      style: TextStyle(
                        fontSize: labelFontSize,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${_promotion!.tarif.toStringAsFixed(2)} %",
                      style: TextStyle(
                        fontSize: valueFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // DATES CARD
  // -------------------------
  Widget _buildDatesCard({
    required double cardPadding,
    required double titleFontSize,
    required double labelFontSize,
    required double iconSize,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue, size: iconSize),
                const SizedBox(width: 12),
                Text(
                  "Période de validité",
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _buildDateInfo(
                    "Date de début",
                    _promotion!.dateDebut,
                    Colors.blue,
                    Icons.play_circle_outline,
                    labelFontSize,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildDateInfo(
                    "Date de fin",
                    _promotion!.dateFin,
                    Colors.orange,
                    Icons.stop_circle_outlined,
                    labelFontSize,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildPromotionStatus(labelFontSize),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(
      String label,
      DateTime? date,
      Color color,
      IconData icon,
      double labelFontSize,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: labelFontSize,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date != null ? _formatDate(date) : "Non définie",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPromotionStatus(double labelFontSize) {
    if (_promotion!.dateDebut == null || _promotion!.dateFin == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final isActive =
        now.isAfter(_promotion!.dateDebut!) && now.isBefore(_promotion!.dateFin!);
    final isUpcoming = now.isBefore(_promotion!.dateDebut!);
    final isExpired = now.isAfter(_promotion!.dateFin!);

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isActive) {
      statusColor = Colors.green;
      statusText = "Active";
      statusIcon = Icons.check_circle;
    } else if (isUpcoming) {
      statusColor = Colors.blue;
      statusText = "À venir";
      statusIcon = Icons.access_time;
    } else {
      statusColor = Colors.grey;
      statusText = "Expirée";
      statusIcon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(statusIcon, color: statusColor, size: 18),
          const SizedBox(width: 8),
          Text(
            "Statut : $statusText",
            style: TextStyle(
              fontSize: labelFontSize,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // PRODUCTS CARD
  // -------------------------
  Widget _buildProductsCard({
    required double cardPadding,
    required bool isMobile,
    required double labelFontSize,
    required double valueFontSize,
    required double imageHeight,
  }) {
    final produitsIds = _promotion!.produitsIds as List<String>;
    final hasFullProducts = _promotion!.produits is List &&
        _promotion!.produits.isNotEmpty &&
        _promotion!.produits.first.nom != null &&
        _promotion!.produits.first.nom.isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: Colors.purple, size: isMobile ? 20 : 24),
                    SizedBox(width: isMobile ? 8 : 12),
                    Text(
                      "Produits inclus",
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 12,
                    vertical: isMobile ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${produitsIds.length} produit${produitsIds.length > 1 ? 's' : ''}",
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 12 : 20),

            if (produitsIds.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 20 : 32),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined, size: isMobile ? 56 : 64, color: Colors.grey[400]),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        "Aucun produit associé",
                        style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else if (hasFullProducts)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _promotion!.produits.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, i) {
                  final produit = _promotion!.produits[i];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 0),
                    leading: Container(
                      width: isMobile ? 56 : 64,
                      height: isMobile ? 56 : 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade100,
                      ),
                      child: produit.imageUrl != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          produit.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.fastfood, color: Colors.orange, size: 36);
                          },
                        ),
                      )
                          : const Icon(Icons.fastfood, color: Colors.orange, size: 36),
                    ),
                    title: Text(
                      produit.nom,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 14 : 16,
                      ),
                    ),
                    subtitle: produit.description != null && produit.description!.isNotEmpty
                        ? Text(
                      produit.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: isMobile ? 12 : 13),
                    )
                        : null,
                    trailing: Container(
                      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 6 : 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${produit.prix.toStringAsFixed(2)} F CFA",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ),
                    onTap: () {
                      context.push('/products/${produit.id}');
                    },
                  );
                },
              )
            else
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, size: isMobile ? 40 : 48, color: Colors.blue),
                      SizedBox(height: isMobile ? 8 : 12),
                      Text(
                        "${produitsIds.length} produit${produitsIds.length > 1 ? 's' : ''} associé${produitsIds.length > 1 ? 's' : ''}",
                        style: TextStyle(fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: isMobile ? 6 : 8),
                      Text(
                        "Les détails des produits ne sont pas disponibles",
                        style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
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

  // -------------------------
  // ACTION BUTTONS
  // -------------------------
  Widget _buildActionButtons(BuildContext context, bool isMobile) {
    if (isMobile) {
      // Buttons stacked for mobile
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/promotions'),
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              label: const Text("Retour à la liste", style: TextStyle(color: Colors.black)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                //context.push('/promotions/${widget.promotionId}/edit');
              },
              icon: const Icon(Icons.edit),
              label: const Text("Modifier"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.accentOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _confirmDelete(context, widget.promotionId),
              icon: const Icon(Icons.delete, color: Colors.red),
              label: const Text("Supprimer", style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      );
    }

    // Desktop: row
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.go('/promotions'),
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            label: const Text("Retour à la liste", style: TextStyle(color: Colors.black)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              //context.push('/promotions/${widget.promotionId}/edit');
            },
            icon: const Icon(Icons.edit),
            label: const Text("Modifier"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppColors.accentOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------
  // UTILITIES
  // -------------------------
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 8),
            const Text("Confirmation de suppression",
                style: TextStyle(fontSize: AppStyle.descriptionFontSize)),
          ],
        ),
        content: Text(
          "Êtes-vous sûr de vouloir supprimer la promotion \"${_promotion!.nom}\" ?\n\n"
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
              //ref.read(deletePromotionProvider.notifier).deletePromotion(id);
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
}
