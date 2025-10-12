/*
import 'package:json_annotation/json_annotation.dart';
import 'package:snacky/features/promotions/domain/entities/promotion_entity.dart';

import '../../../products/data/models/product_model.dart';

part 'promotion_model.g.dart';

@JsonSerializable()
class PromotionModel extends PromotionEntity {
  @JsonKey(name: "_id")
  @override
  final String? id;

  @override
  final String nom;

  @override
  final double tarif;

  @override
  final DateTime? dateDebut;

  @override
  final DateTime? dateFin;

  // ✅ Permettre soit un String (ID) soit un objet CategorieModel complet
  @JsonKey(
    name: "produits",
    fromJson: _produitsFromJson,
    toJson: _produitsToJson,
  )
  @override
  final List<ProductModel> produits;

  const PromotionModel({
    this.id,
    required this.nom,
    required this.tarif,
    this.dateDebut,
    this.dateFin,
    required this.produits,
  }) : super(
    id: id,
    nom: nom,
    tarif: tarif,
    dateDebut: dateDebut,
    dateFin: dateFin,
    produits: produits,
  );

  static List<ProductModel> _produitsFromJson(dynamic json) {
    if (json == null) return [];
    if (json is List) {
      return json.map((item) => ProductModel.fromJson(item)).toList();
    }
    return [];
  }

  static dynamic _produitsToJson(List<ProductModel>? produits) {
    if (produits == null) return [];
    return produits.map((p) => p.toJson()).toList();
  }

  factory PromotionModel.fromJson(Map<String, dynamic> json) =>
      _$PromotionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionModelToJson(this);
}
*/

import 'package:json_annotation/json_annotation.dart';
import 'package:snacky/features/promotions/domain/entities/promotion_entity.dart';

import '../../../products/data/models/product_model.dart';

part 'promotion_model.g.dart';

@JsonSerializable()
class PromotionModel extends PromotionEntity {
  @JsonKey(name: "_id")
  @override
  final String? id;

  @override
  final String nom;

  @override
  final double tarif;

  @override
  final DateTime? dateDebut;

  @override
  final DateTime? dateFin;

  // ✅ Permettre soit une List<String> (IDs) soit une List<ProductModel> (objets complets)
  @JsonKey(
    name: "produits",
    fromJson: _produitsFromJson,
    toJson: _produitsToJson,
  )
  @override
  final List<ProductModel> produits;

  const PromotionModel({
    this.id,
    required this.nom,
    required this.tarif,
    this.dateDebut,
    this.dateFin,
    required this.produits,
  }) : super(
    id: id,
    nom: nom,
    tarif: tarif,
    dateDebut: dateDebut,
    dateFin: dateFin,
    produits: produits,
  );

  // ✅ Gestion flexible : String ou Object
  static List<ProductModel> _produitsFromJson(dynamic json) {
    if (json == null) return [];

    if (json is List) {
      return json.map((item) {
        // Si c'est un String (ID uniquement), créer un ProductModel minimal
        if (item is String) {
          return ProductModel(
            id: item,
            nom: '', // Nom vide car non fourni par l'API
            prix: 0,
            description: '',
            categorie: '',
          );
        }
        // Si c'est un objet complet, le parser normalement
        else if (item is Map<String, dynamic>) {
          return ProductModel.fromJson(item);
        }
        // Par défaut, retourner un modèle vide
        return ProductModel(
          id: '',
          nom: '',
          prix: 0,
          description: '',
          categorie: '',
        );
      }).toList();
    }

    return [];
  }

  static dynamic _produitsToJson(List<ProductModel>? produits) {
    if (produits == null) return [];
    // Lors de l'envoi, on envoie uniquement les IDs
    return produits.map((p) => p.id).toList();
  }

  factory PromotionModel.fromJson(Map<String, dynamic> json) =>
      _$PromotionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionModelToJson(this);
}
