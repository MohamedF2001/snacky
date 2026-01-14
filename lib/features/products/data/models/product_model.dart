// features/products/data/models/product_model.dart
import 'package:json_annotation/json_annotation.dart';
import 'package:snacky/features/products/domain/entities/product_entity.dart';
import 'package:snacky/features/categories/data/models/categorie_model.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel extends ProductEntity {
  @JsonKey(name: "_id")
  @override
  final String? id;

  @override
  final String nom;

  @override
  final String description;

  @override
  final double prix;

  @override
  final String? imageUrl;

  // ✅ Permettre soit un String (ID) soit un objet CategorieModel complet
  @JsonKey(
    name: "categorie",
    fromJson: _categorieFromJson,
    toJson: _categorieToJson,
  )
  @override
  final dynamic categorie;

  const ProductModel({
    this.id,
    required this.nom,
    required this.description,
    required this.prix,
    this.imageUrl,
    this.categorie,
  }) : super(
         id: id,
         nom: nom,
         description: description,
         prix: prix,
         imageUrl: imageUrl,
         categorie: categorie,
       );

  // ✅ Fonction pour parser categorie (String ou Object)
  static dynamic _categorieFromJson(dynamic json) {
    if (json == null) return null;
    if (json is String) {
      // Si c'est un String, le retourner tel quel
      return json;
    } else if (json is Map<String, dynamic>) {
      // Si c'est un objet, le parser en CategorieModel
      return CategorieModel.fromJson(json);
    }
    return null;
  }

  // ✅ Fonction pour sérialiser categorie
  static dynamic _categorieToJson(dynamic categorie) {
    if (categorie == null) return null;
    if (categorie is String) {
      return categorie;
    } else if (categorie is CategorieModel) {
      return categorie.toJson();
    }
    return null;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
