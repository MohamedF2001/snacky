import 'package:snacky/features/products/data/models/product_model.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';
import 'package:snacky/features/promotions/data/models/promotion_model.dart';
import 'package:snacky/features/promotions/domain/entities/promotion_entity.dart';

extension PromotionMapper on PromotionModel {
  PromotionEntity toEntity() {
    return PromotionEntity(
      id: id,
      nom: nom,
      tarif: tarif,
      dateDebut: dateDebut,
      dateFin: dateFin,
      produits: produits, // Peut être String ou CategorieModel
    );
  }
}

extension PromotionEntityMapper on PromotionEntity {
  PromotionModel toModel() {
    return PromotionModel(
      id: id,
      nom: nom,
      tarif: tarif,
      dateDebut: dateDebut,
      dateFin: dateFin,
      produits: produits, // Déjà géré dans ProductModel
    );
  }
}