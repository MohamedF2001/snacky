// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderProductModel _$OrderProductModelFromJson(Map<String, dynamic> json) =>
    OrderProductModel(
      id: json['_id'] as String?,
      produit: OrderProductModel._produitFromJson(json['produit']),
      quantite: (json['quantite'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$OrderProductModelToJson(OrderProductModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'produit': OrderProductModel._produitToJson(instance.produit),
      'quantite': instance.quantite,
    };

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
  id: json['_id'] as String?,
  client: OrderModel._clientFromJson(json['client']),
  nomClient: json['nomClient'] as String? ?? '',
  telephone: json['telephone'] as String? ?? '',
  produits:
      (json['produits'] as List<dynamic>?)
          ?.map((e) => OrderProductModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  coutTotal: (json['coutTotal'] as num?)?.toDouble() ?? 0.0,
  statut: json['statut'] as String? ?? 'en cours',
  numeroTable: (json['numeroTable'] as num?)?.toInt(),
  surPlace: json['surPlace'] as bool? ?? false,
  livraison: json['livraison'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  v: (json['__v'] as num?)?.toInt(),
);

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'client': OrderModel._clientToJson(instance.client),
      'nomClient': instance.nomClient,
      'telephone': instance.telephone,
      'produits': instance.produits.map((e) => e.toJson()).toList(),
      'coutTotal': instance.coutTotal,
      'statut': instance.statut,
      'numeroTable': instance.numeroTable,
      'surPlace': instance.surPlace,
      'livraison': instance.livraison,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      '__v': instance.v,
    };
