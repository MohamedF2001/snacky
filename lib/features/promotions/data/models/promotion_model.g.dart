// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'promotion_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PromotionModel _$PromotionModelFromJson(Map<String, dynamic> json) =>
    PromotionModel(
      id: json['_id'] as String?,
      nom: json['nom'] as String,
      tarif: (json['tarif'] as num).toDouble(),
      dateDebut: json['dateDebut'] == null
          ? null
          : DateTime.parse(json['dateDebut'] as String),
      dateFin: json['dateFin'] == null
          ? null
          : DateTime.parse(json['dateFin'] as String),
      produits: PromotionModel._produitsFromJson(json['produits']),
    );

Map<String, dynamic> _$PromotionModelToJson(PromotionModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'nom': instance.nom,
      'tarif': instance.tarif,
      'dateDebut': instance.dateDebut?.toIso8601String(),
      'dateFin': instance.dateFin?.toIso8601String(),
      'produits': PromotionModel._produitsToJson(instance.produits),
    };
