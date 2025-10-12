/*
import 'package:equatable/equatable.dart';

class PromotionEntity extends Equatable {
  final String? id;
  final String nom;
  final double tarif;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final dynamic produits; // ✅ Changé de CategorieEntity? à dynamic

  const PromotionEntity({
    this.id,
    required this.nom,
    required this.tarif,
    this.dateDebut,
    this.dateFin,
    this.produits,
  });

  @override
  List<Object?> get props => [id, nom, tarif, dateDebut, dateFin, produits];
}
*/

import 'package:equatable/equatable.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';

class PromotionEntity extends Equatable {
  final String? id;
  final String nom;
  final double tarif;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  // ✅ Accepter soit List<ProductEntity> soit List<String>
  final dynamic produits; // Peut être List<ProductEntity> ou List<String>

  const PromotionEntity({
    this.id,
    required this.nom,
    required this.tarif,
    this.dateDebut,
    this.dateFin,
    required this.produits,
  });

  // ✅ Helper pour obtenir les IDs des produits
  List<String> get produitsIds {
    if (produits is List<ProductEntity>) {
      return (produits as List<ProductEntity>)
          .map((p) => p.id ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    } else if (produits is List<String>) {
      return produits as List<String>;
    } else if (produits is List) {
      // Cas où c'est une liste mixte
      return (produits as List).map((e) {
        if (e is String) return e;
        if (e is ProductEntity) return e.id ?? '';
        return '';
      }).where((id) => id.isNotEmpty).toList();
    }
    return [];
  }

  // ✅ Helper pour obtenir les produits complets
  List<ProductEntity> get produitsEntities {
    if (produits is List<ProductEntity>) {
      return produits as List<ProductEntity>;
    }
    return [];
  }

  @override
  List<Object?> get props => [id, nom, tarif, dateDebut, dateFin, produits];
}
