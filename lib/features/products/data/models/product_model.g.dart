// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
  id: json['_id'] as String?,
  nom: json['nom'] as String,
  description: json['description'] as String,
  prix: (json['prix'] as num).toDouble(),
  imageUrl: json['imageUrl'] as String?,
  categorie: ProductModel._categorieFromJson(json['categorie']),
);

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'nom': instance.nom,
      'description': instance.description,
      'prix': instance.prix,
      'imageUrl': instance.imageUrl,
      'categorie': ProductModel._categorieToJson(instance.categorie),
    };
