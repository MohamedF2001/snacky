// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categorie_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategorieModel _$CategorieModelFromJson(Map<String, dynamic> json) =>
    CategorieModel(
      id: json['_id'] as String,
      nom: json['nom'] as String,
      description: json['description'] as String,
      date: json['date'] as String?,
    );

Map<String, dynamic> _$CategorieModelToJson(CategorieModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'nom': instance.nom,
      'description': instance.description,
      'date': instance.date,
    };
